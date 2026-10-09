<!-- FIXTURE: nothing here may be reported by tools/check-leakage.py.
     Covers the false-positive classes that made the first version of this
     scanner unusable: dotted identifiers, filenames, and CIDR notation. -->

A documentation host: 192.0.2.10 (TEST-NET-1)
Ranges written as CIDR: 10.0.0.0/8 and 192.168.0.0/16
Placeholder domains: example.internal, example.com
Public references: github.com, diataxis.fr, fonts.googleapis.com
Dotted identifiers that are not hosts, in code spans as prose writes them: `fs.readFileSync`, `os.path`, `h1.page`, `Path.home`
Filenames sharing a suffix with a TLD: verify-stack.sh, .env.example, build-vale.js
A documentation host with its prefix: 192.0.2.10/24
IPv6 for documentation: 2001:db8::10, ::1, and the ranges fc00::/7, fd00::/8 and fe80::/64
The default routes: 0.0.0.0/0 and ::/0
Slices and hex words that are not addresses: values[0::2], items[10::20], Add::Dec
Filenames in prose, on suffixes that are also TLDs: README.md, build.sh, setup.py, archive.zip
An agent-file import: @STATUS.md
Identifiers in a code span, on delegated suffixes: `m.group`, `obj.id`, `user.name`

```python
match = m.group(1)
key = obj.id
```
