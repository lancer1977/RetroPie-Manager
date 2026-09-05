#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 SETTINGS_FILE" >&2
  exit 2
fi

settings_file=$1
if [[ ! -f "$settings_file" ]]; then
  echo "Settings file not found: $settings_file" >&2
  exit 2
fi

# Flag a Django SECRET_KEY assigned a literal quoted string (a value-shaped
# secret committed to source control), without ever printing the matching
# value. An environment-variable lookup such as
# `SECRET_KEY = os.environ.get('DJANGO_SECRET_KEY', '')` or
# `SECRET_KEY = os.getenv('DJANGO_SECRET_KEY')` is not a violation -- only a
# non-empty literal assigned directly to SECRET_KEY is.
readonly literal_secret_key_pattern="^[[:space:]]*SECRET_KEY[[:space:]]*=[[:space:]]*['\"][^'\"]+['\"]"
readonly env_lookup_pattern='os\.(environ|getenv)'

line_number=0
violations=0

while IFS= read -r line || [[ -n "$line" ]]; do
  ((line_number += 1))
  if [[ "$line" =~ $literal_secret_key_pattern ]] && [[ ! "$line" =~ $env_lookup_pattern ]]; then
    echo "Hardcoded SECRET_KEY violation at $settings_file:$line_number" >&2
    ((violations += 1))
  fi
done < "$settings_file"

if ((violations > 0)); then
  exit 1
fi

echo "No hardcoded SECRET_KEY literal found in $settings_file"
