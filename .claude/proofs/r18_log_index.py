#!/usr/bin/env python3
"""R18: every link in the validation log's index resolves to a real heading.

The anchor rule is GitHub's, confirmed against its own rendered HTML rather than from
memory: lowercase, drop everything that is not a word character, space or hyphen, then
replace each space with a hyphen **without collapsing runs** — so "Round 1 - v1.3.0"
(with an em dash) becomes "round-1--v130", two hyphens where the dash was. A local
model of that rule got it wrong in the other direction and would have "fixed" 24
correct links; the rendered page settled it.
"""
import re
import sys

src = open("docs/validation-log.md", encoding="utf-8").read()


def anchor(heading):
    s = heading.strip().lower().replace("’", "").replace("'", "")
    s = re.sub(r"[^\w\s-]", "", s, flags=re.UNICODE)
    return s.replace(" ", "-")


headings = {anchor(m.group(1)) for m in re.finditer(r"^## (Round .+)$", src, re.M)}
links = set(re.findall(r"\]\(#(round-[^)]+)\)", src))

if not links:
    sys.exit("the index has no round links at all")
missing = sorted(links - headings)
unlinked = sorted(headings - links)
if missing:
    sys.exit("index links with no matching heading: " + ", ".join(missing))
if unlinked:
    sys.exit("rounds missing from the index: " + ", ".join(unlinked))
print(f"validation log index: {len(links)} links, all resolving")
