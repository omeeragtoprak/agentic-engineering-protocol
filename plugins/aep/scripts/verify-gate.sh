#!/bin/sh
# AEP verify gate (Stop hook).
# Deterministic completion gate: while the project's check fails, the agent
# may not declare the task complete. Opt-in per repository: the gate is a
# no-op unless .claude/aep-check.sh exists and is executable.
# Safety: Claude Code overrides a Stop hook after 8 consecutive blocks,
# so a broken check cannot dead-lock a session forever.

CHECK="./.claude/aep-check.sh"

[ -x "$CHECK" ] || exit 0   # no project check configured -> allow stop

OUTPUT=$("$CHECK" 2>&1)
STATUS=$?

if [ $STATUS -ne 0 ]; then
  TAIL=$(printf '%s\n' "$OUTPUT" | tail -n 15)
  printf 'AEP VERIFY GATE: project check failed (exit %s). Fix the root cause before completing - do not suppress the check.\n--- last output ---\n%s\n' "$STATUS" "$TAIL" >&2
  exit 2                    # exit 2 = block stop, stderr is fed back to the agent
fi

exit 0
