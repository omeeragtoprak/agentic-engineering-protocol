---
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent, TodoWrite]
---

limiter.py is misbehaving: users are blocked while under their limit, and one
user's traffic counts against another's. Fix it.
