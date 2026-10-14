#!/usr/bin/env bash
set -eu

SOURCE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/verify.sh"
TEMP="$(mktemp -d)"
trap 'rm -rf -- "$TEMP"' EXIT
BASH_BIN="$BASH"
mkdir -p "$TEMP/repo with spaces/scripts" "$TEMP/repo with spaces/apps/mobile" \
  "$TEMP/repo with spaces/apps/proxy" "$TEMP/bin" "$TEMP/outside"
cp "$SOURCE" "$TEMP/repo with spaces/scripts/verify.sh"
# Keep PATH isolated, including from real Flutter/npm installations.
for tool in dart flutter npm; do
  cat > "$TEMP/bin/$tool" <<'MOCK'
printf '%s|%s|%s\n' "$PWD" "${0##*/}" "$*" >> "$CALLS"
if [[ "${0##*/} $*" == "${FAIL_COMMAND:-}" ]]; then
  exit 23
fi
MOCK
  chmod +x "$TEMP/bin/$tool"
done
export CALLS="$TEMP/calls"

check_run() {
  local expected="$1" status=0
  : > "$CALLS"
  (cd "$TEMP/outside" && PATH="$TEMP/bin" "$BASH_BIN" \
    "$TEMP/repo with spaces/scripts/verify.sh") > "$TEMP/output" 2>&1 || status=$?
  if [[ "$status" != "$expected" ]]; then
    cat "$TEMP/output"
    printf 'FAIL: expected exit %s, got %s\n' "$expected" "$status"
    exit 1
  fi
}

check_run 0
[[ "$(wc -l < "$CALLS")" -eq 7 ]]
grep -Fq 'LULUS: seluruh 7 gerbang.' "$TEMP/output"
cat > "$TEMP/expected" <<EOF
$TEMP/repo with spaces/apps/mobile|dart|format --set-exit-if-changed .
$TEMP/repo with spaces/apps/mobile|flutter|analyze
$TEMP/repo with spaces/apps/mobile|flutter|test
$TEMP/repo with spaces/apps/mobile|flutter|build apk --debug
$TEMP/repo with spaces/apps/proxy|npm|run lint
$TEMP/repo with spaces/apps/proxy|npm|run typecheck
$TEMP/repo with spaces/apps/proxy|npm|test
EOF
diff -u "$TEMP/expected" "$CALLS"
printf 'PASS: all gates, correct directories/arguments, outside root with spaces\n'

export FAIL_COMMAND='flutter analyze'
check_run 1
[[ "$(wc -l < "$CALLS")" -eq 7 ]]
grep -Fq 'GAGAL: Mobile: analyze (exit 23)' "$TEMP/output"
grep -Fq 'GAGAL: 1 dari 7 gerbang gagal.' "$TEMP/output"
printf 'PASS: failed gate preserves status and remaining gates still run\n'
unset FAIL_COMMAND

rm "$TEMP/bin/flutter"
check_run 1
[[ "$(wc -l < "$CALLS")" -eq 4 ]]
grep -Fq 'GAGAL: Mobile: analyze (exit 127)' "$TEMP/output"
grep -Fq 'GAGAL: 3 dari 7 gerbang gagal.' "$TEMP/output"
printf 'PASS: missing tool is failure, not skipped success\n'
