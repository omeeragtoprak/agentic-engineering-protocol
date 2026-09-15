import unittest

from pricing import line_total, subtotal


class TestPricing(unittest.TestCase):
    def test_line_total(self):
        self.assertAlmostEqual(line_total({"sku": "a", "unit_price": 2.5, "qty": 4}), 10.0)

    def test_subtotal_sums_lines(self):
        items = [
            {"sku": "a", "unit_price": 2.5, "qty": 4},
            {"sku": "b", "unit_price": 1.0, "qty": 3},
        ]
        self.assertAlmostEqual(subtotal(items), 13.0)

    def test_subtotal_of_nothing_is_zero(self):
        self.assertAlmostEqual(subtotal([]), 0.0)

    def test_qty_zero_contributes_nothing(self):
        self.assertAlmostEqual(subtotal([{"sku": "a", "unit_price": 9.0, "qty": 0}]), 0.0)


if __name__ == "__main__":
    unittest.main()
