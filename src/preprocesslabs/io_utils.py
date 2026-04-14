from __future__ import annotations

import os
import shutil
import sys
import zipfile
from pathlib import Path
from typing import List

from .models import READABLE_FILENAMES, READABLE_SUFFIXES


def eprint(*args: object, **kwargs: object) -> None:
    print(*args, file=sys.stderr, **kwargs)


def _commonpath(a: Path, b: Path) -> Path:
    return Path(os.path.commonpath([str(a), str(b)]))


def safe_extract_zip(zip_path: Path, dest_dir: Path) -> None:
    dest_dir = dest_dir.resolve()
    with zipfile.ZipFile(zip_path) as zf:
        for member in zf.infolist():
            name = member.filename
            if not name:
                continue
            if name.startswith("/") or name.startswith("\\"):
                raise ValueError(f"Unsafe ZIP member (absolute path): {name}")
            target = (dest_dir / name).resolve()
            if _commonpath(dest_dir, target) != dest_dir:
                raise ValueError(f"Unsafe ZIP member (path traversal): {name}")
        zf.extractall(dest_dir)


def decode_text_file(path: Path) -> str:
    data = path.read_bytes()
    return data.decode("utf-8", errors="replace")


def is_probably_text(path: Path, sample_size: int = 32 * 1024) -> bool:
    data = path.read_bytes()[:sample_size]
    if not data:
        return True
    if b"\x00" in data:
        return False

    text_bytes = set(range(32, 127)) | {9, 10, 12, 13, 8}
    non_text = sum(byte not in text_bytes for byte in data)
    return (non_text / len(data)) <= 0.30


def list_readable_files(extracted_dir: Path) -> List[Path]:
    files: List[Path] = []
    for p in extracted_dir.rglob("*"):
        if not p.is_file():
            continue

        is_readable_kind = p.suffix.lower() in READABLE_SUFFIXES or p.name.lower() in READABLE_FILENAMES
        if is_readable_kind:
            if is_probably_text(p):
                files.append(p)
            else:
                eprint(f"Warning: skipping binary file {p}")

    files.sort(key=lambda x: x.as_posix().lower())
    return files


def write_partial_concatenation(extracted_dir: Path, out_path: Path) -> int:
    readable_files = list_readable_files(extracted_dir)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    with out_path.open("w", encoding="utf-8", newline="\n") as out:
        if not readable_files:
            out.write("==== BEGIN (no_readable_files_found) ====\n")
            out.write("No readable source files were found inside this submission.\n")
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


def copy_file_preserving_uniqueness(src: Path, dst: Path) -> None:
    target = unique_path(dst)
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, target)
