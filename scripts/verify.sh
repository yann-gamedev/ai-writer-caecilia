#!/usr/bin/env bash
set -u

SCRIPT_DIR="${BASH_SOURCE[0]%/*}"
ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)" || exit 1
failures=0
results=()

run_gate() {
  local directory="$1" label="$2" status
  shift 2
  printf '\n>>> %s\n' "$label"
  if (cd -- "$ROOT/$directory" && "$@"); then
    results+=("LULUS: $label")
  else
    status=$?
    results+=("GAGAL: $label (exit $status)")
    failures=$((failures + 1))
  fi
}

# Run every gate even after failures so the summary never hides an unchecked gate.
run_gate apps/mobile 'Mobile: format' dart format --set-exit-if-changed .
run_gate apps/mobile 'Mobile: analyze' flutter analyze
run_gate apps/mobile 'Mobile: test' flutter test
run_gate apps/mobile 'Mobile: APK debug' flutter build apk --debug
run_gate apps/proxy 'Proxy: lint' npm run lint
run_gate apps/proxy 'Proxy: typecheck' npm run typecheck
run_gate apps/proxy 'Proxy: test' npm test

printf '\n=== Ringkasan verifikasi ===\n'
printf '%s\n' "${results[@]}"
if (( failures > 0 )); then
  printf 'GAGAL: %s dari 7 gerbang gagal.\n' "$failures"
  exit 1
fi
printf 'LULUS: seluruh 7 gerbang.\n'
