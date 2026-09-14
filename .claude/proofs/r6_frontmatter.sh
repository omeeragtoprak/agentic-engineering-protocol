#!/bin/sh
# R6: every skill and subagent carries name+description frontmatter, so tools
# other than Claude Code can load them.
exec python3 -c '
import glob, sys
bad = []
files = glob.glob("plugins/aep/skills/*/SKILL.md") + glob.glob("plugins/aep/agents/*.md")
if len(files) < 12:
    sys.exit(f"expected at least 12 skill/agent files, found {len(files)}")
for f in files:
    parts = open(f).read().split("---")
    fm = parts[1] if len(parts) > 2 else ""
    if "name:" not in fm or "description:" not in fm:
        bad.append(f)
sys.exit(f"missing frontmatter: {bad}" if bad else 0)
'
