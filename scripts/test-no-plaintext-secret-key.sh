#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
scanner="$script_directory/check-no-plaintext-secret-key.sh"
fixture_directory=$(mktemp -d)
trap 'rm -rf "$fixture_directory"' EXIT

negative_fixture="$fixture_directory/negative_settings.py"
cat > "$negative_fixture" <<'EOF'
# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'this-is-a-fake-non-functional-fixture-value'
EOF

if "$scanner" "$negative_fixture" >"$fixture_directory/negative.stdout" 2>"$fixture_directory/negative.stderr"; then
  echo "Expected the value-shaped SECRET_KEY fixture to fail" >&2
  exit 1
fi

if ! grep -Fxq "Hardcoded SECRET_KEY violation at $negative_fixture:2" "$fixture_directory/negative.stderr"; then
  echo "Expected a redacted violation location for the negative fixture" >&2
  exit 1
fi

if [[ -s "$fixture_directory/negative.stdout" ]] || grep -Fq 'fake-non-functional-fixture-value' "$fixture_directory/negative.stderr"; then
  echo "Scanner output was not redacted" >&2
  exit 1
fi

reference_fixture="$fixture_directory/reference_settings.py"
cat > "$reference_fixture" <<'EOF'
# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.environ.get('DJANGO_SECRET_KEY', '')
EOF

if ! "$scanner" "$reference_fixture" >"$fixture_directory/reference.stdout" 2>"$fixture_directory/reference.stderr"; then
  echo "Expected the environment-variable reference fixture to pass" >&2
  exit 1
fi

if [[ -s "$fixture_directory/reference.stderr" ]]; then
  echo "Expected no scanner stderr for the passing fixture" >&2
  exit 1
fi

echo "Plaintext SECRET_KEY scanner fixtures passed"
