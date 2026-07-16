---
name: standards
description: The AEP standards reference — security baseline (OWASP-aligned), performance and database discipline, and testing standards. Consult when touching anything web-facing, security-sensitive, performance-critical, or database-related, and during code review.
---

# AEP Standards Reference

## Security baseline (always on)

- **Input:** validate and normalize ALL external input at the boundary (user, network, file, IPC, env). **Output:** encode per sink — HTML, SQL, shell, URL each have their own escaping; one encoder does not fit all.
- **Data access:** parameterized queries only. String-built SQL is a finding even in "internal" tools.
- **AuthZ:** deny-by-default, enforced server-side on every request; never trust client state, hidden fields, or "the UI doesn't allow it".
- **Secrets:** environment variables or a secret manager only — never in code, logs, tests, commits, instruction files, or error messages. Scan the diff for leaked secrets before every commit.
- **Dependencies:** audit on add and periodically (`dotnet list package --vulnerable`, `npm audit`, `pip-audit`, per §P.2); pin via lockfiles; a transitive CVE is still your CVE.
- **Checklist:** OWASP Top 10 is the minimum review list for any web-facing change — injection, broken auth, broken access control, SSRF, misconfiguration, vulnerable components, integrity failures, logging failures, crypto failures, insecure design.
- **Never-disable list:** TLS verification, CORS, CSRF protection, auth checks, or certificate validation are never disabled as a "fix" — not even temporarily, not even in dev configs that could leak to prod.

## Performance & database discipline

- **Measure first.** Profile before optimizing; optimize only the measured hot path; keep the benchmark next to the fix so regressions are visible.
- **Complexity:** state Big-O for non-trivial algorithms; justify anything worse than the obvious bound.
- **Database hunt list:** N+1 queries (inspect ORM-generated SQL when query counts look suspicious) · missing indexes on filtered/joined columns · unbounded result sets (paginate) · long-running transactions · chatty round-trips that should be batched.
- **Caching invariant:** a cache is introduced only with a defined key, TTL, and invalidation strategy. A cache without an invalidation story is a bug with good latency.
- **Memory:** stream or chunk large payloads; never load unbounded data into memory; watch allocation churn on hot paths.

## Testing standards

- **Pyramid:** many fast deterministic unit tests → focused integration tests → few end-to-end smoke paths.
- **Determinism:** independent and order-agnostic; no real-clock/sleep-based timing; no shared mutable fixtures; a flaky test is a defect, not weather.
- **Mock boundary:** mock only at architectural boundaries (network, clock, filesystem, external services); never mock the unit under test — a test that mocks its subject tests nothing.
- **Coverage stance:** coverage is a diagnostic, not a target. Uncovered *critical* branches are blockers; vanity percentages are not. Every public behavior gets at least: one happy path, one boundary, one failure mode.
