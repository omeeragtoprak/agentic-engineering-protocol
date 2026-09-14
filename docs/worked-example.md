# A worked example — what AEP actually produces

Rules describe behaviour; this page shows the output. Everything below is
**verbatim from one measured session**, not a demonstration written by hand:

- Task: [`bench/wider-check`](../bench/wider-check/) — add validation and coercion
  to a settings loader whose project check is wider than its test loop.
- Model: **Haiku 4.5** (deliberately not a frontier model), AEP v1.6.1, 40-turn cap.
- Recorded as Round 9, run B in the [validation log](validation-log.md); the
  session ended with 35 tests green, lint clean, two atomic commits, and the
  pristine lint rules and Makefile untouched.

---

## 1. The spec it persisted, before implementing

Written to `.claude/specs/validate-settings.md`. Note that the test plan maps
one-to-one onto acceptance criteria — that mapping is what makes Phase 4
checkable rather than rhetorical.

```markdown
# Spec: Validate and coerce settings.load()

## Approach
Dictionary-driven validation. Define `VALIDATORS` dict mapping each known setting
to a `(coerce_func, constraints_str)` tuple. `coerce_func` takes raw string,
returns typed value, or raises `ValueError`. `load()` catches and re-raises as
`SettingsError` with format: `"setting '<name>': got '<raw_value>', expected
<constraints_str>"`. Single dispatch point, consistent error format, easy to extend.

## Files
- `settings.py` (add VALIDATORS dict, update load() logic)
- `test_settings.py` (add validation tests for each setting type)

## Data/API
None. `load()` signature unchanged. Output is now a typed dict (ints, floats,
bools) instead of strings.

## Migration
n/a — new validation only, no stored data or external contracts affected.

## Test Plan
Acceptance criteria map to failing tests in test_settings.py:
1. **Port**: test_port_* — valid (1, 65535, 5432), boundary (0, 65536, -1), invalid ("5432x", "", "abc")
2. **Timeout**: test_timeout_* — valid (0.1, 1.0, 60.0), boundary (0, -0.001, "inf"), invalid ("abc", "")
3. **Retries**: test_retries_* — valid (0, 1, 100), boundary (-1), invalid ("abc", "")
4. **Verbose**: test_verbose_* — valid ("true", "false", "yes", "no", "1", "0", "on", "off", mixed case), invalid ("maybe", "")
5. **Host**: test_host_* — passthrough unchanged (string, any value)
6. **Unknown key**: test_unknown_key_rejected — raises SettingsError "unknown setting: <key>"
7. **Error messages**: test_error_message_* — each includes setting name, raw value, constraints
```

**Verified afterwards, not assumed:** those tests were written *before* the
implementation existed. Running the session's final `test_settings.py` against
the pristine `settings.py` produces **29 failures** — the check really could
have been red, which is the only thing that makes its green state evidence.

## 2. The delivery summary it produced

```markdown
## FINAL DELIVERY SUMMARY

**Delivered: Validate and coerce settings.load() input**

**What & why:**
Operators shipping malformed configs (e.g., `port="5432x"`, `timeout=-1`) caused
confusing runtime failures downstream. This change validates input at the trust
boundary — the service now fails fast at startup with clear, actionable error
messages that name the setting, show the bad value, and state what was expected.

**Evidence:**
- **Build/Lint:** 0 lint findings (88-char lines, no broad except clauses) ✓
- **Tests:** 35/35 passing (3 existing + 32 new acceptance criteria + edge case tests) ✓
  - Port: valid (1, 65535, 5432) · boundaries (0, 65536) · invalid ("5432x", "", "abc")
  - Timeout: valid (0.1, 1.0, 60.0) · boundaries (0, -0.001) · **infinity/NaN rejected** ✓
  - Verbose: true variants (true/yes/1/on, case-insensitive) · invalid ("maybe", "")
  - Host: passthrough unchanged ✓
  - Error messages: include setting name, received value, constraints ✓
- **Acceptance (9/9):** All criteria met (verified after adversarial review and fix)
- **Gap closure (3/3):** All Phase 1 gaps closed

**Reviewed by:**
Fresh-context `aep:adversarial-reviewer` subagent identified **1 blocker**: timeout
validator accepted infinity/NaN in violation of acceptance criterion 2. **Finding
resolved:** Added `math.isfinite()` check and regression tests; all 35 tests now pass.

**Trade-offs:**
- **Strictness vs. flexibility:** Verbose accepts standard spellings but rejects
  ambiguous values like "maybe". Rationale: operator configs should be unambiguous.
- **No defaults:** `load()` only validates what is provided; missing keys are not
  filled. Rationale: keeps the function simple, lets callers decide.

**Commits:**
- `f4441cc` — `feat: validate and coerce settings.load() input`
- `13c04f5` — `fix: reject infinity and NaN in timeout validator` (adversarial review follow-up)
```

## 3. What to notice

- **The reviewer earned its place.** A fresh-context subagent, given only the
  diff and the spec, found a real defect — `float("inf")` satisfying a
  "timeout > 0" check — that the authoring context had missed. That is the
  second commit.
- **Evidence is re-runnable, not rhetorical.** Every claim names the command or
  the criterion behind it. "35/35 passing" with a mapped acceptance list is
  checkable by a reader; "all tests pass" is not.
- **Trade-offs are stated, not smoothed over.** Two deliberate restrictions are
  named with rationale, so a reviewer can disagree with the decision rather than
  discover it later.
- **The shape is the agent's, not the template's.** It wrote `**Reviewed by:**`
  as a heading rather than the template's `Review:` row — the substance was
  followed, the formatting was not. That is a documented, measured behaviour,
  not a lapse ([design rule 5](design-rules.md)).

## Honest framing

This is one session, chosen because it is representative of a *measured* round —
not a best-of. The same round's other session produced comparable work but did
not persist a spec file, which is recorded in the validation log rather than
hidden here. In the two rounds before this one, the same model produced **no code
at all**, four times, for a reason that took a protocol change to fix.
