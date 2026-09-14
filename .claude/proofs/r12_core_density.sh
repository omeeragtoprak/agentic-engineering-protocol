#!/bin/sh
# R12: the always-on core stays inside the density budget it publishes.
# IFScale (arXiv:2507.11538) measures instruction-following falling to 68% at 500
# simultaneous instructions, with a bias toward earlier ones. AEP's answer is a
# small core plus on-demand skills; a number nobody checks is a number that drifts.
set -e
CORE=plugins/aep/templates/AGENTS.md
LINES=$(wc -l < "$CORE" | tr -d ' ')
BULLETS=$(grep -cE '^[-*0-9]' "$CORE" | tr -d ' ')
MAX_LINES=120
MAX_BULLETS=60
echo "always-on core: $LINES lines, $BULLETS imperative bullets (budget: $MAX_LINES / $MAX_BULLETS)"
[ "$LINES" -le "$MAX_LINES" ] || { echo "core is over its line budget"; exit 1; }
[ "$BULLETS" -le "$MAX_BULLETS" ] || { echo "core is over its instruction budget"; exit 1; }
# The operating stance must stay in the first third of the file: earlier
# instructions are the ones models weight most.
STANCE=$(grep -n '^## §1 Operating Stance' "$CORE" | cut -d: -f1)
[ -n "$STANCE" ] || { echo "§1 Operating Stance not found"; exit 1; }
[ "$STANCE" -le $((LINES / 3)) ] || { echo "§1 has drifted past the first third of the core"; exit 1; }
