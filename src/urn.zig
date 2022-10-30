const std = @import("std");
const core = @import("core.zig");

const Allocator = std.mem.Allocator;
const Uuid = core.Uuid;

/// Serialize the given UUID into a URN
///
/// Each field is separated by a `-` and printed as a zero-filled
/// hexadecimal digit string with the most significant digit first.
///
/// The caller is responsible for deallocating the string returned
/// by this function.
pub fn uuidToUrn(allocator: Allocator, uuid: Uuid) ![]u8 {
    return try std.fmt.allocPrint(allocator, "{x:0>8}-{x:0>4}-{x:0>4}-{x:0>2}{x:0>2}-{x:0>12}", .{
        core.getTimeLow(uuid),
        core.getTimeMid(uuid),
        core.getTimeHiAndVersion(uuid),
        core.getClockSeqHiAndReserved(uuid),
        core.getClockSeqLow(uuid),
        core.getNode(uuid),
    });
}

/// Deserialize the given URN into a UUID
///
/// If the given URN is malformed, a error is returned.
pub fn urnToUuid(urn: []const u8) !Uuid {
    if (urn.len != 36) {
        return error.InvalidUrnLength;
    } else if (std.mem.count(u8, urn, "-") != 4) {
        return error.MalformedUrn;
    }

    var b: [6]u8 = [6]u8{ 0, 0, 0, 0, 0, 0 };
    var ret: Uuid = 0;
    var i: usize = 0;
    var iter = std.mem.split(u8, urn, "-");
    while (iter.next()) |s| : (i += 1) {
        const check: usize = switch (i) {
            0 => 8,
            1, 2, 3 => 4,
            4 => 12,
            else => unreachable,
        };

        if (s.len != check) {
            return error.MalformedUrn;
        }

        _ = try std.fmt.hexToBytes(b[0 .. s.len / 2], s);

        var j: usize = 0;
        var tmp: Uuid = 0;
        while (j < s.len / 2) : (j += 1) {
            tmp += @intCast(Uuid, b[j]) << (8 * @intCast(u7, j));
        }

        const shift: u7 = switch (i) {
            0 => 0,
            1 => 32,
            2 => 48,
            3 => 64,
            4 => 80,
            else => unreachable,
        };

        ret += tmp << shift;
    }

    return ret;
}

test "uuid to urn" {
    const allocator = std.testing.allocator;

    const uuid1: Uuid = 0xffeeddccbbaa99887766554433221100;
    const urn1 = try uuidToUrn(allocator, uuid1);
    defer allocator.free(urn1);
    try std.testing.expectEqualStrings("00112233-4455-6677-8899-aabbccddeeff", urn1);

    //const uuid2 = UuidOld{
    //    .time_low = 0x14b8a76b,
    //    .time_mid = 0xad9d,
    //    .time_hi_and_version = 0xd111,
    //    .clock_seq_hi_and_reserved = 0x80,
    //    .clock_seq_low = 0xb4,
    //    .node0 = 0x00,
    //    .node1 = 0xc0,
    //    .node2 = 0x4f,
    //    .node3 = 0xd4,
    //    .node4 = 0x30,
    //    .node5 = 0xc8,
    //};
    //const urn2 = try uuidToUrn(allocator, uuid2.toUnsigned());
    //defer allocator.free(urn2);
    //try std.testing.expectEqualStrings("6ba7b814-9dad-11d1-80b4-00c04fd430c8", urn2);
}

test "urn tu uudi" {
    const urn = "6ba7b811-9dad-11d1-80b4-00c04fd430c8";
    const uuid = try urnToUuid(urn);
    try std.testing.expectEqual(@intCast(Uuid, 0xc830d44fc000b480d111ad9d11b8a76b), uuid);
}

test "urn full circle" {
    const allocator = std.testing.allocator;

    const urn = "6ba7b811-9dad-11d1-80b4-00c04fd430c8";
    const uuid = try urnToUuid(urn);
    const urn_new = try uuidToUrn(allocator, uuid);
    defer allocator.free(urn_new);

    try std.testing.expectEqualStrings(urn, urn_new);
}
