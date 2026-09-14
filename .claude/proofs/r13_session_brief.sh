#!/bin/sh
# R13: the session brief reports project state at session start, and stays silent
# in repositories that keep no AEP state.
set -e
ROOT=$(git rev-parse --show-toplevel)
B="$ROOT/plugins/aep/scripts/session-brief.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
cd "$T"; git init -q -b main; echo x > a.txt
OUT=$(sh "$B"); [ -z "$OUT" ] || { echo "brief spoke in a repo with no AEP state: $OUT"; exit 1; }
mkdir .claude
printf '| ID | R | Status | Proof | Source |\n|--|--|--|--|--|\n| R1 | a | open | - | - |\n| R2 | b | done | t | - |\n| R3 | c | deferred 2026-01-01 - why | - | - |\n' > .claude/requirements.md
OUT=$(sh "$B")
printf '%s' "$OUT" | grep -q '"hookEventName":"SessionStart"' || { echo "wrong hook envelope: $OUT"; exit 1; }
printf '%s' "$OUT" | grep -q '1 done, 1 open, 1 deferred' || { echo "counts wrong: $OUT"; exit 1; }
printf '%s' "$OUT" | grep -q 'R1 (open)' || { echo "open row not named: $OUT"; exit 1; }
printf '%s' "$OUT" | python3 -c 'import json,sys; json.load(sys.stdin)' || { echo "not valid JSON"; exit 1; }
