# AGENTS.md

## Purpose

This repository contains the legacy RetroPie-Manager Django application, a
RetroPie-focused fork of Recalbox-Manager.

## Workflow

- Read `README.md`, `repo-state.md`, and `docs/index.md` before changing files.
- Keep maintenance changes small and traceable.
- Do not port the Python 2/Django 1.8 code or asset pipeline unless that is the
  named task.
- Treat full runtime validation as RetroPie-era Python 2 environment work.

## Validation

Run the repo-native validation script:

```bash
bash scripts/validate.sh
```

The script performs a Linux-friendly repository shape and metadata smoke. Full
application startup needs the legacy Python/Django/RetroPie environment
documented in `docs/validation.md`.
