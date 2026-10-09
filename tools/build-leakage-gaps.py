#!/usr/bin/env python3
"""Write the measured cost of check-leakage.py's accepted gaps into its docstring.

The docstring justifies two gaps with counts measured over this repository: how
many filenames the file-extension suffixes would report if counted bare in
prose, and how many findings every suffix would give in code. A count written
by hand goes stale without anyone noticing, which is the defect the audit kept
finding in this repository's own prose. So this measures both with the
scanner's own rules and rewrites the two numbers, and --check fails when the
committed numbers no longer match the tree.

Usage:
    python3 tools/build-leakage-gaps.py           rewrite the counts
    python3 tools/build-leakage-gaps.py --check   exit 1 if they are stale
"""

from __future__ import annotations

import argparse
import importlib.util
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCANNER = ROOT / "tools" / "check-leakage.py"

# Each sentence the counts live in, with the number as its one group.
SENTENCES = (
    re.compile(r"(reported )\d+( filenames in prose)"),
    re.compile(r"(gives )\d+( findings in code)"),
)


def load_scanner():
    spec = importlib.util.spec_from_file_location("check_leakage", SCANNER)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def measure(scanner) -> tuple[int, int]:
    """(filenames on the extension suffixes in prose, findings in code), each
    counted as if the accepted gap were closed."""
    allow = scanner.load_allowlist(scanner.ALLOWLIST)
    bare, url_only = scanner.prose_suffixes(allow)
    collide = {t.lower() for t in allow["tld-prose-url-only"]}
    domains = [d.lower().rstrip(".") for d in allow["domain"]]
    filenames = code = 0
    for path in scanner.tracked_files(ROOT):
        if scanner.skipped(path, ROOT, False, scanner.ALLOWLIST):
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, FileNotFoundError, IsADirectoryError):
            continue
        if path.suffix.lower() in scanner.PROSE_SUFFIXES:
            for _, prose, _ in scanner.markdown_parts(text):
                hosts = scanner.domain_findings(prose, bare | collide, set(), domains)
                filenames += sum(h.lower().rsplit(".", 1)[-1] in collide for h in hosts)
        else:
            for line in text.splitlines():
                code += len(scanner.domain_findings(line, bare, url_only, domains,
                                                    scanner.IMPORT_SUFFIXES))
    return filenames, code


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--check", action="store_true",
                        help="fail if the committed counts differ from the tree")
    args = parser.parse_args()

    text = SCANNER.read_text(encoding="utf-8")
    counts = measure(load_scanner())
    out = text
    for rx, n in zip(SENTENCES, counts):
        if len(rx.findall(out)) != 1:
            print(f"error: {SCANNER.name} must hold exactly one '{rx.pattern}'",
                  file=sys.stderr)
            return 2
        out = rx.sub(lambda m, n=n: f"{m.group(1)}{n}{m.group(2)}", out)

    if args.check:
        if out != text:
            print(f"{SCANNER.name}: the gap counts are stale; the tree gives "
                  f"{counts[0]} filenames in prose and {counts[1]} findings in code.\n"
                  "Run: python3 tools/build-leakage-gaps.py", file=sys.stderr)
            return 1
        print(f"{SCANNER.name}: gap counts match the tree ({counts[0]}, {counts[1]})")
        return 0

    SCANNER.write_text(out, encoding="utf-8")
    print(f"{SCANNER.name}: {counts[0]} filenames in prose, {counts[1]} findings in code")
    return 0


if __name__ == "__main__":
    sys.exit(main())
