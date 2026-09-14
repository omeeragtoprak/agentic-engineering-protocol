#!/bin/sh
# R8: both manifests are well-formed JSON and declare the keys the plugin loader
# requires. (Schema validation itself is the `claude plugin validate` CI step,
# which needs the CLI and is therefore not part of this local gate.)
exec python3 -c '
import json, sys
p = json.load(open("plugins/aep/.claude-plugin/plugin.json"))
m = json.load(open(".claude-plugin/marketplace.json"))
missing = [k for k in ("name", "version", "description") if k not in p]
if missing: sys.exit(f"plugin.json missing {missing}")
if not m.get("plugins"): sys.exit("marketplace.json declares no plugins")
e = m["plugins"][0]
missing = [k for k in ("name", "source", "version") if k not in e]
if missing: sys.exit(f"marketplace entry missing {missing}")
if p["name"] != e["name"]: sys.exit("slug drift: " + p["name"] + " vs " + e["name"])
'
