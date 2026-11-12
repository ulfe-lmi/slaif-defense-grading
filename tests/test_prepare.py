from __future__ import annotations

import csv
import json
import stat
import subprocess
import sys
import zipfile
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
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
FORBIDDEN_IDENTIFIERS = [
    "Ana Novak",
    "Boris Kovac",
    "ana.novak@example.invalid",
    "boris.kovac@example.invalid",
    "63240001",
    "63240002",
    "Ana Novak_12345_assignsubmission_file",
    "Unmatched Person_999_assignsubmission_file",
]
MESSY_FORBIDDEN_IDENTIFIERS = [
    "Mila Kranjc",
    "Luka Horvat",
    "Nika Zupan",
    "Taj Černe",
    "Zoja Žagar",
    "mila.kranjc@example.invalid",
    "luka.horvat@example.invalid",
    "nika.zupan@example.invalid",
    "taj.cerne@example.invalid",
    "zoja.zagar@example.invalid",
    "SID-0001",
    "SID-0002",
    "SID-0003",
    "SID-0004",
    "SID-0005",
    "Mila Kranjc_100_assignsubmission_file",
    "Luka Horvat_200_assignsubmission_file",
    "Taj Černe_400_assignsubmission_file",
    "Unlisted Person_999_assignsubmission_file",
]


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8", newline="\n")


def write_bytes(path: Path, content: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(content)


def build_synthetic_moodle_zip(path: Path) -> None:
    with zipfile.ZipFile(path, "w") as zf:
        zf.writestr(
            "Ana Novak_12345_assignsubmission_file/main.py",
            'print("Ana Novak")\nprint("ana.novak@example.invalid")\nprint("63240001")\n',
        )
        zf.writestr(
            "Ana Novak_12345_assignsubmission_file/notes.md",
            "# Ana Novak\nEmail: ana.novak@example.invalid\nID: 63240001\n",
        )
        zf.writestr(
            "Ana Novak_12345_assignsubmission_file/Ana Novak report.pdf",
            b"%PDF-1.4 synthetic document with an internal name",
        )
        zf.writestr(
            "Ana Novak_12345_assignsubmission_file/Ana Novak worksheet.docx",
            b"synthetic docx with an internal name",
        )
        zf.writestr(
            "Ana Novak_12345_assignsubmission_file/Ana Novak notes.odt",
            b"synthetic odt with an internal name",
        )
        zf.writestr(
            "Ana Novak_12345_assignsubmission_file/Ana Novak comments.rtf",
            b"synthetic rtf with an internal name",
        )
        zf.writestr(
            "Unmatched Person_999_assignsubmission_file/main.py",
            'print("Unmatched Person")\n',
        )


def build_messy_synthetic_fixture(tmp_path: Path) -> tuple[Path, Path, Path]:
    students_csv = tmp_path / "students.csv"
    task_file = tmp_path / "task.tex"
    input_zip = tmp_path / "messy_moodle_export.zip"

    write_text(
        students_csv,
        "name,surname,email,student_id\n"
        "Mila,Kranjc,mila.kranjc@example.invalid,SID-0001\n"
        "Luka,Horvat,luka.horvat@example.invalid,SID-0002\n"
        "Nika,Zupan,nika.zupan@example.invalid,SID-0003\n"
        "Taj,Černe,taj.cerne@example.invalid,SID-0004\n"
        "Zoja,Žagar,zoja.zagar@example.invalid,SID-0005\n",
    )
    write_text(task_file, "\\section{Synthetic Messy Assignment}\nUse dynamic programming and compare variants.\n")

    nested_submission = tmp_path / "mila_submission.zip"
    with zipfile.ZipFile(nested_submission, "w") as zf:
        zf.writestr(
            "src/solution.py",
            'AUTHOR = "Mila Kranjc"\nEMAIL = "mila.kranjc@example.invalid"\nSTUDENT_ID = "SID-0001"\n',
        )
        zf.writestr(
            "notebooks/analysis.ipynb",
            json.dumps(
                {
                    "cells": [
                        {
                            "cell_type": "markdown",
                            "source": ["Mila Kranjc used SID-0001 in this fake notebook."],
                        }
                    ],
                    "metadata": {"author": "mila.kranjc@example.invalid"},
                    "nbformat": 4,
                    "nbformat_minor": 5,
                }
            ),
        )

    with zipfile.ZipFile(input_zip, "w") as zf:
        zf.write(nested_submission, "Mila Kranjc_100_assignsubmission_file/submission.zip")
        zf.writestr("Mila Kranjc_100_assignsubmission_file/Mila Kranjc report.pdf", b"%PDF synthetic Mila Kranjc")
        zf.writestr(
            "Luka Horvat_200_assignsubmission_file/main.c",
            "/* Luka Horvat luka.horvat@example.invalid SID-0002 */\nint main(void) { return 0; }\n",
        )
        zf.writestr(
            "Luka Horvat_200_assignsubmission_file/README.md",
            "# Luka Horvat\nSynthetic notes for SID-0002.\n",
        )
        zf.writestr(
            "Taj Černe_400_assignsubmission_file/Taj Černe analiza final.tex",
            "\\section{Taj Černe}\nContact: taj.cerne@example.invalid\nID: SID-0004\n",
        )
        zf.writestr(
            "Taj Černe_400_assignsubmission_file/čuden file name s presledki.py",
            'print("Taj Černe")\n',
        )
        zf.writestr(
            "Unlisted Person_999_assignsubmission_file/main.py",
            'print("Unlisted Person should stay private")\n',
        )

    return input_zip, students_csv, task_file


def run_messy_prepare(
    tmp_path: Path, include_opaque_documents: bool = False
) -> tuple[Path, Path, subprocess.CompletedProcess[str]]:
    input_zip, students_csv, task_file = build_messy_synthetic_fixture(tmp_path)
    workspace = tmp_path / "lab-agent"
    private_output = tmp_path / "lab-private"
    command = [
        sys.executable,
        "slaif-defense-grading.py",
        "prepare",
        "--input-file",
        str(input_zip),
        "--students-csv",
        str(students_csv),
        "--task-file",
        str(task_file),
        "--workspace",
        str(workspace),
        "--private-output",
        str(private_output),
    ]
    if include_opaque_documents:
        command.append("--include-opaque-documents")

    result = subprocess.run(
        command,
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    return workspace, private_output, result


def relative_workspace_tree(workspace: Path) -> str:
    return "\n".join(
        path.relative_to(workspace).as_posix()
        for path in sorted((p for p in workspace.rglob("*") if p.is_file()), key=lambda p: p.as_posix().casefold())
    )


def run_prepare(
    tmp_path: Path,
    include_opaque_documents: bool = False,
    task_suffix: str = ".tex",
) -> tuple[Path, Path, subprocess.CompletedProcess[str]]:
    students_csv = tmp_path / "students.csv"
    task_file = tmp_path / f"assignment{task_suffix}"
    input_zip = tmp_path / "moodle_export.zip"
    workspace = tmp_path / "workspace" / "lab-agent"
    private_output = tmp_path / "workspace" / "lab-private"

    write_text(
        students_csv,
        "name,surname,email,student_id\n"
        "Ana,Novak,ana.novak@example.invalid,63240001\n"
        "Boris,Kovac,boris.kovac@example.invalid,63240002\n",
    )
    if task_suffix == ".pdf":
        write_bytes(task_file, b"%PDF-1.4 synthetic assignment\n")
    else:
        write_text(task_file, "\\section{Synthetic Task}\n")
    build_synthetic_moodle_zip(input_zip)

    command = [
        sys.executable,
        "slaif-defense-grading.py",
        "prepare",
        "--input-file",
        str(input_zip),
        "--students-csv",
        str(students_csv),
        "--task-file",
        str(task_file),
        "--workspace",
        str(workspace),
        "--private-output",
        str(private_output),
    ]
    if include_opaque_documents:
        command.append("--include-opaque-documents")

    result = subprocess.run(
        command,
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    return workspace, private_output, result


def test_prepare_help_works() -> None:
    result = subprocess.run(
        [sys.executable, "slaif-defense-grading.py", "prepare", "--help"],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode == 0
    assert "--students-csv" in result.stdout
    assert "--private-output" in result.stdout
    assert "--include-opaque-documents" in result.stdout
    assert "task.*" in result.stdout


def test_finalize_help_works() -> None:
    result = subprocess.run(
        [sys.executable, "slaif-defense-grading.py", "finalize", "--help"],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode == 0
    assert "--workspace" in result.stdout
    assert "--private-output" in result.stdout
    assert "--output" in result.stdout
    assert "--strict" in result.stdout


def test_report_template_exists_and_readme_documents_pilot_outputs() -> None:
    template = REPO_ROOT / "templates" / "workspace" / "report_aspects_template.md"
    assert template.exists()
    template_text = template.read_text(encoding="utf-8")
    required_headings = [
        "# Poročilo za ustni zagovor: <Full Name>",
        "## Osnovni podatki",
        "## Primer brez povezane oddaje",
        "## 1. <kratek naslov vidika>",
        "### Vidik poročila oziroma rešitve",
        "### Zakaj ta vidik izstopa",
        "### Vprašanje za študenta",
        "### Pričakovani odgovor",
        "## 2. <kratek naslov vidika>",
        "## 3. <kratek naslov vidika>",
    ]
    for heading in required_headings:
        assert heading in template_text
    assert template_text.count("### Vidik poročila oziroma rešitve") == 3
    assert template_text.count("### Zakaj ta vidik izstopa") == 3
    assert template_text.count("### Vprašanje za študenta") == 3
    assert template_text.count("### Pričakovani odgovor") == 3
    assert "Zapis samo za izvajalca" in template_text
    assert "Tega besedila se ne bere študentu kot namig" in template_text
    assert "Ne izmišljaj vprašanj" in template_text

    agents_text = (REPO_ROOT / "templates" / "workspace" / "AGENTS.md").read_text(encoding="utf-8")
    assert "report_aspects_template.md" in agents_text
    assert "Preserve the headings and template structure exactly" in agents_text
    for heading in required_headings[4:8]:
        assert heading.replace("### ", "").replace("## ", "") in agents_text

    readme = (REPO_ROOT / "README.md").read_text(encoding="utf-8")
    assert readme.startswith('<div style="text-align: center;">')
    assert "[QUICKSTART.md](QUICKSTART.md)" in readme
    assert "python3 slaif-defense-grading.py finalize" in readme
    assert "report_aspects_template.md" in readme
    assert "student_outputs/" in readme
    assert "student_outputs_index.csv" in readme
    assert "--include-opaque-documents" in readme
    assert "--task-file assignment.pdf" in readme
    assert "task.pdf" in readme
    assert "task.*" in readme
    assert "Legacy Command" not in readme
    assert "SLAIF stands for" not in readme
    assert "work completed outside direct supervision" in readme
    assert "plagiarism, unauthorized collaboration, or improper AI-tool use" in readme
    assert "does not automatically prove misconduct" in readme
    assert "What To Inspect" in readme
    assert "What Can Be Shown To Students" in readme


def test_quickstart_documents_complete_workflow() -> None:
    quickstart = REPO_ROOT / "QUICKSTART.md"
    assert quickstart.exists()
    text = quickstart.read_text(encoding="utf-8")
    assert "python3 slaif-defense-grading.py prepare" in text
    assert "./process.sh" in text
    assert "python3 slaif-defense-grading.py finalize" in text
    assert "student_outputs/<Name>.txt" in text
    assert "instructor_reports/<Name>/report_aspects.md" in text
    assert "Do not send it wholesale to students" in text
    assert "--include-opaque-documents" in text
    assert "--task-file work/input/assignment.pdf" in text
    assert "task.pdf" in text
    assert "submissions completed outside direct supervision" in text
    assert "legacy" not in text.casefold()


def test_finalize_collects_named_outputs_and_missing_reports(tmp_path: Path) -> None:
    workspace, private_output, prepare_result = run_prepare(tmp_path)
    assert prepare_result.returncode == 0, prepare_result.stderr

    report_dir = workspace / "Student 0001"
    report_dir.mkdir()
    workspace_report = report_dir / "report_aspects.md"
    original_report = (
        "# Poročilo za ustni zagovor: Student 0001\n\n"
        "## Osnovni podatki\n\n"
        "- Študent: Student 0001\n"
        "- Status povezave z oddajo: matched\n"
        "- Uporabljene datoteke: Student_0001.txt\n"
        "- Opomba za izvajalca: Brez posebnih opomb.\n\n"
        "## Primer brez povezane oddaje\n\n"
        "Oddaja je povezana.\n\n"
        "## 1. Razlaga vhodnih podatkov\n\n"
        "### Vidik poročila oziroma rešitve\n"
        "Student 0001 uporablja Student_0001.txt.\n\n"
        "### Zakaj ta vidik izstopa\n"
        "Vidik je vezan na konkretno datoteko.\n\n"
        "### Vprašanje za študenta\n"
        "Kako deluje rešitev?\n\n"
        "### Pričakovani odgovor\n"
        "Student 0001 razloži rešitev.\n\n"
        "## 2. Omejitev\n\n"
        "### Vidik poročila oziroma rešitve\n"
        "Ni dodatnega vidika.\n\n"
        "### Zakaj ta vidik izstopa\n"
        "Omejitev je navedena.\n\n"
        "### Vprašanje za študenta\n"
        "Ni dodatnega vprašanja.\n\n"
        "### Pričakovani odgovor\n"
        "Ni dodatnega odgovora.\n\n"
        "## 3. Omejitev\n\n"
        "### Vidik poročila oziroma rešitve\n"
        "Ni dodatnega vidika.\n\n"
        "### Zakaj ta vidik izstopa\n"
        "Omejitev je navedena.\n\n"
        "### Vprašanje za študenta\n"
        "Ni dodatnega vprašanja.\n\n"
        "### Pričakovani odgovor\n"
        "Ni dodatnega odgovora.\n"
    )
    workspace_report.write_text(original_report, encoding="utf-8", newline="\n")

    output = tmp_path / "final"
    result = subprocess.run(
        [
            sys.executable,
            "slaif-defense-grading.py",
            "finalize",
            "--workspace",
            str(workspace),
            "--private-output",
            str(private_output),
            "--output",
            str(output),
        ],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode == 0, result.stderr
    assert workspace_report.read_text(encoding="utf-8") == original_report

    named_report = output / "instructor_reports" / "Ana_Novak" / "report_aspects.md"
    assert named_report.exists()
    named_report_text = named_report.read_text(encoding="utf-8")
    assert "Generated locally by slaif-defense-grading finalize" in named_report_text
    assert "# Poročilo za ustni zagovor: Ana Novak" in named_report_text
    assert "## Osnovni podatki" in named_report_text
    assert "## Primer brez povezane oddaje" in named_report_text
    assert "### Vidik poročila oziroma rešitve" in named_report_text
    assert "### Zakaj ta vidik izstopa" in named_report_text
    assert "### Vprašanje za študenta" in named_report_text
    assert "### Pričakovani odgovor" in named_report_text
    assert "Ana_Novak.txt" in named_report_text
    assert "Student 0001" not in named_report_text
    assert "Student_0001" not in named_report_text

    named_student_output = output / "student_outputs" / "Ana_Novak.txt"
    assert named_student_output.exists()
    named_student_output_text = named_student_output.read_text(encoding="utf-8")
    assert "This is the pseudonymized concatenated submission text that the agent saw." in named_student_output_text
    assert "Student: Ana Novak" in named_student_output_text
    assert "Pseudonym: Student 0001" in named_student_output_text
    assert "Ana Novak" not in "\n".join(named_student_output_text.splitlines()[4:])
    assert "ana.novak@example.invalid" not in named_student_output_text
    assert "63240001" not in named_student_output_text
    assert (private_output / "student_outputs" / "Student_0001.txt").read_text(encoding="utf-8") == (
        workspace / "Student_0001.txt"
    ).read_text(encoding="utf-8")

    with (output / "final_index.csv").open("r", encoding="utf-8", newline="") as f:
        final_rows = list(csv.DictReader(f))
    assert [row["pseudonym"] for row in final_rows] == ["Student 0001", "Student 0002"]
    assert final_rows[0]["name"] == "Ana"
    assert final_rows[0]["surname"] == "Novak"
    assert final_rows[0]["full_name"] == "Ana Novak"
    assert final_rows[0]["email"] == "ana.novak@example.invalid"
    assert final_rows[0]["student_id"] == "63240001"
    assert final_rows[0]["report_status"] == "found"
    assert final_rows[0]["report_file"] == "instructor_reports/Ana_Novak/report_aspects.md"
    assert final_rows[0]["student_output_file"] == "student_outputs/Ana_Novak.txt"
    assert final_rows[1]["report_status"] == "missing"
    assert final_rows[1]["report_file"] == ""
    assert final_rows[1]["student_output_file"] == ""

    with (output / "missing_reports.csv").open("r", encoding="utf-8", newline="") as f:
        missing_rows = list(csv.DictReader(f))
    assert missing_rows == [
        {
            "pseudonym": "Student 0002",
            "name": "Boris",
            "surname": "Kovac",
            "full_name": "Boris Kovac",
            "expected_report_path": "Student 0002/report_aspects.md",
            "reason": "report_aspects.md was not found in the pseudonymized workspace",
        }
    ]

    finalize_report = (output / "finalize_report.md").read_text(encoding="utf-8")
    assert "Roster students: 2" in finalize_report
    assert "Found reports: 1" in finalize_report
    assert "Missing reports: 1" in finalize_report
    assert "Copied student-output text files: 1" in finalize_report
    assert "`Student 0002` / Boris Kovac: report_aspects.md was not found in the pseudonymized workspace" in finalize_report
    assert "Instructor reports contain expected answers" in finalize_report

    workspace_text = (workspace / "students.csv").read_text(encoding="utf-8") + (workspace / "associations.csv").read_text(encoding="utf-8")
    assert "Ana Novak" not in workspace_text
    assert "Boris Kovac" not in workspace_text

    strict_output = tmp_path / "final-strict"
    strict_result = subprocess.run(
        [
            sys.executable,
            "slaif-defense-grading.py",
            "finalize",
            "--workspace",
            str(workspace),
            "--private-output",
            str(private_output),
            "--output",
            str(strict_output),
            "--strict",
        ],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    assert strict_result.returncode == 2
    assert "missing 1 expected report" in strict_result.stderr


def test_finalize_uses_deterministic_safe_paths_for_duplicate_names(tmp_path: Path) -> None:
    workspace = tmp_path / "workspace"
    private_output = tmp_path / "private"
    output = tmp_path / "final"
    workspace.mkdir()
    private_output.mkdir()
    (private_output / "student_outputs").mkdir()

    write_text(workspace / "students.csv", "name,surname,full_name\nStudent,0001,Student 0001\nStudent,0002,Student 0002\n")
    write_text(
        workspace / "associations.csv",
        "name,surname,full_name,associated_txt_files,associated_document_files,all_associated_files,status,evidence\n"
        "Student,0001,Student 0001,Student_0001.txt,,Student_0001.txt,matched,matched\n"
        "Student,0002,Student 0002,Student_0002.txt,,Student_0002.txt,matched,matched\n",
    )
    write_text(
        private_output / "pseudonym_map.csv",
        "pseudonym,name,surname,full_name,email,student_id\n"
        "Student 0001,Ana,Novak,Ana Novak,ana1@example.invalid,ID-1\n"
        "Student 0002,Ana,Novak,Ana Novak,ana2@example.invalid,ID-2\n",
    )
    write_text(
        private_output / "student_outputs_index.csv",
        "pseudonym,name,surname,full_name,student_output_file,email,student_id\n"
        "Student 0001,Ana,Novak,Ana Novak,Student_0001.txt,ana1@example.invalid,ID-1\n"
        "Student 0002,Ana,Novak,Ana Novak,Student_0002.txt,ana2@example.invalid,ID-2\n",
    )
    write_text(private_output / "student_outputs" / "Student_0001.txt", "Student 0001 content\n")
    write_text(private_output / "student_outputs" / "Student_0002.txt", "Student 0002 content\n")
    write_text(workspace / "Student 0001" / "report_aspects.md", "# Poročilo za ustni zagovor: Student 0001\n")
    write_text(workspace / "Student 0002" / "report_aspects.md", "# Poročilo za ustni zagovor: Student 0002\n")

    result = subprocess.run(
        [
            sys.executable,
            "slaif-defense-grading.py",
            "finalize",
            "--workspace",
            str(workspace),
            "--private-output",
            str(private_output),
            "--output",
            str(output),
        ],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode == 0, result.stderr
    assert (output / "instructor_reports" / "Ana_Novak" / "report_aspects.md").exists()
    assert (output / "instructor_reports" / "Ana_Novak__Student_0002" / "report_aspects.md").exists()
    assert (output / "student_outputs" / "Ana_Novak.txt").exists()
    assert (output / "student_outputs" / "Ana_Novak__Student_0002.txt").exists()

    with (output / "final_index.csv").open("r", encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f))
    assert rows[0]["report_file"] == "instructor_reports/Ana_Novak/report_aspects.md"
    assert rows[1]["report_file"] == "instructor_reports/Ana_Novak__Student_0002/report_aspects.md"
    assert rows[0]["student_output_file"] == "student_outputs/Ana_Novak.txt"
    assert rows[1]["student_output_file"] == "student_outputs/Ana_Novak__Student_0002.txt"



def test_prepare_creates_pseudonymized_workspace_and_private_outputs(tmp_path: Path) -> None:
    workspace, private_output, result = run_prepare(tmp_path)

    assert result.returncode == 0, result.stderr
    assert (workspace / "students.csv").read_text(encoding="utf-8") == (
        "name,surname,full_name\n"
        "Student,0001,Student 0001\n"
        "Student,0002,Student 0002\n"
    )
    assert (workspace / "task.tex").read_text(encoding="utf-8") == "\\section{Synthetic Task}\n"
    assert not (workspace / "task.pdf").exists()

    process_sh = workspace / "process.sh"
    process_text = process_sh.read_text(encoding="utf-8")
    assert process_sh.stat().st_mode & stat.S_IXUSR
    assert "Phase 1" not in process_text
    assert "cat .slaif_prompts" not in process_text
    assert "test -f prompt.txt" in process_text
    assert process_text.count("$(cat prompt.txt)") == 2
    assert process_text.count("codex --ask-for-approval never exec --skip-git-repo-check") == 2
    assert process_text.count("--model gpt-6-astra") == 2
    assert process_text.count('model_reasoning_effort="xhigh"') == 2
    assert process_text.count("model_context_window=1000000") == 2
    assert process_text.index("Run oral-verification report for Student 0001") < process_text.index(
        "Run oral-verification report for Student 0002"
    )
    assert "Ana Novak" not in process_text
    assert "Boris Kovac" not in process_text
    assert not (workspace / ".slaif_prompts").exists()
    assert (workspace / "prompt.txt").read_text(encoding="utf-8") == (
        REPO_ROOT / "templates" / "workspace" / "prompt.txt"
    ).read_text(encoding="utf-8")

    agents_md = workspace / "AGENTS.md"
    assert agents_md.exists()
    assert agents_md.read_text(encoding="utf-8") == (REPO_ROOT / "templates" / "workspace" / "AGENTS.md").read_text(
        encoding="utf-8"
    )
    agents_text = agents_md.read_text(encoding="utf-8")
    assert "Run oral-verification report for Student 0001" in agents_text
    assert "students.csv" in agents_text
    assert "associations.csv" in agents_text
    assert "task.*" in agents_text
    assert "task.pdf" in agents_text
    assert "report_aspects_template.md" in agents_text
    assert "Use `report_aspects_template.md` as the mandatory output template" in agents_text
    assert "Preserve the headings and template structure exactly" in agents_text
    assert "Do not invent questions" in agents_text
    assert "Do not expose expected answers to students" in agents_text
    assert "Vidik poročila oziroma rešitve" in agents_text
    assert "Zakaj ta vidik izstopa" in agents_text
    assert "Vprašanje za študenta" in agents_text
    assert "Pričakovani odgovor" in agents_text
    assert "preprocessing" in agents_text
    assert "already done locally" in agents_text
    assert "Do not redo preprocessing" in agents_text
    assert "The only student submission files are the files listed in `associations.csv`." in agents_text
    assert "Do not accuse AI use" in agents_text
    for value in FORBIDDEN_IDENTIFIERS:
        assert value not in agents_text

    report_template = workspace / "report_aspects_template.md"
    assert report_template.exists()
    assert report_template.read_text(encoding="utf-8") == (
        REPO_ROOT / "templates" / "workspace" / "report_aspects_template.md"
    ).read_text(encoding="utf-8")
    for value in FORBIDDEN_IDENTIFIERS:
        assert value not in report_template.read_text(encoding="utf-8")

    student_text = (workspace / "Student_0001.txt").read_text(encoding="utf-8")
    assert "==== BEGIN Student 0001 | submission | main.py ====" in student_text
    assert "Student 0001" in student_text
    assert "Ana Novak" not in student_text
    assert "ana.novak@example.invalid" not in student_text
    assert "63240001" not in student_text
    assert "==== BEGIN Student 0001 | submission | notes.md ====" in student_text
    assert not list(workspace.glob("*.pdf"))
    assert not list(workspace.glob("*.docx"))
    assert not list(workspace.glob("*.odt"))
    assert not list(workspace.glob("*.rtf"))
    assert not (workspace / "Unmatched_Person.txt").exists()

    with (workspace / "associations.csv").open("r", encoding="utf-8", newline="") as f:
        association_reader = csv.DictReader(f)
        association_rows = list(association_reader)
    assert association_reader.fieldnames == ASSOCIATION_COLUMNS
    assert [row["full_name"] for row in association_rows] == ["Student 0001", "Student 0002"]
    assert association_rows[0]["name"] == "Student"
    assert association_rows[0]["surname"] == "0001"
    assert association_rows[0]["associated_txt_files"] == "Student_0001.txt"
    assert association_rows[0]["associated_document_files"] == ""
    assert association_rows[0]["all_associated_files"] == "Student_0001.txt"
    assert association_rows[0]["status"] == "matched"
    assert association_rows[0]["evidence"] == "Generated pseudonymized submission package for Student 0001."
    assert association_rows[1]["associated_txt_files"] == ""
    assert association_rows[1]["associated_document_files"] == ""
    assert association_rows[1]["all_associated_files"] == ""
    assert association_rows[1]["status"] == "unresolved"
    assert association_rows[1]["evidence"] == "No matched pseudonymized submission files were generated."
    association_text = (workspace / "associations.csv").read_text(encoding="utf-8")
    for value in FORBIDDEN_IDENTIFIERS:
        assert value not in association_text

    map_path = private_output / "pseudonym_map.csv"
    assert map_path.exists()
    assert not (workspace / "pseudonym_map.csv").exists()
    with map_path.open("r", encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f))
    assert rows[0]["pseudonym"] == "Student 0001"
    assert rows[0]["name"] == "Ana"
    assert rows[0]["surname"] == "Novak"
    assert rows[0]["email"] == "ana.novak@example.invalid"
    assert rows[0]["student_id"] == "63240001"

    student_outputs = private_output / "student_outputs"
    assert student_outputs.exists()
    assert (student_outputs / "Student_0001.txt").read_text(encoding="utf-8") == (workspace / "Student_0001.txt").read_text(
        encoding="utf-8"
    )
    assert not (student_outputs / "Student_0002.txt").exists()
    student_output_text = (student_outputs / "Student_0001.txt").read_text(encoding="utf-8")
    for value in FORBIDDEN_IDENTIFIERS:
        assert value not in student_output_text

    index_path = private_output / "student_outputs_index.csv"
    assert index_path.exists()
    with index_path.open("r", encoding="utf-8", newline="") as f:
        index_rows = list(csv.DictReader(f))
    assert index_rows == [
        {
            "pseudonym": "Student 0001",
            "name": "Ana",
            "surname": "Novak",
            "full_name": "Ana Novak",
            "student_output_file": "Student_0001.txt",
            "email": "ana.novak@example.invalid",
            "student_id": "63240001",
        }
    ]

    report = (private_output / "preprocessing_report.md").read_text(encoding="utf-8")
    assert "Roster students: 2" in report
    assert "Matched students: 1" in report
    assert "Students without submissions: 1" in report
    assert "Unmatched Person_999_assignsubmission_file" in report
    assert "excluded from the workspace by default" in report
    assert "cannot safely pseudonymize their internal content or metadata" in report
    assert "Ana Novak report.pdf" in report
    assert "Ana Novak worksheet.docx" in report
    assert "Ana Novak notes.odt" in report
    assert "Ana Novak comments.rtf" in report
    assert "Original matched LMS folder: `Ana Novak_12345_assignsubmission_file`" in report
    assert "Workspace text output: `Student_0001.txt`" in report
    assert "Student-visible concatenated outputs were written to `student_outputs/`" in report
    assert "`student_outputs_index.csv` maps those pseudonymized files back to real roster rows" in report


def test_prepare_can_explicitly_include_opaque_documents_with_warning(tmp_path: Path) -> None:
    workspace, private_output, result = run_prepare(tmp_path, include_opaque_documents=True)

    assert result.returncode == 0, result.stderr
    copied_names = sorted(path.name for path in workspace.iterdir() if path.suffix in {".pdf", ".docx", ".odt", ".rtf"})
    assert len(copied_names) == 4
    assert {Path(name).suffix for name in copied_names} == {".pdf", ".docx", ".odt", ".rtf"}
    for name in copied_names:
        assert name.startswith("Student_0001__document_")
        assert "Ana Novak" not in name

    report = (private_output / "preprocessing_report.md").read_text(encoding="utf-8")
    assert "Opaque document inclusion was explicitly enabled" in report
    assert "internal content and metadata were not inspected or redacted" in report
    assert "Student_0001__document_" in report
    assert "Excluded opaque documents: none" in report

    with (workspace / "associations.csv").open("r", encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f))
    copied_names = sorted(path.name for path in workspace.iterdir() if path.suffix in {".pdf", ".docx", ".odt", ".rtf"})
    assert rows[0]["associated_txt_files"] == "Student_0001.txt"
    assert rows[0]["associated_document_files"] == ";".join(copied_names)
    assert rows[0]["all_associated_files"] == ";".join(["Student_0001.txt", *copied_names])
    assert rows[0]["status"] == "matched"
    for value in FORBIDDEN_IDENTIFIERS:
        assert value not in (workspace / "associations.csv").read_text(encoding="utf-8")


def test_prepare_preserves_pdf_task_file_type_without_including_student_pdfs(tmp_path: Path) -> None:
    workspace, private_output, result = run_prepare(tmp_path, task_suffix=".pdf")

    assert result.returncode == 0, result.stderr
    assert (workspace / "task.pdf").read_bytes() == b"%PDF-1.4 synthetic assignment\n"
    assert not (workspace / "task.tex").exists()

    workspace_pdfs = sorted(path.name for path in workspace.glob("*.pdf"))
    assert workspace_pdfs == ["task.pdf"]
    assert not list(workspace.glob("*.docx"))
    assert not list(workspace.glob("*.odt"))
    assert not list(workspace.glob("*.rtf"))

    with (workspace / "associations.csv").open("r", encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f))
    assert rows[0]["associated_txt_files"] == "Student_0001.txt"
    assert rows[0]["associated_document_files"] == ""
    assert rows[0]["all_associated_files"] == "Student_0001.txt"

    associations_text = (workspace / "associations.csv").read_text(encoding="utf-8")
    assert "task.pdf" not in associations_text
    for value in FORBIDDEN_IDENTIFIERS:
        assert value not in associations_text

    agents_text = (workspace / "AGENTS.md").read_text(encoding="utf-8")
    assert "task.*" in agents_text
    assert "task.pdf" in agents_text
    assert "read it as PDF" in agents_text
    assert "task.tex` contains the assignment" not in agents_text

    report = (private_output / "preprocessing_report.md").read_text(encoding="utf-8")
    assert "Ana Novak report.pdf" in report
    assert "excluded from the workspace by default" in report


def test_messy_prepare_default_mode_end_to_end_audit(tmp_path: Path) -> None:
    workspace, private_output, result = run_messy_prepare(tmp_path)
    tree = relative_workspace_tree(workspace)

    assert result.returncode == 0, result.stderr
    assert (workspace / "AGENTS.md").exists(), tree
    assert (workspace / "students.csv").exists(), tree
    assert (workspace / "associations.csv").exists(), tree
    assert (workspace / "task.tex").read_text(encoding="utf-8").startswith("\\section{Synthetic Messy Assignment}"), tree
    assert not (workspace / "task.pdf").exists(), tree
    assert (workspace / "report_aspects_template.md").exists(), tree
    assert (workspace / "process.sh").exists(), tree
    assert not (workspace / ".slaif_prompts").exists(), tree

    assert (workspace / "students.csv").read_text(encoding="utf-8") == (
        "name,surname,full_name\n"
        "Student,0001,Student 0001\n"
        "Student,0002,Student 0002\n"
        "Student,0003,Student 0003\n"
        "Student,0004,Student 0004\n"
        "Student,0005,Student 0005\n"
    )

    process_sh = workspace / "process.sh"
    process_text = process_sh.read_text(encoding="utf-8")
    assert process_sh.stat().st_mode & stat.S_IXUSR
    assert "Phase 1" not in process_text
    assert "cat .slaif_prompts" not in process_text
    assert "test -f prompt.txt" in process_text
    assert process_text.count("$(cat prompt.txt)") == 5
    assert process_text.count("Run oral-verification report for Student ") == 5
    for idx in range(1, 5):
        assert process_text.index(f"Run oral-verification report for Student {idx:04d}") < process_text.index(
            f"Run oral-verification report for Student {idx + 1:04d}"
        )

    agents_text = (workspace / "AGENTS.md").read_text(encoding="utf-8")
    assert agents_text == (REPO_ROOT / "templates" / "workspace" / "AGENTS.md").read_text(encoding="utf-8")
    assert "students.csv" in agents_text
    assert "associations.csv" in agents_text
    assert "task.*" in agents_text
    assert "task.pdf" in agents_text
    assert "report_aspects_template.md" in agents_text
    assert "The only student submission files are the files listed in `associations.csv`." in agents_text
    assert "Preserve the headings and template structure exactly" in agents_text
    assert "<Full Name>/report_aspects.md" in agents_text
    assert "Do not infer, request, or reconstruct real student identities." in agents_text
    assert "Do not accuse AI use" in agents_text
    assert "Do not redo preprocessing" in agents_text
    assert "Run Phase 1" not in agents_text
    assert "Build associations" not in agents_text

    template_text = (workspace / "report_aspects_template.md").read_text(encoding="utf-8")
    assert "# Poročilo za ustni zagovor: <Full Name>" in template_text
    for value in MESSY_FORBIDDEN_IDENTIFIERS:
        assert value not in template_text

    with (workspace / "associations.csv").open("r", encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    assert reader.fieldnames == ASSOCIATION_COLUMNS
    assert [row["full_name"] for row in rows] == [
        "Student 0001",
        "Student 0002",
        "Student 0003",
        "Student 0004",
        "Student 0005",
    ]
    assert [row["status"] for row in rows] == ["matched", "matched", "unresolved", "matched", "unresolved"]
    assert rows[0]["associated_txt_files"] == "Student_0001.txt"
    assert rows[1]["associated_txt_files"] == "Student_0002.txt"
    assert rows[2]["all_associated_files"] == ""
    assert rows[3]["associated_txt_files"] == "Student_0004.txt"
    assert rows[4]["all_associated_files"] == ""
    assert all(row["associated_document_files"] == "" for row in rows)
    assert all("Mila Kranjc report.pdf" not in row["all_associated_files"] for row in rows)

    assert (workspace / "Student_0001.txt").exists(), tree
    assert (workspace / "Student_0002.txt").exists(), tree
    assert not (workspace / "Student_0003.txt").exists(), tree
    assert (workspace / "Student_0004.txt").exists(), tree
    assert not (workspace / "Student_0005.txt").exists(), tree
    assert not list(workspace.glob("*.pdf")), tree
    assert not any("Unlisted" in path.name for path in workspace.rglob("*")), tree

    student_0001 = (workspace / "Student_0001.txt").read_text(encoding="utf-8")
    assert "notebooks/analysis.ipynb" in student_0001
    assert "Student 0001" in student_0001
    assert "Mila Kranjc" not in student_0001
    assert "mila.kranjc@example.invalid" not in student_0001
    assert "SID-0001" not in student_0001

    student_0004 = (workspace / "Student_0004.txt").read_text(encoding="utf-8")
    assert "Student 0004 analiza final.tex" in student_0004
    assert "čuden file name s presledki.py" in student_0004
    assert "Taj Černe" not in student_0004
    assert "taj.cerne@example.invalid" not in student_0004
    assert "SID-0004" not in student_0004

    report = (private_output / "preprocessing_report.md").read_text(encoding="utf-8")
    assert "Roster students: 5" in report
    assert "Matched students: 3" in report
    assert "Students without submissions: 2" in report
    assert "Unlisted Person_999_assignsubmission_file" in report
    assert "Mila Kranjc_100_assignsubmission_file/" in report
    assert "Mila Kranjc report.pdf" in report
    assert "excluded from the workspace by default" in report
    assert "Original matched LMS folder: `Mila Kranjc_100_assignsubmission_file`" in report
    assert "Original matched LMS folder: `Luka Horvat_200_assignsubmission_file`" in report
    assert "Original matched LMS folder: `Taj Černe_400_assignsubmission_file`" in report
    assert "Student-visible concatenated outputs were written to `student_outputs/`" in report

    student_outputs = private_output / "student_outputs"
    assert sorted(path.name for path in student_outputs.glob("*.txt")) == [
        "Student_0001.txt",
        "Student_0002.txt",
        "Student_0004.txt",
    ]
    assert (student_outputs / "Student_0001.txt").read_text(encoding="utf-8") == (workspace / "Student_0001.txt").read_text(
        encoding="utf-8"
    )
    assert not (student_outputs / "Student_0003.txt").exists()
    assert not (student_outputs / "Student_0005.txt").exists()

    with (private_output / "student_outputs_index.csv").open("r", encoding="utf-8", newline="") as f:
        output_index_rows = list(csv.DictReader(f))
    assert [row["pseudonym"] for row in output_index_rows] == ["Student 0001", "Student 0002", "Student 0004"]
    assert output_index_rows[0]["name"] == "Mila"
    assert output_index_rows[0]["surname"] == "Kranjc"
    assert output_index_rows[0]["full_name"] == "Mila Kranjc"
    assert output_index_rows[0]["email"] == "mila.kranjc@example.invalid"
    assert output_index_rows[0]["student_id"] == "SID-0001"
    assert output_index_rows[0]["student_output_file"] == "Student_0001.txt"

    for output_file in student_outputs.glob("*.txt"):
        output_text = output_file.read_text(encoding="utf-8")
        for value in MESSY_FORBIDDEN_IDENTIFIERS:
            assert value not in output_text, f"{value!r} leaked in private student output {output_file.name!r}"

    for path in workspace.rglob("*"):
        rel = path.relative_to(workspace).as_posix()
        for value in MESSY_FORBIDDEN_IDENTIFIERS:
            assert value not in rel, f"{value!r} leaked in workspace path {rel!r}\n{tree}"
        if path.is_file() and path.suffix.lower() in {
            ".txt",
            ".csv",
            ".sh",
            ".tex",
            ".md",
            ".py",
            ".m",
            ".c",
            ".h",
            ".cpp",
            ".hpp",
            ".ipynb",
        }:
            text = path.read_text(encoding="utf-8")
            for value in MESSY_FORBIDDEN_IDENTIFIERS:
                assert value not in text, f"{value!r} leaked in workspace file {rel!r}\n{tree}"


def test_messy_prepare_opt_in_opaque_documents_are_pseudonymized(tmp_path: Path) -> None:
    workspace, private_output, result = run_messy_prepare(tmp_path, include_opaque_documents=True)
    tree = relative_workspace_tree(workspace)

    assert result.returncode == 0, result.stderr
    copied_documents = sorted(path.name for path in workspace.iterdir() if path.suffix.lower() in {".pdf", ".docx"})
    assert copied_documents == ["Student_0001__document_001.pdf"], tree
    assert "Mila Kranjc" not in copied_documents[0]

    with (workspace / "associations.csv").open("r", encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f))
    assert rows[0]["associated_document_files"] == "Student_0001__document_001.pdf"
    assert rows[0]["all_associated_files"] == "Student_0001.txt;Student_0001__document_001.pdf"
    assert rows[1]["associated_document_files"] == ""

    report = (private_output / "preprocessing_report.md").read_text(encoding="utf-8")
    assert "Opaque document inclusion was explicitly enabled" in report
    assert "internal content and metadata were not inspected or redacted" in report
    assert "Student_0001__document_001.pdf" in report

    workspace_text = (workspace / "associations.csv").read_text(encoding="utf-8") + "\n" + (workspace / "process.sh").read_text(
        encoding="utf-8"
    )
    for value in MESSY_FORBIDDEN_IDENTIFIERS:
        assert value not in workspace_text


def test_workspace_generated_text_and_filenames_do_not_contain_real_identifiers(tmp_path: Path) -> None:
    workspace, _private_output, result = run_prepare(tmp_path)

    assert result.returncode == 0, result.stderr
    for path in workspace.rglob("*"):
        rel = path.relative_to(workspace).as_posix()
        for value in FORBIDDEN_IDENTIFIERS:
            assert value not in rel
        if path.is_file() and path.suffix in {".txt", ".csv", ".sh", ".tex", ".md", ".py", ".m", ".c", ".h", ".cpp", ".hpp", ".ipynb"}:
            text = path.read_text(encoding="utf-8")
            for value in FORBIDDEN_IDENTIFIERS:
                assert value not in text
