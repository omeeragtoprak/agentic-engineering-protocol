#!/bin/sh
# R16 (mechanism half): the gate reports a significant diff that no fresh-context
# review touched, and stays quiet once one has run. Run with AEP_REVIEW_BLOCK=0 so
# the reports can be read; the blocking default is exercised separately in CI.
set -e
ROOT=$(git rev-parse --show-toplevel)
G="$ROOT/plugins/aep/scripts/verify-gate.sh"
REC="$ROOT/plugins/aep/scripts/record-review.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
cp "$G" "$T/gate.sh"
cd "$T"; git init -q -b main; mkdir -p .claude src tests
printf '#!/bin/sh\necho OK\n' > .claude/aep-check.sh; chmod +x .claude/aep-check.sh
echo "a=1" > src/a.py; echo "b=1" > src/b.py
git add -A; git -c user.email=p@l -c user.name=p commit -qm base
echo "a=2" >> src/a.py
AEP_REVIEW_BLOCK=0 sh gate.sh | grep -q "no fresh-context review" && { echo "a three-line change tripped the threshold"; exit 1; }
# one file, substantially rewritten, is significant too - the first version of this
# rule counted files only and missed the commonest shape there is
python3 -c "open('src/a.py','a').write(chr(10).join(f'z{i}={i}' for i in range(30)))"
AEP_REVIEW_BLOCK=0 sh gate.sh | grep -q "no fresh-context review" || { echo "a 30-line single-file rewrite was not reported"; exit 1; }
git checkout -- src/a.py 2>/dev/null || true
echo "a=2" >> src/a.py
echo "b=2" >> src/b.py
AEP_REVIEW_BLOCK=0 sh gate.sh | grep -q "no fresh-context review" || { echo "unreviewed diff not reported"; exit 1; }
sleep 1
# a subagent that is not a reviewer must not silence it
printf '{"agent_type":"general-purpose"}' | sh "$REC"
AEP_REVIEW_BLOCK=0 sh gate.sh | grep -q "no fresh-context review" || { echo "a test-runner subagent counted as a review"; exit 1; }
printf '{"agent_type":"aep:adversarial-reviewer"}' | sh "$REC"
AEP_REVIEW_BLOCK=0 sh gate.sh | grep -q "no fresh-context review" && { echo "a recorded review was ignored"; exit 1; }
git add -A; git -c user.email=p@l -c user.name=p commit -qm reviewed
echo "x=1" > tests/test_a.py; echo "y=1" > tests/test_b.py
AEP_REVIEW_BLOCK=0 sh gate.sh | grep -q "no fresh-context review" && { echo "complained about test-only changes"; exit 1; }

# a session that commits its work must still be asked: the tree is clean, so the
# check falls back to the commit just made. Two runs finished exactly this way and
# were never asked, which is how this case got here.
git add -A; git -c user.email=p@l -c user.name=p commit -qm tests
python3 -c "open('src/c.py','w').write(chr(10).join(f'q{i}={i}' for i in range(30)))"
git add -A; git -c user.email=p@l -c user.name=p commit -qm "committed work"
AEP_REVIEW_BLOCK=0 AEP_REVIEW_BLOCK=0 sh gate.sh | grep -q "no fresh-context review" || { echo "committed work was never asked about"; exit 1; }

# but an old commit is not this session's work: a repository whose last commit is
# months old must not be blamed for it
python3 -c "open('src/e.py','w').write(chr(10).join(f'e{i}={i}' for i in range(40)))"
git add -A
GIT_AUTHOR_DATE="2025-01-02T10:00:00" GIT_COMMITTER_DATE="2025-01-02T10:00:00" \
  git -c user.email=p@l -c user.name=p commit -qm "old work"
AEP_REVIEW_BLOCK=0 sh gate.sh | grep -q "no fresh-context review" && { echo "blamed the session for an old commit"; exit 1; }
exit 0
