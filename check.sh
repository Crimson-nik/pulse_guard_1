#!/usr/bin/env bash
# Full verification. Run from the repository root.
#
#   1. regenerates the Python fixtures from the reference implementation
#   2. runs the core tests, which compare the Dart port against those fixtures
#   3. analyses and tests the app
#
# Fails on the first problem. No network needed once dependencies are fetched.

set -uo pipefail
cd "$(dirname "$0")"

# Absolute paths: the core tests run inside packages/ppg_core, where a
# relative ./ sdk path would no longer resolve.
FLUTTER=${FLUTTER:-$PWD/.toolchain/flutter/bin/flutter}
DART=${DART:-$PWD/.toolchain/flutter/bin/dart}
export PUB_CACHE=${PUB_CACHE:-$PWD/.toolchain/pub-cache}

if [ ! -x "$FLUTTER" ]; then
  FLUTTER=$(command -v flutter || true)
  DART=$(command -v dart || true)
fi
if [ -z "${FLUTTER:-}" ] || [ ! -x "$FLUTTER" ]; then
  echo "flutter not found. Set FLUTTER=/path/to/flutter/bin/flutter" >&2
  exit 1
fi

step() { printf '\n\033[1m== %s\033[0m\n' "$1"; }

step "Regenerating fixtures from the Python reference"
python3 tools/pyref/ppg_reference.py || exit 1

step "Core tests (Dart port against the reference)"
( cd packages/ppg_core && "$DART" test ) || exit 1

step "Static analysis"
"$FLUTTER" analyze || exit 1

step "App tests"
"$FLUTTER" test || exit 1

step "Agreement tool smoke test"
python3 tools/pyref/agreement.py --help >/dev/null || exit 1

printf '\n\033[1;32mAll checks passed.\033[0m\n'
echo "Build an APK with: $FLUTTER build apk"
