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
A credential shape: ghp_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
An ambiguous suffix in URL context: https://notreal.dev/path
