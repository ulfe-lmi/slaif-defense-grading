from __future__ import annotations

import subprocess
import sys
import zipfile
from pathlib import Path

from slaif_defense_grading.prepare import read_roster

REPO_ROOT = Path(__file__).resolve().parent.parent


def build_moodle_style_roster(path: Path) -> None:
    """Synthetic Moodle-style roster: title line, tabs, Slovenian headers, UTF-16 BOM."""
    lines = [
        "Synthetic Course (12345) 2025/26 - student roster",
        "Vpisna številka\tPriimek, Ime\tE-mail\tLetnik program",
        "63240001\tNovak, Ana\tana.novak@example.invalid\t1 BMA-EL-AI RE",
        "63240002\tKovač, Boris\tboris.kovac@example.invalid\t2 BMA-EL-AI RE",
    ]
    path.write_bytes(("\r\n".join(lines) + "\r\n").encode("utf-16"))


def test_read_roster_moodle_utf16_tsv_with_title_line(tmp_path: Path) -> None:
    students_csv = tmp_path / "students.csv"
    build_moodle_style_roster(students_csv)

    students = read_roster(students_csv)

    assert [student.pseudonym for student in students] == ["Student 0001", "Student 0002"]
    first, second = students
    assert (first.name, first.surname, first.full_name) == ("Ana", "Novak", "Ana Novak")
    assert first.row["email"] == "ana.novak@example.invalid"
    assert first.row["student_id"] == "63240001"
    assert (second.name, second.surname) == ("Boris", "Kovač")
    assert first.fieldnames == ["name", "surname", "email", "student_id"]


def test_read_roster_utf8_sig_comma_still_works(tmp_path: Path) -> None:
    students_csv = tmp_path / "students.csv"
    students_csv.write_bytes(
        b"\xef\xbb\xbfname,surname,email\nAna,Novak,ana.novak@example.invalid\n"
    )

    students = read_roster(students_csv)

    assert [(student.name, student.surname) for student in students] == [("Ana", "Novak")]
    assert students[0].row["email"] == "ana.novak@example.invalid"


def test_read_roster_binary_gives_clear_error(tmp_path: Path) -> None:
    students_csv = tmp_path / "students.csv"
    students_csv.write_bytes(b"\x89PNG\r\n\x1a\nnot-a-roster")

    try:
        read_roster(students_csv)
    except ValueError as exc:
        assert "not valid UTF-8" in str(exc)
    else:
        raise AssertionError("expected ValueError for binary roster")


def test_prepare_with_moodle_utf16_roster_matches_folders(tmp_path: Path) -> None:
    students_csv = tmp_path / "students.csv"
    task_file = tmp_path / "task.tex"
    input_zip = tmp_path / "moodle_export.zip"
    build_moodle_style_roster(students_csv)
    task_file.write_text("\\section{Synthetic Assignment}\n", encoding="utf-8")

    with zipfile.ZipFile(input_zip, "w") as zf:
        zf.writestr(
            "Ana Novak_12345_assignsubmission_file/main.py",
            'print("Ana Novak")\nprint("ana.novak@example.invalid")\nprint("63240001")\n',
        )
        zf.writestr(
            "Boris Kovač_12346_assignsubmission_file/notes.md",
            "# Boris Kovač\nEmail: boris.kovac@example.invalid\nID: 63240002\n",
        )

    workspace = tmp_path / "lab-agent"
    private_output = tmp_path / "lab-private"
    result = subprocess.run(
        [
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
        ],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode == 0, result.stderr
    workspace_text = "".join(
        path.read_text(encoding="utf-8", errors="replace")
        for path in (p for p in workspace.rglob("*") if p.is_file())
    )
    for identifier in ("Ana Novak", "Boris Kovač", "63240001", "63240002"):
        assert identifier not in workspace_text
    assert "2/2 students matched" in (result.stdout + result.stderr)
    assert (private_output / "pseudonym_map.csv").exists()
