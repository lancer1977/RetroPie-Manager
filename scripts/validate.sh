#!/usr/bin/env bash
set -euo pipefail

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
