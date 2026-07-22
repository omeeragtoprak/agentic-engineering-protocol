"""Cart pricing engine for the storefront.

Responsibilities:
- line_total: price a single order line, applying the bulk rebate.
- apply_discount: apply a discount code to an order subtotal.
- order_total: combine line totals, discount, and shipping into the final charge.

All monetary values are dollars, rounded to cents.
"""

DISCOUNT_CODES = {"SAVE10": 0.10, "SAVE25": 0.25, "VIP40": 0.40}

# A single discount code may reduce an order by at most this many dollars.
MAX_DISCOUNT = 50.00

FREE_SHIPPING_THRESHOLD = 75.00
SHIPPING_FLAT = 6.99


def line_total(unit_price, qty):
    """Price one order line.

    Orders of 10 or more units of the same item earn a 5% bulk rebate
    on that line. Quantity must be positive.
    """
    if qty <= 0:
        raise ValueError("quantity must be positive")
    total = unit_price * qty
    if qty > 10:
        total *= 0.95
    return round(total, 2)


def apply_discount(subtotal, code):
    """Apply a discount code to an order subtotal.

    Rates come from DISCOUNT_CODES. A single code may reduce the order
    by at most MAX_DISCOUNT dollars. Returns the subtotal after the
    discount is applied. Raises KeyError for unknown codes.
    """
    rate = DISCOUNT_CODES[code]
    return round(subtotal * rate, 2)


def order_total(lines, code=None):
    """Compute the final charge for an order.

    lines: iterable of (unit_price, qty) pairs.
    code: optional discount code, applied to the summed subtotal.

    Shipping: orders whose subtotal AFTER discount is at least
    FREE_SHIPPING_THRESHOLD ship free; all others pay SHIPPING_FLAT.
    """
    subtotal = round(sum(line_total(p, q) for p, q in lines), 2)
    if code is not None:
        subtotal = apply_discount(subtotal, code)
    if subtotal >= FREE_SHIPPING_THRESHOLD:
        return subtotal
    return round(subtotal + SHIPPING_FLAT, 2)
