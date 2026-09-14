# Proofs

One script per `done` row in [`../requirements.md`](../requirements.md). Each one
**exercises the behavior** the row claims and exits non-zero when it stops holding.

A proof that names a CI step, a file, or a function only asserts that a string
still exists somewhere — an earlier version of this ledger did exactly that, and an
adversarial review demonstrated that gutting a CI step's body left every row green
while the requirement was false. Proofs live here so they can be run, read, and
broken on purpose.
