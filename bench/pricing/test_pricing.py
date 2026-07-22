import unittest

from pricing import apply_discount, line_total, order_total


class TestLineTotal(unittest.TestCase):
    def test_simple_line(self):
        self.assertEqual(line_total(19.99, 2), 39.98)

    def test_bulk_rebate_at_threshold(self):
        # 10 units is the documented threshold for the 5% rebate.
        self.assertEqual(line_total(4.00, 10), 38.00)

    def test_bulk_rebate_above_threshold(self):
        self.assertEqual(line_total(2.50, 12), 28.50)

    def test_rejects_non_positive_quantity(self):
        with self.assertRaises(ValueError):
            line_total(5.00, 0)


class TestApplyDiscount(unittest.TestCase):
    def test_save10(self):
        self.assertEqual(apply_discount(100.00, "SAVE10"), 90.00)

    def test_save25(self):
        self.assertEqual(apply_discount(40.00, "SAVE25"), 30.00)

    def test_unknown_code_raises(self):
        with self.assertRaises(KeyError):
            apply_discount(100.00, "NOPE")

    def test_cap_enforced_on_large_orders(self):
        # 40% of $500 is $200, but a code may take off at most $50.
        self.assertEqual(apply_discount(500.00, "VIP40"), 450.00)

    def test_discount_under_cap_applies_fully(self):
        self.assertEqual(apply_discount(100.00, "VIP40"), 60.00)


class TestOrderTotal(unittest.TestCase):
    def test_no_discount_with_shipping(self):
        self.assertEqual(order_total([(10.00, 3)]), 36.99)

    def test_discount_then_shipping_charged(self):
        # $80 cart, SAVE25 -> $60, below free-shipping threshold.
        self.assertEqual(order_total([(20.00, 4)], "SAVE25"), 66.99)

    def test_free_shipping_at_threshold(self):
        self.assertEqual(order_total([(25.00, 4)]), 100.00)


if __name__ == "__main__":
    unittest.main()
