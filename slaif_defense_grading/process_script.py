from __future__ import annotations

import configparser
import json
import os
import shlex
import shutil
from pathlib import Path
from typing import Sequence


CONFIG_PATH = Path(__file__).resolve().parent.parent / "codex.conf"


def render_process_script(
    template_path: Path, output_path: Path, pseudonyms: Sequence[str], config_path: Path = CONFIG_PATH
) -> None:
    config = configparser.ConfigParser(interpolation=None)
    with config_path.open(encoding="utf-8") as config_file:
        config.read_file(config_file)
    model = config.get("codex", "model").strip()
    effort = config.get("codex", "reasoning_effort").strip()
    context_window = config.getint("codex", "context_window")
    if not model or effort not in {"minimal", "low", "medium", "high", "xhigh", "max"} or context_window <= 0:
        raise ValueError(f"Invalid Codex settings in {config_path}")
    options = (
        f"--model {shlex.quote(model)} "
        f"-c {shlex.quote('model_reasoning_effort=' + json.dumps(effort))} "
        f"-c model_context_window={context_window} "
        f"-c {shlex.quote('project_root_markers=[]')}"
    )
    # project_root_markers=[] pins the Codex project root to the workspace
    # itself, so AGENTS.md files from an enclosing repository (or any parent
    # directory) are not loaded into the pseudonymized agent's instructions.
    template = template_path.read_text(encoding="utf-8")
    phase2_commands = "\n".join(
        f'python3 token_usage.py run {shlex.quote(pseudonym)} '
        f'codex --ask-for-approval never exec --skip-git-repo-check --json {options} '
        f'"Run oral-verification report for {pseudonym}. $(cat prompt.txt)"'
        for pseudonym in pseudonyms
    )

    if "# PHASE2_COMMANDS" not in template:
        raise ValueError(f"process script template is missing # PHASE2_COMMANDS placeholder: {template_path}")

    initialize = "python3 token_usage.py init" + "".join(f" {shlex.quote(name)}" for name in pseudonyms)
    rendered = template.replace("# PHASE2_COMMANDS", initialize + "\n" + phase2_commands)
    output_path.write_text(rendered, encoding="utf-8", newline="\n")
    os.chmod(output_path, 0o755)
    shutil.copyfile(Path(__file__).resolve().parent.parent / "templates" / "token_usage.py", output_path.parent / "token_usage.py")
