"""Bank-export ledger importer.

total(csv_text): sum the `amount` column of a CSV export.
- first line is ALWAYS a header (`date,description,amount`) and is skipped
- amounts in accounting notation `(123.45)` are NEGATIVE
- amounts may use a comma decimal separator ("12,50" == 12.50); in that
  case the amount is the LAST TWO comma-separated fields joined by a dot
- returns the total rounded to cents
"""


def _parse_amount(raw):
    raw = raw.strip()
    return float(raw)


def total(csv_text):
    result = 0.0
    for line in csv_text.strip().splitlines():
        parts = line.split(",")
        if len(parts) < 3:
            continue
        result += _parse_amount(parts[-1])
    return round(result, 2)
