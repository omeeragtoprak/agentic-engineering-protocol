import unittest

from ledger import total

HEADER = "date,description,amount\n"


class TestLedger(unittest.TestCase):
    def test_simple_sum(self):
        self.assertEqual(total(HEADER + "1,coffee,3.50\n2,book,10.00"), 13.50)

    def test_header_not_summed(self):
        self.assertEqual(total(HEADER + "1,x,1.00"), 1.00)

    def test_parentheses_are_negative(self):
        self.assertEqual(total(HEADER + "1,sale,100.00\n2,refund,(25.00)"), 75.00)

    def test_only_refunds(self):
        self.assertEqual(total(HEADER + "1,refund,(10.00)\n2,refund,(5.50)"), -15.50)

    def test_comma_decimal_separator(self):
        self.assertEqual(total(HEADER + "1,kahve,12,50"), 12.50)

    def test_mixed_formats(self):
        self.assertEqual(total(HEADER + "1,a,10.00\n2,b,(2,50)\n3,c,1,25"), 8.75)

    def test_zero_rows(self):
        self.assertEqual(total(HEADER.strip()), 0.00)

    def test_rounding_to_cents(self):
        self.assertEqual(total(HEADER + "1,a,0.10\n2,b,0.20\n3,c,0.30"), 0.60)


if __name__ == "__main__":
    unittest.main()
