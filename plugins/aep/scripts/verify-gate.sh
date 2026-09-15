#!/bin/sh
# AEP verify gate (Stop hook), v2.
# Deterministic completion gate: while the project's check fails, the agent
# may not declare the task complete. Opt-in per repository: the gate is a
# no-op unless .claude/aep-check.sh exists and is executable.
# v2 adds tamper visibility: uncommitted changes to test files are reported,
# so passing the gate by weakening tests cannot happen silently.
# v3 also watches the gate's own inputs. Observed in a probe: given a check that
# exits 1, an agent edited the check to exit 0 and stopped. The check script, the
# traceability checker and the requirements ledger are therefore reported the same
# way tests are - the gate cannot stop that edit, but it can refuse to hide it.
# Safety: Claude Code overrides a Stop hook after 8 consecutive blocks,
# so a broken check cannot dead-lock a session forever.

CHECK="./.claude/aep-check.sh"

[ -x "$CHECK" ] || exit 0   # no project check configured -> allow stop

# Uncommitted changes to test-looking files, or to the gate's own inputs
# (empty outside git repos).
TAMPER=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  TAMPER=$(git status --porcelain 2>/dev/null | cut -c4- \
    | grep -Ei '(^|/)(tests?|specs?)(/|$)|(^|/)test_[^/]*$|(^|/)conftest\.py$|[^/]*(_test|\.test|\.spec)\.[A-Za-z0-9]+$|(^|/)\.claude/(aep-check\.sh|trace\.py|requirements\.md)$' \
    | head -5)
fi

OUTPUT=$("$CHECK" 2>&1)
STATUS=$?

if [ $STATUS -ne 0 ]; then
  TAIL=$(printf '%s\n' "$OUTPUT" | tail -n 15)
  printf 'AEP VERIFY GATE: project check failed (exit %s). Fix the root cause before completing - do not suppress the check.\n--- last output ---\n%s\n' "$STATUS" "$TAIL" >&2
  if [ -n "$TAMPER" ]; then
    printf 'TEST-INTEGRITY NOTE: uncommitted changes to test files or to the gate own inputs (check script, trace.py, requirements ledger) detected. Making the gate pass by editing what it checks is a protocol violation; justify any such change in the delivery summary.\n%s\n' "$TAMPER" >&2
  fi
  exit 2                    # exit 2 = block stop, stderr is fed back to the agent
fi

# Suppressed tests satisfy an exit code while a real assertion is knowingly
# failing (unittest expectedFailure, pytest xfail, skips). Legitimate, but never
# invisible: measured in a controlled run where the gate passed a suite carrying
# a known-broken contract test.
SUPPRESSED=$(printf '%s\n' "$OUTPUT" | grep -Eio '[0-9]+ (expected failures?|skipped|xfailed|xpassed)|OK \((expected failures|skipped)[^)]*\)' | head -3 | tr '\n' ' ')

# The ledger is a project-level commitment record; code that lands without a row
# is exactly how it rots. Measured in Round 10: across twelve task-sessions with
# the ledger present and the instructions loaded, not one row was ever written.
# Prose could not reach the agent at the moment it mattered; this can - it fires
# at the Stop, while there is still a turn left to act in.
STALE_LEDGER=""
if [ -f ".claude/requirements.md" ] && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # If the ledger has moved since the nudge, forget it: the next task starts clean.
  # Compared by content, not mtime - two writes inside one second are not ordered.
  GD=$(git rev-parse --git-dir 2>/dev/null)
  LEDGER_SUM=$(cksum .claude/requirements.md 2>/dev/null | cut -d" " -f1,2)
  if [ -n "$GD" ] && [ -f "$GD/aep-ledger-nudge" ]; then
    if [ "$(cat "$GD/aep-ledger-nudge" 2>/dev/null)" != "$LEDGER_SUM" ]; then
      rm -f "$GD/aep-ledger-nudge" 2>/dev/null || true
    fi
  fi
  DIRTY=$(git status --porcelain 2>/dev/null | cut -c4- | grep -v '^\.claude/requirements\.md$' | head -1)
  LEDGER_DIRTY=$(git status --porcelain 2>/dev/null | cut -c4- | grep -c '^\.claude/requirements\.md$')
  if [ -n "$DIRTY" ] && [ "$LEDGER_DIRTY" -eq 0 ]; then
    STALE_LEDGER="uncommitted changes"
  elif [ -z "$DIRTY" ]; then
    HEADFILES=$(git show --name-only --format= HEAD 2>/dev/null)
    if printf '%s\n' "$HEADFILES" | grep -qv '^\.claude/requirements\.md$' &&
       ! printf '%s\n' "$HEADFILES" | grep -q '^\.claude/requirements\.md$'; then
      STALE_LEDGER="the last commit"
    fi
  fi
fi

# Was this diff reviewed in a fresh context? The gate cannot read the conversation,
# but the SubagentStop recorder leaves a line per finished subagent in .git, so it can
# ask whether *any* review ran since the last commit. Measured in Round 20: three
# sessions with a significant diff, none of which invoked a reviewer, and the core's
# instruction to do so was loaded in every one. This reports; it does not block.
UNREVIEWED=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # Uncommitted work first; if the tree is clean, look at the commit just made — the
  # protocol tells agents to commit, and a session that does was invisible here.
  # Measured: two runs finished, committed, and the gate never asked about a review.
  SRC_LIST=$(git status --porcelain 2>/dev/null | cut -c4-)
  FROM_HEAD=""
  if [ -z "$SRC_LIST" ]; then
    # Only a *recent* commit can plausibly be this session's work. Without this,
    # opening a repository whose last commit is months old and stopping gets you
    # blocked for someone else's diff — measured, and it would be the first thing a
    # new user saw. Eight hours is a heuristic, and its failure mode is stated: a
    # session that commits early and stops much later is not asked.
    HEAD_AGE=$(( $(date +%s) - $(git log -1 --format=%ct 2>/dev/null || echo 0) ))
    if [ "$HEAD_AGE" -lt "${AEP_REVIEW_HEAD_MAX_AGE:-28800}" ]; then
      SRC_LIST=$(git show --name-only --format= HEAD 2>/dev/null)
      FROM_HEAD="yes"
    fi
  fi
  CHANGED=$(printf '%s\n' "$SRC_LIST" \
    | grep -Ev '(^|/)(tests?|specs?)(/|$)|(^|/)test_[^/]*$|[^/]*(_test|\.test|\.spec)\.[A-Za-z0-9]+$|^\.claude/' \
    | grep -Ec '\.(py|js|ts|tsx|jsx|go|rs|rb|java|cs|kt|swift|php|sh)$' || true)
  # "Significant" is two or more source files, or one file substantially rewritten.
  # The first version of this rule counted files only, and missed the commonest shape
  # there is: a single module changed by thirty lines. Measured — three runs where the
  # notice never fired because the diff touched one file.
  LINES=0
  if [ "${CHANGED:-0}" -ge 1 ]; then
    DIFF_RANGE="HEAD"
    [ -n "$FROM_HEAD" ] && DIFF_RANGE="HEAD~1..HEAD"
    LINES=$(git diff $DIFF_RANGE --numstat 2>/dev/null \
      | grep -Ev '(^|/)(tests?|specs?)/|(^|/)test_[^/]*\s|^\.claude/' \
      | awk '$3 ~ /\.(py|js|ts|tsx|jsx|go|rs|rb|java|cs|kt|swift|php|sh)$/ { n += $1 + $2 } END { print n + 0 }')
    # `git diff` does not see a file that was never tracked, so a brand-new 30-line
    # module counted as zero changed lines — which is exactly the shape that most
    # deserves a review. Untracked source files are counted whole.
    NEWLINES=$(git ls-files --others --exclude-standard 2>/dev/null \
      | grep -Ev '(^|/)(tests?|specs?)/|(^|/)test_[^/]*$|^\.claude/' \
      | grep -E '\.(py|js|ts|tsx|jsx|go|rs|rb|java|cs|kt|swift|php|sh)$' \
      | tr '\n' '\0' | xargs -0 cat 2>/dev/null | wc -l | tr -d ' ')
    LINES=$((LINES + ${NEWLINES:-0}))
  fi
  if [ "${CHANGED:-0}" -ge 2 ] || [ "${LINES:-0}" -ge 25 ]; then
    GD=$(git rev-parse --git-dir 2>/dev/null)
    REVIEWS="$GD/aep-reviews"
    LAST_COMMIT=$(git log -1 --format=%ct 2>/dev/null || echo 0)
    # when the change we are judging *is* the last commit, a review from just before
    # it still counts - it graded that work
    [ -n "$FROM_HEAD" ] && LAST_COMMIT=$(git log -1 --skip=1 --format=%ct 2>/dev/null || echo 0)
    SEEN=""
    if [ -f "$REVIEWS" ]; then
      # Strictly after: a review recorded in the same second as the commit is
      # discarded, because it was almost certainly the work being committed. That
      # fails towards one notice too many rather than one too few, which is the
      # right direction for a gate.
      # Only a review counts as a review. The recorder logs every finished subagent,
      # and an agent sent to run the tests is not a fresh-context grader — measured:
      # an eval run used two subagents as test runners and the gate fell silent, which
      # is the failure this filter exists to stop.
      SEEN=$(awk -v since="$LAST_COMMIT" '$1 + 0 > since { print $3 }' "$REVIEWS" 2>/dev/null \
        | grep -Ei 'review|audit|critic|adversar|security|performance|gap' \
        | sort -u | tr '\n' ' ')
    fi
    [ -z "$SEEN" ] && UNREVIEWED="$CHANGED source file(s), $LINES changed line(s)"
  fi
fi

# A non-blocking notice at Stop arrives *after* the work is finished — measured: in
# every eval run it landed on the second-to-last line of the transcript and the run
# ended. It still reaches a human in an interactive session, which is why it stays
# the default; what it cannot do is change the turn it appears in.
#
# Blocking once would change the turn. It is off by default because the measurement
# that would justify it was cut short by a usage limit (Round 16): two usable runs,
# no row written either time. Set AEP_LEDGER_BLOCK=1 to turn it on — the marker lives
# in .git so it is never committed, and a second Stop passes whatever you decided.
NUDGE=""
if [ "${AEP_LEDGER_BLOCK:-0}" = "1" ] && [ -n "$STALE_LEDGER" ]; then
  MARKER=""
  GITDIR=$(git rev-parse --git-dir 2>/dev/null)
  [ -n "$GITDIR" ] && MARKER="$GITDIR/aep-ledger-nudge"
  if [ -n "$MARKER" ] && [ ! -f "$MARKER" ]; then
    printf '%s' "$LEDGER_SUM" > "$MARKER" 2>/dev/null || true
    NUDGE="yes"
  fi
fi

# On by default, which is unusual for this project and was earned rather than assumed.
# A notice at Stop cannot change the run it appears in; a single block can. Measured
# on two tasks and two models, counting only runs where the gate actually asked:
# notice 0 of 7 ran a review, blocking 7 of 7. The criterion for turning this on was
# written down before the second measurement existed - replication on a different task
# and a different model - and then met.
#
# AEP_REVIEW_BLOCK=0 turns it off. It asks once per commit, and Claude Code overrides
# a Stop hook after repeated blocks, so it cannot dead-lock a session.
REVIEW_NUDGE=""
if [ "${AEP_REVIEW_BLOCK:-1}" = "1" ] && [ -n "$UNREVIEWED" ]; then
  RMARK=""
  RGD=$(git rev-parse --git-dir 2>/dev/null)
  [ -n "$RGD" ] && RMARK="$RGD/aep-review-nudge"
  RHEAD=$(git log -1 --format=%H 2>/dev/null)
  if [ -n "$RMARK" ] && [ "$(cat "$RMARK" 2>/dev/null)" != "$RHEAD" ]; then
    printf '%s' "$RHEAD" > "$RMARK" 2>/dev/null || true
    REVIEW_NUDGE="yes"
  fi
fi

if [ -n "$REVIEW_NUDGE" ]; then
  printf 'AEP REVIEW: this change touches %s and nothing graded it but you.\nDo one of two things, then finish:\n  1. run a fresh-context review (aep:adversarial-reviewer) over the diff and the spec; or\n  2. state in the delivery summary that the authoring context graded its own work.\nThis is asked once per commit; stopping again passes either way.\n' "$UNREVIEWED" >&2
  exit 2
fi

if [ -n "$NUDGE" ]; then
  printf 'AEP LEDGER: this task changed %s, and .claude/requirements.md has no row for it.\nDo one of two things, then finish:\n  1. add a row - `done` with a proof that exists, or `deferred`/`dropped` with a date and a reason; or\n  2. state in one line that this task committed to nothing new.\nThis is asked once per session; stopping again passes either way.\n' "$STALE_LEDGER" >&2
  exit 2
fi

NOTES=""
add_note() { NOTES="$NOTES $1"; }
[ -n "$TAMPER" ] && add_note "Test files or the gate own inputs have uncommitted changes ($(printf '%s' "$TAMPER" | tr '\n' ';' | tr -d '\"\\')) - confirm they were strengthened, not weakened."
[ -n "$SUPPRESSED" ] && add_note "The suite reports suppressed tests ($(printf '%s' "$SUPPRESSED" | tr -d '\"\\')) - a green exit code does not mean every assertion ran; name each one and why."
[ -n "$UNREVIEWED" ] && add_note "This change touches $UNREVIEWED and no fresh-context review ran since the last commit - the author graded its own diff. Name that in the delivery summary, or run aep:adversarial-reviewer before finishing."
[ -n "$STALE_LEDGER" ] && add_note "The requirements ledger has no row for $STALE_LEDGER - if this task committed to something, record it in .claude/requirements.md (done with a proof, or deferred with a date and a reason); if it committed to nothing, say so in the delivery summary."

if [ -n "$NOTES" ]; then
  # Check is green but something deserves a look: surface it, non-blocking.
  printf '{"systemMessage":"AEP gate green, with something to confirm:%s"}\n' "$NOTES"
fi

exit 0
