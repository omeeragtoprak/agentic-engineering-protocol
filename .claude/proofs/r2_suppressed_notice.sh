#!/bin/sh
# R2: a green suite that hides suppressed tests still surfaces a notice.
set -e
ROOT=$(git rev-parse --show-toplevel)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
cp "$ROOT/plugins/aep/scripts/verify-gate.sh" "$T/gate.sh"
cd "$T"; mkdir .claude
printf '#!/bin/sh\necho "OK (expected failures=1)"\n' > .claude/aep-check.sh
chmod +x .claude/aep-check.sh
OUT=$(sh gate.sh)
printf '%s' "$OUT" | grep -q "suppressed tests" || { echo "no suppressed-test notice: $OUT"; exit 1; }
printf '#!/bin/sh\necho "OK"\n' > .claude/aep-check.sh
OUT=$(sh gate.sh)
[ -z "$OUT" ] || { echo "clean green suite produced a notice: $OUT"; exit 1; }
