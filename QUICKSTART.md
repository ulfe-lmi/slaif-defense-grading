# Quickstart

This workflow prepares oral-defense questions for submissions completed outside direct supervision.

This guide runs the full local workflow:

1. prepare a pseudonymized workspace;
2. run the later oral-verification agent;
3. finalize named private instructor outputs.

## Inputs Needed

Prepare these local files:

- Moodle/Canvas export ZIP, for example `moodle_export.zip`;
- real local `students.csv` with at least `name,surname`;
- assignment file, for example `assignment.pdf` or `task.tex`.

Do not commit real rosters, submission ZIPs, generated workspaces, private mappings, or final outputs.

## Install/Setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Prepare Pseudonymized Workspace

```bash
python3 slaif-defense-grading.py prepare \
  --input-file moodle_export.zip \
  --students-csv students.csv \
  --task-file assignment.pdf \
  --workspace work/lab-agent \
  --private-output work/lab-private
```

The assignment is copied into the workspace under a canonical name such as `task.pdf` or `task.tex`; the original basename is not preserved.

Default mode excludes opaque documents such as PDF/DOCX/DOC/ODT/RTF because their internal content and metadata are not redacted.

`--include-opaque-documents` exists, but it weakens privacy. It copies opaque documents under pseudonymized filenames only; internal document content and metadata may still contain real identifiers.

## Inspect Before Running Agent

Inspect:

```text
work/lab-agent/
work/lab-agent/report_aspects_template.md
work/lab-private/preprocessing_report.md
```

`work/lab-agent/` should contain no real names, emails, student IDs, or original LMS folder names. The private report may contain real matching details and must remain local.

The workspace should contain the generated assignment file, usually `task.pdf` or `task.tex`, and `report_aspects_template.md`, which fixes the structure of every generated instructor report.

## Run Agent

```bash
cd work/lab-agent
./process.sh
cd -
```

`process.sh` runs one Codex command per pseudonymized student in roster order. It does not run Phase 1; `associations.csv` was generated locally by `prepare`.

Before `prepare`, edit `codex.conf` in the project to change the default model (`gpt-6-astra`), reasoning effort (`xhigh`), or context window (1,000,000 tokens). These settings are embedded in the generated commands, so changes require preparing a new workspace.

## Finalize Named Local Outputs

After the agent creates reports such as `Student 0001/report_aspects.md`, run:

```bash
python3 slaif-defense-grading.py finalize \
  --workspace work/lab-agent \
  --private-output work/lab-private \
  --output work/final
```

Use strict mode when every report is expected:

```bash
python3 slaif-defense-grading.py finalize \
  --workspace work/lab-agent \
  --private-output work/lab-private \
  --output work/final \
  --strict
```

## Inspect Final Outputs

Expected shape:

```text
work/final/
  final_index.csv
  finalize_report.md
  missing_reports.csv
  instructor_reports/
    Mila_Kranjc/
      report_aspects.md
  student_outputs/
    Mila_Kranjc.txt
```

`work/final/` is private/local and may contain real student identities.

## What To Share With Students

`student_outputs/<Name>.txt` is the concatenated pseudonymized submission text that the agent saw. It can be shown individually to the corresponding student if appropriate.

`instructor_reports/<Name>/report_aspects.md` is instructor-facing and includes expected answers. Do not send it wholesale to students.

Do not share `pseudonym_map.csv`, `student_outputs_index.csv`, or `final_index.csv` wholesale with students.

## Troubleshooting

- Missing reports after agent run: check `work/final/missing_reports.csv` and rerun `./process.sh` or the specific missing student command in `work/lab-agent`.
- Unmatched LMS folders: inspect `work/lab-private/preprocessing_report.md`; unmatched folders are intentionally not copied into the agent workspace.
- Missing submissions: students with no matched submission are marked `unresolved` in `associations.csv`.
- Real identifiers detected in workspace: `prepare` fails before completion; inspect the error and source data locally.
- Permission issue on `process.sh`: run `chmod +x work/lab-agent/process.sh`.
