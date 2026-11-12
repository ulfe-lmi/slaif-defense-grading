#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

# The editable task prompt is read at runtime so the instructor can adjust
# prompt.txt (e.g. replace the SUBJECT placeholder) before running this script.
test -f prompt.txt || { echo "ERROR: prompt.txt is missing in the workspace" >&2; exit 1; }

# PHASE2_COMMANDS
