#!/bin/sh
# R3: uncommitted changes to test files - and to the gate's own inputs - are
# reported, so a weakened suite or an edited check cannot pass silently.
set -e
ROOT=$(git rev-parse --show-toplevel)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
cp "$ROOT/plugins/aep/scripts/verify-gate.sh" "$T/gate.sh"
cd "$T"; git init -q -b main; mkdir .claude tests
printf '#!/bin/sh\necho OK\n' > .claude/aep-check.sh; chmod +x .claude/aep-check.sh
echo "def test_x(): assert True" > tests/test_x.py
git add -A; git -c user.email=p@l -c user.name=p commit -qm base
echo "def test_x(): pass" > tests/test_x.py
OUT=$(sh gate.sh)
printf '%s' "$OUT" | grep -q "tests/test_x.py" || { echo "test edit not reported: $OUT"; exit 1; }
git checkout -- tests/test_x.py
printf '#!/bin/sh\necho OK # edited\n' > .claude/aep-check.sh
OUT=$(sh gate.sh)
printf '%s' "$OUT" | grep -q "aep-check.sh" || { echo "check-script edit not reported: $OUT"; exit 1; }
