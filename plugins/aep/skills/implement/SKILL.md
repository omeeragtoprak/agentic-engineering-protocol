---
name: implement
description: Production-grade implementation standards — typing, naming, error handling, concurrency, dependencies, configuration, and atomic scope. Use while writing or modifying any code, and consult when reviewing code for standards violations.
---

# AEP Phase 3 — Implement

Repo conventions (§P.3) win over this floor. Where the repo is silent, these rules apply.

## Typing & structure

- Strict static typing; no untyped public surfaces — no implicit `any`/`dynamic`/`object` where a real type exists. Enable and satisfy the strictest checker mode the project already uses.
- SOLID and separation of concerns; composition over inheritance; explicit dependency injection over globals and singletons.
- Small single-purpose functions; guard clauses over deep nesting; prefer immutability wherever state is contested.

## Naming & documentation

- Self-documenting names beat comments. Docstrings state inputs, outputs, side effects, and thrown exceptions.
- Comments explain **why**, not **what**. A comment restating the code is noise; a comment recording a non-obvious constraint is gold.

## Errors & boundaries

- Validate and normalize at trust boundaries (user input, network, files, IPC); fail fast with actionable errors.
- Never swallow exceptions; never log secrets; user-facing messages never leak internals or stack traces.
- Errors are typed/structured and logged with context (correlation IDs where the project has them).

## Concurrency

- Treat shared state as contested: prove thread-safety, document locking order, avoid time/sleep-based logic for correctness.
- Async all the way down or not at all — no sync-over-async deadlock patterns.

## Dependencies & configuration

- Prefer the standard library and existing project dependencies. A new dependency requires a one-line justification (maintenance, license, security, size) and a lockfile update.
- Configuration through the project's mechanism only. **Never** hardcode secrets, connection strings, or environment-specific paths — not even "temporarily".

## Data

- UTC in storage, timezone conversion at the edges; UTF-8 everywhere.
- Parameterized data access only — never concatenate user input into SQL, shell commands, or HTML.

## Scope integrity

- One task = one coherent change set. No drive-by refactors inside a bug fix; if you spot unrelated debt, log it in §P.5 and move on.
- Every edit stays inside the spec's file list; growing the list mid-implementation means the spec was wrong — go back to `aep:plan` and say so.

## Exit gate

Code complete · scope atomic · conventions matched · nothing hardcoded. Proceed to `aep:verify` — immediately, not "later".
