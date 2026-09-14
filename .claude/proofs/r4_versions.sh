#!/bin/sh
# R4: the plugin version and the marketplace entry cannot drift apart.
exec python3 -c '
import json, sys
p = json.load(open("plugins/aep/.claude-plugin/plugin.json"))["version"]
m = json.load(open(".claude-plugin/marketplace.json"))["plugins"][0]["version"]
sys.exit(0 if p == m else f"version drift: plugin.json {p} vs marketplace.json {m}")
'
