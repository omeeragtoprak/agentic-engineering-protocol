#!/bin/sh
# R7: every shipped shell script parses under POSIX sh.
set -e
for f in plugins/aep/scripts/verify-gate.sh plugins/aep/templates/aep-check.sh.example \
         install.sh bench/score.sh .claude/aep-check.sh .claude/proofs/*.sh; do
  sh -n "$f" || { echo "syntax error: $f"; exit 1; }
done
