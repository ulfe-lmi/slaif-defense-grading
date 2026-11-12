from __future__ import annotations

import csv
import io
import re
import shutil
import tempfile
import zipfile
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence

from .core import (
    infer_student_label_from_folder,
    iter_nested_zips,
    iter_submission_dirs,
    merge_master_inputs,
    stage_zip_with_sibling_files,
)
from .io_utils import decode_text_file, list_document_files, list_readable_files, unique_path
from .models import DOCUMENT_SUFFIXES, READABLE_SUFFIXES
from .process_script import render_process_script


@dataclass(frozen=True)
class RosterStudent:
    row_number: int
    row: Dict[str, str]
    fieldnames: Sequence[str]
    name: str
    surname: str
    full_name: str
    pseudonym_index: int

    @property
    def pseudonym(self) -> str:
        return f"Student {self.pseudonym_index:04d}"

    @property
    def pseudonym_name(self) -> str:
        return "Student"

    @property
    def pseudonym_surname(self) -> str:
        return f"{self.pseudonym_index:04d}"

    @property
    def filename_stem(self) -> str:
        return f"Student_{self.pseudonym_index:04d}"


@dataclass
class PrepareResult:
    roster_count: int
    matched_count: int
    missing_count: int
    unmatched_folders: List[str]
    copied_documents: List[Path]
    excluded_documents: List[str]
    manifest_entries: List["ManifestEntry"]
    include_opaque_documents: bool
    student_outputs_dir: Path
    student_outputs_index: Path


@dataclass
class ManifestEntry:
    original_folder: str
    pseudonym: str
    text_output: str
    copied_opaque_documents: List[str]
    excluded_opaque_documents: List[str]


@dataclass(frozen=True)
class Association:
    student: RosterStudent
    txt_files: List[str]
    document_files: List[str]

    @property
    def all_files(self) -> List[str]:
        return [*self.txt_files, *self.document_files]

    @property
    def status(self) -> str:
        return "matched" if self.all_files else "unresolved"

    @property
    def evidence(self) -> str:
        if self.all_files:
            return f"Generated pseudonymized submission package for {self.student.pseudonym}."
        return "No matched pseudonymized submission files were generated."


ASSOCIATION_COLUMNS = [
    "name",
    "surname",
    "full_name",
    "associated_txt_files",
    "associated_document_files",
    "all_associated_files",
    "status",
    "evidence",
]

# Canonical roster column order (also used for the private pseudonym map).
CANONICAL_ROSTER_COLUMNS = ["name", "surname", "full_name", "email", "student_id"]

# Marker for a single header cell holding "Surname, Name" (Slovenian Moodle
# roster exports, e.g. the "Priimek, Ime" column), split into both columns.
SPLIT_SURNAME_NAME = "__split_surname_name"

# Known header labels from external rosters (e.g. Moodle exports). Keys are
# normalized (trimmed, BOM-stripped, casefolded) header cells.
ROSTER_HEADER_ALIASES: Dict[str, str] = {
    "ime": "name",
    "name": "name",
    "first name": "name",
    "firstname": "name",
    "priimek": "surname",
    "surname": "surname",
    "last name": "surname",
    "lastname": "surname",
    "priimek, ime": SPLIT_SURNAME_NAME,
    "priimek,ime": SPLIT_SURNAME_NAME,
    "full name": "full_name",
    "full_name": "full_name",
    "fullname": "full_name",
    "e-mail": "email",
    "email": "email",
    "email address": "email",
    "e-mail address": "email",
    "id number": "student_id",
    "student id": "student_id",
    "student_id": "student_id",
    "vpisna številka": "student_id",
    "vpisna stevilka": "student_id",
}


def _normalize_header_label(label: str) -> str:
    return label.lstrip("\ufeff").strip().casefold()


def normalize_identity(value: str) -> str:
    return re.sub(r"\s+", " ", value.strip()).casefold()


def is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
    except ValueError:
        return False
    return True


def workspace_task_filename(task_file: Path) -> str:
    suffix = task_file.suffix.lower()
    return f"task{suffix}" if suffix else "task"


def detect_roster_encoding(students_csv: Path) -> str:
    """Detect the roster file encoding from a leading BOM, if any.

    Instructor rosters are frequently exported from Moodle, Excel, or
    Notepad as UTF-16; a UTF-16 BOM would otherwise crash the UTF-8
    reader with an unhelpful ``codec can't decode byte 0xff`` error.
    """
    head = students_csv.read_bytes()[:4]
    if head.startswith(b"\xff\xfe") or head.startswith(b"\xfe\xff"):
        # The utf-16 codec consumes the BOM and picks the byte order from it.
        return "utf-16"
    if head.startswith(b"\xef\xbb\xbf"):
        return "utf-8-sig"
    try:
        head.decode("utf-8")
    except UnicodeDecodeError:
        if b"\x00" in head:
            # NUL bytes are not valid UTF-8; assume BOM-less UTF-16
            # (common in Excel exports), which defaults to little-endian.
            return "utf-16"
        raise ValueError(
            f"students CSV is not valid UTF-8 (and has no recognized BOM): {students_csv}. "
            "Re-save the roster as UTF-8 (or UTF-8 with BOM) and try again."
        ) from None
    return "utf-8"


def read_roster(students_csv: Path) -> List[RosterStudent]:
    text = students_csv.read_bytes().decode(detect_roster_encoding(students_csv))

    lines = [line for line in text.splitlines() if line.strip()]
    if not lines:
        raise ValueError("students CSV is empty")
    delimiter = "\t" if any("\t" in line for line in lines[:10]) else ","

    rows = list(csv.reader(io.StringIO(text, newline=""), delimiter=delimiter))
    header_index = None
    for index, row in enumerate(rows[:10]):
        provides = {
            ROSTER_HEADER_ALIASES[_normalize_header_label(cell)]
            for cell in row
            if _normalize_header_label(cell) in ROSTER_HEADER_ALIASES
        }
        if SPLIT_SURNAME_NAME in provides:
            provides.update({"name", "surname"})
        if {"name", "surname"} <= provides:
            header_index = index
            break
    if header_index is None:
        raise ValueError(
            "students CSV has no header row with name and surname columns "
            "(searched the first 10 lines; known header labels include "
            "name, surname, ime, priimek, and 'Priimek, Ime')"
        )

    header_row = rows[header_index]
    columns: List[Optional[str]] = []
    split_index: Optional[int] = None
    for position, cell in enumerate(header_row):
        label = _normalize_header_label(cell)
        if label not in ROSTER_HEADER_ALIASES:
            columns.append(None)
            continue
        canonical = ROSTER_HEADER_ALIASES[label]
        if canonical == SPLIT_SURNAME_NAME:
            split_index = position
            columns.append(None)
        else:
            columns.append(canonical)

    provided = {name for name in columns if name}
    if split_index is not None:
        provided.update({"name", "surname"})
    fieldnames = [name for name in CANONICAL_ROSTER_COLUMNS if name in provided]

    students: List[RosterStudent] = []
    for idx, row in enumerate(rows[header_index + 1:], start=1):
        if not row or all(not cell.strip() for cell in row):
            continue
        values: Dict[str, str] = {}
        for position, cell in enumerate(row):
            canonical = columns[position] if position < len(columns) else None
            if canonical and canonical not in values:
                values[canonical] = cell.strip()
        if split_index is not None and split_index < len(row):
            # "Priimek, Ime" cells hold "Surname, Name" in one column.
            surname_part, _, name_part = row[split_index].strip().partition(",")
            if not values.get("surname"):
                values["surname"] = surname_part.strip()
            if not values.get("name"):
                values["name"] = name_part.strip()

        name = values.get("name", "")
        surname = values.get("surname", "")
        if not name or not surname:
            raise ValueError(f"students CSV row {idx} must have non-empty name and surname")

        full_name = values.get("full_name") or f"{name} {surname}"
        students.append(
            RosterStudent(
                row_number=idx,
                row=values,
                fieldnames=fieldnames,
                name=name,
                surname=surname,
                full_name=full_name.strip(),
                pseudonym_index=idx,
            )
        )

    seen: Dict[str, RosterStudent] = {}
    duplicates: List[str] = []
    for student in students:
        key = normalize_identity(f"{student.name} {student.surname}")
        if key in seen:
            duplicates.append(f"{student.name} {student.surname}")
        seen[key] = student
    if duplicates:
        raise ValueError(
            "students CSV contains duplicate name/surname identities that cannot be matched conservatively: "
            + ", ".join(sorted(set(duplicates), key=str.casefold))
        )

    return students


def write_workspace_students_csv(students: Sequence[RosterStudent], workspace: Path) -> None:
    path = workspace / "students.csv"
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["name", "surname", "full_name"], lineterminator="\n")
        writer.writeheader()
        for student in students:
            writer.writerow(
                {
                    "name": student.pseudonym_name,
                    "surname": student.pseudonym_surname,
                    "full_name": student.pseudonym,
                }
            )


def write_private_pseudonym_map(students: Sequence[RosterStudent], private_output: Path) -> None:
    extra_fields = [field for field in students[0].fieldnames if field not in {"name", "surname", "full_name"}] if students else []
    fieldnames = ["pseudonym", "name", "surname", "full_name", *extra_fields]
    path = private_output / "pseudonym_map.csv"

    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, lineterminator="\n")
        writer.writeheader()
        for student in students:
            row = {
                "pseudonym": student.pseudonym,
                "name": student.name,
                "surname": student.surname,
                "full_name": student.full_name,
            }
            for field in extra_fields:
                row[field] = student.row.get(field, "")
            writer.writerow(row)


def optional_roster_fields(students: Sequence[RosterStudent]) -> List[str]:
    if not students:
        return []
    return [field for field in students[0].fieldnames if field not in {"name", "surname", "full_name"}]


def iter_scrub_patterns(students: Sequence[RosterStudent]) -> Iterable[tuple[re.Pattern[str], str]]:
    for student in students:
        names = {student.full_name, f"{student.name} {student.surname}"}
        source_full_name = student.row.get("full_name")
        if source_full_name:
            names.add(source_full_name)

        for full_name in sorted((name for name in names if name.strip()), key=len, reverse=True):
            parts = [re.escape(part) for part in re.split(r"\s+", full_name.strip()) if part]
            if parts:
                yield re.compile(r"\b" + r"\s+".join(parts) + r"\b", re.IGNORECASE), student.pseudonym

        email = student.row.get("email", "").strip()
        if email:
            yield re.compile(re.escape(email), re.IGNORECASE), student.pseudonym

        student_id = student.row.get("student_id", "").strip()
        if student_id:
            yield re.compile(re.escape(student_id)), student.pseudonym


def scrub_text(text: str, students: Sequence[RosterStudent]) -> str:
    scrubbed = text
    for pattern, replacement in iter_scrub_patterns(students):
        scrubbed = pattern.sub(replacement, scrubbed)
    return scrubbed


def readable_relative_path(path: Path, extracted_dir: Path, students: Sequence[RosterStudent]) -> str:
    rel = path.relative_to(extracted_dir).as_posix()
    rel = scrub_text(rel, students)
    rel = re.sub(r"\s+", " ", rel).strip()
    return rel or "submission"


def write_pseudonymized_text_output(
    student: RosterStudent,
    extracted_dirs: Sequence[Path],
    workspace: Path,
    all_students: Sequence[RosterStudent],
) -> Path:
    output_path = workspace / f"{student.filename_stem}.txt"

    with output_path.open("w", encoding="utf-8", newline="\n") as out:
        wrote_any_file = False
        for extracted_dir in extracted_dirs:
            readable_files = list_readable_files(extracted_dir)
            if not readable_files:
                out.write(f"==== BEGIN {student.pseudonym} | submission | no_readable_files_found ====\n")
                out.write("No readable source files were found inside this submission.\n")
                out.write(f"==== END {student.pseudonym} | submission | no_readable_files_found ====\n\n")
                continue

            for readable_file in readable_files:
                rel = readable_relative_path(readable_file, extracted_dir, all_students)
                content = scrub_text(decode_text_file(readable_file), all_students)
                out.write(f"==== BEGIN {student.pseudonym} | submission | {rel} ====\n")
                out.write(content)
                if not content.endswith("\n"):
                    out.write("\n")
                out.write(f"==== END {student.pseudonym} | submission | {rel} ====\n\n")
                wrote_any_file = True

        if not extracted_dirs:
            out.write(f"==== BEGIN {student.pseudonym} | submission | no_submission_found ====\n")
            out.write("No matched submission was found for this roster student.\n")
            out.write(f"==== END {student.pseudonym} | submission | no_submission_found ====\n")

    return output_path


def opaque_document_relative_paths(extracted_dirs: Sequence[Path]) -> List[str]:
    documents: List[str] = []
    for extracted_dir in extracted_dirs:
        for source in list_document_files(extracted_dir):
            documents.append(source.relative_to(extracted_dir).as_posix())
    return sorted(documents, key=str.casefold)


def copy_pseudonymized_documents(student: RosterStudent, extracted_dirs: Sequence[Path], workspace: Path) -> List[Path]:
    copied: List[Path] = []
    document_number = 1
    for extracted_dir in extracted_dirs:
        for source in list_document_files(extracted_dir):
            target = workspace / f"{student.filename_stem}__document_{document_number:03d}{source.suffix.lower()}"
            target = unique_path(target)
            shutil.copy2(source, target)
            copied.append(target)
            document_number += 1
    return copied


def semicolon_join(values: Sequence[str]) -> str:
    return ";".join(values)


def write_associations_csv(
    students: Sequence[RosterStudent],
    workspace: Path,
    text_outputs_by_row: Dict[int, str],
    document_outputs_by_row: Dict[int, List[str]],
) -> List[Association]:
    associations = [
        Association(
            student=student,
            txt_files=[text_outputs_by_row[student.row_number]] if student.row_number in text_outputs_by_row else [],
            document_files=document_outputs_by_row.get(student.row_number, []),
        )
        for student in students
    ]

    with (workspace / "associations.csv").open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=ASSOCIATION_COLUMNS, lineterminator="\n")
        writer.writeheader()
        for association in associations:
            student = association.student
            writer.writerow(
                {
                    "name": student.pseudonym_name,
                    "surname": student.pseudonym_surname,
                    "full_name": student.pseudonym,
                    "associated_txt_files": semicolon_join(association.txt_files),
                    "associated_document_files": semicolon_join(association.document_files),
                    "all_associated_files": semicolon_join(association.all_files),
                    "status": association.status,
                    "evidence": association.evidence,
                }
            )

    return associations


def copy_private_student_outputs(
    students: Sequence[RosterStudent],
    workspace: Path,
    private_output: Path,
    text_outputs_by_row: Dict[int, str],
) -> tuple[Path, Path]:
    output_dir = private_output / "student_outputs"
    output_dir.mkdir(parents=True, exist_ok=True)
    index_path = private_output / "student_outputs_index.csv"

    extra_fields = optional_roster_fields(students)
    fieldnames = ["pseudonym", "name", "surname", "full_name", "student_output_file", *extra_fields]
    with index_path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, lineterminator="\n")
        writer.writeheader()
        for student in students:
            filename = text_outputs_by_row.get(student.row_number)
            if not filename:
                continue

            source = workspace / filename
            target = output_dir / filename
            shutil.copy2(source, target)

            row = {
                "pseudonym": student.pseudonym,
                "name": student.name,
                "surname": student.surname,
                "full_name": student.full_name,
                "student_output_file": filename,
            }
            for field in extra_fields:
                row[field] = student.row.get(field, "")
            writer.writerow(row)

    return output_dir, index_path


def discover_submission_dirs(student_folder_path: Path, outer_extract: Path, unzipped_root: Path) -> List[Path]:
    extracted_dirs: List[Path] = []
    student_zips = sorted(iter_nested_zips(student_folder_path), key=lambda p: p.as_posix().casefold())

    if student_zips:
        for zpath in student_zips:
            try:
                extracted_dirs.append(stage_zip_with_sibling_files(zpath, outer_extract, unzipped_root))
            except zipfile.BadZipFile:
                continue
        return extracted_dirs

    return iter_submission_dirs(student_folder_path)


def write_preprocessing_report(
    private_output: Path,
    result: PrepareResult,
) -> None:
    report = private_output / "preprocessing_report.md"
    lines = [
        "# Preprocessing Report",
        "",
        f"- Roster students: {result.roster_count}",
        f"- Matched students: {result.matched_count}",
        f"- Students without submissions: {result.missing_count}",
        "",
        "## Unmatched LMS Folders",
        "",
    ]

    if result.unmatched_folders:
        lines.extend(f"- `{folder}`" for folder in sorted(result.unmatched_folders, key=str.casefold))
    else:
        lines.append("- None")

    lines.extend(
        [
            "",
            "## Privacy Notes",
            "",
            "- Text/source scrubbing is best-effort and local. It replaces known roster full names, emails, and student IDs before writing workspace text files.",
            "- Only the generated workspace directory should be given to the later agent.",
            "- The private pseudonym map and this report must stay outside the agent workspace.",
            f"- Student-visible concatenated outputs were written to `{result.student_outputs_dir.name}/`.",
            f"- `{result.student_outputs_index.name}` maps those pseudonymized files back to real roster rows for instructor use.",
            "- Student-output files are pseudonymized copies of the exact text input files generated for the agent.",
            "- Use the private index or pseudonym map to identify which pseudonymized file belongs to which student; do not share the full private mapping wholesale with students.",
        ]
    )

    if result.excluded_documents:
        lines.extend(
            [
                "- Opaque documents were excluded from the workspace by default because this tool cannot safely pseudonymize their internal content or metadata.",
                "",
                "## Excluded Opaque Documents",
                "",
            ]
        )
        lines.extend(f"- `{path}`" for path in result.excluded_documents)

    if result.copied_documents:
        lines.extend(
            [
                "- Opaque document inclusion was explicitly enabled. These files were copied with pseudonymized filenames only; internal content and metadata were not inspected or redacted and may still contain real identities.",
                "",
                "## Copied Opaque Documents",
                "",
            ]
        )
        lines.extend(f"- `{path.name}`" for path in result.copied_documents)

    lines.extend(["", "## Matched Folder Manifest", ""])
    if result.manifest_entries:
        for entry in result.manifest_entries:
            lines.extend(
                [
                    f"### {entry.pseudonym}",
                    "",
                    f"- Original matched LMS folder: `{entry.original_folder}`",
                    f"- Workspace text output: `{entry.text_output}`",
                    "- Copied opaque documents: "
                    + (", ".join(f"`{path}`" for path in entry.copied_opaque_documents) if entry.copied_opaque_documents else "none"),
                    "- Excluded opaque documents: "
                    + (
                        ", ".join(f"`{path}`" for path in entry.excluded_opaque_documents)
                        if entry.excluded_opaque_documents
                        else "none"
                    ),
                    "",
                ]
            )
    else:
        lines.append("- None")

    report.write_text("\n".join(lines) + "\n", encoding="utf-8")


def leak_check_workspace(
    workspace: Path,
    students: Sequence[RosterStudent],
    include_opaque_documents: bool,
    extra_private_identifiers: Sequence[str] = (),
    allowed_opaque_paths: Sequence[Path] = (),
) -> None:
    identifiers: List[str] = []
    for student in students:
        identifiers.extend([student.full_name, f"{student.name} {student.surname}"])
        for field in ("full_name", "email", "student_id"):
            value = student.row.get(field, "").strip()
            if value:
                identifiers.append(value)

    identifiers.extend(extra_private_identifiers)
    identifiers = sorted({value for value in identifiers if value.strip()}, key=len, reverse=True)
    text_suffixes = {*READABLE_SUFFIXES, ".csv", ".sh"}
    allowed_opaque_rel_paths = {
        path.relative_to(workspace).as_posix()
        for path in allowed_opaque_paths
        if is_relative_to(path, workspace)
    }

    for path in sorted(workspace.rglob("*"), key=lambda p: p.as_posix().casefold()):
        rel_name = path.relative_to(workspace).as_posix()
        for identifier in identifiers:
            if identifier.casefold() in rel_name.casefold():
                raise ValueError(f"privacy leak detected in workspace filename: {rel_name}")

        if (
            path.is_file()
            and not include_opaque_documents
            and path.suffix.lower() in DOCUMENT_SUFFIXES
            and rel_name not in allowed_opaque_rel_paths
        ):
            raise ValueError(f"opaque document was written without explicit opt-in: {rel_name}")

        if path.is_file() and path.suffix.lower() in text_suffixes:
            text = path.read_text(encoding="utf-8", errors="replace")
            for identifier in identifiers:
                if identifier.casefold() in text.casefold():
                    rel = path.relative_to(workspace).as_posix()
                    raise ValueError(f"privacy leak detected in generated workspace text file {rel}: {identifier}")


def prepare_workspace(
    input_zips: Sequence[Path],
    students_csv: Path,
    task_file: Path,
    workspace: Path,
    private_output: Path,
    template_path: Path,
    workspace_agents_template: Path,
    report_template: Path,
    prompt_template: Path,
    include_opaque_documents: bool = False,
) -> PrepareResult:
    students = read_roster(students_csv)
    roster_by_identity = {normalize_identity(f"{student.name} {student.surname}"): student for student in students}

    workspace_resolved = workspace.resolve()
    private_output_resolved = private_output.resolve()
    if workspace_resolved == private_output_resolved or is_relative_to(private_output_resolved, workspace_resolved):
        raise ValueError("--private-output must be outside --workspace")

    for input_zip in input_zips:
        if not input_zip.exists():
            raise FileNotFoundError(f"input file does not exist: {input_zip}")
        if not zipfile.is_zipfile(input_zip):
            raise ValueError(f"input file is not a valid ZIP: {input_zip}")

    if not task_file.exists():
        raise FileNotFoundError(f"task file does not exist: {task_file}")
    if not workspace_agents_template.exists():
        raise FileNotFoundError(f"workspace AGENTS template does not exist: {workspace_agents_template}")
    if not report_template.exists():
        raise FileNotFoundError(f"report template does not exist: {report_template}")
    if not prompt_template.exists():
        raise FileNotFoundError(f"prompt template does not exist: {prompt_template}")

    workspace.mkdir(parents=True, exist_ok=True)
    private_output.mkdir(parents=True, exist_ok=True)
    task_workspace_path = workspace / workspace_task_filename(task_file)

    write_workspace_students_csv(students, workspace)
    write_private_pseudonym_map(students, private_output)
    shutil.copy2(workspace_agents_template, workspace / "AGENTS.md")
    shutil.copy2(report_template, workspace / "report_aspects_template.md")
    shutil.copy2(task_file, task_workspace_path)
    # Editable task prompt: the instructor may adjust it (e.g. replace the
    # SUBJECT placeholder) before running process.sh. process.sh reads it at
    # runtime and embeds it into every per-student Codex command.
    shutil.copy2(prompt_template, workspace / "prompt.txt")

    matched_students: Dict[int, RosterStudent] = {}
    unmatched_folders: List[str] = []
    copied_documents: List[Path] = []
    excluded_documents: List[str] = []
    manifest_entries: List[ManifestEntry] = []
    text_outputs_by_row: Dict[int, str] = {}
    document_outputs_by_row: Dict[int, List[str]] = {}

    with tempfile.TemporaryDirectory(dir="/tmp", prefix="slaif-defense-grading_prepare_") as tmp:
        tmpdir = Path(tmp)
        outer_extract = tmpdir / "outer_extracted"
        outer_extract.mkdir(parents=True, exist_ok=True)
        merge_master_inputs(input_zips, outer_extract)

        unzipped_root = tmpdir / "unzipped_submissions"
        unzipped_root.mkdir(parents=True, exist_ok=True)

        student_folders = sorted([p for p in outer_extract.iterdir() if p.is_dir()], key=lambda p: p.as_posix().casefold())
        for student_folder_path in student_folders:
            folder_label = infer_student_label_from_folder(student_folder_path.name)
            student = roster_by_identity.get(normalize_identity(folder_label))
            if student is None:
                unmatched_folders.append(student_folder_path.name)
                continue

            extracted_dirs = discover_submission_dirs(student_folder_path, outer_extract, unzipped_root)
            matched_students[student.row_number] = student
            text_output = write_pseudonymized_text_output(student, extracted_dirs, workspace, students)
            text_outputs_by_row[student.row_number] = text_output.name
            opaque_documents = opaque_document_relative_paths(extracted_dirs)
            copied_for_student: List[Path] = []
            excluded_for_student: List[str] = []

            if include_opaque_documents:
                copied_for_student = copy_pseudonymized_documents(student, extracted_dirs, workspace)
                copied_documents.extend(copied_for_student)
                document_outputs_by_row[student.row_number] = [path.name for path in copied_for_student]
            else:
                excluded_for_student = opaque_documents
                excluded_documents.extend(f"{student_folder_path.name}/{path}" for path in opaque_documents)

            manifest_entries.append(
                ManifestEntry(
                    original_folder=student_folder_path.name,
                    pseudonym=student.pseudonym,
                    text_output=text_output.name,
                    copied_opaque_documents=document_outputs_by_row.get(student.row_number, []),
                    excluded_opaque_documents=excluded_for_student,
                )
            )

    associations = write_associations_csv(students, workspace, text_outputs_by_row, document_outputs_by_row)
    render_process_script(template_path, workspace / "process.sh", [association.student.pseudonym for association in associations])
    student_outputs_dir, student_outputs_index = copy_private_student_outputs(
        students,
        workspace,
        private_output,
        text_outputs_by_row,
    )

    result = PrepareResult(
        roster_count=len(students),
        matched_count=len(matched_students),
        missing_count=len(students) - len(matched_students),
        unmatched_folders=unmatched_folders,
        copied_documents=copied_documents,
        excluded_documents=excluded_documents,
        manifest_entries=manifest_entries,
        include_opaque_documents=include_opaque_documents,
        student_outputs_dir=student_outputs_dir,
        student_outputs_index=student_outputs_index,
    )
    write_preprocessing_report(private_output, result)
    private_identifiers = [entry.original_folder for entry in manifest_entries]
    private_identifiers.extend(unmatched_folders)
    leak_check_workspace(
        workspace,
        students,
        include_opaque_documents,
        private_identifiers,
        allowed_opaque_paths=[task_workspace_path],
    )
    return result
