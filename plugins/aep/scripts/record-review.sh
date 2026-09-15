#!/bin/sh
# AEP review recorder (SubagentStop hook).
#
# The gate can see the working tree but not the conversation, so it cannot tell
# whether a diff was reviewed in a fresh context. This can: SubagentStop carries
# `agent_type`, so every finished subagent leaves one line behind and the gate can
# ask whether any review happened since the last commit.
#
# It never blocks — exit 2 is not honoured for this event anyway — and it writes
# inside .git, so nothing it records is ever committed.
set -u

INPUT=$(cat 2>/dev/null || true)

GITDIR=$(git rev-parse --git-dir 2>/dev/null) || exit 0
[ -n "$GITDIR" ] || exit 0

AGENT=$(printf '%s' "$INPUT" | sed -n 's/.*"agent_type"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$AGENT" ] || AGENT="unknown"

# Epoch first: the gate compares it against `git log --format=%ct`, and parsing an
# ISO string in awk meant reading a UTC stamp as local time - three hours of silent
# wrongness on this machine, caught by a behavioural test rather than by reading it.
printf '%s %s %s\n' "$(date +%s)" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$AGENT" \
  >> "$GITDIR/aep-reviews" 2>/dev/null || true
exit 0
