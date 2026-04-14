from __future__ import annotations

import os
import re
import shutil
from difflib import SequenceMatcher
from pathlib import Path
from typing import Dict, Iterable, List, Sequence, Tuple

from .io_utils import copy_file_preserving_uniqueness, eprint, safe_extract_zip, unique_path
from .models import DELIM_RE, SIMILARITY_THRESHOLD, SubmissionArtifact


def infer_student_label(zip_path: Path, outer_root: Path) -> Tuple[str, str]:
    try:
        rel = zip_path.relative_to(outer_root)
        parts = rel.parts
    except ValueError:
        parts = zip_path.parts

    student_folder = parts[0] if parts else zip_path.stem
    label = student_folder.split("_", 1)[0].strip() or student_folder.strip() or "UNKNOWN"
    return label, student_folder


def infer_student_label_from_folder(folder_name: str) -> str:
    return folder_name.split("_", 1)[0].strip() or folder_name.strip() or "UNKNOWN"


def merge_master_inputs(input_zips: Sequence[Path], merged_root: Path) -> None:
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
    for dirpath, _dirnames, filenames in os.walk(root_dir):
        for fn in filenames:
            if fn.lower().endswith(".zip"):
                yield Path(dirpath) / fn


def iter_submission_dirs(student_folder: Path) -> List[Path]:
    subdirs = [p for p in student_folder.iterdir() if p.is_dir()]
    if subdirs:
        return sorted(subdirs, key=lambda p: p.as_posix().casefold())

    has_files = any(p.is_file() for p in student_folder.iterdir())
    if has_files:
        return [student_folder]

    return []


def stage_zip_with_sibling_files(zip_path: Path, outer_root: Path, unzipped_root: Path) -> Path:
    rel = zip_path.relative_to(outer_root)
    zip_base = zip_path.stem

    staged_dir = unzipped_root / rel.parent / zip_base
    staged_dir.mkdir(parents=True, exist_ok=True)
    safe_extract_zip(zip_path, staged_dir)

    student_root = outer_root / rel.parts[0]
    outside_dir = staged_dir / "__outside_zip__"

    for p in sorted(student_root.rglob("*"), key=lambda x: x.as_posix().casefold()):
        if not p.is_file():
            continue
        if p == zip_path:
            continue
        if p.suffix.lower() == ".zip":
            continue

        rel_outside = p.relative_to(student_root)
        copy_file_preserving_uniqueness(p, outside_dir / rel_outside)

    return staged_dir


def build_big_output(artifacts: Sequence[SubmissionArtifact], output_file: Path) -> None:
    def sort_key(a: SubmissionArtifact) -> Tuple[str, str, str]:
        return (a.student_label.casefold(), a.submission_name.casefold(), str(a.submission_source).casefold())

    artifacts_sorted = sorted(artifacts, key=sort_key)
    output_file.parent.mkdir(parents=True, exist_ok=True)

    with output_file.open("w", encoding="utf-8", newline="\n") as out:
        for idx, art in enumerate(artifacts_sorted):
            if idx != 0:
                out.write("\n")

            with art.partial_concat_path.open("r", encoding="utf-8", errors="replace") as inp:
                for line in inp:
                    stripped = line.rstrip("\n")
                    m = DELIM_RE.match(stripped)
                    if m:
                        kind, payload = m.group(1), m.group(2)
                        out.write(f"==== {kind} {art.student_label} | {art.submission_name} | {payload} ====\n")
                    else:
                        out.write(line)


def sanitize_filename(name: str) -> str:
    cleaned = re.sub(r"[\\/]+", "_", name.strip())
    cleaned = re.sub(r"\s+", " ", cleaned)
    return cleaned or "UNKNOWN"


def build_per_student_outputs(artifacts: Sequence[SubmissionArtifact], output_dir: Path) -> List[Path]:
    output_dir.mkdir(parents=True, exist_ok=True)

    by_student: dict[str, List[SubmissionArtifact]] = {}
    for art in artifacts:
        by_student.setdefault(art.student_folder, []).append(art)

    written: List[Path] = []
    for student_folder, student_artifacts in sorted(by_student.items(), key=lambda item: item[0].casefold()):
        filename = sanitize_filename(student_folder)
        output_path = unique_path(output_dir / f"{filename}.txt")
        build_big_output(student_artifacts, output_path)
        written.append(output_path)

    return written


def normalize_similarity_text(text: str) -> str:
    return "\n".join(line.rstrip() for line in text.splitlines())


def read_artifact_text(artifact: SubmissionArtifact) -> str:
    return artifact.partial_concat_path.read_text(encoding="utf-8", errors="replace")


def merge_artifact_group(artifacts: Sequence[SubmissionArtifact]) -> SubmissionArtifact:
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
