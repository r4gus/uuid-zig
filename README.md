# UUID Zig

Universally Unique IDentifiers (UUIDs) are 128 bit long IDs that do not require a central
registration process.

## Getting started

Copy this library into your project or add it as a Git-submodule:

```
git submodule add https://github.com/r4gus/uuid-zig.git
```

Then add the following to your `build.zig`:

```
exe.addPackagePath("uuid-zig", "path/to/uuid-zig/src/main.zig");
```

To generate a version 4 (random) UUID you can use:

```zig
const uuid = @import("uuid-zig");

const id = uuid.v4.new();
```

You can parse URNs (UUID strings):

```zig
const uuid = @import("uuid-zig");

const id = try uuid.parseUrn("6ba7b811-9dad-11d1-80b4-00c04fd430c8");
```

## Which UUID version should I use?

Consider version 4 (random) UUIDs if you just need unique identifiers.

## Encoding

This library encodes UUIDs in big-endian format, e.g. `00112233-4455-6677-8899-aabbccddeeff`
is encoded as `00 11 22 33 44 55 66 77 88 99 aa bb cc dd ee ff` where `00` is the least and
`ff` is the most significant byte (see [RFC4122 4.1.2 Layout and Byte Order](https://datatracker.ietf.org/doc/html/rfc4122#section-4.1.2)).

## References

* [RFC4122: A Universally Unique IDentifier (UUID) URN Namespace](https://datatracker.ietf.org/doc/html/rfc4122)
* [New UUID Formats: draft-peabody-dispatch-new-uuid-format-04](https://datatracker.ietf.org/doc/html/draft-peabody-dispatch-new-uuid-format)
