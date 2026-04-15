const std = @import("std");
const core = @import("core.zig");

const Uuid = core.Uuid;
const time = std.time;

/// Create a time-based version 7 UUID
///
/// This UUID features a time-ordered value field derived
/// from the widely implemented and well known Unix Epoch
/// timestamp source (# of milliseconds since midnight
/// 1 Jan 1970 UTC - leap seconds excluded).
///
/// Implementations SHOULD utilize this UUID over
/// version 1 and 6 if possible.
pub fn new(io: std.Io) Uuid {
    //   0                   1                   2                   3
    //   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
    //  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    //  |                           unix_ts_ms                          |
    //  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    //  |          unix_ts_ms           |  var  |       rand_a          |
    //  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    //  |var|                        rand_b                             |
    //  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    //  |                            rand_b                             |
    //  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

    // Get milliseconds since 1 Jan 1970 UTC
    const ts = std.Io.Timestamp.now(io, .real);
    const tms = @as(u48, @intCast(ts.toMilliseconds() & 0xffffffffffff));
    // Fill everything after the timestamp with random bytes
    var uuid: Uuid = undefined;
    const s = std.mem.asBytes(&uuid);
    io.random(s);
    uuid <<= 48;
    // Encode tms in big endian and OR it to the uuid
    uuid |= @as(Uuid, @intCast(core.switchU48(tms)));
    // Set variant and version field
    // * variant - top two bits are 1, 0
    // * version - top four bits are 0, 1, 1, 1
    uuid &= 0xffffffffffffff3fff0fffffffffffff;
    uuid |= 0x00000000000000800070000000000000;
    return uuid;
}

test "create a version 7 UUID" {
    const uuid1 = new(std.testing.io);
    try std.testing.expectEqual(core.Version.time_based_epoch, core.version(uuid1));
    try std.testing.expectEqual(core.Variant.rfc4122, core.variant(uuid1));

    const uuid2 = new(std.testing.io);
    try std.testing.expectEqual(core.Version.time_based_epoch, core.version(uuid2));
    try std.testing.expectEqual(core.Variant.rfc4122, core.variant(uuid2));

    try std.testing.expect(uuid1 != uuid2);
}
