const std = @import("std");
const core = @import("core.zig");

const Uuid = core.Uuid;

/// Create a version 5 UUID from the namespace and name.
pub fn new(namespace: Uuid, name: []const u8) Uuid {
    const digest = hash(namespace, name);

    // Use the first 16 bytes of the hash as the uuid bits
    var uuid: Uuid = std.mem.bytesToValue(u128, digest[0..16]);

    // Set the two most significant bits of the
    // clock_seq_hi_and_reserved to zero and one.
    // Set the four most significant bits of the
    // time_hi_and_version field to the 4-bit version number.
    uuid &= 0xffffffffffffff3fff0fffffffffffff;
    uuid |= 0x00000000000000800050000000000000;
    return uuid;
}

fn hash(namespace: Uuid, name: []const u8) [std.crypto.hash.Sha1.digest_length]u8 {
    // Generate the sha1 hash
    var sha = std.crypto.hash.Sha1.init(.{});
    sha.update(std.mem.asBytes(&namespace));
    sha.update(name);
    return sha.finalResult();
}

test "A.4 Example of a UUIDv5 Value (rfc9562) - only hash" {
    const urn = @import("urn.zig");

    const dns = urn.deserialize("6ba7b810-9dad-11d1-80b4-00c04fd430c8") catch unreachable;
    const name = "www.example.com";

    const digest = hash(dns, name);

    try std.testing.expectEqualSlices(u8, "\x2e\xd6\x65\x7d\xe9\x27\x46\x8b\x55\xe1\x26\x65\xa8\xae\xa6\xa2\x2d\xee\x3e\x35", &digest);
}

test "A.4 Example of a UUIDv5 Value (rfc9562)" {
    const urn = @import("urn.zig");

    const dns = urn.deserialize("6ba7b810-9dad-11d1-80b4-00c04fd430c8") catch unreachable;
    const name = "www.example.com";

    const uuidv5 = new(dns, name);
    const urnv5 = urn.serialize(uuidv5);

    try std.testing.expectEqualStrings("2ed6657d-e927-568b-95e1-2665a8aea6a2", &urnv5);

    try std.testing.expectEqual(core.Version.name_based_sha1, core.version(uuidv5));
}

test "create a version 5 UUID" {
    const urn = @import("urn.zig");
    const namespace1 = urn.deserialize("15f62bf5-5f5b-4dc6-96b3-386ee85d0922") catch unreachable;
    const namespace2 = urn.deserialize("70aad581-fc81-4886-92df-f03c9ad340bf") catch unreachable;

    const base = new(namespace1, "base_uuid");

    try std.testing.expectEqual(core.Version.name_based_sha1, core.version(base));
    try std.testing.expectEqual(core.Variant.rfc4122, core.variant(base));

    const same_namespace = new(namespace1, "same_namespace");
    try std.testing.expectEqual(core.Version.name_based_sha1, core.version(same_namespace));
    try std.testing.expectEqual(core.Variant.rfc4122, core.variant(same_namespace));

    try std.testing.expect(base != same_namespace);

    const same_name = new(namespace2, "base_uuid");
    try std.testing.expectEqual(core.Version.name_based_sha1, core.version(same_name));
    try std.testing.expectEqual(core.Variant.rfc4122, core.variant(same_name));

    try std.testing.expect(base != same_name);

    const same = new(namespace1, "base_uuid");
    try std.testing.expectEqual(base, same);

    // Expected uuids generated with https://www.uuidtools.com/v5
    try std.testing.expectEqualStrings(
        "a771e72c-fa33-5ad7-a26d-f63a2aa62fe1",
        &urn.serialize(base),
    );
    try std.testing.expectEqualStrings(
        "24ade676-fc5c-56bb-a99c-c467801a48b9",
        &urn.serialize(same_namespace),
    );
    try std.testing.expectEqualStrings(
        "f2668bee-a4af-5f56-92fd-b371cdcd9cd2",
        &urn.serialize(same_name),
    );
}
