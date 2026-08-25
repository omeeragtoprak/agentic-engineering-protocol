#!/usr/bin/env python3
"""Project lint: the rules CI enforces on every merge.

- max line length 88 (the repo's formatter setting)
- no broad `except Exception` / bare `except` without a re-raise
"""
import pathlib
import re
import sys

MAX_LEN = 88
findings = []

for path in sorted(pathlib.Path(".").glob("*.py")):
    if path.name == "lint.py":
        continue
    for n, line in enumerate(path.read_text().splitlines(), 1):
        if len(line) > MAX_LEN:
            findings.append(f"{path}:{n}: line too long ({len(line)} > {MAX_LEN})")
        if re.match(r"\s*except\s*(Exception\s*)?:", line):
            findings.append(f"{path}:{n}: broad except - catch a specific type")

for f in findings:
    print(f)
print(f"{len(findings)} lint finding(s)")
sys.exit(1 if findings else 0)
