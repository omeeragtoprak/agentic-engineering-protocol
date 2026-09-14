#!/usr/bin/env python3
"""Requirements traceability checker — template.

Copy to `.claude/trace.py` and chain it into `.claude/aep-check.sh`:

    #!/bin/sh
    make test && python3 .claude/trace.py

It reads `.claude/requirements.md` — a plain Markdown table, one row per
requirement — and fails when the ledger and the repository disagree:

  * a `done` row whose proof no longer exists  (the ledger went stale)
  * a `done` row with no proof, including an empty `cmd:`
  * a `deferred` row whose status cell lacks a date or a reason
  * a duplicate ID, an unknown status, a missing source spec, a malformed row
  * a `cmd:` proof that does not exit 0

A ledger that cannot fail is decoration; this one fails when it stops being true.

Trust note: a `cmd:` proof is executed with the shell, so the ledger is trusted
input at the same level as `.claude/aep-check.sh` itself. If this runs in CI on
pull requests from outside contributors, set `AEP_TRACE_NO_CMD=1` there — command
proofs are then skipped and **named in the output as unverified** rather than
silently counted as passing.

A `|` inside a cell must be escaped as `\\|`. Long shell pipelines belong in a
small script (`cmd: .claude/proofs/r4_versions.sh`), which is more readable in the
table and testable on its own.
"""
import os
import re
import subprocess
import sys

LEDGER = os.environ.get("AEP_LEDGER", ".claude/requirements.md")
STATUSES = {"open", "done", "deferred", "dropped"}
NO_CMD = os.environ.get("AEP_TRACE_NO_CMD") == "1"
NONE = ("", "-", "—")

# Code and executable config only. Markdown is deliberately excluded: a proof
# that "exists" because it is mentioned in a document proves nothing.
SEARCH_EXT = (".py", ".js", ".ts", ".tsx", ".jsx", ".go", ".rs", ".rb", ".java",
              ".cs", ".kt", ".swift", ".php", ".sh", ".sql", ".feature",
              ".yml", ".yaml")
SKIP_DIRS = {".git", "node_modules", "__pycache__", ".venv", "venv", "dist",
             "build", "target", ".mypy_cache", ".pytest_cache"}

ROW = re.compile(r"^\|(?P<cells>.+)\|\s*$")
CELL_SPLIT = re.compile(r"(?<!\\)\|")
SEPARATOR = re.compile(r"^:?-{2,}:?$")
# A deferral is auditable only if the STATUS cell itself carries both a date and
# a reason. Reading the reason out of the requirement text would accept every
# deferral ever written, because every row has requirement text.
DEFERRED_OK = re.compile(r"^deferred\b[^0-9]*\b(\d{4}-\d{2}-\d{2})\b\s*[-—:,]?\s*(\S.*\S)")


def parse_rows(text):
    """Return (rows, problems). A row that is not 5 cells is a problem, not noise."""
    rows, problems = [], []
    for n, line in enumerate(text.splitlines(), 1):
        m = ROW.match(line.strip())
        if not m:
            continue
        cells = [c.strip().replace("\\|", "|") for c in CELL_SPLIT.split(m.group("cells"))]
        if cells and cells[0].lower() == "id":
            continue                                   # header
        if cells and all(SEPARATOR.match(c) for c in cells if c):
            continue                                   # ---|---|--- separator
        if len(cells) != 5:
            problems.append(f"{LEDGER}:{n} malformed row: {len(cells)} cell(s), "
                            f"expected 5 (escape any | inside a cell as \\|)")
            continue
        rows.append({"line": n, "id": cells[0], "text": cells[1],
                     "status": cells[2].lower(), "proof": cells[3], "source": cells[4]})
    return rows, problems


def corpus():
    """Every searchable file except this script.

    The checker's own source is excluded on purpose: a proof must not be
    satisfied by the fact that this file happens to mention it — found when a
    test scenario passed because the docstring above names a proof string.
    """
    me = os.path.realpath(__file__)
    out = []
    for root, dirs, files in os.walk("."):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        for f in files:
            if f.endswith(SEARCH_EXT) and os.path.realpath(os.path.join(root, f)) != me:
                out.append(os.path.join(root, f))
    return out


def resolve_proofs(proofs, files):
    """Locate every symbol proof in one pass over the corpus, not one pass each.

    Matching is word-bounded, not a naked substring: a proof named `TAMPER` must
    not be satisfied by a variable someone renamed to `TAMPERED`. A rename is
    exactly the decay this checker exists to notice.
    """
    pending = {p: re.compile(r"(?<!\w)" + re.escape(p) + r"(?!\w)") for p in proofs}
    found = set()
    for path in files:
        if not pending:
            break
        try:
            text = open(path, encoding="utf-8", errors="replace").read()
        except OSError:
            continue
        for proof, pattern in list(pending.items()):
            if pattern.search(text):
                found.add(proof)
                del pending[proof]
    return found


def main():
    if not os.path.isfile(LEDGER):
        print(f"FAIL no requirements ledger at {LEDGER}")
        return 1

    rows, problems = parse_rows(open(LEDGER, encoding="utf-8").read())
    if not rows and not problems:
        print(f"FAIL {LEDGER} has no requirement rows")
        return 1

    symbols = [r["proof"].strip("`") for r in rows
               if r["status"].split()[:1] == ["done"]
               and not r["proof"].strip("`").startswith("cmd:")
               and r["proof"].strip("`") not in NONE]
    found = resolve_proofs(symbols, corpus()) if symbols else set()

    unverified = []
    seen = {}

    for r in rows:
        where = f"{LEDGER}:{r['line']} [{r['id']}]"

        if r["id"] in seen:
            problems.append(f"{where} duplicate ID (also line {seen[r['id']]})")
        seen[r["id"]] = r["line"]

        status = r["status"].split()[0] if r["status"] else ""
        if status not in STATUSES:
            problems.append(f"{where} unknown status {r['status']!r} "
                            f"(expected one of: {', '.join(sorted(STATUSES))})")
            continue

        src = r["source"].strip("`").split("#")[0].strip()
        if src and src not in NONE and not os.path.exists(src):
            problems.append(f"{where} source not found: {src}")

        if status == "done":
            proof = r["proof"].strip("`").strip()
            if proof in NONE:
                problems.append(f"{where} done without a proof")
            elif proof.startswith("cmd:"):
                cmd = proof[4:].strip()
                if not cmd:
                    problems.append(f"{where} done without a proof (empty cmd:)")
                elif NO_CMD:
                    unverified.append(f"{where} command proof not executed: {cmd}")
                else:
                    try:
                        rc = subprocess.run(cmd, shell=True, capture_output=True,
                                            timeout=300).returncode
                    except subprocess.TimeoutExpired:
                        rc = -1
                    if rc != 0:
                        problems.append(f"{where} proof command failed (exit {rc}): {cmd}")
            elif proof not in found:
                problems.append(f"{where} proof no longer exists in the codebase: "
                                f"{proof} — the ledger has gone stale")

        if status == "deferred" and not DEFERRED_OK.match(r["status"]):
            problems.append(f"{where} deferred without a date and a reason in the "
                            f"status cell (expected: deferred YYYY-MM-DD — why)")

    counts = {}
    for r in rows:
        counts[r["status"].split()[0]] = counts.get(r["status"].split()[0], 0) + 1
    summary = " · ".join(f"{k}: {v}" for k, v in sorted(counts.items()))

    for p in problems:
        print("FAIL " + p)
    for u in unverified:
        print("UNVERIFIED " + u)
    print(f"{len(rows)} requirement(s) — {summary}")
    if unverified:
        print(f"{len(unverified)} command proof(s) NOT executed (AEP_TRACE_NO_CMD=1) "
              f"— those rows are unproven, not passing")
    if problems:
        print(f"{len(problems)} traceability problem(s)")
        return 1
    print("traceability OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
