import json
import csv
import os
import subprocess
from pathlib import Path

from slaif_defense_grading.process_script import render_process_script


def test_config_is_passed_to_every_codex_command(tmp_path: Path, monkeypatch) -> None:
    config = tmp_path / "codex.conf"
    config.write_text("[codex]\nmodel = custom-model\nreasoning_effort = high\ncontext_window = 123456\n")
    template = tmp_path / "template"
    template.write_text("#!/bin/bash\nset -euo pipefail\n# PHASE2_COMMANDS\n")
    (tmp_path / "prompt.txt").write_text("Editable task prompt line.\n", encoding="utf-8")
    output = tmp_path / "process.sh"
    render_process_script(template, output, ["Student 0001", "Student 0002"], config)

    executable = tmp_path / "codex"
    executable.write_text(
        "#!/usr/bin/env python3\nimport json, os, sys\n"
        "with open(os.environ['CALLS_FILE'], 'a') as f: f.write(json.dumps(sys.argv[1:]) + '\\n')\n"
    )
    executable.chmod(0o755)
    calls_file = tmp_path / "calls"
    monkeypatch.setenv("PATH", f"{tmp_path}:{os.environ['PATH']}")
    monkeypatch.setenv("CALLS_FILE", str(calls_file))
    subprocess.run([str(output)], cwd=tmp_path, check=True)
    calls = [json.loads(line) for line in calls_file.read_text().splitlines()]
    assert len(calls) == 2
    for call, student in zip(calls, ("Student 0001", "Student 0002")):
        assert call[call.index("--model") + 1] == "custom-model"
        assert 'model_reasoning_effort="high"' in call
        assert "model_context_window=123456" in call
        assert "project_root_markers=[]" in call
        assert call[-1] == f"Run oral-verification report for {student}. Editable task prompt line."
    with (tmp_path / "token_usage.csv").open(newline="") as f:
        rows = list(csv.DictReader(f))
    assert [row["status"] for row in rows] == ["usage_unavailable", "usage_unavailable", "incomplete"]
    assert rows[-1]["input_tokens"] == rows[-1]["output_tokens"] == ""


def test_usage_totals_and_failed_run(tmp_path: Path, monkeypatch) -> None:
    template = tmp_path / "template"
    template.write_text("#!/bin/bash\nset -euo pipefail\ncd \"$(dirname \"$0\")\"\n# PHASE2_COMMANDS\n")
    output = tmp_path / "process.sh"
    render_process_script(template, output, ["Student 0001", "Student 0002", "Student 0003"])
    executable = tmp_path / "codex"
    executable.write_text(
        "#!/usr/bin/env python3\nimport json, sys\n"
        "if 'Student 0002' in sys.argv[-1]: sys.exit(2)\n"
        "print(json.dumps({'type': 'turn.completed', 'usage': {'input_tokens': 100, 'output_tokens': 25}}))\n"
    )
    executable.chmod(0o755)
    monkeypatch.setenv("PATH", f"{tmp_path}:{os.environ['PATH']}")
    result = subprocess.run([str(output)], cwd=tmp_path)
    assert result.returncode == 2
    with (tmp_path / "token_usage.csv").open(newline="") as f:
        rows = list(csv.DictReader(f))
    assert rows == [
        {"pseudonym": "Student 0001", "input_tokens": "100", "output_tokens": "25", "status": "completed"},
        {"pseudonym": "Student 0002", "input_tokens": "", "output_tokens": "", "status": "failed"},
        {"pseudonym": "Student 0003", "input_tokens": "", "output_tokens": "", "status": "not_started"},
        {"pseudonym": "TOTAL", "input_tokens": "100", "output_tokens": "25", "status": "incomplete"},
    ]

    # A fresh successful run replaces the old accounting and totals both students.
    executable.write_text(
        "#!/usr/bin/env python3\nimport json\n"
        "print(json.dumps({'type': 'turn.completed', 'usage': {'input_tokens': 100, 'output_tokens': 25}}))\n"
    )
    subprocess.run([str(output)], cwd=tmp_path, check=True)
    with (tmp_path / "token_usage.csv").open(newline="") as f:
        rows = list(csv.DictReader(f))
    assert [row["status"] for row in rows] == ["completed", "completed", "completed", "complete"]
    assert rows[-1]["input_tokens"] == "300"
    assert rows[-1]["output_tokens"] == "75"
