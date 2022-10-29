# UUID Zig

Universally Unique IDentifiers (UUIDs) are 128 bit long IDs that do not require a central
registration process.

## Encoding

This library encodes UUIDs in big-endian format, e.g. `00112233-4455-6677-8899-aabbccddeeff`
is encoded as `00 11 22 33 44 55 66 77 88 99 aa bb cc dd ee ff` where `00` is the least and
`ff` is the most significant byte (see [RFC4122 4.1.2 Layout and Byte Order](https://datatracker.ietf.org/doc/html/rfc4122#section-4.1.2)).
