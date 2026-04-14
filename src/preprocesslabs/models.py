from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path

READABLE_SUFFIXES = {".txt", ".m", ".py", ".c", ".h", ".cpp", ".hpp"}
READABLE_FILENAMES = {"makefile"}
SIMILARITY_THRESHOLD = 0.98

DELIM_RE = re.compile(r"^==== (BEGIN|END) (.+) ====$")


@dataclass(frozen=True)
class SubmissionArtifact:
    student_label: str
    student_folder: str
    submission_source: Path
    submission_name: str
    extracted_dir: Path
    partial_concat_path: Path
    source_kind: str
