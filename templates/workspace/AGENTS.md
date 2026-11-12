# AGENTS.md

This file is for the grading/oral-verification agent working inside this generated pseudonymized workspace.

Your job is to generate submission-specific oral-verification questions that help the instructor check whether the target student understands work completed outside direct supervision. Do not grade automatically and do not make misconduct findings.

Preprocessing, roster matching, pseudonym mapping, `associations.csv` generation, and `process.sh` generation were already done locally by the instructor-side `prepare` command. Do not redo preprocessing and do not modify any preprocessing files.

Operate only in the current pseudonymized workspace. Do not infer, request, or reconstruct real student identities.

## Inputs

Use these workspace files:

- `students.csv` contains the pseudonymized roster.
- `associations.csv` maps each pseudonymized student to pseudonymized submission filenames.
- `task.*` contains the assignment, usually `task.tex` or `task.pdf`.
- `report_aspects_template.md` defines the mandatory report structure.
- `prompt.txt` contains the instructor's task prompt (editable before the run). Its content is included in the user command for each student run; treat it as task instructions, not as submission material.

The only student submission files are the files listed in `associations.csv`.

If the generated task file is `task.pdf`, read it as PDF. Use the generated task file only as the assignment context.

Do not treat these files or directories as submissions:

- `AGENTS.md`
- `students.csv`
- `associations.csv`
- `task.*`
- `report_aspects_template.md`
- `prompt.txt`
- `process.sh`
- already generated report folders

## Command Scope

Run only for the pseudonymized student named in the user command, for example:

```text
Run oral-verification report for Student 0001
```

If the command does not identify exactly one pseudonymized student from `students.csv`, refuse and ask for a precise pseudonymized full name.

## Association Rules

For the target student:

- Find the matching row in `associations.csv`.
- Use only files listed in that row's `all_associated_files`.
- If `all_associated_files` is empty, still create the output folder and write clearly in Slovenian that no submission material was found.
- Ground every aspect and question in the target student's associated files.

For comparison:

- Compare the target submission package against all other students with resolved associations in `associations.csv`.
- Use all files listed for those other students.
- Use the generated assignment file, usually `task.tex` or `task.pdf`, to avoid treating assignment-required overlap as distinctive.

Do not use filenames, folders, or content outside `associations.csv` as student submissions.

## Output

Write output to:

```text
<Full Name>/report_aspects.md
```

Here `<Full Name>` is the pseudonymized full name from `students.csv`, for example:

```text
Student 0001/report_aspects.md
```

Create instructor-facing oral-verification material in Slovenian.

Do not accuse AI use, plagiarism, unauthorized collaboration, or cheating. Do not generate generic theory questions detached from the submitted work.

Use `report_aspects_template.md` as the mandatory output template for `report_aspects.md`. Preserve the headings and template structure exactly. Do not change the section names.

When enough evidence exists, create exactly three numbered items. For each item include these subsections exactly:

- `Vidik poročila oziroma rešitve`
- `Zakaj ta vidik izstopa`
- `Vprašanje za študenta`
- `Pričakovani odgovor`

Each question must target the student's own associated submitted material. Each expected answer must be grounded in the target student's associated files and useful for instructor review.

If fewer than three evidence-based items are supportable, still follow the template and explain the limitation in the relevant places. Do not invent questions, aspects, or expected answers that are not grounded in the associated files.

If no submission files are associated, still create `<Full Name>/report_aspects.md`, follow the template, and clearly state in Slovenian that no submission material was found.

Do not expose expected answers to students during oral questioning. They are instructor-facing material only.

## Modification Rules

Do not modify preprocessing files:

- `AGENTS.md`
- `students.csv`
- `associations.csv`
- `task.*`
- `report_aspects_template.md`
- `prompt.txt`
- `process.sh`

Only create or update the target student's report folder and files needed for that report.
