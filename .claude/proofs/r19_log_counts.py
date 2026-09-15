#!/usr/bin/env python3
"""R19: the validation log's summary counts match its own table.

A sentence about how often this project was wrong is exactly the sentence that must
not drift. The first version said "nine … four … three" from memory; the table said
nine, five, three.
"""
import re
import sys

src = open("docs/validation-log.md", encoding="utf-8").read()

m = re.search(r"\| # \| What was asked \| Verdict \|\n\|[^\n]*\|\n((?:\|.*\n)+)", src)
if not m:
    sys.exit("no round table found")
rows = [r for r in m.group(1).splitlines() if r.startswith("|")]

NEGATIVE = r"\*\*(no|refuted|against|not usable|no local benefit|downgraded|corrected later)"
negative = [r for r in rows if re.search(NEGATIVE, r, re.I)]

withdrawn = re.search(r"### Claims this project withdrew\n\n((?:- .*\n(?:  .*\n)*)+)", src)
if not withdrawn:
    sys.exit("no withdrawn-claims section found")
bullets = len(re.findall(r"^- ", withdrawn.group(1), re.M))

claim = re.search(r"\*\*(\w+)\*\* carry a negative or self-correcting verdict.*?"
                  r"\*\*(\w+)\*\* made\b.*?\*\*(\w+)\*\* corrected", src, re.S)
if not claim:
    sys.exit("the summary sentence is missing or reworded — update this check with it")

WORDS = {"one":1,"two":2,"three":3,"four":4,"five":5,"six":6,"seven":7,"eight":8,
         "nine":9,"ten":10,"eleven":11,"twelve":12}
said_neg, said_wd, said_corr = (WORDS.get(g.lower(), -1) for g in claim.groups())

problems = []
if said_neg != len(negative):
    problems.append(f"summary says {said_neg} negative verdicts, table has {len(negative)}")
if said_wd != bullets:
    problems.append(f"summary says {said_wd} withdrawals, the list has {bullets}")
if problems:
    sys.exit("; ".join(problems))
print(f"log summary matches its table: {len(negative)} negative, {bullets} withdrawn, "
      f"{said_corr} self-corrections ({len(rows)} rounds)")
