const std = @import("std");
const core = @import("core.zig");

const Uuid = core.Uuid;

/// Create a version 4 UUID using a RNG provided via the IO interface
pub fn new(io: std.Io) Uuid {
    var uuid: Uuid = undefined;

    // Set all bits to pseudo-randomly chosen values.
    const s = std.mem.asBytes(&uuid);
    io.random(s);

    // Set the two most significant bits of the
    // clock_seq_hi_and_reserved to zero and one.
    // Set the four most significant bits of the
    // time_hi_and_version field to the 4-bit version number.
    uuid &= 0xffffffffffffff3fff0fffffffffffff;
    uuid |= 0x00000000000000800040000000000000;
    return uuid;
}

test "create a version 4 UUID" {
    const uuid1 = new(std.testing.io);

    try std.testing.expectEqual(core.Version.random, core.version(uuid1));
    try std.testing.expectEqual(core.Variant.rfc4122, core.variant(uuid1));

    const uuid2 = new(std.testing.io);
    try std.testing.expectEqual(core.Version.random, core.version(uuid2));
    try std.testing.expectEqual(core.Variant.rfc4122, core.variant(uuid2));

    try std.testing.expect(uuid1 != uuid2);
}
