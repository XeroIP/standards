<!-- FIXTURE: nothing here may be reported by tools/check-leakage.py.
     Covers the false-positive classes that made the first version of this
     scanner unusable: dotted identifiers, filenames, and CIDR notation. -->

A documentation host: 192.0.2.10 (TEST-NET-1)
Ranges written as CIDR: 10.0.0.0/8 and 192.168.0.0/16
Placeholder domains: example.internal, example.com
Public references: github.com, diataxis.fr, fonts.googleapis.com
Dotted identifiers that are not hosts: fs.readFileSync, os.path, h1.page, Path.home
Filenames sharing a suffix with a TLD: verify-stack.sh, .env.example, build-vale.js
