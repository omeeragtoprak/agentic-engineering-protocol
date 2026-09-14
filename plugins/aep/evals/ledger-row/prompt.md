---
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Agent, TodoWrite]
---

Support ticket: users report being rate-limited even though they are under the
limit, and limits seem to leak between users. Investigate and fix limiter.py. The
docstrings describe the intended behaviour.
