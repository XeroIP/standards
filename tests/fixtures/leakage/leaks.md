<!-- FIXTURE: every line here must be reported by tools/check-leakage.py.
     Used as a negative test — a leak detector that never fires is worse than
     none, so the failure path is exercised rather than assumed.

     The values below are shaped like infrastructure but are fictional. An
     earlier draft of this fixture used the real host address and the real
     domain, which would have reproduced, inside the test for the leak, exactly
     the leak the test exists to prevent. -->

A host inside a real private range: 192.168.99.99
A domain that is not on the allowlist: notarealdomain.net
A domain registered after the allowlist was written: somelab.io
An internal hostname: somehost.internal
A credential shape: ghp_FAKE0fake1FAKE2fake3FAKE4fake5FAKE6f
An ambiguous suffix in URL context: https://notreal.dev/path
A range outside every permitted block: 198.18.0.0/15
A host written with its subnet: 192.168.99.99/24
A host written as a one-address block: 192.168.99.99/32
A subnet inside a private block: 192.168.99.0/24
A host on a private IPv6 network: fd12:3456:789a::99
A personal domain on a country suffix, in prose: notarealdomain.nl
A personal domain on a newer suffix, in prose: notarealdomain.dev
A suffix that is also a file extension, inside a URL: https://notarealdomain.sh/x
The same suffix in an address: admin@notarealdomain.zip
A host on a private-use suffix: somehost.home
A host on a private-use suffix: somehost.corp
A host on a private-use suffix: somehost.lan
A host on a private-use suffix: somehost.local
A host on a private-use suffix: somehost.localdomain
A host on a private-use suffix: somehost.private
A host on a private-use suffix: somehost.intranet
