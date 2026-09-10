#!/usr/bin/env bash
# Runs the gate suite twice, because a suite that has only ever been seen green
# proves nothing. The first run is against the real hook and must pass. The
# second is against a copy with the credential-deny leg cut out, and must FAIL
# on exactly the two cases that leg exists to catch. A red run that comes back
# green means the suite is not testing what it claims to test, so this script
# treats that as the build failure, not as a pass.
set -uo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
real_gate="$here/../../ch06-pristine/.claude/hooks/gate-aws-cli.sh"
suite="$here/test-gate-aws-cli.sh"

for tool in jq awk; do
  command -v "$tool" >/dev/null || { echo "missing dependency: $tool" >&2; exit 127; }
done
[ -f "$real_gate" ] || { echo "gate not found: $real_gate" >&2; exit 127; }

echo "green run: the gate as shipped"
if ! GATE="$real_gate" bash "$suite"; then
  echo "the suite fails against the real gate; fix that before reading further" >&2
  exit 1
fi

# Break one leg on purpose. Lines 32-36 of the gate are the credential-read
# branch; awk drops that if-block and leaves the rest of the classifier intact,
# so the two deny cases should now come back as something else.
broken=$(mktemp -t gate-aws-cli-broken.XXXXXX)
trap 'rm -f "$broken"' EXIT
awk '
  /^if \[\[ "\$command" == \*"get-secret-value"\*/ { skip = 1 }
  skip && /^fi$/                                   { skip = 0; next }
  !skip                                            { print }
' "$real_gate" >"$broken"
chmod +x "$broken"

if ! grep -q "get-secret-value" "$real_gate"; then
  echo "the gate no longer has a credential leg; this script needs updating" >&2
  exit 1
fi
if grep -q "get-secret-value" "$broken"; then
  echo "failed to remove the credential leg; the red run would be meaningless" >&2
  exit 1
fi

echo
echo "red run: the same suite against a gate with its deny leg removed"
red_output=$(GATE="$broken" bash "$suite" 2>&1)
red_status=$?
echo "$red_output"

if [ "$red_status" -eq 0 ]; then
  echo
  echo "BUILD FAILURE: the suite passed against a broken gate, so it is not" >&2
  echo "asserting the denies it claims to assert." >&2
  exit 1
fi

denied_cases=$(grep -c "expected deny" <<<"$red_output")
if [ "$denied_cases" -ne 2 ]; then
  echo
  echo "BUILD FAILURE: expected exactly 2 deny cases to go red, saw $denied_cases." >&2
  exit 1
fi

echo
echo "both runs behaved: green against the real gate, red on both deny cases"
echo "against the broken one. The suite has now been observed failing."
