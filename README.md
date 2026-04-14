# lab-grading

`preprocess-labs.py` is a command-line utility for turning a **master ZIP of student submissions** into readable concatenated text files for grading and review.

It is designed for Moodle/Canvas-style exports where:

- You start with one or more ZIPs (the *master ZIP inputs*).
- Inside it there is typically **one folder per student**, e.g. `Name Surname_16712_assignsubmission_file/`.
- Inside each student folder there is usually either:
  - one or more nested submission ZIP files, or
  - submission subfolders that contain the submission files directly.

The tool extracts/reads submissions, finds readable source files, wraps them with clear delimiters, and builds either one combined output file or one output file per student.

---

## What files are included

The script includes only these suffixes (case-insensitive):

- `.txt`
- `.m` (MATLAB)
- `.py` (Python)
- `.c`, `.h`, `.cpp`, `.hpp` (C/C++)
- `.ipynb` (Jupyter notebook JSON)

Additional filtering is applied:

- Files that look binary are skipped, even if the suffix matches.
- Text is decoded as UTF-8 with replacement (`errors="replace"`) for robustness with mixed encodings.

PDF behavior:

- `.pdf` files are **not** concatenated into text output.
- In `--output-directory` mode, PDF files are copied verbatim next to each student's `.txt` output.
  - If there is one PDF for a student, it is named `<student_output_basename>.pdf`.
  - If there are multiple PDFs, they are named `<student_output_basename>-001.pdf`, `<student_output_basename>-002.pdf`, etc.

---

## Output format

Each included file is wrapped with BEGIN/END delimiters.

In final outputs, delimiter lines include:

1. Student name (inferred from the student folder name).
2. Submission name (ZIP base name or submission folder name).
3. Relative file path inside that submission.

Example:

```text
==== BEGIN Jane Doe | submission1 | src/main.py ====
... file content ...
==== END Jane Doe | submission1 | src/main.py ====
```

If a submission contains no readable text files, a placeholder block is emitted for that submission.

---

## How processing works

### 1) Extract master ZIP

The script creates a temporary working directory under `/tmp` and safely extracts each provided master ZIP there.

If multiple ZIPs are provided, they are merged in argument order and **later ZIPs win** for duplicate students (same inferred student name from folder prefix before the first underscore).

### 2) Discover submissions per student

For each top-level student folder:

- If nested ZIPs are found recursively, those ZIPs are used as submission sources.
- If no nested ZIPs are found, direct subfolders are treated as submission sources.
- If there are no subfolders but there are files directly in the student folder, the student folder itself is treated as a submission source.

### 3) Build per-submission partial outputs

For each submission source:

- ZIP sources are extracted to a temp location.
- Directory sources are read directly.
- Readable files are concatenated into a per-submission `.txt` artifact with delimiters.

### 4) Build final output(s)

Then the script writes either:

- a single global output file (`--output-file`), or
- one output file per student in an output directory (`--output-directory`).

When generating the final output, delimiter lines are augmented with student + submission metadata.

---

## Command line usage

```bash
python preprocess-labs.py \
  --input-file <MASTER1.zip> [<MASTER2.zip> ...] \
  (--output-file <OUTPUT.txt> | --output-directory <OUTPUT_DIR>) \
  [--similarity-check]
```

### Arguments

- `-i, --input-file` (**required**): one or more paths to master ZIP files. When multiple ZIPs are provided, later ZIPs replace earlier submissions for duplicate students.
- `-o, --output-file`: write one combined output file.
- `-d, --output-directory`: write one output file per student.
- `--similarity-check`: before writing a single output file, compare submissions and merge near-identical ones into one entry that lists all matched student names.

Notes:

- `--output-file` and `--output-directory` are mutually exclusive.
- One of them must be provided.
- Similarity grouping currently uses a threshold of `0.98`.

---

## Examples

### Example A: single combined output

```bash
python preprocess-labs.py \
  --input-file data/2025/CV/Vaja5.zip \
  --output-file data/2025/CV/outputs/vaja5.txt
```

### Example B: merge two exports, where the second overrides duplicates

```bash
python preprocess-labs.py \
  --input-file data/2025/CV/Vaja4.zip data/2025/CV/Vaja5.zip \
  --output-file data/2025/CV/outputs/merged_vaja.txt
```

### Example C: one output file per student

```bash
python preprocess-labs.py \
  --input-file data/2025/CV/Vaja5.zip \
  --output-directory data/2025/CV/outputs/vaja5
```

### Example D: combined output with similarity grouping

```bash
python preprocess-labs.py \
  --input-file data/2025/CV/Vaja5.zip \
  --output-file data/2025/CV/outputs/vaja5_grouped.txt \
  --similarity-check
```

### Help

```bash
python preprocess-labs.py --help
```

If run with no arguments, the script prints help and exits successfully.

---

## Temporary files and safety

- Temporary files are created under `/tmp/preprocesslabs_*`.
- Temporary directories are removed automatically on normal exit.
- ZIP extraction includes path traversal protection (Zip Slip guard).

---

## Files in this repo

- `preprocess-labs.py` — command-line preprocessing tool
- `README.md` — documentation
