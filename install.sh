#!/bin/sh
# AEP installer for tools other than Claude Code.
# (On Claude Code, use the marketplace instead:
#   /plugin marketplace add omeeragtoprak/agentic-engineering-protocol
#   /plugin install aep@agentic-engineering)
#
# Usage:
#   ./install.sh codex-project   # skills -> ./.agents/skills, core + project scaffold
#   ./install.sh codex-global    # skills -> ~/.codex/skills,  core + project scaffold
#   ./install.sh agents-md       # core -> ./AGENTS.md + project scaffold (any AGENTS.md tool)
#   ./install.sh skills DIR      # skills -> DIR (any Agent Skills-standard tool)
#
# Project scaffold = ./.claude/{requirements.md, trace.py, aep-check.sh}: the
# requirements ledger, its traceability checker, and the project check the
# protocol refers to. Existing files are never overwritten.
#
# Run from the repository you want to install AEP into, with this repo cloned
# somewhere reachable; or run from inside this repo to install into it.

set -e
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SRC="$HERE/plugins/aep"
TARGET="${1:-help}"

copy_core() {
  if [ -f ./AGENTS.md ]; then
    echo "AGENTS.md already exists here - not overwriting. Merge manually from:"
    echo "  $SRC/templates/AGENTS.md"
  else
    cp "$SRC/templates/AGENTS.md" ./AGENTS.md
    echo "installed ./AGENTS.md (fill in section P via your agent, or run /aep:init on Claude Code)"
  fi
}

# The protocol references three project-local files by canonical path. Without
# them, "close the ledger" and "run the check" are instructions pointing at
# nothing — so install them here rather than leaving the agent to invent a
# parallel tracker.
copy_project_scaffold() {
  mkdir -p .claude
  for pair in "requirements.md:requirements.md" \
              "trace.py.example:trace.py" \
              "aep-check.sh.example:aep-check.sh"; do
    src=${pair%%:*}; dst=${pair#*:}
    if [ -e "./.claude/$dst" ]; then
      echo "./.claude/$dst already exists - not overwriting"
    else
      cp "$SRC/templates/$src" "./.claude/$dst"
      case "$dst" in *.sh|*.py) chmod +x "./.claude/$dst" ;; esac
      echo "installed ./.claude/$dst"
    fi
  done
  echo "  -> .claude/aep-check.sh already runs .claude/trace.py, so a stale ledger"
  echo "     fails the check; replace its stub with your real build+test command."
}

copy_skills() {
  DEST="$1"
  mkdir -p "$DEST"
  cp -R "$SRC/skills/." "$DEST/"
  echo "installed skills -> $DEST"
}

case "$TARGET" in
  codex-project)
    copy_skills ./.agents/skills
    copy_core
    copy_project_scaffold
    ;;
  codex-global)
    copy_skills "$HOME/.codex/skills"
    copy_core
    copy_project_scaffold
    ;;
  agents-md)
    copy_core
    copy_project_scaffold
    ;;
  skills)
    [ -n "$2" ] || { echo "usage: ./install.sh skills DIR" >&2; exit 1; }
    copy_skills "$2"
    ;;
  *)
    sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac

echo
echo "Note: the deterministic Stop-hook verify gate is a Claude Code feature."
echo "On other tools the skills instruct the agent to run the equivalent checks;"
echo "enforcement there relies on the protocol, not on a hook."
