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
import inspect, itertools, sys
sys.path.insert(0, ".")
def out(k, v): print(f"{k:<20} {v}")
try:
    import pricing
except Exception as e:
    out("decision_held", f"n/a (import failed: {e})"); raise SystemExit

items = [{"sku": "a", "unit_price": 100.0, "qty": 1}]

def discount_values():
    """The discount may be a number or an object the repo defined."""
    vals = [20, 20.0]
    for name, cls in inspect.getmembers(pricing, inspect.isclass):
        if cls.__module__ != "pricing":
            continue
        for args in (("SAVE20", 20), (20,), ("SAVE20", 20.0), (20.0,)):
            try:
                vals.append(cls(*args)); break
            except Exception:
                continue
    return vals

CREDIT_WORDS = ("credit", "loyalty", "points", "balance", "wallet")

def credit_values():
    """A credit may be a plain 10.0 or an object this repo defined for it."""
    vals = [10.0, 10]
    for name, cls in inspect.getmembers(pricing, inspect.isclass):
        if cls.__module__ != "pricing" or not any(w in name.lower() for w in CREDIT_WORDS):
            continue
        for args in ((10.0,), (10,), ("LOYALTY", 10.0)):
            try:
                vals.append(cls(*args)); break
            except Exception:
                continue
    return vals

hits = []
for name, f in inspect.getmembers(pricing, inspect.isfunction):
    if name.startswith("_"):
        continue
    params = inspect.signature(f).parameters
    if not any(any(w in p.lower() for w in CREDIT_WORDS) for p in params):
        continue                      # no credit parameter: not the ticket-6 entry point
    for disc in discount_values():
        kw = {}
        for p in params:
            pl = p.lower()
            if any(w in pl for w in CREDIT_WORDS): kw[p] = None  # filled per candidate below
            elif "tax" in pl:                      kw[p] = 0.08
            elif "disc" in pl or "code" in pl or "coupon" in pl: kw[p] = disc
            elif "item" in pl or "order" in pl or "line" in pl:  kw[p] = items
        if len(kw) < len(params) - sum(1 for p in params.values() if p.default is not p.empty):
            continue
        done = False
        for credit in credit_values():
            call = dict(kw)
            for p in call:
                if any(w in p.lower() for w in CREDIT_WORDS):
                    call[p] = credit
            try:
                hits.append((name, round(float(f(**call)), 2))); done = True; break
            except Exception:
                continue
        if done:
            break

if not hits:
    out("decision_held", "n/a (no function with a credit-shaped parameter priced an order)")
else:
    out("priced_with_credit", hits)
    vals = {v for _, v in hits}
    if vals == {75.6}:   out("decision_held", "credit before tax (75.60) - consistent with discount-then-tax")
    elif vals == {76.4}: out("decision_held", "credit after tax (76.40)")
    else:                out("decision_held", f"neither canonical value: {sorted(vals)}")
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
