const std = @import("std");
const testing = std.testing;

/// Universally Unique IDentifier
///
/// A UUID is 128 bits long, and can guarantee uniqueness across space and time (RFC4122).
pub const UUID = u128;

/// Universally Unique IDentifier
///
/// A UUID is 128 bits long, and can guarantee uniqueness across space and time (RFC4122).
pub const Uuid = packed struct {
    time_low: u32,
    time_mid: u16,
    time_hi_and_version: u16,
    clock_seq_hi_and_reserved: u8,
    clock_seq_low: u8,
    node0: u8,
    node1: u8,
    node2: u8,
    node3: u8,
    node4: u8,
    node5: u8,

    pub fn fromUnsigned(uuid: UUID) @This() {
        return @bitCast(Uuid, uuid);
    }

    pub fn toUnsigned(self: *const @This()) UUID {
        return @bitCast(UUID, self.*);
    }

    pub fn variant(self: *const @This()) Variant {
        // Msb0  Msb1  Msb2
        //  0      x     x
        //  1      0     x
        //  1      1     0
        //  1      1     1
        return switch (self.*.clock_seq_hi_and_reserved >> 5) {
            0, 1, 2, 3 => .reserved_bw,
            4, 5 => .rfc4122,
            6 => .reserved_ms,
            7 => .reserved_fu,
            else => unreachable,
        };
    }

    pub fn version(self: *const @This()) Version {
        return switch (self.*.time_hi_and_version >> 4) {
            1 => .time_based,
            2 => .dce_security,
            3 => .name_based_md5,
            4 => .random,
            5 => .name_based_sha1,
            else => .ndef,
        };
    }
};

/// The variant field determines the layout of the UUID
pub const Variant = enum {
    /// Reserved, NCS backward compatibility
    reserved_bw,
    /// The variant specified in RFC4122
    rfc4122,
    /// Reserved, Micorsoft Corporation backward compatibility
    reserved_ms,
    /// Reserved for future definition
    reserved_fu,
};

pub fn variant(uuid: UUID) Variant {
    const uuid_t = Uuid.fromUnsigned(uuid);
    return uuid_t.variant();
}

/// The version (sub-type) of a UUID
pub const Version = enum(u4) {
    time_based = 1,
    dce_security = 2,
    name_based_md5 = 3,
    random = 4,
    name_based_sha1 = 5,
    ndef,
};

pub fn version(uuid: UUID) Version {
    const uuid_t = Uuid.fromUnsigned(uuid);
    return uuid_t.version();
}

test "get fields" {
    //const uuid: UUID = 0xffeeddccbbaa22334444555566666666;

    //const uuid_e = Uuid{
    //    .time_low = 0x66666666,
    //    .time_mid = 0x5555,
    //    .time_hi_and_version = 0x4444,
    //    .clock_seq_hi_and_reserved = 0x33,
    //    .clock_seq_low = 0x22,
    //    .node0 = 0xaa,
    //    .node1 = 0xbb,
    //    .node2 = 0xcc,
    //    .node3 = 0xdd,
    //    .node4 = 0xee,
    //    .node5 = 0xff,
    //};

    //const uuid_t = Uuid.fromUnsigned(uuid);
}

test "get variant" {
    try std.testing.expectEqual(Variant.reserved_bw, variant(0xaaaaaaaaaaaaaa00aaaaaaaaaaaaaaaa));
    try std.testing.expectEqual(Variant.reserved_bw, variant(0xaaaaaaaaaaaaaa20aaaaaaaaaaaaaaaa));
    try std.testing.expectEqual(Variant.reserved_bw, variant(0xaaaaaaaaaaaaaa40aaaaaaaaaaaaaaaa));
    try std.testing.expectEqual(Variant.reserved_bw, variant(0xaaaaaaaaaaaaaa60aaaaaaaaaaaaaaaa));

    try std.testing.expectEqual(Variant.rfc4122, variant(0xaaaaaaaaaaaaaa80aaaaaaaaaaaaaaaa));
    try std.testing.expectEqual(Variant.rfc4122, variant(0xaaaaaaaaaaaaaaA0aaaaaaaaaaaaaaaa));

    try std.testing.expectEqual(Variant.reserved_ms, variant(0xaaaaaaaaaaaaaaC0aaaaaaaaaaaaaaaa));

    try std.testing.expectEqual(Variant.reserved_fu, variant(0xaaaaaaaaaaaaaaE0aaaaaaaaaaaaaaaa));
}

test "get version" {
    try std.testing.expectEqual(Version.time_based, version(0xaaaaaaaaaaaaaaaa0010aaaaaaaaaaaa));
    try std.testing.expectEqual(Version.dce_security, version(0xaaaaaaaaaaaaaaaa0020aaaaaaaaaaaa));
    try std.testing.expectEqual(Version.name_based_md5, version(0xaaaaaaaaaaaaaaaa0030aaaaaaaaaaaa));
    try std.testing.expectEqual(Version.random, version(0xaaaaaaaaaaaaaaaa0040aaaaaaaaaaaa));
    try std.testing.expectEqual(Version.name_based_sha1, version(0xaaaaaaaaaaaaaaaa0050aaaaaaaaaaaa));
}
