"""Order pricing.

An order is a list of line items: {"sku": str, "unit_price": float, "qty": int}.
Money is handled in float dollars for this exercise.
"""


def line_total(item):
    return item["unit_price"] * item["qty"]


def subtotal(items):
    return sum(line_total(i) for i in items)
