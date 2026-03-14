# AutoFileSorter

Automated Windows-based file classification and organization system using Batch + PowerShell.

---

## Overview

AutoFileSorter processes files dropped into a designated folder, validates filenames against a strict pattern, dynamically creates a hierarchical folder structure, handles duplicates safely, and logs all operations. Non-matching files can optionally be quarantined.

---

## Features

### 1. Drop Folder Monitoring
- Monitors a configured dropbox folder (default: `C:\filesorter\dropbox`) for incoming files.
- Processes all files automatically.

### 2. Filename Validation
- Accepts only filenames with exactly **3 tokens** separated by **2 underscores**:
token1_token2_token3.ext
BASE
--└── token1
--└── token1_token2
--└── token1_token2_YYYYMMDD_token3
- Rejects extra underscores or `.log` files.
- Optionally quarantines invalid files.

### 3. Dynamic Folder Creation
- Builds a **3-level folder hierarchy** based on filename tokens and current date:

### 4. Configurable File Movement
- `MOVE_FILES=1` → files are moved into their target folders.
- `MOVE_FILES=0` → only folder structure is created; files remain in dropbox.

### 5. Duplicate Handling
- Automatically renames duplicates:
filename.ext → filename_DUP.ext → filename_DUP2.ext ...
- Prevents overwriting existing files.

### 6. Logging
- Creates a **daily log file** in `BASE/logs`:
- Logs folder creation, file moves, skips, and errors with timestamps.

### 7. Error Handling
- Handles:
  - Folder creation failures
  - Move failures
  - Invalid filenames
- Errors are logged without stopping the batch run.

### 8. Optional Quarantine
- Non-matching files can be moved to:
- DROPBOX_unmatched

- Isolates invalid files for manual review.
---
## Happy Path Filename Convention

## Example Folder Structure
Given `docs_fix12345TestCase_20260314.docx`:
C:\filesorter\autocreate
└── docs
└── docs_fix12345TestCase
└── docs_fix12345TestCase_20260314
└── docs_fix12345TestCase_20260314_20260314.docx


---

## Configuration

| Variable       | Description |
|----------------|-------------|
| `DROPBOX`      | Input folder for incoming files |
| `BASE`         | Root folder for organized output |
| `MOVE_FILES`   | `1` = move files, `0` = create folders only |
| `QUARANTINE`   | Folder for unmatched files (optional) |
| `LOGDIR`       | Folder for daily logs |

---

## Logging Example
2026-03-14T15:50:16 "============================================================"
2026-03-14T15:50:16 "START | dropbox=C:\filesorter\dropbox | move_files=1 | date=20260314"
2026-03-14T15:50:16 "============================================================"
2026-03-14T15:50:17 "[DIR] created: C:\filesorter\autocreate\docs"
2026-03-14T15:50:17 "[DIR] created: C:\filesorter\autocreate\docs\docs_fix12345TestCase"
2026-03-14T15:50:17 "[DIR] created: C:\filesorter\autocreate\docs\docs_fix12345TestCase\docs_fix12345TestCase_20260314_20260314"
2026-03-14T15:50:17 "[OK] docs_fix12345TestCase_20260314.docx -> docs\docs_fix12345TestCase\docs_fix12345TestCase_20260314_20260314"
2026-03-14T15:50:17 "[MOVE] docs_fix12345TestCase_20260314.docx -> C:\filesorter\autocreate\docs\docs_fix12345TestCase\docs_fix12345TestCase_20260314_20260314\docs_fix12345TestCase_20260314.docx"
2026-03-14T15:50:17 "[MOVED] docs_fix12345TestCase_20260314.docx -> C:\filesorter\autocreate\docs\docs_fix12345TestCase\docs_fix12345TestCase_20260314_20260314\docs_fix12345TestCase_20260314.docx"
2026-03-14T15:50:18 "============================================================"
2026-03-14T15:50:18 "END"
2026-03-14T15:50:18 "============================================================"
