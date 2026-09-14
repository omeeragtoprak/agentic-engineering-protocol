#!/bin/sh
# R5: a done requirement whose proof has left the tree fails the check.
set -e
ROOT=$(git rev-parse --show-toplevel)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir -p "$T/.claude"; cp "$ROOT/plugins/aep/templates/trace.py.example" "$T/.claude/trace.py"
cd "$T"
printf '| ID | R | Status | Proof | Source |\n|--|--|--|--|--|\n| R1 | A | done | proof_that_left_the_tree | - |\n' > .claude/requirements.md
set +e; python3 .claude/trace.py >/dev/null 2>&1; RC=$?; set -e
[ "$RC" -eq 1 ] || { echo "stale proof did not fail (exit $RC)"; exit 1; }
echo "def proof_that_left_the_tree(): pass" > kept.py
python3 .claude/trace.py >/dev/null 2>&1 || { echo "present proof failed"; exit 1; }
