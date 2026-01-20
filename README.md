# README.md

`preprocesslabs.py` is a small command‑line utility for turning a **"master" ZIP of student submissions** into a **single, readable, concatenated text file**.

It is designed for the common Moodle/Canvas download format where:

- You start with one ZIP (the *master* ZIP).
- Inside it there is typically **one folder per student**, e.g.
  `Name Surname_16712_assignsubmission_file/`
- Inside each student folder there is usually **another ZIP file** (the student's submission ZIP),
  or a **submission subfolder** that contains the same files that would have been in the ZIP.
- Inside each submission ZIP or submission folder there can be multiple files and folders.

The tool extracts each submission ZIP to a temporary directory under `/tmp` (or reads submission
folders directly), finds readable files, concatenates them with clear delimiters, and finally
creates **one big output file** for all students (or one output file per student if you use the
output directory option).

---

## What files are included

Only these file types are concatenated:

- `.txt`
- `.m` (MATLAB)
- `.py` (Python)

File suffix matching is case‑insensitive (e.g. `.PY` is included).

---

## Output format

Each included file is wrapped with a clear BEGIN/END delimiter.

In the **final output file** (or per-student files), delimiter lines are augmented with:

1. The student's name (inferred from the top‑level folder name in the master ZIP, e.g. `Name Surname_...` → `Name Surname`).
2. The submission name (ZIP base name or submission folder name).
3. The relative file path inside the submission ZIP or folder.

Example delimiter lines:

```

\==== BEGIN Name Surname | submission\_name | path/to/file.py ====  
... file content ...  
\==== END Name Surname | submission\_name | path/to/file.py ====

````

---

## How it works internally

### Step 1 — Extract the master ZIP

The script creates a temporary working directory under `/tmp` and extracts the master ZIP there.

### Step 2 — Find nested submission ZIPs

It recursively searches inside the extracted master ZIP contents for any files ending in `.zip`.

Each nested ZIP is treated as a *submission ZIP*. If a student folder contains no ZIPs, each
submission subfolder is treated like a submission ZIP would have been.

### Step 3 — Extract each submission ZIP and create a partial concatenation file

For each submission ZIP or submission folder:

1. ZIPs are extracted under `/tmp` (inside the temporary working directory); folders are read in place.
2. The extracted contents are searched recursively for files ending in `.txt`, `.m`, or `.py`.
3. All found readable files are concatenated into a single text file (the **partial concatenation**), named after the submission ZIP:
   - `submission.zip` → `submission.txt`

The partial files are saved in the temporary working directory while the script runs.

### Step 4 — Create the final output

Finally, the script either:

- Concatenates all partial `.txt` files into the single output file you specify with `--output-file`.
- Writes one concatenated `.txt` file per student into the directory you specify with `--output-directory`.

While copying each partial file into the big output, it detects delimiter lines and rewrites them to include:

- Student name
- Submission name (ZIP base name or folder name)

---

## Temporary files

All extraction and partial files are created in a temporary directory under `/tmp`, for example:

- `/tmp/preprocesslabs_xxxxxxxx/outer_extracted/...`
- `/tmp/preprocesslabs_xxxxxxxx/unzipped_submissions/...`

By default, the temporary directory is removed automatically when the script exits.

---

## Usage

### Basic

```bash
python preprocesslabs.py --input-file <MASTER.zip> --output-file <OUTPUT.txt>
````

### Per-student outputs

```bash
python preprocesslabs.py --input-file <MASTER.zip> --output-directory <OUTPUT_DIR>
````

Example:

```bash
python preprocesslabs.py -i submissions.zip -o all_submissions.txt
```

### Help

```bash
python preprocesslabs.py --help
```

If you run the script with **no arguments**, it prints the help text.

* * *

Notes and limitations
---------------------

*   The script decodes text as UTF‑8 with replacement for invalid bytes. This avoids crashes on mixed encodings.
*   Extraction is done with a **path traversal safeguard** (ZIP slip protection) to prevent malicious ZIP entries writing outside the intended `/tmp` directory.
*   Nested ZIPs found inside the master ZIP are treated as "submission ZIPs". If a student folder does not
    contain ZIPs, its submission subfolders are used instead. If neither ZIPs nor submission subfolders are
    found, the script will exit with an error.

* * *

Files
-----

*   `preprocess-labs.py` — the command-line tool
*   `README.md` — this documentation
