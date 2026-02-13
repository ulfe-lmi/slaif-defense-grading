#!/usr/bin/env python3
"""preprocesslabs.py

Unpacks one or more "Moodle-style" master ZIPs that contain one folder per student,
where each folder contains (one or more) submission ZIP files or submission subfolders.

If multiple master ZIPs are provided, they are merged in argument order and later ZIPs
replace earlier submissions for duplicate students.

For every submission ZIP or submission folder found inside the merged input:
  1) Extract it into a temporary directory under /tmp (ZIPs only).
  2) Collect readable source files with suffix: .txt, .m, .py (case-insensitive).
  3) Concatenate the collected files into a per-submission text file with clear BEGIN/END
     delimiters.

Finally, concatenates all per-submission text files into ONE big output file. In the final
output, each BEGIN/END delimiter line is augmented with the student's name (inferred from
folder names like "Name Surname_12345_assignsubmission_file") and the submission name.

Example:
  python preprocesslabs.py --input-file submissions_A.zip submissions_B.zip --output-file all_submissions.txt

Run with --help for full instructions.
"""

from __future__ import annotations

import argparse
import os
import re
import shutil
import sys
import tempfile
import textwrap
import zipfile
from dataclasses import dataclass
from difflib import SequenceMatcher
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Tuple


READABLE_SUFFIXES = {".txt", ".m", ".py"}
SIMILARITY_THRESHOLD = 0.98

# Delimiter format used in per-submission concatenation.
DELIM_RE = re.compile(r"^==== (BEGIN|END) (.+) ====$")


@dataclass(frozen=True)
class SubmissionArtifact:
    student_label: str
    student_folder: str
    submission_source: Path
    submission_name: str
    extracted_dir: Path
    partial_concat_path: Path
    source_kind: str


def eprint(*args: object, **kwargs: object) -> None:
    """Print to stderr."""
    print(*args, file=sys.stderr, **kwargs)


def _commonpath(a: Path, b: Path) -> Path:
    """Cross-platform common path as Path."""
    return Path(os.path.commonpath([str(a), str(b)]))


def safe_extract_zip(zip_path: Path, dest_dir: Path) -> None:
    """Safely extract a zip file to dest_dir.

    Protects against Zip Slip/path traversal attacks by ensuring every member extracts
    within dest_dir.

    Raises:
        zipfile.BadZipFile: if the ZIP is invalid
        ValueError: if a path traversal attempt is detected
    """
    dest_dir = dest_dir.resolve()
    with zipfile.ZipFile(zip_path) as zf:
        for member in zf.infolist():
            name = member.filename

            # Skip empty names.
            if not name:
                continue

            # Disallow absolute paths.
            if name.startswith("/") or name.startswith("\\"):
                raise ValueError(f"Unsafe ZIP member (absolute path): {name}")

            # Compute target path and ensure it stays within dest_dir.
            target = (dest_dir / name).resolve()
            if _commonpath(dest_dir, target) != dest_dir:
                raise ValueError(f"Unsafe ZIP member (path traversal): {name}")

        zf.extractall(dest_dir)


def infer_student_label(zip_path: Path, outer_root: Path) -> Tuple[str, str]:
    """Infer student name label and the student folder name from a nested zip path.

    Typical Moodle export looks like:
      <outer_root>/<Student Name>_<id>_assignsubmission_file/<submission>.zip

    Returns:
      (student_label, student_folder)
    """
    try:
        rel = zip_path.relative_to(outer_root)
        parts = rel.parts
    except ValueError:
        # Should not happen, but fall back.
        parts = zip_path.parts

    # Moodle style: first path component is the student's folder.
    student_folder = parts[0] if parts else zip_path.stem

    # Extract "Name Surname" part from folder name up to first underscore.
    # If no underscore, keep whole folder.
    label = student_folder.split("_", 1)[0].strip() or student_folder.strip() or "UNKNOWN"

    return label, student_folder


def infer_student_label_from_folder(folder_name: str) -> str:
    """Infer student label from a Moodle-style folder name."""
    return folder_name.split("_", 1)[0].strip() or folder_name.strip() or "UNKNOWN"


def merge_master_inputs(input_zips: Sequence[Path], merged_root: Path) -> None:
    """Extract and merge master ZIP inputs into merged_root.

    Later ZIPs replace earlier submissions for the same inferred student label.
    """
    merged_root.mkdir(parents=True, exist_ok=True)
    students_by_label: Dict[str, Path] = {}

    for idx, input_zip in enumerate(input_zips, start=1):
        source_root = merged_root.parent / f"outer_extracted_{idx}"
        source_root.mkdir(parents=True, exist_ok=True)

        eprint(f"[preprocesslabs] Extracting master ZIP #{idx} -> {source_root}")
        safe_extract_zip(input_zip, source_root)

        for student_path in sorted((p for p in source_root.iterdir() if p.is_dir()), key=lambda p: p.as_posix().casefold()):
            label = infer_student_label_from_folder(student_path.name).casefold()

            existing = students_by_label.get(label)
            if existing is not None and existing.exists():
                shutil.rmtree(existing)

            target = merged_root / student_path.name
            if target.exists():
                shutil.rmtree(target)

            shutil.copytree(student_path, target)
            students_by_label[label] = target


def iter_nested_zips(root_dir: Path) -> Iterable[Path]:
    """Yield all .zip files under root_dir (recursively), case-insensitive."""
    for dirpath, _dirnames, filenames in os.walk(root_dir):
        for fn in filenames:
            if fn.lower().endswith(".zip"):
                yield Path(dirpath) / fn


def iter_submission_dirs(student_folder: Path) -> List[Path]:
    """Return candidate submission folders inside a student folder.

    If direct subfolders exist, treat each subfolder as a submission folder.
    Otherwise, if the student folder contains files, treat the student folder
    itself as the submission folder.
    """
    subdirs = [p for p in student_folder.iterdir() if p.is_dir()]
    if subdirs:
        return sorted(subdirs, key=lambda p: p.as_posix().casefold())

    has_files = any(p.is_file() for p in student_folder.iterdir())
    if has_files:
        return [student_folder]

    return []


def decode_text_file(path: Path) -> str:
    """Read a file as text.

    Uses UTF-8 with replacement for invalid bytes. This is robust for student submissions
    with mixed encodings; content may include replacement characters if the file is not
    valid UTF-8.
    """
    data = path.read_bytes()
    return data.decode("utf-8", errors="replace")


def is_probably_text(path: Path, sample_size: int = 32 * 1024) -> bool:
    """Return True if a file appears to be text, based on a small byte sample."""
    data = path.read_bytes()[:sample_size]
    if not data:
        return True

    if b"\x00" in data:
        return False

    text_bytes = set(range(32, 127)) | {9, 10, 12, 13, 8}
    non_text = sum(byte not in text_bytes for byte in data)
    return (non_text / len(data)) <= 0.30


def list_readable_files(extracted_dir: Path) -> List[Path]:
    """Return all readable files under extracted_dir."""
    files: List[Path] = []
    for p in extracted_dir.rglob("*"):
        if p.is_file() and p.suffix.lower() in READABLE_SUFFIXES:
            if is_probably_text(p):
                files.append(p)
            else:
                eprint(f"Warning: skipping binary file {p}")

    files.sort(key=lambda x: x.as_posix().lower())
    return files


def write_partial_concatenation(extracted_dir: Path, out_path: Path) -> int:
    """Create per-submission concatenation file.

    Returns:
        Number of readable files concatenated.
    """
    readable_files = list_readable_files(extracted_dir)

    out_path.parent.mkdir(parents=True, exist_ok=True)

    with out_path.open("w", encoding="utf-8", newline="\n") as out:
        if not readable_files:
            out.write("==== BEGIN (no_readable_files_found) ====\n")
            out.write("No .txt, .m, or .py files were found inside this submission.\n")
            out.write("==== END (no_readable_files_found) ====\n")
            return 0

        for fp in readable_files:
            rel = fp.relative_to(extracted_dir).as_posix()
            out.write(f"==== BEGIN {rel} ====\n")
            content = decode_text_file(fp)
            out.write(content)
            if not content.endswith("\n"):
                out.write("\n")
            out.write(f"==== END {rel} ====\n\n")

    return len(readable_files)


def unique_path(path: Path) -> Path:
    """If path exists, add _N before suffix until unique."""
    if not path.exists():
        return path

    stem = path.stem
    suffix = path.suffix
    parent = path.parent
    n = 1
    while True:
        candidate = parent / f"{stem}_{n}{suffix}"
        if not candidate.exists():
            return candidate
        n += 1


def build_big_output(artifacts: Sequence[SubmissionArtifact], output_file: Path) -> None:
    """Concatenate all partial files into one big output, augmenting delimiter headers."""

    # Deterministic order: by student label (casefold), then by submission name, then by path.
    def sort_key(a: SubmissionArtifact) -> Tuple[str, str, str]:
        return (a.student_label.casefold(), a.submission_name.casefold(), str(a.submission_source).casefold())

    artifacts_sorted = sorted(artifacts, key=sort_key)

    output_file.parent.mkdir(parents=True, exist_ok=True)

    with output_file.open("w", encoding="utf-8", newline="\n") as out:
        for idx, art in enumerate(artifacts_sorted):
            # Optional separation between submissions.
            if idx != 0:
                out.write("\n")

            with art.partial_concat_path.open("r", encoding="utf-8", errors="replace") as inp:
                for line in inp:
                    stripped = line.rstrip("\n")
                    m = DELIM_RE.match(stripped)
                    if m:
                        kind, payload = m.group(1), m.group(2)
                        # Add student name + submission name in every delimiter line.
                        new_line = f"==== {kind} {art.student_label} | {art.submission_name} | {payload} ====\n"
                        out.write(new_line)
                    else:
                        out.write(line)


def sanitize_filename(name: str) -> str:
    """Return a filename-safe version of the provided name."""
    cleaned = re.sub(r"[\\/]+", "_", name.strip())
    cleaned = re.sub(r"\s+", " ", cleaned)
    return cleaned or "UNKNOWN"


def build_per_student_outputs(
    artifacts: Sequence[SubmissionArtifact],
    output_dir: Path,
) -> List[Path]:
    """Create one concatenated output file per student in output_dir."""
    output_dir.mkdir(parents=True, exist_ok=True)

    by_student: dict[str, List[SubmissionArtifact]] = {}
    for art in artifacts:
        by_student.setdefault(art.student_folder, []).append(art)

    written: List[Path] = []
    for student_folder, student_artifacts in sorted(
        by_student.items(),
        key=lambda item: item[0].casefold(),
    ):
        filename = sanitize_filename(student_folder)
        output_path = unique_path(output_dir / f"{filename}.txt")
        build_big_output(student_artifacts, output_path)
        written.append(output_path)

    return written


def normalize_similarity_text(text: str) -> str:
    """Normalize text for similarity comparisons."""
    return "\n".join(line.rstrip() for line in text.splitlines())


def read_artifact_text(artifact: SubmissionArtifact) -> str:
    """Read the concatenated text for a submission artifact."""
    return artifact.partial_concat_path.read_text(encoding="utf-8", errors="replace")


def merge_artifact_group(artifacts: Sequence[SubmissionArtifact]) -> SubmissionArtifact:
    """Merge similar artifacts into a single representative artifact."""
    if not artifacts:
        raise ValueError("Expected at least one artifact to merge.")

    students = sorted({art.student_label for art in artifacts}, key=str.casefold)
    submissions = sorted({art.submission_name for art in artifacts}, key=str.casefold)
    merged_label = " & ".join(students)
    merged_submission = " + ".join(submissions)

    first = artifacts[0]
    return SubmissionArtifact(
        student_label=merged_label,
        student_folder=first.student_folder,
        submission_source=first.submission_source,
        submission_name=merged_submission,
        extracted_dir=first.extracted_dir,
        partial_concat_path=first.partial_concat_path,
        source_kind=first.source_kind,
    )


def group_similar_artifacts(artifacts: Sequence[SubmissionArtifact]) -> List[SubmissionArtifact]:
    """Group similar submissions and return representative artifacts."""
    if not artifacts:
        return []

    texts = [normalize_similarity_text(read_artifact_text(art)) for art in artifacts]
    parents = list(range(len(artifacts)))

    def find(idx: int) -> int:
        while parents[idx] != idx:
            parents[idx] = parents[parents[idx]]
            idx = parents[idx]
        return idx

    def union(a: int, b: int) -> None:
        root_a = find(a)
        root_b = find(b)
        if root_a != root_b:
            parents[root_b] = root_a

    for i, art_i in enumerate(artifacts):
        for j in range(i + 1, len(artifacts)):
            art_j = artifacts[j]
            if art_i.student_folder == art_j.student_folder:
                continue
            if texts[i] == texts[j]:
                union(i, j)
                continue
            similarity = SequenceMatcher(None, texts[i], texts[j]).ratio()
            if similarity >= SIMILARITY_THRESHOLD:
                union(i, j)

    grouped: dict[int, List[SubmissionArtifact]] = {}
    for idx, art in enumerate(artifacts):
        grouped.setdefault(find(idx), []).append(art)

    merged_artifacts: List[SubmissionArtifact] = []
    for group in grouped.values():
        if len(group) > 1:
            students = ", ".join(sorted({art.student_label for art in group}, key=str.casefold))
            eprint(f"[preprocesslabs] Similarity match: grouping submissions for {students}")
        merged_artifacts.append(merge_artifact_group(group))

    return merged_artifacts


def build_arg_parser() -> argparse.ArgumentParser:
    """Create an ArgumentParser with detailed help text."""
    description = textwrap.dedent(
        """\
        Preprocess one or more master ZIPs that contain per-student folders with
        submission ZIPs or submission subfolders.

        What it does (high level):
          1) Extracts all provided master ZIPs to temporary directories under /tmp.
             Later ZIPs replace earlier submissions for duplicate students.
          2) Finds every nested .zip (recursively) inside the extracted contents.
             If a student folder has no nested ZIPs, uses subfolders as submission sources.
          3) For each submission source (ZIP or folder):
             - extracts ZIPs under /tmp (folders are read directly)
             - finds readable files: .txt, .m, .py
             - concatenates them into a per-submission .txt with BEGIN/END delimiters
        4) Either:
           - Concatenates all per-submission .txt files into ONE big output file, or
           - Writes one concatenated output file per student in an output directory.
           Every delimiter line in outputs is augmented with the student's name (inferred
           from folder names like "Name Surname_12345_assignsubmission_file") and the
           submission name.

        Output format (delimiter lines):
          ==== BEGIN <student> | <submission_name> | <relative_path_inside_submission> ====
          ... file content ...
          ==== END   <student> | <submission_name> | <relative_path_inside_submission> ====

        Notes:
          - Extraction happens under /tmp (temporary directory).
          - Text is decoded as UTF-8 with replacement for invalid bytes.
        """
    )

    parser = argparse.ArgumentParser(
        prog="preprocesslabs.py",
        description=description,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "--input-file",
        "-i",
        nargs="+",
        required=True,
        help=(
            "Path(s) to one or more master ZIP files. If multiple ZIPs are provided, "
            "later ZIPs replace earlier submissions for duplicate students."
        ),
    )

    output_group = parser.add_mutually_exclusive_group(required=True)
    output_group.add_argument(
        "--output-file",
        "-o",
        help="Path to write the final big concatenated .txt file.",
    )
    output_group.add_argument(
        "--output-directory",
        "-d",
        help="Directory to write one concatenated .txt file per student.",
    )

    parser.add_argument(
        "--similarity-check",
        action="store_true",
        help=(
            "When set, compare all submissions for similarity before building the final "
            "concatenated output, and merge near-identical submissions into a single entry "
            "that lists all student names."
        ),
    )

    return parser


def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    """Parse CLI args."""
    return build_arg_parser().parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> int:
    # If run without arguments, print help and exit cleanly.
    if argv is None:
        argv = sys.argv[1:]
    if len(argv) == 0:
        # Print the same help text as --help, but without raising SystemExit.
        build_arg_parser().print_help()
        return 0

    args = parse_args(argv)

    input_zips = [Path(raw).expanduser().resolve() for raw in args.input_file]
    output_file = Path(args.output_file).expanduser().resolve() if args.output_file else None
    output_directory = Path(args.output_directory).expanduser().resolve() if args.output_directory else None

    for input_zip in input_zips:
        if not input_zip.exists():
            eprint(f"ERROR: input file does not exist: {input_zip}")
            return 2

        if not zipfile.is_zipfile(input_zip):
            eprint(f"ERROR: input file is not a valid ZIP: {input_zip}")
            return 2

    artifacts: List[SubmissionArtifact] = []

    # Work under /tmp as requested.
    with tempfile.TemporaryDirectory(dir="/tmp", prefix="preprocesslabs_") as tmp:
        tmpdir = Path(tmp)
        outer_extract = tmpdir / "outer_extracted"
        outer_extract.mkdir(parents=True, exist_ok=True)

        try:
            merge_master_inputs(input_zips, outer_extract)
        except Exception as exc:  # noqa: BLE001
            eprint(f"ERROR: failed to extract input ZIP(s): {exc}")
            return 3

        unzipped_root = tmpdir / "unzipped_submissions"
        unzipped_root.mkdir(parents=True, exist_ok=True)

        student_folders = sorted(
            [p for p in outer_extract.iterdir() if p.is_dir()],
            key=lambda p: p.as_posix().casefold(),
        )

        if not student_folders:
            eprint("ERROR: No student folders were found inside the provided ZIP file(s).")
            return 4

        total_zips = 0
        total_dirs = 0

        for student_folder_path in student_folders:
            student_zips = sorted(
                iter_nested_zips(student_folder_path),
                key=lambda p: p.as_posix().casefold(),
            )

            if student_zips:
                total_zips += len(student_zips)
                for zpath in student_zips:
                    student_label, student_folder = infer_student_label(zpath, outer_extract)
                    zip_base = zpath.stem

                    # Mirror relative structure under unzipped_root.
                    rel = zpath.relative_to(outer_extract)
                    extracted_dir = unzipped_root / rel.parent / zip_base
                    extracted_dir.mkdir(parents=True, exist_ok=True)

                    eprint(f"[preprocesslabs]  - {student_label} :: extracting {rel.as_posix()}")

                    try:
                        safe_extract_zip(zpath, extracted_dir)
                    except zipfile.BadZipFile:
                        eprint(f"[preprocesslabs]    WARNING: Bad zip file, skipping: {zpath}")
                        continue
                    except Exception as exc:  # noqa: BLE001
                        eprint(f"[preprocesslabs]    WARNING: Failed to extract {zpath}: {exc}")
                        continue

                    partial_path = unique_path(extracted_dir.parent / f"{zip_base}.txt")

                    try:
                        num = write_partial_concatenation(extracted_dir, partial_path)
                    except Exception as exc:  # noqa: BLE001
                        eprint(f"[preprocesslabs]    WARNING: Failed to concatenate files for {zpath}: {exc}")
                        continue

                    eprint(f"[preprocesslabs]    -> concatenated {num} file(s) into {partial_path.name}")

                    artifacts.append(
                        SubmissionArtifact(
                            student_label=student_label,
                            student_folder=student_folder,
                            submission_source=zpath,
                            submission_name=zip_base,
                            extracted_dir=extracted_dir,
                            partial_concat_path=partial_path,
                            source_kind="zip",
                        )
                    )
                continue

            submission_dirs = iter_submission_dirs(student_folder_path)
            if not submission_dirs:
                continue

            total_dirs += len(submission_dirs)

            for submission_dir in submission_dirs:
                student_label, student_folder = infer_student_label(submission_dir, outer_extract)
                submission_name = submission_dir.name

                rel = submission_dir.relative_to(outer_extract)
                extracted_dir = submission_dir
                partial_path = unique_path(unzipped_root / rel.parent / f"{submission_name}.txt")

                eprint(f"[preprocesslabs]  - {student_label} :: reading folder {rel.as_posix()}")

                try:
                    num = write_partial_concatenation(extracted_dir, partial_path)
                except Exception as exc:  # noqa: BLE001
                    eprint(f"[preprocesslabs]    WARNING: Failed to concatenate files for {submission_dir}: {exc}")
                    continue

                eprint(f"[preprocesslabs]    -> concatenated {num} file(s) into {partial_path.name}")

                artifacts.append(
                    SubmissionArtifact(
                        student_label=student_label,
                        student_folder=student_folder,
                        submission_source=submission_dir,
                        submission_name=submission_name,
                        extracted_dir=extracted_dir,
                        partial_concat_path=partial_path,
                        source_kind="dir",
                    )
                )

        if total_zips or total_dirs:
            eprint(f"[preprocesslabs] Found {total_zips} nested ZIP(s) and {total_dirs} submission folder(s).")

        if not artifacts:
            eprint("ERROR: No valid submission ZIPs or folders were processed.")
            return 5

        if output_directory is not None:
            if output_directory.exists() and not output_directory.is_dir():
                eprint(f"ERROR: output directory is not a directory: {output_directory}")
                return 6
            eprint(f"[preprocesslabs] Building per-student outputs -> {output_directory}")
            try:
                written = build_per_student_outputs(artifacts, output_directory)
            except Exception as exc:  # noqa: BLE001
                eprint(f"ERROR: Failed to write output directory: {exc}")
                return 6
            eprint(f"[preprocesslabs] Done. Wrote {len(written)} file(s) to {output_directory}")
        else:
            assert output_file is not None
            if args.similarity_check:
                eprint("[preprocesslabs] Running similarity check across submissions")
                artifacts = group_similar_artifacts(artifacts)
            eprint(f"[preprocesslabs] Building final output -> {output_file}")
            try:
                build_big_output(artifacts, output_file)
            except Exception as exc:  # noqa: BLE001
                eprint(f"ERROR: Failed to write output file: {exc}")
                return 6

            eprint(f"[preprocesslabs] Done. Wrote {output_file}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
