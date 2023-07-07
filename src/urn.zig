const std = @import("std");
const core = @import("core.zig");

const Uuid = core.Uuid;

pub const Urn = [36]u8;

/// Serialize the given UUID into a URN
///
/// Each field is separated by a `-` and printed as a zero-filled
/// hexadecimal digit string with the most significant digit first.
///
/// The caller is responsible for deallocating the string returned
/// by this function.
pub fn serialize(uuid: Uuid) Urn {
    var urn: Urn = undefined;
    _ = std.fmt.bufPrint(&urn, "{x:0>8}-{x:0>4}-{x:0>4}-{x:0>2}{x:0>2}-{x:0>12}", .{
        core.getTimeLow(uuid),
        core.getTimeMid(uuid),
        core.getTimeHiAndVersion(uuid),
        core.getClockSeqHiAndReserved(uuid),
        core.getClockSeqLow(uuid),
        core.getNode(uuid),
    }) catch unreachable;
    return urn;
}

fn hex2hw(h: u8) !u8 {
    return switch (h) {
        48...57 => h - 48,
        65...70 => h - 65 + 10,
        97...102 => h - 97 + 10,
        else => return error.InvalidHexChar,
    };
}

/// Deserialize the given URN into a UUID
///
/// If the given URN is malformed, a error is returned.
pub fn deserialize(s: []const u8) !Uuid {
    if (s.len != 36) {
        return error.MalformedUrn;
    } else if (std.mem.count(u8, s, "-") != 4) {
        return error.MalformedUrn;
    } else if (s[8] != '-' or s[13] != '-' or s[18] != '-' or s[23] != '-') {
        return error.MalformedUrn;
    }

    var uuid: Uuid = 0;
    var i: usize = 0;
    var j: u7 = 0;
    while (i <= 34) {
        if (s[i] == '-') {
            i += 1;
            continue;
        }

        const digit: u8 = (try hex2hw(s[i]) << 4) | try hex2hw(s[i + 1]);
        uuid |= @as(Uuid, @intCast(digit)) << (j * 8);
        i += 2;
        j += 1;
    }

    return uuid;
}

test "uuid to urn" {
    const uuid1: Uuid = 0xffeeddccbbaa99887766554433221100;
    const urn1 = serialize(uuid1);
    try std.testing.expectEqualSlices(u8, "00112233-4455-6677-8899-aabbccddeeff", urn1[0..]);
}

test "urn tu uudi" {
    const urn1 = "6ba7b811-9dad-11d1-80b4-00c04fd430c8";
    const uuid = try deserialize(urn1);
    try std.testing.expectEqual(@as(Uuid, @intCast(0xc830d44fc000b480d111ad9d11b8a76b)), uuid);
}

test "urn full circle" {
    const urn1 = "6ba7b811-9dad-11d1-80b4-00c04fd430c8";
    const uuid = try deserialize(urn1);
    const urn_new = serialize(uuid);

    try std.testing.expectEqualStrings(urn1, &urn_new);
}
