#!/bin/sh
# R1: the Stop hook blocks completion while the project's check fails, and allows
# it when the check passes.
set -e
ROOT=$(git rev-parse --show-toplevel)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
cp "$ROOT/plugins/aep/scripts/verify-gate.sh" "$T/gate.sh"
cd "$T"; mkdir .claude
printf '#!/bin/sh\nexit 1\n' > .claude/aep-check.sh; chmod +x .claude/aep-check.sh
set +e; sh gate.sh 2>/dev/null; RC=$?; set -e
[ "$RC" -eq 2 ] || { echo "failing check did not block (exit $RC, expected 2)"; exit 1; }
printf '#!/bin/sh\nexit 0\n' > .claude/aep-check.sh
sh gate.sh >/dev/null 2>&1 || { echo "passing check did not allow stop"; exit 1; }
# and with no check configured at all, the gate is a no-op
rm .claude/aep-check.sh
sh gate.sh >/dev/null 2>&1 || { echo "absent check did not allow stop"; exit 1; }
