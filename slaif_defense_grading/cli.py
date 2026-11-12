from __future__ import annotations

import argparse
import textwrap
from pathlib import Path
from typing import Optional, Sequence

from .io_utils import eprint
from .finalize import finalize_outputs
from .prepare import prepare_workspace


REPO_ROOT = Path(__file__).resolve().parent.parent


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="slaif-defense-grading.py",
        description=(
            "Local prepare/finalize workflow for AI-assisted oral-defense questions. "
            "Use prepare before running the agent, then finalize after reports are generated."
        ),
    )
    subparsers = parser.add_subparsers(dest="command", metavar="command")

    prepare_parser = subparsers.add_parser(
        "prepare",
        help="create a pseudonymized agent workspace from local instructor data",
        description=textwrap.dedent(
            """\
            Create a pseudonymized workspace for later AI-assisted oral-defense question preparation.

            Real roster data is read locally from --students-csv. The generated workspace
            receives only pseudonyms, a canonical task.* assignment file, a workspace
            AGENTS.md, a report template, the editable task prompt prompt.txt,
            pseudonymized submission text files, associations.csv, and a locally
            rendered process.sh. The private pseudonym map,
            student-output copies, and preprocessing report are written under
            --private-output, outside the workspace.
            """
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    add_prepare_arguments(prepare_parser)

    finalize_parser = subparsers.add_parser(
        "finalize",
        help="collect pseudonymized agent outputs into private named instructor outputs",
        description=textwrap.dedent(
            """\
            Create private named final outputs after the agent has run in the pseudonymized
            workspace. This command reads the workspace and private prepare outputs, maps
            pseudonyms back to real local roster rows, and writes instructor-facing files
            under --output. It does not modify the pseudonymized workspace.
            """
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    add_finalize_arguments(finalize_parser)
    return parser


def add_prepare_arguments(parser: argparse.ArgumentParser) -> None:
    parser.add_argument(
        "--input-file",
        "-i",
        nargs="+",
        required=True,
        help=(
            "Path(s) to one or more Moodle/Canvas master ZIP exports. Later ZIPs override "
            "earlier submissions for duplicate LMS student folders."
        ),
    )
    parser.add_argument("--students-csv", required=True, help="Private local roster CSV with at least name,surname.")
    parser.add_argument(
        "--task-file",
        required=True,
        help=(
            "Instructor assignment file. It is copied into the generated workspace under a "
            "canonical task.* name such as task.tex or task.pdf."
        ),
    )
    parser.add_argument("--workspace", required=True, help="Agent-facing output workspace with pseudonymized data only.")
    parser.add_argument(
        "--private-output",
        required=True,
        help="Private output directory for pseudonym_map.csv and preprocessing_report.md. Must be outside --workspace.",
    )
    parser.add_argument(
        "--include-opaque-documents",
        action="store_true",
        help=(
            "Opt in to copying opaque documents such as PDF/DOCX/DOC/ODT/RTF under pseudonymized filenames. "
            "This weakens the privacy guarantee because internal content and metadata are not redacted."
        ),
    )


def add_finalize_arguments(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--workspace", required=True, help="Prepared pseudonymized workspace after the agent has run.")
    parser.add_argument("--private-output", required=True, help="Private output directory created by prepare.")
    parser.add_argument("--output", required=True, help="Private final output directory for named instructor outputs.")
    parser.add_argument("--strict", action="store_true", help="Fail if any expected report_aspects.md is missing.")


def build_prepare_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="slaif-defense-grading.py prepare",
        description="Create a pseudonymized workspace from local instructor data.",
    )
    add_prepare_arguments(parser)
    return parser


def build_finalize_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="slaif-defense-grading.py finalize",
        description="Create private named final outputs from a completed pseudonymized workspace.",
    )
    add_finalize_arguments(parser)
    return parser


def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    return build_arg_parser().parse_args(argv)


def run_prepare(args: argparse.Namespace) -> int:
    input_zips = [Path(raw).expanduser().resolve() for raw in args.input_file]
    students_csv = Path(args.students_csv).expanduser().resolve()
    task_file = Path(args.task_file).expanduser().resolve()
    workspace = Path(args.workspace).expanduser().resolve()
    private_output = Path(args.private_output).expanduser().resolve()
    template_path = REPO_ROOT / "templates" / "process.sh.tpl"
    workspace_agents_template = REPO_ROOT / "templates" / "workspace" / "AGENTS.md"
    report_template = REPO_ROOT / "templates" / "workspace" / "report_aspects_template.md"
    prompt_template = REPO_ROOT / "templates" / "workspace" / "prompt.txt"

    try:
        result = prepare_workspace(
            input_zips=input_zips,
            students_csv=students_csv,
            task_file=task_file,
            workspace=workspace,
            private_output=private_output,
            template_path=template_path,
            workspace_agents_template=workspace_agents_template,
            report_template=report_template,
            prompt_template=prompt_template,
            include_opaque_documents=args.include_opaque_documents,
        )
    except Exception as exc:  # noqa: BLE001
        eprint(f"ERROR: prepare failed: {exc}")
        return 2

    eprint(
        "[slaif-defense-grading] Prepared pseudonymized workspace "
        f"({result.matched_count}/{result.roster_count} students matched): {workspace}"
    )
    eprint(f"[slaif-defense-grading] Private outputs: {private_output}")
    return 0


def run_finalize(args: argparse.Namespace) -> int:
    workspace = Path(args.workspace).expanduser().resolve()
    private_output = Path(args.private_output).expanduser().resolve()
    output = Path(args.output).expanduser().resolve()

    try:
        result = finalize_outputs(
            workspace=workspace,
            private_output=private_output,
            output=output,
            strict=args.strict,
        )
    except Exception as exc:  # noqa: BLE001
        eprint(f"ERROR: finalize failed: {exc}")
        return 2

    eprint(
        "[slaif-defense-grading] Finalized private outputs "
        f"({result.found_reports}/{result.roster_count} reports found, "
        f"{result.copied_student_outputs} student outputs copied): {output}"
    )
    return 0


def main(argv: Optional[Sequence[str]] = None) -> int:
    if argv is None:
        import sys

        argv = sys.argv[1:]

    argv = list(argv)
    if not argv:
        build_arg_parser().print_help()
        return 0

    if argv[0] == "prepare":
        return run_prepare(build_prepare_parser().parse_args(argv[1:]))

    if argv[0] == "finalize":
        return run_finalize(build_finalize_parser().parse_args(argv[1:]))

    if argv[0] in {"-h", "--help"}:
        build_arg_parser().print_help()
        return 0

    build_arg_parser().parse_args(argv)
    return 2
