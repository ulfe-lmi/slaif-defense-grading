# Quickstart

This workflow prepares oral-defense questions for submissions completed outside direct supervision.

This guide runs the full local workflow:

1. prepare a pseudonymized workspace;
2. run the later oral-verification agent;
3. finalize named private instructor outputs.

## Inputs Needed

Prepare these local files:

- Moodle/Canvas export ZIP, for example `moodle_export.zip`;
- real local roster CSV with at least name and surname data. Plain `name,surname,...` CSV works, and external system exports (for example Moodle) are also supported: UTF-8 (with or without BOM) or UTF-16, comma- or tab-separated, with an optional title row above the header. Recognized headers include `name`/`surname`, `Ime`/`Priimek`, the combined `Priimek, Ime` column, `E-mail`/`Email`, and `Vpisna številka`/`Student ID`/`ID number`;
- assignment file, for example `assignment.pdf` or `task.tex`.

Do not commit real rosters, submission ZIPs, generated workspaces, private mappings, or final outputs.

From the repository directory, create a local input folder inside `work/`:

```bash
mkdir -p work/input
```

Place the downloaded Moodle/Canvas export ZIP, your roster, and the assignment file in `work/input/`. For example, copy the downloaded export there, replacing the filename with the one you downloaded:

```bash
cp ~/Downloads/moodle_export.zip work/input/
```

Copy your roster and assignment file there as `students.csv` and `assignment.pdf`, or adjust the paths in the command below to match their actual locations and names. You create `work/input/`; the workflow creates the output directories when needed. The repository's `.gitignore` excludes `work/` from Git.

The example layout is:

```text
work/
  input/        # private input files
  lab-agent/    # generated pseudonymized agent workspace
  lab-private/  # private mapping and preprocessing outputs
  final/        # private named instructor outputs
```

Keep the input files, private mapping, and named outputs outside `lab-agent/`. You may also choose paths outside the repository; supply those paths explicitly in the commands.

## Install/Setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Prepare Pseudonymized Workspace

```bash
python3 slaif-defense-grading.py prepare \
  --input-file work/input/moodle_export.zip \
  --students-csv work/input/students.csv \
  --task-file work/input/assignment.pdf \
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
work/lab-agent/prompt.txt
work/lab-agent/report_aspects_template.md
work/lab-private/preprocessing_report.md
```

Edit `work/lab-agent/prompt.txt` if needed — for example, replace the `SUBJECT` placeholder with the real course subject. The script reads it at runtime, so this edit does not require re-running `prepare`.

`work/lab-agent/` should contain no real names, emails, student IDs, or original LMS folder names. The private report may contain real matching details and must remain local.

The workspace should contain the generated assignment file, usually `task.pdf` or `task.tex`, and `report_aspects_template.md`, which fixes the structure of every generated instructor report.

## Run Agent

```bash
cd work/lab-agent
./process.sh
cd -
```

`process.sh` runs one Codex command per pseudonymized student in roster order. It does not run Phase 1; `associations.csv` was generated locally by `prepare`.

The run writes `token_usage.csv` with per-student input and output tokens and a total. An `incomplete` total sums only available counts. Running the script again replaces that file.

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
