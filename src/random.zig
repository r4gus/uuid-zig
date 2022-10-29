const std = @import("std");
const core = @import("core.zig");

const Uuid = core.UUID;
const rand = std.crypto.random;

/// Create a version 4 UUID using a CSPRNG
pub fn v4Uuid() Uuid {
    // Set all bits to pseudo-randomly chosen values.
    var uuid: Uuid = rand.int(Uuid);
    // Set the two most significant bits of the
    // clock_seq_hi_and_reserved to zero and one.
    // Set the four most significant bits of the
    // time_hi_and_version field to the 4-bit version number.
    uuid &= 0xffffffffffffff3fff0fffffffffffff;
    uuid |= 0x00000000000000800040000000000000;
    return uuid;
}

test "create a version 4 UUID" {
    const uuid1 = v4Uuid();
    try std.testing.expectEqual(core.Version.random, core.version(uuid1));
    try std.testing.expectEqual(core.Variant.rfc4122, core.variant(uuid1));

    const uuid2 = v4Uuid();
    try std.testing.expectEqual(core.Version.random, core.version(uuid2));
    try std.testing.expectEqual(core.Variant.rfc4122, core.variant(uuid2));

    try std.testing.expect(uuid1 != uuid2);
}
