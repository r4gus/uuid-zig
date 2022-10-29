const std = @import("std");
const core = @import("core.zig");

const Allocator = std.mem.Allocator;
const UUID = core.UUID;
const Uuid = core.Uuid;

pub fn uuidToUrn(allocator: Allocator, uuid: UUID) ![]u8 {
    const u = Uuid.fromUnsigned(uuid);
    const tl = ((u.time_low & 0xff000000) >> 24) + ((u.time_low & 0x00ff0000) >> 8) + ((u.time_low & 0x0000ff00) << 8) + ((u.time_low & 0x000000ff) << 24);
    const tm = ((u.time_mid & 0xff00) >> 8) + ((u.time_mid & 0xff) << 8);
    const th = ((u.time_hi_and_version & 0xff00) >> 8) + ((u.time_hi_and_version & 0xff) << 8);
    return try std.fmt.allocPrint(allocator, "{x:0>8}-{x:0>4}-{x:0>4}-{x:0>2}{x:0>2}-{x:0>2}{x:0>2}{x:0>2}{x:0>2}{x:0>2}{x:0>2}", .{
        tl,
        tm,
        th,
        u.clock_seq_hi_and_reserved,
        u.clock_seq_low,
        u.node0,
        u.node1,
        u.node2,
        u.node3,
        u.node4,
        u.node5,
    });
}

pub fn urnToUuid(urn: []const u8) !UUID {
    if (urn.len != 36) {
        return error.InvalidUrnLength;
    } else if (std.mem.count(u8, urn, "-") != 4) {
        return error.MalformedUrn;
    }

    var b: [6]u8 = [6]u8{ 0, 0, 0, 0, 0, 0 };
    var ret: UUID = 0;
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
        var tmp: UUID = 0;
        while (j < s.len / 2) : (j += 1) {
            tmp += @intCast(UUID, b[j]) << (8 * @intCast(u7, j));
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

    const uuid1: UUID = 0xffeeddccbbaa99887766554433221100;
    const urn1 = try uuidToUrn(allocator, uuid1);
    defer allocator.free(urn1);
    try std.testing.expectEqualStrings("00112233-4455-6677-8899-aabbccddeeff", urn1);

    const uuid2 = Uuid{
        .time_low = 0x14b8a76b,
        .time_mid = 0xad9d,
        .time_hi_and_version = 0xd111,
        .clock_seq_hi_and_reserved = 0x80,
        .clock_seq_low = 0xb4,
        .node0 = 0x00,
        .node1 = 0xc0,
        .node2 = 0x4f,
        .node3 = 0xd4,
        .node4 = 0x30,
        .node5 = 0xc8,
    };
    const urn2 = try uuidToUrn(allocator, uuid2.toUnsigned());
    defer allocator.free(urn2);
    try std.testing.expectEqualStrings("6ba7b814-9dad-11d1-80b4-00c04fd430c8", urn2);
}

test "urn tu uudi" {
    const urn = "6ba7b811-9dad-11d1-80b4-00c04fd430c8";
    const uuid = try urnToUuid(urn);
    try std.testing.expectEqual(@intCast(UUID, 0xc830d44fc000b480d111ad9d11b8a76b), uuid);
}
