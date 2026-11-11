"""Run Codex and record its JSONL token usage in the pseudonymized workspace."""

import csv
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

USAGE_FILE = Path("token_usage.csv")
FIELDS = ("pseudonym", "input_tokens", "output_tokens", "status")


def write_rows(rows):
    complete = all(row["status"] == "completed" for row in rows)
    totals = {
        "pseudonym": "TOTAL",
        "input_tokens": sum(int(row["input_tokens"]) for row in rows if row["input_tokens"] != "") if any(row["input_tokens"] != "" for row in rows) else "",
        "output_tokens": sum(int(row["output_tokens"]) for row in rows if row["output_tokens"] != "") if any(row["output_tokens"] != "" for row in rows) else "",
        "status": "complete" if complete else "incomplete",
    }
    # Replace atomically so an interruption cannot leave a partially written CSV.
    with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", newline="", dir=".", delete=False) as handle:
        temporary = handle.name
        writer = csv.DictWriter(handle, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(rows)
        writer.writerow(totals)
    try:
        os.replace(temporary, USAGE_FILE)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def run_student(student, command):
    with USAGE_FILE.open(encoding="utf-8", newline="") as handle:
        rows = [row for row in csv.DictReader(handle) if row["pseudonym"] != "TOTAL"]
    row = next(row for row in rows if row["pseudonym"] == student)
    row["status"] = "running"
    write_rows(rows)
    usage_seen = False
    exit_code = 1
    try:
        with subprocess.Popen(command, stdout=subprocess.PIPE, text=True, encoding="utf-8", errors="replace") as process:
            for line in process.stdout:
                print(line, end="", flush=True)
                try:
                    event = json.loads(line)
                except json.JSONDecodeError:
                    # Codex may emit non-JSON output; it cannot contain a usage event.
                    continue
                if not isinstance(event, dict) or event.get("type") != "turn.completed":
                    continue
                usage = event.get("usage")
                if not isinstance(usage, dict):
                    continue
                input_tokens, output_tokens = usage.get("input_tokens"), usage.get("output_tokens")
                if type(input_tokens) is int and input_tokens >= 0 and type(output_tokens) is int and output_tokens >= 0:
                    row["input_tokens"] = str(input_tokens)
                    row["output_tokens"] = str(output_tokens)
                    usage_seen = True
                    write_rows(rows)
            exit_code = process.wait()
    finally:
        row["status"] = ("completed" if usage_seen else "usage_unavailable") if exit_code == 0 else "failed"
        write_rows(rows)
    return exit_code


if __name__ == "__main__":
    if sys.argv[1] == "init":
        write_rows([{"pseudonym": student, "input_tokens": "", "output_tokens": "", "status": "not_started"} for student in sys.argv[2:]])
    elif sys.argv[1] == "run":
        sys.exit(run_student(sys.argv[2], sys.argv[3:]))
    else:
        raise SystemExit("Unknown token usage command")
