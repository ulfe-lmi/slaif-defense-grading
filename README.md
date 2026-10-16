<div style="text-align: center;">
  <a href="https://www.slaif.si">
    <img src="docs/assets/slaif-logo.svg" width="400" height="400">
  </a>
</div>

# SLAIF Defense Grading

A local-first workflow for preparing oral-defense questions for student work completed outside direct supervision.

The tool prepares a pseudonymized workspace for an AI coding agent, runs no grading decisions itself, and then maps the agent's pseudonymized reports back to private instructor-facing outputs.

It is designed for instructors who need targeted questions about submitted code, reports, notebooks, graphs, parameters, explanations, or other artifacts. This can support ordinary oral defenses as well as cases where the instructor needs to probe possible plagiarism, unauthorized collaboration, or improper AI-tool use.

The tool does not automatically prove misconduct. It helps prepare concrete, submission-specific questions so the instructor can verify whether the student understands the work they submitted.

For a complete step-by-step run, see [QUICKSTART.md](QUICKSTART.md).

## What Problem This Solves

Many lab assignments are completed outside direct supervision. Written submissions alone do not always show whether a student understands the work they submitted, and generic oral-defense questions are weak because they are not tied to the actual artifacts.

This workflow creates targeted oral-verification questions from the submitted material. It can help reveal cases where a student cannot explain their own code, report, notebook, graph, parameter choices, or conclusions. That signal may be relevant to plagiarism, unauthorized collaboration, or improper AI-tool use, but it is not automatic proof. Final judgment remains a human instructor decision.

## Current Workflow

The supported workflow is:

1. `prepare`: run local preprocessing and create a pseudonymized agent workspace.
2. Run `process.sh`: ask the agent to generate one pseudonymized oral-verification report per student.
3. `finalize`: locally map pseudonymized reports back to private named instructor outputs.

Prepare the pseudonymized workspace:

```bash
python3 slaif-defense-grading.py prepare \
  --input-file moodle_export.zip \
  --students-csv students.csv \
  --task-file assignment.pdf \
  --workspace workspace/lab-agent \
  --private-output workspace/lab-private
```

Multiple ZIP exports are supported with one `--input-file` argument followed by one or more ZIP paths:

```bash
python3 slaif-defense-grading.py prepare \
  --input-file export1.zip export2.zip \
  --students-csv students.csv \
  --task-file assignment.pdf \
  --workspace workspace/lab-agent \
  --private-output workspace/lab-private
```

`prepare` currently:

- reads the private real `students.csv` locally;
- assigns deterministic pseudonyms in CSV order, such as `Student 0001`;
- processes Moodle/Canvas-style ZIP exports with safe ZIP extraction;
- creates a pseudonymized agent workspace;
- writes private `pseudonym_map.csv` outside the workspace;
- writes private `preprocessing_report.md` outside the workspace;
- copies the assignment into the workspace with a canonical `task.*` filename, such as `task.tex` or `task.pdf`;
- generates pseudonymized `students.csv`;
- generates pseudonymized `associations.csv`;
- copies `templates/workspace/AGENTS.md` into the workspace as `AGENTS.md`;
- copies `templates/workspace/report_aspects_template.md` into the workspace;
- renders executable `process.sh`;
- writes pseudonymized student-output copies for instructor/student review;
- writes private `student_outputs_index.csv`;
- excludes opaque documents by default.

Later ZIPs override earlier submissions for duplicate LMS student folders.

## Generated Outputs

Agent-facing workspace:

```text
lab-agent/
  AGENTS.md
  Student_0001.txt
  Student_0002.txt
  associations.csv
  process.sh
  report_aspects_template.md
  students.csv
  task.pdf
```

Private instructor-only output:

```text
lab-private/
  preprocessing_report.md
  pseudonym_map.csv
  student_outputs/
    Student_0001.txt
    Student_0002.txt
  student_outputs_index.csv
```

The workspace `students.csv` contains only pseudonym data:

```csv
name,surname,full_name
Student,0001,Student 0001
Student,0002,Student 0002
```

`associations.csv` is generated locally by `prepare`. It maps each pseudonymized student to pseudonymized workspace filenames and never contains real names, emails, student IDs, or original LMS folder names.

The instructor assignment file is copied under a canonical non-private workspace name. For example, `assignment.pdf` becomes `task.pdf`, `task.tex` remains `task.tex`, and other suffixes become `task<suffix>`. The original assignment basename is not preserved.

`report_aspects_template.md` defines the mandatory structure for every generated `report_aspects.md`. The generated workspace `AGENTS.md` instructs the later grading agent to follow this template and preserve its headings.

`student_outputs/` contains pseudonymized copies of the same concatenated `Student_XXXX.txt` files that the agent sees. These files are intended as per-student review material that an instructor can retrieve and show individually. The private `student_outputs_index.csv` and `pseudonym_map.csv` identify which file belongs to which real student and must not be shared wholesale with students.

## Running The Agent Workflow

### What To Inspect Before Running The Agent

Before running `process.sh`, inspect:

- `workspace/lab-agent/` and confirm generated filenames are pseudonymized;
- `workspace/lab-agent/students.csv` and `workspace/lab-agent/associations.csv`;
- `workspace/lab-agent/report_aspects_template.md`;
- `workspace/lab-private/preprocessing_report.md`.

The agent-facing workspace should contain no real names, emails, student IDs, or original LMS folder names. The private report may contain real matching details and must remain local.

After `prepare` completes, run the generated script from inside the pseudonymized workspace:

```bash
cd workspace/lab-agent
./process.sh
```

`process.sh` runs one Codex command per pseudonymized student in roster order:

```bash
codex --ask-for-approval never --full-auto exec --skip-git-repo-check "Run oral-verification report for Student 0001"
```

There is no agent-run Phase 1. Association generation is local preprocessing and is already complete before `process.sh` runs.

## Finalize Named Local Outputs

After the agent writes reports such as `Student 0001/report_aspects.md`, run:

```bash
python3 slaif-defense-grading.py finalize \
  --workspace workspace/lab-agent \
  --private-output workspace/lab-private \
  --output workspace/final
```

Final output is private/local and may contain real student identities:

```text
final/
  final_index.csv
  finalize_report.md
  missing_reports.csv
  instructor_reports/
    Mila_Kranjc/
      report_aspects.md
  student_outputs/
    Mila_Kranjc.txt
```

`finalize` maps pseudonymized reports and student-output text files back to real roster rows using the private maps. It does not modify the pseudonymized workspace. Use `--strict` if missing agent reports should make finalization fail.

## What Can Be Shown To Students

`final/student_outputs/<Name>.txt` is the pseudonymized concatenated submission text that the agent saw. It may be shown individually to the corresponding student when useful for review.

`final/instructor_reports/<Name>/report_aspects.md` is instructor-facing. It contains expected answers and should not be sent wholesale to students.

Do not share `pseudonym_map.csv`, `student_outputs_index.csv`, or `final_index.csv` wholesale with students.

## AGENTS.md Roles

There are two different `AGENTS.md` files:

- Root `AGENTS.md` is for coding agents modifying this repository.
- Generated workspace `AGENTS.md` is copied from `templates/workspace/AGENTS.md` and is for the later oral-verification/grading agent inside the pseudonymized workspace.

Preprocessing is not an agent task. The later agent should use `students.csv`, `associations.csv`, and the generated assignment file (`task.tex`, `task.pdf`, or another `task.*`), and should treat only files listed in `associations.csv` as student submissions.

There is no `.slaif_prompts/` directory.

## Privacy Model

The default workspace is pseudonymized text-only material.

- Real student identities may be used only during local preprocessing.
- The real input roster is never copied into the agent workspace.
- The private pseudonym map stays outside the workspace.
- Unmatched LMS folders are not copied into the workspace and appear only in the private report.
- Generated filenames, CSVs, shell scripts, `AGENTS.md`, and text/source/notebook files are leak-checked for known roster identifiers.
- `report_aspects_template.md` is copied into the workspace and included in the same text leak-check boundary.
- Known full names, emails, and `student_id` values are scrubbed from generated text outputs before the workspace leak check runs.
- Private `student_outputs/` files are pseudonymized copies of the generated agent input text files and must not contain real names, emails, student IDs, or LMS folder names.

Matching is conservative. LMS folders are matched to roster rows by exact normalized `name surname` from the folder prefix before the first Moodle underscore:

```text
Ana Novak_12345_assignsubmission_file -> Ana Novak
```

## Opaque Documents

Opaque document files are excluded by default:

```text
.pdf
.docx
.doc
.odt
.rtf
```

They are excluded because this lightweight tool does not redact internal document content or metadata. Their existence is recorded in `private-output/preprocessing_report.md`.

This default exclusion applies to student-submitted opaque documents. The instructor-provided assignment may still be a PDF and is copied as `task.pdf`.

To explicitly include opaque documents under pseudonymized filenames:

```bash
python3 slaif-defense-grading.py prepare \
  --input-file moodle_export.zip \
  --students-csv students.csv \
  --task-file assignment.pdf \
  --workspace workspace/lab-agent \
  --private-output workspace/lab-private \
  --include-opaque-documents
```

This weakens the privacy guarantee. Copied opaque document filenames are pseudonymized, but PDF/DOCX/etc. internal content and metadata are not inspected or redacted.

## Testing And Audit Coverage

Tests use only synthetic data.

The end-to-end messy fixture covers:

- 5-student roster;
- nested ZIP submission;
- direct-folder submission;
- missing roster students;
- unmatched LMS folder;
- notebook JSON treated as text;
- Markdown, TeX, and source files;
- weird/non-ASCII filename;
- fake real identifiers requiring scrubbing;
- default-excluded opaque PDF;
- opt-in opaque document behavior.

Run tests with:

```bash
pytest
```

## Repository Structure

```text
README.md
AGENTS.md
QUICKSTART.md
requirements.txt
slaif-defense-grading.py

slaif_defense_grading/
  __init__.py
  cli.py
  core.py
  finalize.py
  io_utils.py
  models.py
  prepare.py
  process_script.py

templates/
  process.sh.tpl
  workspace/
    AGENTS.md
    report_aspects_template.md

tests/
```

Install the minimal dependency set:

```bash
pip install -r requirements.txt
```

## Maintainer

Janez Perš  
Faculty of Electrical Engineering, University of Ljubljana  
Laboratory for Machine Intelligence (LMI)  
Email: janez.pers@fe.uni-lj.si  

- Profile: https://lmi.fe.uni-lj.si/en/janez-pers-2/
- Laboratory: https://lmi.fe.uni-lj.si/en

## Security Contact

For responsible disclosure of vulnerabilities, please contact:  
janez.pers@fe.uni-lj.si

## Acknowledgement

We acknowledge the support of the EC/EuroHPC JU and the Slovenian Ministry of HESI via the project SLAIF (grant number 101254461).

Project website: https://www.slaif.si
