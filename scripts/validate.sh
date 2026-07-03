#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

required_paths=(
  "AGENTS.md"
  "README.md"
  "repo-state.md"
  "docs/index.md"
  "docs/validation.md"
  ".devstudio/project.yaml"
  ".github/workflows/ci.yml"
  "Makefile"
  "manage.py"
  "rpmanager.sh"
  "package.json"
  "Gruntfile.js"
  "compass/Gemfile"
  "pip-requirements/basic.txt"
  "pip-requirements/development.txt"
  "project/settings.py"
  "project/urls.py"
  "project/wsgi.py"
  "project/MANIFEST.xml"
  "project/assets.json"
)

for path in "${required_paths[@]}"; do
  if [[ ! -e "$path" ]]; then
    echo "Missing required path: $path" >&2
    exit 1
  fi
done

bash -n rpmanager.sh

python3 - <<'PY'
from pathlib import Path
import json
import xml.etree.ElementTree as ET

json.loads(Path("package.json").read_text())
json.loads(Path("project/assets.json").read_text())
ET.parse("project/MANIFEST.xml")

requirements = Path("pip-requirements/basic.txt").read_text()
if "django>=1.8,<1.9" not in requirements:
    raise SystemExit("pip-requirements/basic.txt no longer documents Django 1.8")
PY

echo "RetroPie-Manager repository shape validation passed."
