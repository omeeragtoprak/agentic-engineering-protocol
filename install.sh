#!/bin/sh
# AEP installer for tools other than Claude Code.
# (On Claude Code, use the marketplace instead:
#   /plugin marketplace add omeeragtoprak/agentic-engineering-protocol
#   /plugin install aep@agentic-engineering)
#
# Usage:
#   ./install.sh codex-project   # skills -> ./.agents/skills, core -> ./AGENTS.md
#   ./install.sh codex-global    # skills -> ~/.codex/skills,  core -> ./AGENTS.md
#   ./install.sh agents-md       # core -> ./AGENTS.md only (any AGENTS.md-reading tool)
#   ./install.sh skills DIR      # skills -> DIR (any Agent Skills-standard tool)
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
    ;;
  codex-global)
    copy_skills "$HOME/.codex/skills"
    copy_core
    ;;
  agents-md)
    copy_core
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
