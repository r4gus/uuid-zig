const std = @import("std");
const core = @import("core.zig");

const Uuid = core.Uuid;

/// Create a version 5 UUID from the namespace and name.
/// The io parameter is not necessary, it is only for API consistency.
pub fn new(io: std.Io, namespace: Uuid, name: []const u8) Uuid {
    _ = io;
    return newNoIo(namespace, name);
}

/// Create a version 5 UUID from the namespace and name.
pub fn newNoIo(namespace: Uuid, name: []const u8) Uuid {
    // Generate the sha1 hash
    var sha = std.crypto.hash.Sha1.init(.{});
    sha.update(std.mem.asBytes(&namespace));
    sha.update(name);
    const hash = sha.finalResult();

    // Use the first 16 bytes of the hash as the uuid bits
    var uuid: Uuid = std.mem.bytesToValue(u128, hash[0..16]);

    // Set the two most significant bits of the
    // clock_seq_hi_and_reserved to zero and one.
    // Set the four most significant bits of the
    // time_hi_and_version field to the 4-bit version number.
    uuid &= 0xffffffffffffff3fff0fffffffffffff;
    uuid |= 0x00000000000000800050000000000000;
    return uuid;
}

test "create a version 5 UUID" {
    const urn = @import("urn.zig");
    const namespace1 = urn.deserialize("15f62bf5-5f5b-4dc6-96b3-386ee85d0922") catch unreachable;
    const namespace2 = urn.deserialize("70aad581-fc81-4886-92df-f03c9ad340bf") catch unreachable;

    const base = new(std.testing.io, namespace1, "base_uuid");

    try std.testing.expectEqual(core.Version.name_based_sha1, core.version(base));
    try std.testing.expectEqual(core.Variant.rfc4122, core.variant(base));

    const same_namespace = new(std.testing.io, namespace1, "same_namespace");
    try std.testing.expectEqual(core.Version.name_based_sha1, core.version(same_namespace));
    try std.testing.expectEqual(core.Variant.rfc4122, core.variant(same_namespace));

    try std.testing.expect(base != same_namespace);

    const same_name = new(std.testing.io, namespace2, "base_uuid");
    try std.testing.expectEqual(core.Version.name_based_sha1, core.version(same_name));
    try std.testing.expectEqual(core.Variant.rfc4122, core.variant(same_name));

    try std.testing.expect(base != same_name);

    const same = new(std.testing.io, namespace1, "base_uuid");
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
