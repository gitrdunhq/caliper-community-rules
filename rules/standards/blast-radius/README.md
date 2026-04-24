# Blast Radius Scripts

Scripts for dependency graph analysis and duplication detection.

## duplicate-source-files.py

Detects source files with identical or near-identical content by comparing
normalized SHA-256 hashes. Duplicate source files are a maintenance hazard --
bugs fixed in one copy survive in others.

### Usage

```bash
python duplicate-source-files.py /path/to/project
python duplicate-source-files.py /path/to/project --extensions .py,.js
python duplicate-source-files.py /path/to/project --min-lines 20
```

### Output

JSON array of duplicate groups:

```json
[
  {
    "hash": "a1b2c3d4e5f6",
    "count": 2,
    "files": ["src/utils.py", "lib/utils_copy.py"]
  }
]
```

Exit code 1 if duplicates found, 0 if clean.
