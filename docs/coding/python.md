---
title: Python
type: reference
status: active
updated: 2026-09-07
summary: ruff and black, typing expectations, and packaging layout.
---

# Python

## Tooling

| Concern | Tool | Config |
| --- | --- | --- |
| Lint | ruff | `pyproject.toml` |
| Format | black | `pyproject.toml`, line length 100 |
| Types | mypy, where the package ships types | `pyproject.toml` |
| Test | pytest | `pyproject.toml` |

ruff replaces flake8, isort, pyupgrade, and most plugin sets. Do not add those separately.

## Layout

`src/` layout for anything installable — it prevents the test suite from importing the working
directory instead of the installed package, which is a class of bug that only appears once the
package is published.

Ship `py.typed` when the package exports typed interfaces.

## Rules

- Type hints on public functions. Internal helpers where they help.
- No bare `except:`. Catch the exception you can handle.
- `pathlib` over `os.path`.
- f-strings over `%` and `.format()`.
- Standard library before a dependency. `argparse` is usually enough.

## Scripts

A utility script gets a `if __name__ == "__main__":` guard and an `argparse` interface, even
when it starts as a one-off. Both cost a minute and are what make it runnable a year later.
