from __future__ import annotations

import argparse
import tempfile
import textwrap
import zipfile
from pathlib import Path
from typing import List, Optional, Sequence

from .core import (
    build_big_output,
    build_per_student_outputs,
    group_similar_artifacts,
    infer_student_label,
    iter_nested_zips,
    iter_submission_dirs,
    merge_master_inputs,
    stage_zip_with_sibling_files,
)
from .io_utils import eprint, unique_path, write_partial_concatenation
from .models import SubmissionArtifact


def build_arg_parser() -> argparse.ArgumentParser:
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
             - finds readable files: .txt, .m, .py, .c, .h, .cpp, .hpp, MakeFile/Makefile
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
    output_group.add_argument("--output-file", "-o", help="Path to write the final big concatenated .txt file.")
    output_group.add_argument("--output-directory", "-d", help="Directory to write one concatenated .txt file per student.")

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
    return build_arg_parser().parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> int:
    if argv is None:
        import sys

        argv = sys.argv[1:]

    if len(argv) == 0:
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

        student_folders = sorted([p for p in outer_extract.iterdir() if p.is_dir()], key=lambda p: p.as_posix().casefold())

        if not student_folders:
            eprint("ERROR: No student folders were found inside the provided ZIP file(s).")
            return 4

        total_zips = 0
        total_dirs = 0

        for student_folder_path in student_folders:
            student_zips = sorted(iter_nested_zips(student_folder_path), key=lambda p: p.as_posix().casefold())

            if student_zips:
                total_zips += len(student_zips)
                for zpath in student_zips:
                    student_label, student_folder = infer_student_label(zpath, outer_extract)
                    zip_base = zpath.stem
                    rel = zpath.relative_to(outer_extract)

                    eprint(f"[preprocesslabs]  - {student_label} :: extracting {rel.as_posix()} (+ outside-ZIP files)")

                    try:
                        extracted_dir = stage_zip_with_sibling_files(zpath, outer_extract, unzipped_root)
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
