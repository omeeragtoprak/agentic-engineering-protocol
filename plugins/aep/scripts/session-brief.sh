#!/bin/sh
# AEP session brief (SessionStart hook).
#
# §5.1 asks the agent to re-anchor on the protocol and the project's state at
# session start. That is a rule that has to fire at a moment, and design rule 9
# says prose is the wrong instrument for those: this reports the state instead.
#
# It is informational only - it never blocks, never runs the project's check
# (too slow for a session start), and stays silent in repositories that keep no
# AEP state, because a brief that appears everywhere is one nobody reads.
set -u

LEDGER=".claude/requirements.md"
CHECK=".claude/aep-check.sh"

[ -f "$LEDGER" ] || [ -x "$CHECK" ] || exit 0

LINES=""

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  LINES="Tree: ${BRANCH:-detached}, ${DIRTY} uncommitted file(s)."
fi

if [ -x "$CHECK" ]; then
  LINES="$LINES Check: $CHECK exists and has not been run this session."
fi

if [ -f "$LEDGER" ]; then
  COUNTS=$(awk -F'|' '
    /^\|/ {
      s = $4
      gsub(/^[ \t]+|[ \t]+$/, "", s)
      split(s, w, " ")
      st = tolower(w[1])
      if (st == "open" || st == "done" || st == "deferred" || st == "dropped") c[st]++
    }
    END {
      printf "%d done, %d open, %d deferred, %d dropped", c["done"], c["open"], c["deferred"], c["dropped"]
    }' "$LEDGER")
  LINES="$LINES Requirements ledger: $COUNTS."
  OPEN=$(awk -F'|' '
    /^\|/ {
      s = $4; gsub(/^[ \t]+|[ \t]+$/, "", s)
      split(s, w, " ")
      if (tolower(w[1]) == "open" || tolower(w[1]) == "deferred") {
        id = $2; gsub(/^[ \t]+|[ \t]+$/, "", id)
        txt = $3; gsub(/^[ \t]+|[ \t]+$/, "", txt)
        if (length(txt) > 90) txt = substr(txt, 1, 90) "..."
        printf "%s (%s) %s; ", id, tolower(w[1]), txt
      }
    }' "$LEDGER" | cut -c1-400)
  [ -n "$OPEN" ] && LINES="$LINES Still open: $OPEN"
fi

[ -n "$LINES" ] || exit 0

ESC=$(printf '%s' "$LINES" | tr -d '"\\' | tr '\n' ' ' | sed 's/^ *//; s/  */ /g')
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"AEP project state, read from the repository: %s"}}\n' "$ESC"
exit 0
