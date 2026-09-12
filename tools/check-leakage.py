#!/usr/bin/env python3
"""Fail when a tracked file contains infrastructure not on the allowlist.

Replaces a denylist that named the real domain, the real subnet, and two real
host names — in a public repository. The guard published what it guarded, and it
could only ever catch values someone had thought to enumerate.

This inverts it. `tools/allowlist.txt` names the values that may appear:
documentation-reserved ranges, RFC 2606 example domains, and the public third
parties this repository links to. Anything else that has the shape of
infrastructure is a finding. The allowlist is safe to publish because every
entry is reserved or already public, and unfamiliar values fail by default —
including a domain registered next year, which is the case the denylist missed.

An optional private supplement adds specific values that have no recognisable
shape (a project codename, a service nickname). It is additive: the public
allowlist stands alone, so a fresh clone with no supplement still gets real
protection.

Usage:
    python3 tools/check-leakage.py                  scan tracked files
    python3 tools/check-leakage.py --paths a.md b.md
    python3 tools/check-leakage.py --private ~/.config/xeroip/leakage.local.txt
"""

from __future__ import annotations

import argparse
import ipaddress
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ALLOWLIST = ROOT / "tools" / "allowlist.txt"

# Default location for the optional private supplement. Absent by default.
PRIVATE_DEFAULT = Path(
    os.environ.get("XEROIP_LEAKAGE_SUPPLEMENT", "")
) if os.environ.get("XEROIP_LEAKAGE_SUPPLEMENT") else (
    Path.home() / ".config" / "xeroip" / "leakage.local.txt"
)

# An octet-bounded pattern, so a four-part version string and a genuine address are
# distinguished by validity rather than by hoping four dotted numbers are rare.
# (A version string with four parts is the case this guards against.)
IPV4_RE = re.compile(
    r"\b((?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))"
    r"(/(?:3[0-2]|[12]?\d))?\b"
)

# Requires a dot and a plausible TLD, so bare words and file names do not match.
FQDN_RE = re.compile(
    r"\b((?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z]{2,24})\b", re.IGNORECASE
)

# Extensions that are never prose and would otherwise produce noise.
SKIP_SUFFIXES = {".png", ".jpg", ".jpeg", ".gif", ".webp", ".pdf", ".zip",
                 ".woff", ".woff2", ".ttf", ".otf", ".ico", ".lock"}
SKIP_NAMES = {"package-lock.json"}

# Test fixtures deliberately contain leak-shaped values so the failure path can
# be exercised. They are excluded from the repo-wide scan and asserted against
# directly by tests/test-leakage.sh, which is the only place they are read.
#
# The values inside them are fictional. Excluding a path from a leak scanner is
# how a real leak hides, so this exclusion is narrow, named, and the fixtures
# are reviewed on the same terms as anything else in a public repository.
SKIP_DIRS = {"tests/fixtures"}


def load_allowlist(path: Path) -> dict[str, list[str]]:
    """Read the sectioned allowlist. Unknown sections are an error, not ignored:
    a typo'd section header would otherwise silently drop every value under it."""
    known = {"ip-cidr", "ip-host", "domain", "credential-pattern", "tld",
             "tld-url-context-only"}
    sections: dict[str, list[str]] = {k: [] for k in known}
    current = None

    for lineno, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("[") and line.endswith("]"):
            current = line[1:-1]
            if current not in known:
                raise SystemExit(f"{path}:{lineno}: unknown section [{current}]")
            continue
        if current is None:
            raise SystemExit(f"{path}:{lineno}: value outside any section")
        sections[current].append(line.split("#")[0].strip())

    return sections


def load_private(path: Path) -> list[str]:
    """Specific values with no recognisable shape. Optional by design."""
    if not path.exists():
        return []
    out = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if line and not line.startswith("#"):
            out.append(line)
    return out


def tracked_files() -> list[Path]:
    result = subprocess.run(
        ["git", "-C", str(ROOT), "ls-files"],
        capture_output=True, text=True, check=True,
    )
    return [ROOT / p for p in result.stdout.splitlines() if p]


def registrable(host: str) -> str:
    """The last two labels, used to allow a whole domain rather than every
    subdomain of it. Deliberately naive — no public-suffix list — because the
    failure mode is over-reporting, which is the safe direction here."""
    parts = host.lower().rstrip(".").split(".")
    return ".".join(parts[-2:]) if len(parts) >= 2 else host.lower()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--paths", nargs="*", type=Path,
                        help="scan these files instead of everything tracked")
    parser.add_argument("--private", type=Path, default=PRIVATE_DEFAULT,
                        help="optional private supplement of specific values")
    parser.add_argument("--allowlist", type=Path, default=ALLOWLIST)
    args = parser.parse_args()

    allow = load_allowlist(args.allowlist)
    private = load_private(args.private)

    cidr_ok = [ipaddress.ip_network(c, strict=False) for c in allow["ip-cidr"]]
    host_ok = [ipaddress.ip_network(c, strict=False) for c in allow["ip-host"]]
    tlds = {t.lower() for t in allow["tld"]}
    tlds_url_only = {t.lower() for t in allow["tld-url-context-only"]}
    domain_ok = {d.lower() for d in allow["domain"]}
    domain_ok |= {registrable(d) for d in allow["domain"]}
    cred_res = [re.compile(p) for p in allow["credential-pattern"]]
    private_res = [re.compile(p) for p in private]

    files = args.paths if args.paths else tracked_files()
    findings: list[tuple[Path, int, str, str]] = []
    scanned = 0

    for path in files:
        if path.suffix.lower() in SKIP_SUFFIXES or path.name in SKIP_NAMES:
            continue
        if not args.paths and any(d in str(path).replace("\\", "/") for d in SKIP_DIRS):
            continue
        # The allowlist necessarily contains every allowed value; scanning it
        # against itself proves nothing and reports everything.
        if path.resolve() == args.allowlist.resolve():
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, FileNotFoundError, IsADirectoryError):
            continue
        scanned += 1

        for lineno, line in enumerate(text.splitlines(), 1):
            for match, prefix in IPV4_RE.findall(line):
                try:
                    addr = ipaddress.ip_address(match)
                except ValueError:
                    continue
                if prefix:
                    net = ipaddress.ip_network(f"{match}{prefix}", strict=False)
                    if not any(net.subnet_of(ok) for ok in cidr_ok):
                        findings.append((path, lineno, f"{match}{prefix}",
                                         "CIDR not in [ip-cidr]"))
                elif not any(addr in ok for ok in host_ok):
                    findings.append((path, lineno, match,
                                     "host address outside the documentation ranges "
                                     "(RFC 5737: 192.0.2.0/24, 198.51.100.0/24, "
                                     "203.0.113.0/24)"))

            for host in FQDN_RE.findall(line):
                low = host.lower()
                suffix = low.rsplit(".", 1)[-1]
                # A dotted token is only a hostname if its last label is a real
                # suffix. Everything else is an identifier: fs.readFileSync,
                # os.path, h1.page. Without this the scanner is unusable.
                if suffix in tlds_url_only:
                    # Ambiguous with a file extension, so require URL context.
                    if not re.search(r"(?://|@)" + re.escape(host), line, re.I):
                        continue
                elif suffix not in tlds:
                    continue
                if low in domain_ok or registrable(low) in domain_ok:
                    continue
                findings.append((path, lineno, host, "domain not in [domain]"))

            for rx in cred_res:
                if rx.search(line):
                    findings.append((path, lineno, rx.pattern, "credential shape"))
            for rx in private_res:
                if rx.search(line):
                    findings.append((path, lineno, "<redacted>",
                                     "matches the private supplement"))

    for path, lineno, value, why in findings:
        # --paths may point outside the repository (fixtures, ad-hoc checks), so
        # relative_to would raise. Report whatever form is readable.
        try:
            rel = path.relative_to(ROOT)
        except ValueError:
            rel = path
        print(f"{rel}:{lineno}: {value}  — {why}")

    if findings:
        print(f"\n{len(findings)} finding(s) in {scanned} file(s).\n")
        print("This repository is public. Use a placeholder instead:")
        print("  domains   example.internal, example.com")
        print("  addresses 192.0.2.10 (TEST-NET-1), or a CIDR when a range is meant")
        print("  services  service-a, service-b")
        print("\nIf the value is legitimately public — a third party you link to —")
        print("add it to tools/allowlist.txt with a comment saying why.")
        print("\nIf this has already been pushed, the value is public. Rotate what it")
        print("protects and treat the history as disclosed; a later commit does not")
        print("retract it.")
        return 1

    supplement = "with" if private else "without"
    print(f"leakage: {scanned} file(s) clean ({supplement} a private supplement)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
