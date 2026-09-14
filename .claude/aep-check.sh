#!/bin/sh
# AEP's own verify gate. Same commands CI runs, plus this repo's own ledger.
set -e
python3 .claude/ci.py
python3 .claude/trace.py
