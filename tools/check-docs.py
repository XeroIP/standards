#!/usr/bin/env python3
"""Validate a documentation tree against the documentation standard.

Every rule here is one the standard claims is enforced. A standard that names an
enforcement mechanism it does not have is worse than one that admits a rule is a
review item, so this file and docs/documentation/ are kept in step deliberately.

Checks:
  front matter   required keys, known keys only, enum values, date format,
                 superseded_by present when status is superseded
  naming         lowercase-hyphenated, no ordinal prefix outside adr/,
                 dated pages lead with an ISO date
  links          every relative Markdown link resolves to a file that exists
  headings       the body H1 matches the front matter title
  ops-log        services and a change_type from the allowed set
  incidents      required sections present, in order
  adr            id matches filename, no numbering gap

Usage:
    python3 tools/check-docs.py docs/
    python3 tools/check-docs.py docs/ --json
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import date
from pathlib import Path

REQUIRED = {"title", "type", "status", "updated"}
KNOWN = REQUIRED | {
    "summary", "tags", "services", "issue", "supersedes", "superseded_by",
    "severity_ui", "id", "date", "deciders", "severity", "window", "data_loss",
    "revision", "change_type",
}
TYPES = {"tutorial", "how-to", "reference", "explanation", "adr", "incident",
         "ops-log", "project"}
STATUSES = {"draft", "active", "superseded", "archived",
            "proposed", "accepted", "rejected", "deprecated"}
SEVERITY_UI_ALLOWED = {"incident", "how-to", "reference"}

# What an ops-log entry was. Named change_type because `type` is already the
# document type: the standard asked for both under one key, which no page could
# satisfy, and nothing caught it because only `services` was ever enforced.
CHANGE_TYPES = {"change", "investigation", "maintenance", "incident-followup"}

INCIDENT_SECTIONS = [
    "overview", "impact and scope", "timeline", "technical findings",
    "root cause analysis", "resolution and recovery",
    "corrective and preventive actions", "monitoring and observability lessons",
    "monitoring plan", "open questions", "appendix: evidence",
    "appendix: investigation walkthrough",
]

NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*\.md$")
DATED_RE = re.compile(r"^\d{4}-\d{2}-\d{2}-[a-z0-9]+(-[a-z0-9]+)*\.md$")
ADR_RE = re.compile(r"^(\d{4})-[a-z0-9]+(-[a-z0-9]+)*\.md$")
ORDINAL_RE = re.compile(r"^\d+[-_]")
LINK_RE = re.compile(r"(?<!\!)\[[^\]]*\]\(([^)#\s]+)(?:#[^)]*)?\)")

problems: list[dict] = []


def fail(path: Path, message: str, line: int = 0) -> None:
    problems.append({"file": str(path), "line": line, "message": message})


def parse_front_matter(text: str) -> tuple[dict | None, int]:
    """Return (mapping, body_start_line). Nested blocks are recorded as present
    without parsing their contents — only top-level keys are validated here."""
    if not text.startswith("---\n"):
        return None, 0
    end = text.find("\n---", 4)
    if end == -1:
        return None, 0
    block = text[4:end]
    data: dict[str, str] = {}
    for raw in block.split("\n"):
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        if raw.startswith((" ", "\t")):      # nested under the previous key
            continue
        m = re.match(r"^([\w_]+):\s*(.*)$", raw)
        if m:
            data[m.group(1)] = m.group(2).strip()
    return data, text[:end].count("\n") + 2


def check_front_matter(path: Path, fm: dict | None) -> None:
    if fm is None:
        fail(path, "no front matter")
        return

    for key in sorted(REQUIRED - fm.keys()):
        fail(path, f"front matter missing required key: {key}")
    for key in sorted(fm.keys() - KNOWN):
        fail(path, f"front matter has unknown key: {key} (a typo here silently "
                   f"drops the page from generated indexes)")

    doc_type = fm.get("type", "").strip("\"'")
    if doc_type and doc_type not in TYPES:
        fail(path, f"type '{doc_type}' is not one of {sorted(TYPES)}")

    status = fm.get("status", "").strip("\"'")
    if status and status not in STATUSES:
        fail(path, f"status '{status}' is not one of {sorted(STATUSES)}")
    if status == "superseded" and not fm.get("superseded_by"):
        fail(path, "status is superseded but superseded_by is missing")

    updated = fm.get("updated", "").strip("\"'")
    if updated:
        try:
            date.fromisoformat(updated)
        except ValueError:
            fail(path, f"updated '{updated}' is not YYYY-MM-DD")

    sev = fm.get("severity_ui", "").strip("\"'").lower()
    if sev == "true" and doc_type not in SEVERITY_UI_ALLOWED:
        fail(path, f"severity_ui is only allowed on {sorted(SEVERITY_UI_ALLOWED)} pages, "
                   f"not '{doc_type}'")

    if doc_type == "incident":
        for key in ("services", "severity", "window", "data_loss"):
            if key not in fm:
                fail(path, f"incident page missing required key: {key}")
    if doc_type == "ops-log":
        if "services" not in fm:
            fail(path, "ops-log entry missing required key: services")
        change_type = fm.get("change_type", "").strip("\"'")
        if not change_type:
            fail(path, "ops-log entry missing required key: change_type")
        elif change_type not in CHANGE_TYPES:
            fail(path, f"change_type '{change_type}' is not one of {sorted(CHANGE_TYPES)}")
    if doc_type == "project" and "services" not in fm:
        fail(path, "project record missing required key: services")


def check_name(path: Path, root: Path) -> None:
    name = path.name
    rel = path.relative_to(root)
    parent = rel.parts[0] if len(rel.parts) > 1 else ""

    if name == "README.md":
        return

    if parent == "adr":
        if not ADR_RE.match(name):
            fail(path, "ADR filename must be NNNN-short-slug.md")
        return

    # A leading ISO date is resolved before the ordinal rule, because `2026-...`
    # matches both. Testing the ordinal rule first made every correctly named
    # dated page fail as an ordinal, and left the rule below unreachable — the
    # standard named an enforcement it did not have. The two are distinguishable:
    # a date sorts chronologically and means something, a counter only encodes
    # position, which is the thing the naming rule forbids putting in a path.
    dated = bool(DATED_RE.match(name))

    if parent in {"ops-log", "incidents", "projects"}:
        if not dated:
            fail(path, f"pages under {parent}/ must be named YYYY-MM-DD-slug.md")
        return

    if not dated and ORDINAL_RE.match(name):
        fail(path, "ordinal prefix in filename — ordering belongs in the navigation "
                   "config, not the path (see docs/documentation/naming.md)")
        return

    if not NAME_RE.match(name):
        fail(path, "filename must be lowercase-hyphenated and end in .md")


FENCE_RE = re.compile(r"^\s*(```|~~~)")
CODE_SPAN_RE = re.compile(r"(`+)(?:(?!\1).)*\1", re.S)


def strip_code(text: str) -> str:
    """Blank out fenced blocks and inline code spans, preserving line numbering.

    Without this, any page that documents link syntax gets its own example
    reported as a broken link — which is exactly what happened to
    docs/documentation/naming.md, whose whole subject is how to write links.
    """
    out = []
    in_fence = False
    for line in text.split("\n"):
        if FENCE_RE.match(line):
            in_fence = not in_fence
            out.append("")
            continue
        out.append("" if in_fence else CODE_SPAN_RE.sub(lambda m: " " * len(m.group(0)), line))
    return "\n".join(out)


def check_links(path: Path, text: str) -> None:
    for i, line in enumerate(strip_code(text).split("\n"), start=1):
        for target in LINK_RE.findall(line):
            if re.match(r"^[a-z]+:", target) or target.startswith("/"):
                continue          # external or site-absolute; lychee's job
            resolved = (path.parent / target).resolve()
            if not resolved.exists():
                fail(path, f"broken relative link: {target}", i)


def check_incident(path: Path, text: str) -> None:
    headings = [h.strip().lower().rstrip(".") for h in re.findall(r"^##\s+(.+)$", text, re.M)]
    normalised = [re.sub(r"^\d+\.\s*", "", h) for h in headings]
    position = 0
    for required in INCIDENT_SECTIONS:
        try:
            position = normalised.index(required, position) + 1
        except ValueError:
            fail(path, f"incident review missing required section: {required}")


H1_RE = re.compile(r"^#\s+(.+?)\s*$", re.M)


def check_h1(path: Path, text: str, fm: dict | None) -> None:
    """The body H1 and the front-matter title have to say the same thing.

    page-anatomy.md requires this and explains why both exist: `title` drives
    navigation and llms.txt, the H1 is what a reader of the raw Markdown sees.
    A page that disagrees with itself shows one string in the nav and another on
    the page, which is precisely the drift the generated-index rule exists to
    prevent — so it is checked here rather than left to review.
    """
    if not fm or "title" not in fm:
        return
    body = text[text.find("\n---", 4) + 4:] if text.startswith("---\n") else text
    m = H1_RE.search(body)
    if not m:
        fail(path, "no body H1 (see docs/documentation/page-anatomy.md)")
        return
    title = fm["title"].strip().strip("\"'")
    if m.group(1) != title:
        fail(path, f"body H1 '{m.group(1)}' does not match front matter title '{title}'")


def check_adr_numbering(files: list[Path]) -> None:
    numbers = []
    for path in files:
        m = ADR_RE.match(path.name)
        if not m:
            continue
        number = int(m.group(1))
        numbers.append(number)
        text = path.read_text(encoding="utf-8")
        fm, _ = parse_front_matter(text)
        declared = (fm or {}).get("id", "").strip("\"'")
        if declared and declared != f"ADR-{number:04d}":
            fail(path, f"front matter id '{declared}' does not match filename number {number:04d}")
    for expected, actual in enumerate(sorted(numbers), start=1):
        if expected != actual:
            problems.append({"file": "adr/", "line": 0,
                             "message": f"ADR numbering gap: expected {expected:04d}, found {actual:04d}"})
            break


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    root: Path = args.root
    if not root.is_dir():
        print(f"error: {root} is not a directory", file=sys.stderr)
        return 2

    # docs/prose/vendor/ holds instructions meant to be pasted verbatim into a
    # system prompt or rules file. Front matter would travel with them and
    # corrupt the one thing they exist for, so they are excluded by design.
    pages = sorted(
        p for p in root.rglob("*.md")
        if ".standards" not in p.parts and "vendor" not in p.parts
    )
    for path in pages:
        text = path.read_text(encoding="utf-8")
        fm, _ = parse_front_matter(text)
        check_front_matter(path, fm)
        check_name(path, root)
        check_links(path, text)
        check_h1(path, text, fm)
        if (fm or {}).get("type", "").strip("\"'") == "incident":
            check_incident(path, text)

    check_adr_numbering([p for p in pages if p.parent.name == "adr"])

    if args.json:
        print(json.dumps(problems, indent=2))
    else:
        for p in problems:
            location = f"{p['file']}:{p['line']}" if p["line"] else p["file"]
            print(f"{location}: {p['message']}")
        print(f"\n{len(pages)} pages checked, {len(problems)} problem(s)")

    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
