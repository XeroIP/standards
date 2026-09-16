# Security policy

## What this repository is, and what its risk is

This repository holds engineering standards. It runs nothing, stores no data, and has no
users. Its central risk is not a vulnerability in code — it is a **leaked infrastructure
value**: a real domain, hostname, IP address, container name, live file path, or anything
resembling a credential, written into a public repository by accident.

That is the finding worth reporting, and it is treated as urgent.

## Reporting

Use **GitHub's private vulnerability reporting** on this repository: the Security tab, then
"Report a vulnerability". That channel is private, so a report does not itself publish the
value being reported.

Do not open a public issue for a leaked value. An issue quoting it republishes it, more
visibly than the original.

If private reporting is unavailable to you, open an issue saying only that you have a report
and naming no specifics.

## What counts

| Report | Example |
| --- | --- |
| A leaked infrastructure value | A real hostname or address in a page, a workflow, or a commit message |
| A value leaked in an image | Text visible in a screenshot or photograph — see below |
| A credential shape | A key, token, or private key that reached a commit |
| A flaw in a tool here | A gate that passes something it should reject, or executes untrusted input |

**Images are the gap.** `tools/check-leakage.py` skips image formats by design, because it
reads text. A hostname rendered inside a screenshot passes every automated check in this
repository, and `grep` finds nothing. If you spot one, it is a real finding and no tool was
ever going to catch it.

## Response

- Acknowledged within a few days. This is a personal repository, not a staffed one.
- A leaked value is removed, and whatever it protects is treated as disclosed and rotated. A
  later commit does not retract something that was public, so the value is not trusted again
  simply because the file changed.
- History rewriting is considered but not assumed: a public history cannot be reliably
  un-pushed once cloned, so rotation is the primary response and removal is secondary.

## What is out of scope

Findings in the private infrastructure this repository documents by placeholder. Nothing here
describes a running system, and the placeholders — `example.internal`, `192.0.2.10`,
`service-a` — are reserved for documentation by RFC 2606 and RFC 5737. They are not targets.
