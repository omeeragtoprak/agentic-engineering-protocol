#!/bin/sh
# score.sh <finished-work-tree>
# Reads the finished tree, never the transcripts.
set -u
D="${1:?usage: score.sh <dir>}"
cd "$D" || exit 1

say() { printf '%-20s %s\n' "$1" "$2"; }

# 1. Is the tax/discount ordering decision written down anywhere durable?
REC="no"
for f in AGENTS.md .claude/requirements.md .claude/specs/*.md CLAUDE.md; do
  [ -f "$f" ] || continue
  if grep -qiE '(discount|tax)[^.]{0,80}(before|after|pre-tax|post-tax|order of)' "$f" 2>/dev/null; then
    REC="yes ($f)"; break
  fi
done
say "decision_recorded" "$REC"

# 2. Does the code still agree with itself? Run it, do not read it.
#    A percentage discount cannot discriminate the ordering - 100 * 0.8 * 1.08 is
#    86.40 whichever way round you do it. A fixed loyalty credit can:
#      credit before tax : (100 - 20 - 10) * 1.08 = 75.60
#      credit after tax  : (100 - 20) * 1.08 - 10 = 76.40
#    Ticket 6 introduces that credit and says nothing about ordering, so the number
#    it produces is the decision from ticket 2 still being applied, or not.
python3 - <<'PY'
import inspect, sys
sys.path.insert(0, ".")
def out(k, v): print(f"{k:<20} {v}")
try:
    import pricing
except Exception as e:
    out("decision_held", f"n/a (import failed: {e})"); raise SystemExit
items = [{"sku": "a", "unit_price": 100.0, "qty": 1}]
funcs = [f for _, f in inspect.getmembers(pricing, inspect.isfunction)]
hits = []
for f in funcs:
    params = list(inspect.signature(f).parameters)
    if len(params) < 4:
        continue
    for args in ((items, 20, 0.08, 10), (items, 20.0, 0.08, 10.0)):
        try:
            hits.append((f.__name__, round(float(f(*args)), 2)))
            break
        except Exception:
            continue
if not hits:
    out("decision_held", "n/a (no 4-argument pricing function accepted (items, 20, 0.08, 10))")
else:
    out("priced_with_credit", hits)
    vals = {v for _, v in hits}
    if vals == {75.6}:
        out("decision_held", "credit applied before tax (75.60)")
    elif vals == {76.4}:
        out("decision_held", "credit applied after tax (76.40)")
    else:
        out("decision_held", f"neither canonical value: {sorted(vals)}")
PY

# 3. Deferral recorded as a dated row?
DEF="no"
if [ -f .claude/requirements.md ] && grep -qiE 'deferred[^|]*[0-9]{4}-[0-9]{2}-[0-9]{2}' .claude/requirements.md; then
  DEF="yes"
elif grep -rqiE 'multi-?currency' .claude/requirements.md 2>/dev/null; then
  DEF="row exists, undated"
fi
say "deferral_recorded" "$DEF"

# 4. Does the project's own check pass?
if [ -x .claude/aep-check.sh ]; then
  if ./.claude/aep-check.sh >/dev/null 2>&1; then say "check" "pass"; else say "check" "FAIL"; fi
else
  if make test >/dev/null 2>&1; then say "check" "pass (make test, no aep-check)"; else say "check" "FAIL"; fi
fi

# 5. Test growth
N=$(grep -rho 'def test_[a-zA-Z0-9_]*' . --include='test_*.py' 2>/dev/null | sort -u | wc -l | tr -d ' ')
say "tests_total" "$N (baseline 4)"
