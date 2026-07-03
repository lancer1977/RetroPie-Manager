# Validation

## Command

Run the root validation wrapper:

```bash
bash scripts/validate.sh
```

The wrapper performs a Linux-friendly smoke check. It verifies the expected
Django app layout, dependency manifests, launcher script, Makefile, and local
stewardship files. It also parses safe metadata files such as `package.json`,
`project/MANIFEST.xml`, and `project/assets.json`.

## Full Runtime Boundary

RetroPie-Manager is a legacy Python 2/Django 1.8 application with npm and Ruby
Compass asset tooling. Full install and runtime validation need:

- A RetroPie-compatible Linux/Raspberry Pi environment.
- Python 2-compatible virtualenv tooling.
- Dependencies from `pip-requirements/basic.txt`.
- npm packages from `package.json`.
- Ruby Bundler support for `compass/Gemfile` if rebuilding frontend assets.

The historical install path is:

```bash
make install
```

In the current Linux environment, `python` is Python 3.14 and Python 2 is not
installed. A Python 3 compile pass fails on expected Python 2-era syntax, so CI
uses the structural validation wrapper instead of claiming a full app runtime
check.

## Tests

No automated test suite is currently present. The repeatable health check
available in this environment is `scripts/validate.sh`.
