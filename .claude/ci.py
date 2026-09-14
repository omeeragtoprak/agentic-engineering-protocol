#!/usr/bin/env python3
"""Run every CI step from .github/workflows/ci.yml locally, in order.

The repository's check and its CI run the same commands, so "green locally" and
"green on GitHub" cannot drift apart silently. Two details keep that true:

  * steps run under `bash -e`, which is what GitHub Actions uses — without it a
    step whose last command succeeds passes even though an earlier one failed;
  * the workflow is parsed without PyYAML, so this gate has no dependency a
    fresh clone might not have. The parser is deliberately narrow: it reads the
    `- name:` / `run: |` shape this workflow uses and fails loudly if the file
    stops looking like that.
"""
import re
import subprocess
import sys

WORKFLOW = ".github/workflows/ci.yml"
SKIP = {"Claude plugin validate"}   # installs the CLI from npm; run before a release
MIN_STEPS = 6                       # a parser that silently finds nothing is not a check


def steps(path):
    out, name, body, indent = [], None, None, None
    for raw in open(path, encoding="utf-8").read().splitlines():
        m = re.match(r"^(\s*)- name:\s*(.+?)\s*$", raw)
        if m:
            if name and body is not None:
                out.append((name, "\n".join(body)))
            name, body, indent = m.group(2), None, None
            continue
        m = re.match(r"^(\s*)run:\s*\|\s*$", raw)
        if m and name:
            body, indent = [], None
            continue
        if body is not None:
            if not raw.strip():
                body.append("")
                continue
            lead = len(raw) - len(raw.lstrip())
            if indent is None:
                indent = lead
            if lead < indent:                      # dedent ends the block
                out.append((name, "\n".join(body)))
                name, body, indent = None, None, None
                continue
            body.append(raw[indent:])
    if name and body is not None:
        out.append((name, "\n".join(body)))
    return out


found = steps(WORKFLOW)
if len(found) < MIN_STEPS:
    sys.exit(f"{WORKFLOW}: parsed only {len(found)} run-steps (expected >= {MIN_STEPS}) — "
             f"the workflow shape changed; fix this parser rather than trusting it")

failed = []
for name, body in found:
    if name in SKIP:
        continue
    r = subprocess.run(["bash", "-e", "-c", body], capture_output=True, text=True)
    print(("ok   " if r.returncode == 0 else "FAIL ") + name)
    if r.returncode:
        failed.append(name)
        print(r.stdout[-2000:], r.stderr[-2000:])

sys.exit(1 if failed else 0)
