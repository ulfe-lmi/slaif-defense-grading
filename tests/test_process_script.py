import json
import os
import subprocess
from pathlib import Path

from slaif_defense_grading.process_script import render_process_script


def test_config_is_passed_to_every_codex_command(tmp_path: Path, monkeypatch) -> None:
    config = tmp_path / "codex.conf"
    config.write_text("[codex]\nmodel = custom-model\nreasoning_effort = high\ncontext_window = 123456\n")
    template = tmp_path / "template"
    template.write_text("#!/bin/bash\nset -euo pipefail\n# PHASE2_COMMANDS\n")
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
    subprocess.run([str(output)], check=True)
    calls = [json.loads(line) for line in calls_file.read_text().splitlines()]
    assert len(calls) == 2
    for call, student in zip(calls, ("Student 0001", "Student 0002")):
        assert call[call.index("--model") + 1] == "custom-model"
        assert 'model_reasoning_effort="high"' in call
        assert "model_context_window=123456" in call
        assert call[-1] == f"Run oral-verification report for {student}"
