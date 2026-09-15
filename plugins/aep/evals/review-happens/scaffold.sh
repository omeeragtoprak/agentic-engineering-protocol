#!/bin/bash
# Seeds a repository with a green suite and a module worth changing substantially.
set -e
cat > pricing.py <<'PY'
"""Order pricing."""


def line_total(item):
    return item["unit_price"] * item["qty"]


def subtotal(items):
    return sum(line_total(i) for i in items)
PY
cat > test_pricing.py <<'PY'
import unittest

from pricing import line_total, subtotal


class TestPricing(unittest.TestCase):
    def test_line_total(self):
        self.assertAlmostEqual(line_total({"unit_price": 2.5, "qty": 4}), 10.0)

    def test_subtotal(self):
        self.assertAlmostEqual(subtotal([{"unit_price": 2.5, "qty": 4}]), 10.0)
PY
printf 'test:\n\t@python3 -m unittest -q\n' > Makefile
mkdir -p .claude
printf '#!/bin/sh\nset -e\nmake test\n' > .claude/aep-check.sh
chmod +x .claude/aep-check.sh
git init -q -b main
git add -A
git -c user.email=eval@local -c user.name=eval commit -qm baseline
