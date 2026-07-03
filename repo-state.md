# RetroPie-Manager Repo State

Last reviewed: 2026-07-03

## Purpose

`RetroPie-Manager` is an unmaintained Recalbox-Manager fork for RetroPie 4.x. It
provides a Django web UI for managing RetroPie system status, configuration,
BIOS files, and ROMs.

## Current State

- Main app entry point: `manage.py`.
- Service launcher: `rpmanager.sh`.
- Django settings and URL routing live under `project/`.
- Python dependencies live under `pip-requirements/`.
- Frontend asset tooling uses `package.json`, `Gruntfile.js`, and
  `compass/Gemfile`.
- The codebase targets a Python 2/Django 1.8 era runtime.

## Native Validation

```bash
bash scripts/validate.sh
```

The current validation path checks repository shape and safe metadata parsing.
Full startup should be verified on a RetroPie-compatible Python 2 environment.
