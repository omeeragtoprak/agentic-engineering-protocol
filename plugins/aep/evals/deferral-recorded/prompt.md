---
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent, TodoWrite]
---

Add a burst allowance to the rate limiter: a user may exceed the steady limit by up
to `burst` extra calls, replenished at the steady rate. Keep per-user isolation and
pruning.

Out of scope for this ticket: per-tenant (organization-level) limits. The billing
team has not decided how tenants map to users yet, so do not implement them now.
