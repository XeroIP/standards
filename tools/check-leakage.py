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

The repository scanned is the one the command runs in, not the one this file
lives in. A consuming repository runs a vendored copy at
`.standards/tools/check-leakage.py`; resolving the scan from the script's own
location read only `.standards/` and never the consumer's files.

What counts as a hostname depends on where it is written. In Markdown prose,
outside code spans and fences, a dotted word is a hostname when its last label
is any suffix IANA has delegated (`tools/iana-tlds.txt`, refreshed weekly by
`.github/workflows/refresh-tld-list.yml`) or a private-use name such as `.lan`
or `.home`. In code and config files, and in code spans and fences, only the
short `[tld]` list counts, because there a dotted word is usually an
identifier.

Two gaps are accepted, each for a stated reason:

- A host on one of the suffixes that are also common file extensions (`.md`,
  `.py`, `.sh` and the rest of `[tld-prose-url-only]`) is reported in prose
  only inside a URL. Counting them bare reported 93 filenames in this
  repository's prose (measured 2026-10-09), and a gate that reports every
  filename stops being read.
  The list was checked against the maintainer's own domains: no overlap.
- A host on an unusual suffix written in code, or in a code span or fence, is
  not reported. Counting every suffix there gave 81 findings in this
  repository's code (measured 2026-10-09), every one false: identifiers such
  as `m.group` and `obj.id`.

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

# Where this file and its allowlist live: the standards repo, or a consumer's
# `.standards/`. Not what gets scanned; see repo_root().
SCRIPT_ROOT = Path(__file__).resolve().parent.parent
ALLOWLIST = SCRIPT_ROOT / "tools" / "allowlist.txt"
IANA_TLDS = SCRIPT_ROOT / "tools" / "iana-tlds.txt"

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

# A run of hex groups and colons, validated by ipaddress afterwards. The
# boundaries exclude a dot so `::ffff:192.0.2.1` is left to the IPv4 pattern.
IPV6_RE = re.compile(
    r"(?<![\w:.])((?:[0-9a-f]{0,4}:){2,7}[0-9a-f]{0,4})"
    r"(/(?:12[0-8]|1[01]\d|[1-9]?\d))?(?![\w:.])", re.IGNORECASE
)

HOST_FINDING = ("host address outside the documentation ranges (RFC 5737: "
                "192.0.2.0/24, 198.51.100.0/24, 203.0.113.0/24; RFC 3849: 2001:db8::/32)")

# Requires a dot and a plausible TLD, so bare words and file names do not match.
FQDN_RE = re.compile(
    r"\b((?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z]{2,24})\b", re.IGNORECASE
)

# Markdown: its prose is read against every delegated suffix.
PROSE_SUFFIXES = {".md", ".markdown"}
FENCE_RE = re.compile(r"^ {0,3}(`{3,}|~{3,})")
CODE_SPAN_RE = re.compile(r"(`+)(.+?)\1")

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
# are reviewed on the same terms as anything else in a public repository. Each
# entry is a directory relative to the repository root, matched as a path
# prefix: `notes/tests/fixtures-old/` is scanned.
SKIP_DIRS = {"tests/fixtures/leakage", "tests/fixtures/allowlist-extra"}


def load_allowlist(path: Path) -> dict[str, list[str]]:
    """Read the sectioned allowlist. Unknown sections are an error, not ignored:
    a typo'd section header would otherwise silently drop every value under it."""
    known = {"ip-cidr", "ip-host", "domain", "credential-pattern", "tld",
             "tld-url-context-only", "tld-private-use", "tld-prose-url-only"}
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


def load_iana(path: Path) -> set[str]:
    """IANA's delegated suffixes, lower-cased. A missing list is an error: the
    prose check would otherwise fall back to the short list without a word."""
    if not path.exists():
        print(f"error: {path} is missing. Run: python3 tools/update-tlds.py",
              file=sys.stderr)
        raise SystemExit(2)
    return {line.strip().lower() for line in path.read_text(encoding="utf-8").splitlines()
            if line.strip() and not line.startswith("#")}


def markdown_parts(text: str):
    """Each line of a Markdown file as (lineno, prose, code): code is whatever
    sits in a fence or a code span, prose is the rest."""
    fence = None
    for lineno, line in enumerate(text.splitlines(), 1):
        m = FENCE_RE.match(line)
        if fence:
            if (m and m.group(1)[0] == fence[0] and len(m.group(1)) >= len(fence)
                    and not line.strip().strip(fence[0])):
                fence = None
            yield lineno, "", line
        elif m:
            fence = m.group(1)
            yield lineno, "", line
        else:
            spans = [m.group(0) for m in CODE_SPAN_RE.finditer(line)]
            yield lineno, CODE_SPAN_RE.sub(" ", line), " ".join(spans)


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


def repo_root() -> Path | None:
    """The repository the command runs in, or None outside one."""
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True,
    )
    return Path(result.stdout.strip()) if result.returncode == 0 else None


def tracked_files(root: Path) -> list[Path]:
    result = subprocess.run(
        ["git", "-C", str(root), "ls-files"],
        capture_output=True, text=True, check=True,
    )
    return [root / p for p in result.stdout.splitlines() if p]


def domain_allowed(host: str, allowed: list[str]) -> bool:
    """An allowlisted domain permits itself and its own subdomains, never its
    siblings. Listing `xeroip.github.io` must not permit every other site on the
    same shared host. The rule this replaced allowed an entry's last two labels,
    so one host under a shared suffix opened the whole suffix."""
    return any(host == d or host.endswith("." + d) for d in allowed)


def looks_like_ipv6(token: str) -> bool:
    """ipaddress accepts a Python slice (`0::2`) and a hex word pair (`Add::Dec`)
    as IPv6. A written address has a digit, and either three groups or one group
    of three or more digits, as `2001:db8::10` has both."""
    groups = [g for g in token.split(":") if g]
    return (any(c.isdigit() for c in token)
            and (len(groups) >= 3 or any(len(g) >= 3 for g in groups)))


def domain_findings(text: str, bare: set[str], url_only: set[str],
                    allowed: list[str], url_mark: str = r"(?://|@)") -> list[str]:
    """The hostnames in text that are not allowlisted. A dotted word is only a
    hostname when its last label is in bare, or in url_only with url_mark (a
    `://` or `@`) before it. Everything else is an identifier: fs.readFileSync,
    os.path."""
    out = []
    for host in FQDN_RE.findall(text):
        low = host.lower()
        suffix = low.rsplit(".", 1)[-1]
        if suffix in url_only:
            if not re.search(url_mark + re.escape(host), text, re.I):
                continue
        elif suffix not in bare:
            continue
        if not domain_allowed(low, allowed):
            out.append(host)
    return out


def ip_finding(written: str, prefix: str, cidr_ok: list, host_ok: list) -> str | None:
    """Why an address or CIDR may not be written, or None if it may.

    A host is permitted inside [ip-host]. A block is permitted when [ip-cidr]
    lists it exactly, or when it sits inside [ip-host], whose every address may
    be written anyway. A subnet of a private block is not the block:
    `192.168.0.0/16` says "a private network", and a /24 inside it names the one
    in use. So does an address written with its prefix, or a single-address
    block such as a /32: each is a host, and is checked as one.
    The rule this replaced tested containment in [ip-cidr], so a listed
    `0.0.0.0/0` permitted every CIDR there is."""
    addr = ipaddress.ip_address(written)
    in_hosts = any(addr in ok for ok in host_ok)
    if not prefix:
        return None if in_hosts else HOST_FINDING
    net = ipaddress.ip_network(f"{written}{prefix}", strict=False)
    if addr != net.network_address or net.num_addresses == 1:
        return None if in_hosts else HOST_FINDING
    if net in cidr_ok or any(net.version == ok.version and net.subnet_of(ok)
                             for ok in host_ok):
        return None
    return "CIDR not in [ip-cidr]"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--paths", nargs="*", type=Path,
                        help="scan these files instead of everything tracked")
    parser.add_argument("--private", type=Path, default=PRIVATE_DEFAULT,
                        help="optional private supplement of specific values")
    parser.add_argument("--allowlist", type=Path, default=ALLOWLIST)
    parser.add_argument("--allowlist-extra", type=Path, default=None,
                        help="a repo's own permitted values, merged into the allowlist")
    args = parser.parse_args()

    # A path that does not exist is an error, not an empty scan. Passing one
    # returned "clean", so a typo in a CI invocation would report success while
    # checking nothing — the vacuous pass this tool exists to prevent elsewhere.
    missing = [p for p in (args.paths or []) if not p.exists()]
    if missing:
        for p in missing:
            print(f"error: no such path: {p}", file=sys.stderr)
        return 2

    allow = load_allowlist(args.allowlist)

    # A consuming repository's own legitimately-public values are merged in
    # rather than replacing the shared list. Pointing --allowlist at a repo file
    # would drop every shared entry, so a repo could weaken the common rules by
    # declaring one of its own — the opposite of what this is for. (--private is
    # not this: it adds values to *report*, not to permit.)
    if args.allowlist_extra and args.allowlist_extra.exists():
        for section, values in load_allowlist(args.allowlist_extra).items():
            allow[section].extend(values)
    private = load_private(args.private)

    cidr_ok = [ipaddress.ip_network(c, strict=False) for c in allow["ip-cidr"]]
    host_ok = [ipaddress.ip_network(c, strict=False) for c in allow["ip-host"]]
    tlds = {t.lower() for t in allow["tld"]}
    tlds_url_only = {t.lower() for t in allow["tld-url-context-only"]}
    # Prose: every delegated suffix and the private-use names, less those that
    # are also file extensions, which need a URL around them.
    prose_url_only = {t.lower() for t in allow["tld-prose-url-only"]}
    prose_bare = (load_iana(IANA_TLDS) | tlds
                  | {t.lower() for t in allow["tld-private-use"]}) - prose_url_only
    prose_url = prose_url_only | (tlds_url_only - prose_bare)
    domain_ok = [d.lower().rstrip(".") for d in allow["domain"]]
    cred_res = [re.compile(p) for p in allow["credential-pattern"]]
    private_res = [re.compile(p) for p in private]

    root = repo_root()
    if root is None and not args.paths:
        print("error: not inside a git repository. Run from the repository to scan, "
              "or pass --paths.", file=sys.stderr)
        return 2
    files = args.paths if args.paths else tracked_files(root)
    findings: list[tuple[Path, int, str, str]] = []
    scanned = 0

    for path in files:
        if path.suffix.lower() in SKIP_SUFFIXES or path.name in SKIP_NAMES:
            continue
        if not args.paths:
            rel = path.relative_to(root).as_posix()
            if any(rel == d or rel.startswith(d + "/") for d in SKIP_DIRS):
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

        lines = text.splitlines()
        if path.suffix.lower() in PROSE_SUFFIXES:
            parts = markdown_parts(text)
        else:
            parts = ((n, "", line) for n, line in enumerate(lines, 1))

        for lineno, prose, code in parts:
            line = lines[lineno - 1]
            # In prose an `@` marks a host only after a user part, as in an
            # address: `@STATUS.md` is an agent-file import, not a host.
            hosts = (domain_findings(prose, prose_bare, prose_url, domain_ok,
                                     r"(?://|\w@)")
                     + domain_findings(code, tlds, tlds_url_only, domain_ok))
            for host in hosts:
                findings.append((path, lineno, host, "domain not in [domain]"))

            candidates = IPV4_RE.findall(line) + [
                (m, p) for m, p in IPV6_RE.findall(line) if looks_like_ipv6(m)]
            for match, prefix in candidates:
                try:
                    why = ip_finding(match, prefix, cidr_ok, host_ok)
                except ValueError:
                    continue
                if why:
                    findings.append((path, lineno, f"{match}{prefix}", why))

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
            rel = path.resolve().relative_to(root) if root else path
        except ValueError:
            rel = path
        print(f"{rel}:{lineno}: {value}  — {why}")

    if findings:
        print(f"\n{len(findings)} finding(s) in {scanned} file(s).\n")
        print("This repository is public. Use a placeholder instead:")
        print("  domains   example.internal, example.com")
        print("  addresses 192.0.2.10 (TEST-NET-1) or 2001:db8::10, or a listed CIDR")
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
