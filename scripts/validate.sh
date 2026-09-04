#!/usr/bin/env bash
set -euo pipefail

./scripts/test-no-plaintext-secret-key.sh
./scripts/check-no-plaintext-secret-key.sh project/settings.py

node --check Gruntfile.js
python3 - <<'PY'
import json
from html.parser import HTMLParser
from pathlib import Path

json.loads(Path("project/assets.json").read_text(encoding="utf-8"))
parser = HTMLParser()
for path in Path("project/templates").glob("*.html"):
    parser.feed(path.read_text(encoding="utf-8", errors="ignore"))
print("RetroPie manager JavaScript, JSON, and HTML checks passed")
PY
