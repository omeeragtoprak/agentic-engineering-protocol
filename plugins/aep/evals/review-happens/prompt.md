---
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent, TodoWrite]
---

Extend pricing.py for checkout:

1. Discount codes — a code carries a percentage applied to the order, and an invalid
   percentage is rejected.
2. Sales tax — a rate applied to what the customer pays.
3. A receipt breakdown a customer can read: the line items, what was taken off, what was
   added, and the final amount.
4. Tests covering each of those, including the rejection case.

Keep the existing functions working.
