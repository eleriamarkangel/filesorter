# filesorter
An automated Windows-based file classification system using batch scripting and PowerShell.

Features
1. Drop Folder Monitoring

Monitors a configured dropbox folder (default: C:\filesorter\dropbox) for incoming files.

Processes all files automatically.

2. Filename Validation

Accepts only filenames with exactly 3 tokens separated by 2 underscores:

token1_token2_token3.ext

Rejects extra underscores or .log files.

Optionally quarantines invalid files.

3. Dynamic Folder Creation

Builds a 3-level folder hierarchy based on filename tokens and current date:

BASE
└── token1
    └── token1_token2
        └── token1_token2_YYYYMMDD_token3
4. Configurable File Movement

MOVE_FILES=1: files are moved into their target folders.

MOVE_FILES=0: only folder structure is created; files remain in dropbox.

5. Duplicate Handling

Automatically renames duplicates:

filename.ext → filename_DUP.ext → filename_DUP2.ext ...

Prevents overwriting existing files.

6. Logging

Creates a daily log file in BASE/logs:

filesorter_YYYYMMDD.log

Logs folder creation, file moves, skips, and errors with timestamps.

7. Error Handling

Gracefully handles:

Folder creation failures

Move failures

Invalid filenames

Errors logged without stopping the batch run.

8. Optional Quarantine

Non-matching files can be moved to:

DROPBOX\_unmatched

Isolates invalid files for manual review.

Happy Path Filename Convention
token1_token2_token3.ext

Exactly 3 tokens, 2 underscores.

Any extension except .log.

Example: documents_feature12345TestCases_20260101.docx

Example Folder Structure

Given documents_feature12345TestCases_20260101.docx:

C:\filesorter\autocreate
└── docs
    └── docs_savntDegreesJD
        └── documents_feature12345TestCases_20260101_20260314
            └── documents_feature12345TestCases_20260101.docx
Configuration
Variable	Description
DROPBOX	Input folder for incoming files
BASE	Root folder for organized output
MOVE_FILES	1 = move files, 0 = create folders only
QUARANTINE	Folder for unmatched files (optional)
LOGDIR	Folder for daily logs
Logging Example
2026-03-14T13:44:21 [DIR]  created: C:\filesorter\autocreate\docs
2026-03-14T13:44:22 [OK]   documents_feature12345TestCases_20260101.docx -> docs\docs_savntDegreesJD\documents_feature12345TestCases_20260101_20260314
2026-03-14T13:44:23 [MOVED] documents_feature12345TestCases_20260101.docx -> target folder
2026-03-14T13:44:24 [SKIP] example_invalid_file.txt (pattern != xxx_xxx_xxx)
Notes

Uses PowerShell for stable date formatting.

Fully idempotent: rerunning the script won’t break existing folders.

Easy to extend for additional filename patterns or custom folder logic.
