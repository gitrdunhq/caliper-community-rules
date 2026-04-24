#!/usr/bin/env python3
"""Detect source files with identical or near-identical content.

This script hashes all source files in a directory tree and reports
groups of files that share the same content hash. Duplicate source
files are a maintenance hazard -- bugs fixed in one copy survive
in others, and readers cannot tell which copy is canonical.

Usage:
    python duplicate-source-files.py <directory> [--extensions .py,.js,.ts]

Output:
    JSON array of duplicate groups, each containing the hash and
    list of file paths that share it.
"""

import argparse
import hashlib
import json
import sys
from collections import defaultdict
from pathlib import Path

DEFAULT_EXTENSIONS = {
    ".py", ".js", ".ts", ".tsx", ".jsx", ".go", ".rs", ".java",
    ".rb", ".php", ".c", ".cpp", ".h", ".hpp", ".cs", ".swift",
    ".kt", ".scala", ".sh", ".bash", ".zsh",
}


def hash_file(path: Path) -> str:
    """Return SHA-256 hex digest of file contents, ignoring trailing whitespace."""
    hasher = hashlib.sha256()
    content = path.read_text(encoding="utf-8", errors="replace")
    # Normalize: strip trailing whitespace per line, single trailing newline
    normalized = "\n".join(line.rstrip() for line in content.splitlines()) + "\n"
    hasher.update(normalized.encode("utf-8"))
    return hasher.hexdigest()


def find_duplicates(
    root: Path, extensions: set[str], min_lines: int = 10
) -> list[dict]:
    """Find groups of files with identical normalized content."""
    hashes: dict[str, list[str]] = defaultdict(list)

    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if path.suffix not in extensions:
            continue
        # Skip hidden dirs and common vendor/build dirs
        parts = path.parts
        if any(p.startswith(".") or p in ("node_modules", "vendor", "__pycache__", "dist", "build") for p in parts):
            continue
        # Skip tiny files
        try:
            line_count = len(path.read_text(encoding="utf-8", errors="replace").splitlines())
        except (OSError, UnicodeDecodeError):
            continue
        if line_count < min_lines:
            continue

        try:
            file_hash = hash_file(path)
        except (OSError, UnicodeDecodeError):
            continue
        hashes[file_hash].append(str(path.relative_to(root)))

    # Only keep groups with 2+ files
    duplicates = []
    for file_hash, paths in sorted(hashes.items()):
        if len(paths) >= 2:
            duplicates.append({
                "hash": file_hash[:12],
                "count": len(paths),
                "files": sorted(paths),
            })

    return duplicates


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Detect duplicate source files by content hash"
    )
    parser.add_argument("directory", type=Path, help="Root directory to scan")
    parser.add_argument(
        "--extensions",
        type=str,
        default=None,
        help="Comma-separated file extensions (e.g. .py,.js,.ts)",
    )
    parser.add_argument(
        "--min-lines",
        type=int,
        default=10,
        help="Minimum line count to consider (default: 10)",
    )
    args = parser.parse_args()

    if not args.directory.is_dir():
        print(f"Error: {args.directory} is not a directory", file=sys.stderr)
        return 1

    extensions = DEFAULT_EXTENSIONS
    if args.extensions:
        extensions = {e.strip() if e.startswith(".") else f".{e.strip()}" for e in args.extensions.split(",")}

    duplicates = find_duplicates(args.directory, extensions, args.min_lines)

    if duplicates:
        print(json.dumps(duplicates, indent=2))
        print(f"\nFound {len(duplicates)} duplicate group(s)", file=sys.stderr)
        return 1
    else:
        print("No duplicate source files found.")
        return 0


if __name__ == "__main__":
    raise SystemExit(main())
