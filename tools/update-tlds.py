#!/usr/bin/env python3
"""Fetch IANA's list of delegated top-level domains into tools/iana-tlds.txt.

check-leakage.py reads that file to decide which dotted words in Markdown prose
are hostnames. A short hand-kept list missed a personal domain on any suffix
nobody had thought to add, which is the case an allowlist exists to catch.

The file is IANA's own, byte for byte, so its provenance can be checked against
the source. It is rewritten only when the set of suffixes changes. IANA bumps
the version line every day, and a commit per header change would bury the
commits that matter.

A truncated or garbled download must not shrink the list: every suffix it drops
is one the scanner stops reporting. So a fetch is validated before it is
written, and a result under MIN_ENTRIES is refused.

Usage:
    python3 tools/update-tlds.py            fetch; rewrite the file if the set changed
    python3 tools/update-tlds.py --check    validate the committed file, offline

Exit status: 0 on success, 1 when --check finds the committed file invalid,
2 when a fetch fails or returns something that is not the list.
"""

from __future__ import annotations

import argparse
import re
import sys
import urllib.request
from pathlib import Path

SOURCE = "https://data.iana.org/TLD/tlds-alpha-by-domain.txt"
TARGET = Path(__file__).resolve().parent / "iana-tlds.txt"

# The root zone has held over 1,400 suffixes since 2016. A list far short of
# that is a failed download, not a policy change.
MIN_ENTRIES = 1000

LABEL_RE = re.compile(r"^[A-Z0-9-]+$")


def parse(text: str) -> set[str]:
    """The suffixes in IANA's format, or ValueError naming what is wrong."""
    lines = text.splitlines()
    if not lines or not lines[0].startswith("# Version "):
        raise ValueError("first line is not IANA's '# Version' header")
    labels = [line.strip() for line in lines[1:] if line.strip()]
    bad = [label for label in labels if not LABEL_RE.match(label)]
    if bad:
        raise ValueError(f"{len(bad)} line(s) are not suffixes, first: {bad[0]!r}")
    if len(set(labels)) != len(labels):
        raise ValueError("duplicate suffixes")
    if len(labels) < MIN_ENTRIES:
        raise ValueError(f"{len(labels)} suffixes, fewer than {MIN_ENTRIES}")
    return set(labels)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--check", action="store_true",
                        help="validate the committed file without fetching")
    args = parser.parse_args()

    current = TARGET.read_text(encoding="utf-8") if TARGET.exists() else ""

    if args.check:
        try:
            labels = parse(current)
        except ValueError as e:
            print(f"{TARGET.name}: {e}", file=sys.stderr)
            return 1
        print(f"{TARGET.name}: {len(labels)} suffixes, {current.splitlines()[0][2:]}")
        return 0

    try:
        with urllib.request.urlopen(SOURCE, timeout=30) as response:
            fetched = response.read().decode("ascii")
        new = parse(fetched)
    except (OSError, UnicodeDecodeError, ValueError) as e:
        print(f"error: {SOURCE}: {e}", file=sys.stderr)
        return 2

    try:
        old = parse(current)
    except ValueError:
        old = set()

    if new == old:
        print(f"unchanged: {len(new)} suffixes ({fetched.splitlines()[0][2:]})")
        return 0

    TARGET.write_text(fetched, encoding="utf-8")
    added, removed = sorted(new - old), sorted(old - new)
    print(f"updated: {len(new)} suffixes, {len(added)} added, {len(removed)} removed")
    if old:
        for label in added:
            print(f"  + {label.lower()}")
        for label in removed:
            print(f"  - {label.lower()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
