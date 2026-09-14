#!/bin/sh
# AEP verify gate (Stop hook), v2.
# Deterministic completion gate: while the project's check fails, the agent
# may not declare the task complete. Opt-in per repository: the gate is a
# no-op unless .claude/aep-check.sh exists and is executable.
# v2 adds tamper visibility: uncommitted changes to test files are reported,
# so passing the gate by weakening tests cannot happen silently.
# v3 also watches the gate's own inputs. Observed in a probe: given a check that
# exits 1, an agent edited the check to exit 0 and stopped. The check script, the
# traceability checker and the requirements ledger are therefore reported the same
# way tests are - the gate cannot stop that edit, but it can refuse to hide it.
# Safety: Claude Code overrides a Stop hook after 8 consecutive blocks,
# so a broken check cannot dead-lock a session forever.

CHECK="./.claude/aep-check.sh"

[ -x "$CHECK" ] || exit 0   # no project check configured -> allow stop

# Uncommitted changes to test-looking files, or to the gate's own inputs
# (empty outside git repos).
TAMPER=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  TAMPER=$(git status --porcelain 2>/dev/null | cut -c4- \
    | grep -Ei '(^|/)(tests?|specs?)(/|$)|(^|/)test_[^/]*$|(^|/)conftest\.py$|[^/]*(_test|\.test|\.spec)\.[A-Za-z0-9]+$|(^|/)\.claude/(aep-check\.sh|trace\.py|requirements\.md)$' \
    | head -5)
fi

OUTPUT=$("$CHECK" 2>&1)
STATUS=$?

if [ $STATUS -ne 0 ]; then
  TAIL=$(printf '%s\n' "$OUTPUT" | tail -n 15)
  printf 'AEP VERIFY GATE: project check failed (exit %s). Fix the root cause before completing - do not suppress the check.\n--- last output ---\n%s\n' "$STATUS" "$TAIL" >&2
  if [ -n "$TAMPER" ]; then
    printf 'TEST-INTEGRITY NOTE: uncommitted changes to test files or to the gate own inputs (check script, trace.py, requirements ledger) detected. Making the gate pass by editing what it checks is a protocol violation; justify any such change in the delivery summary.\n%s\n' "$TAMPER" >&2
  fi
  exit 2                    # exit 2 = block stop, stderr is fed back to the agent
fi

# Suppressed tests satisfy an exit code while a real assertion is knowingly
# failing (unittest expectedFailure, pytest xfail, skips). Legitimate, but never
# invisible: measured in a controlled run where the gate passed a suite carrying
# a known-broken contract test.
SUPPRESSED=$(printf '%s\n' "$OUTPUT" | grep -Eio '[0-9]+ (expected failures?|skipped|xfailed|xpassed)|OK \((expected failures|skipped)[^)]*\)' | head -3 | tr '\n' ' ')

# The ledger is a project-level commitment record; code that lands without a row
# is exactly how it rots. Measured in Round 10: across twelve task-sessions with
# the ledger present and the instructions loaded, not one row was ever written.
# Prose could not reach the agent at the moment it mattered; this can - it fires
# at the Stop, while there is still a turn left to act in.
STALE_LEDGER=""
if [ -f ".claude/requirements.md" ] && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  DIRTY=$(git status --porcelain 2>/dev/null | cut -c4- | grep -v '^\.claude/requirements\.md$' | head -1)
  LEDGER_DIRTY=$(git status --porcelain 2>/dev/null | cut -c4- | grep -c '^\.claude/requirements\.md$')
  if [ -n "$DIRTY" ] && [ "$LEDGER_DIRTY" -eq 0 ]; then
    STALE_LEDGER="uncommitted changes"
  elif [ -z "$DIRTY" ]; then
    HEADFILES=$(git show --name-only --format= HEAD 2>/dev/null)
    if printf '%s\n' "$HEADFILES" | grep -qv '^\.claude/requirements\.md$' &&
       ! printf '%s\n' "$HEADFILES" | grep -q '^\.claude/requirements\.md$'; then
      STALE_LEDGER="the last commit"
    fi
  fi
fi

NOTES=""
add_note() { NOTES="$NOTES $1"; }
[ -n "$TAMPER" ] && add_note "Test files or the gate own inputs have uncommitted changes ($(printf '%s' "$TAMPER" | tr '\n' ';' | tr -d '\"\\')) - confirm they were strengthened, not weakened."
[ -n "$SUPPRESSED" ] && add_note "The suite reports suppressed tests ($(printf '%s' "$SUPPRESSED" | tr -d '\"\\')) - a green exit code does not mean every assertion ran; name each one and why."
[ -n "$STALE_LEDGER" ] && add_note "The requirements ledger has no row for $STALE_LEDGER - if this task committed to something, record it in .claude/requirements.md (done with a proof, or deferred with a date and a reason); if it committed to nothing, say so in the delivery summary."

if [ -n "$NOTES" ]; then
  # Check is green but something deserves a look: surface it, non-blocking.
  printf '{"systemMessage":"AEP gate green, with something to confirm:%s"}\n' "$NOTES"
fi

exit 0
