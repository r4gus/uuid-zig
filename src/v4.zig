const std = @import("std");
const core = @import("core.zig");

const Uuid = core.Uuid;

/// Create a version 4 UUID using a RNG provided via the IO interface
pub fn fromIo(io: std.Io) Uuid {
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

/// Create a version 4 UUID using the provided RNG
pub fn fromRandom(rng: std.Random) Uuid {
    var uuid: Uuid = undefined;

    // Set all bits to pseudo-randomly chosen values.
    const s = std.mem.asBytes(&uuid);
    rng.bytes(s);

    // Set the two most significant bits of the
    // clock_seq_hi_and_reserved to zero and one.
    // Set the four most significant bits of the
    // time_hi_and_version field to the 4-bit version number.
    uuid &= 0xffffffffffffff3fff0fffffffffffff;
    uuid |= 0x00000000000000800040000000000000;
    return uuid;
}

test "create a version 4 UUID" {
    const uuid1 = fromIo(std.testing.io);

    try std.testing.expectEqual(core.Version.random, core.version(uuid1));
    try std.testing.expectEqual(core.Variant.rfc4122, core.variant(uuid1));

    const uuid2 = fromIo(std.testing.io);
    try std.testing.expectEqual(core.Version.random, core.version(uuid2));
    try std.testing.expectEqual(core.Variant.rfc4122, core.variant(uuid2));

    try std.testing.expect(uuid1 != uuid2);

    const rng: std.Random.IoSource = .{ .io = std.testing.io };
    const uuid3 = fromRandom(rng.interface());
    try std.testing.expectEqual(core.Version.random, core.version(uuid3));
    try std.testing.expectEqual(core.Variant.rfc4122, core.variant(uuid3));

    try std.testing.expect(uuid1 != uuid3);
    try std.testing.expect(uuid2 != uuid3);
}
