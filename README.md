# UUID Zig

Universally Unique IDentifiers (UUIDs) are 128 bit long IDs that do not require a central
registration process.

Versions:

| Zig version | uuid-zig version |
|:-----------:|:----------------:|
| 13.0        | 2.0, 2.1         |
| 14.0        | 3.0              |

To add the `uuid-zig` package to your `build.zig.zon` run:

```
# Replace <VERSION TAG> with the version you want to use
zig fetch --save https://github.com/r4gus/uuid-zig/archive/refs/tags/<VERSION TAG>.tar.gz

// e.g., zig fetch --save https://github.com/r4gus/uuid-zig/archive/refs/tags/0.3.0.tar.gz
```

## Getting started

To generate a version 4 (random) UUID you can use:

```zig
const uuid = @import("uuid");

const id = uuid.v4.new();
```

You can serialize a UUID into a URN:

```zig
const uuid = @import("uuid");

const id = uuid.v7.new();

const urn = uuid.urn.serialize(id);
```

You can also parse URNs (UUID strings):

```zig
const uuid = @import("uuid");

const id = try uuid.urn.deserialize("6ba7b811-9dad-11d1-80b4-00c04fd430c8");
```

## Which UUID version should I use?

Consider version 4 (`v4`) UUIDs if you just need unique identifiers and version 7 (`v7`)
if you want to use UUIDs as database keys or need to sort them.

### Supported versions

* `v4` - UUIDs using random data.
* `v7` - UUIDs using a Epoch timestamp in combination with random data.

## Encoding

This library encodes UUIDs in big-endian format, e.g. `00112233-4455-6677-8899-aabbccddeeff`
is encoded as `00 11 22 33 44 55 66 77 88 99 aa bb cc dd ee ff` where `00` is the least and
`ff` is the most significant byte (see [RFC4122 4.1.2 Layout and Byte Order](https://datatracker.ietf.org/doc/html/rfc4122#section-4.1.2)).

## C Library

Run `zig build -Doptimize=ReleaseFast` to build the C-Library. You will find the library in `zig-out/lib` and the header in `zig-out/include`.

You can find a C-example in the examples folder.

## Benchmark

To run a simple benchmark execute:

```
zig build bench -- 10000000 v7
```

Example: ThinkPad X1 Yoga 3rd with an i7-8550U

```
v4: 10000000 UUIDs in 595.063ms
v7: 10000000 UUIDs in 892.564ms
```

Example: Macbook Pro with M3 Pro

```
v4: 10000000 UUIDs in 1.666s
v7: 10000000 UUIDs in 546.736ms
```

## References

* [RFC4122: A Universally Unique IDentifier (UUID) URN Namespace](https://datatracker.ietf.org/doc/html/rfc4122)
* [New UUID Formats: draft-peabody-dispatch-new-uuid-format-04](https://datatracker.ietf.org/doc/html/draft-peabody-dispatch-new-uuid-format)
