#!/bin/sh
# AEP verify gate (Stop hook), v2.
# Deterministic completion gate: while the project's check fails, the agent
# may not declare the task complete. Opt-in per repository: the gate is a
# no-op unless .claude/aep-check.sh exists and is executable.
# v2 adds tamper visibility: uncommitted changes to test files are reported,
# so passing the gate by weakening tests cannot happen silently.
# Safety: Claude Code overrides a Stop hook after 8 consecutive blocks,
# so a broken check cannot dead-lock a session forever.

CHECK="./.claude/aep-check.sh"

[ -x "$CHECK" ] || exit 0   # no project check configured -> allow stop

# Uncommitted changes to test-looking files (empty outside git repos).
TAMPER=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  TAMPER=$(git status --porcelain 2>/dev/null | cut -c4- \
    | grep -Ei '(^|/)(tests?|specs?)(/|$)|(^|/)test_[^/]*$|(^|/)conftest\.py$|[^/]*(_test|\.test|\.spec)\.[A-Za-z0-9]+$' \
    | head -5)
fi

OUTPUT=$("$CHECK" 2>&1)
STATUS=$?

if [ $STATUS -ne 0 ]; then
  TAIL=$(printf '%s\n' "$OUTPUT" | tail -n 15)
  printf 'AEP VERIFY GATE: project check failed (exit %s). Fix the root cause before completing - do not suppress the check.\n--- last output ---\n%s\n' "$STATUS" "$TAIL" >&2
  if [ -n "$TAMPER" ]; then
    printf 'TEST-INTEGRITY NOTE: uncommitted changes to test files detected. Weakening or deleting tests to satisfy the gate is a protocol violation; justify any test change in the delivery summary.\n%s\n' "$TAMPER" >&2
  fi
  exit 2                    # exit 2 = block stop, stderr is fed back to the agent
fi

# Suppressed tests satisfy an exit code while a real assertion is knowingly
# failing (unittest expectedFailure, pytest xfail, skips). Legitimate, but never
# invisible: measured in a controlled run where the gate passed a suite carrying
# a known-broken contract test.
SUPPRESSED=$(printf '%s\n' "$OUTPUT" | grep -Eio '[0-9]+ (expected failures?|skipped|xfailed|xpassed)|OK \((expected failures|skipped)[^)]*\)' | head -3 | tr '\n' ' ')

if [ -n "$TAMPER" ] || [ -n "$SUPPRESSED" ]; then
  # Check is green but something deserves a look: surface it, non-blocking.
  ESC=$(printf '%s' "$TAMPER" | tr '\n' ';' | tr -d '"\\')
  SUP=$(printf '%s' "$SUPPRESSED" | tr -d '"\\')
  if [ -n "$TAMPER" ] && [ -n "$SUPPRESSED" ]; then
    printf '{"systemMessage":"AEP gate green, with two things to confirm: test files have uncommitted changes (%s), and the suite reports suppressed tests (%s). Name both in the delivery summary - a green exit code does not mean every assertion ran."}\n' "$ESC" "$SUP"
  elif [ -n "$TAMPER" ]; then
    printf '{"systemMessage":"AEP gate green, but test files have uncommitted changes (%s). Confirm tests were strengthened, not weakened - see the delivery summary."}\n' "$ESC"
  else
    printf '{"systemMessage":"AEP gate green, but the suite reports suppressed tests (%s). Skips and expected-failures satisfy the exit code while a real assertion is not being enforced - name each one and why in the delivery summary."}\n' "$SUP"
  fi
fi

exit 0
