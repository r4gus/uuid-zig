const std = @import("std");
const testing = std.testing;

/// Universally Unique IDentifier
///
/// A UUID is 128 bits long, and can guarantee uniqueness across space and time (RFC4122).
pub const Uuid = u128;

/// Switch between little and big endian
pub fn switchU16(v: u16) u16 {
    return ((v >> 8) & 0x00ff) | ((v << 8) & 0xff00);
}

/// Switch between little and big endian
pub fn switchU32(v: u32) u32 {
    return ((v >> 24) & 0x000000ff) | ((v >> 8) & 0x0000ff00) | ((v << 8) & 0x00ff0000) | ((v << 24) & 0xff000000);
}

/// Switch between little and big endian
pub fn switchU48(v: u48) u48 {
    return ((v >> 40) & 0x0000000000ff) | ((v >> 24) & 0x00000000ff00) | ((v >> 8) & 0x000000ff0000) | ((v << 8) & 0x0000ff000000) | ((v << 24) & 0x00ff00000000) | ((v << 40) & 0xff0000000000);
}

pub fn getTimeLow(uuid: Uuid) u32 {
    return switchU32(@as(u32, @intCast(uuid & 0xffffffff)));
}

pub fn setTimeLow(uuid: *Uuid, v: u32) void {
    uuid.* &= ~@as(Uuid, @intCast(0xffffffff));
    uuid.* |= @as(Uuid, @intCast(switchU32(v)));
}

pub fn getTimeMid(uuid: Uuid) u16 {
    return switchU16(@as(u16, @intCast((uuid >> 32) & 0xffff)));
}

pub fn setTimeMid(uuid: *Uuid, v: u16) void {
    uuid.* &= ~(@as(Uuid, @intCast(0xffff)) << 32);
    uuid.* |= @as(Uuid, @intCast(switchU16(v))) << 32;
}

pub fn getTimeHiAndVersion(uuid: Uuid) u16 {
    return switchU16(@as(u16, @intCast((uuid >> 48) & 0xffff)));
}

pub fn setTimeHiAndVersion(uuid: *Uuid, v: u16) void {
    uuid.* &= ~(@as(Uuid, @intCast(0xffff)) << 48);
    uuid.* |= @as(Uuid, @intCast(switchU16(v))) << 48;
}

pub fn getClockSeqHiAndReserved(uuid: Uuid) u8 {
    return @as(u8, @intCast((uuid >> 64) & 0xff));
}

pub fn setClockSeqHiAndReserved(uuid: *Uuid, v: u8) void {
    uuid.* &= ~(@as(Uuid, @intCast(0xff)) << 64);
    uuid.* |= @as(Uuid, @intCast(v)) << 64;
}

pub fn getClockSeqLow(uuid: Uuid) u8 {
    return @as(u8, @intCast((uuid >> 72) & 0xff));
}

pub fn setClockSeqLow(uuid: *Uuid, v: u8) void {
    uuid.* &= ~(@as(Uuid, @intCast(0xff)) << 72);
    uuid.* |= @as(Uuid, @intCast(v)) << 72;
}

pub fn getNode(uuid: Uuid) u48 {
    return switchU48(@as(u48, @intCast((uuid >> 80) & 0xffffffffffff)));
}

pub fn setNode(uuid: *Uuid, v: u48) void {
    uuid.* &= ~(@as(Uuid, @intCast(0xffffffffffff)) << 80);
    uuid.* |= @as(Uuid, @intCast(switchU48(v))) << 80;
}

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
    /// Version 6, 7 and 8
    new_formats,
};

/// Get the variant of the given UUID
pub fn variant(uuid: Uuid) Variant {
    // Msb0  Msb1  Msb2
    //  0      x     x
    //  1      0     x
    //  1      1     0
    //  1      1     1
    return switch (getClockSeqHiAndReserved(uuid) >> 5) {
        0, 1, 2, 3 => .reserved_bw,
        4, 5 => .rfc4122,
        6 => .reserved_ms,
        7 => .reserved_fu,
        8, 9, 0xA, 0xB => .new_formats,
        else => unreachable,
    };
}

/// The version (sub-type) of a UUID
///
/// Versions:
///
/// * `v1` - Version 1 UUIDs using a timestamp and monotonic counter
/// * `v2` - Version 2 DCE UUIDs
/// * `v3` - Version 3 UUIDs based on the MD5 hash of some data
/// * `v4` - Version 4 UUIDs with random data
/// * `v5` - Version 5 UUIDs based on the SHA1 hash of some data
/// * `v6` - Version 6 UUIDs using a gregorian calendar time stamp
/// * `v7` - Version 7 UUIDs using a epoch time stamp
/// * `v8` - Version 8 UUIDs are vendor specific
pub const Version = enum(u4) {
    // old (RFC4122)
    time_based = 1,
    dce_security = 2,
    name_based_md5 = 3,
    random = 4,
    name_based_sha1 = 5,
    // new
    time_based_greg = 6,
    time_based_epoch = 7,
    custom = 8,
    ndef,
};

/// Get the version of the given UUID
pub fn version(uuid: Uuid) Version {
    return switch ((getTimeHiAndVersion(uuid) >> 12) & 0xf) {
        1 => .time_based,
        2 => .dce_security,
        3 => .name_based_md5,
        4 => .random,
        5 => .name_based_sha1,
        6 => .time_based_greg,
        7 => .time_based_epoch,
        8 => .custom,
        else => .ndef,
    };
}

test "get/set time_low" {
    var id: Uuid = 0xffeeddccbbaa99887766554433221100;
    try std.testing.expectEqual(@as(u32, @intCast(0x00112233)), getTimeLow(id));

    setTimeLow(&id, 0xaabbccdd);
    try std.testing.expectEqual(@as(u32, @intCast(0xaabbccdd)), getTimeLow(id));
}

test "get/set time_mid" {
    var id: Uuid = 0xffeeddccbbaa99887766554433221100;
    try std.testing.expectEqual(@as(u16, @intCast(0x4455)), getTimeMid(id));

    setTimeMid(&id, 0xaabb);
    try std.testing.expectEqual(@as(Uuid, @intCast(0xffeeddccbbaa99887766bbaa33221100)), id);
    try std.testing.expectEqual(@as(u16, @intCast(0xaabb)), getTimeMid(id));
}

test "get/set time_hi_and_version" {
    var id: Uuid = 0xffeeddccbbaa99887766554433221100;
    try std.testing.expectEqual(@as(u16, @intCast(0x6677)), getTimeHiAndVersion(id));

    setTimeHiAndVersion(&id, 0xaabb);
    try std.testing.expectEqual(@as(Uuid, @intCast(0xffeeddccbbaa9988bbaa554433221100)), id);
    try std.testing.expectEqual(@as(u16, @intCast(0xaabb)), getTimeHiAndVersion(id));
}

test "get/set clock_seq_hi_and_reserved" {
    var id: Uuid = 0xffeeddccbbaa99887766554433221100;
    try std.testing.expectEqual(@as(u8, @intCast(0x88)), getClockSeqHiAndReserved(id));

    setClockSeqHiAndReserved(&id, 0xff);
    try std.testing.expectEqual(@as(Uuid, @intCast(0xffeeddccbbaa99ff7766554433221100)), id);
    try std.testing.expectEqual(@as(u8, @intCast(0xff)), getClockSeqHiAndReserved(id));
}

test "get/set clock_seq_low" {
    var id: Uuid = 0xffeeddccbbaa99887766554433221100;
    try std.testing.expectEqual(@as(u8, @intCast(0x99)), getClockSeqLow(id));

    setClockSeqLow(&id, 0xff);
    try std.testing.expectEqual(@as(Uuid, @intCast(0xffeeddccbbaaff887766554433221100)), id);
    try std.testing.expectEqual(@as(u8, @intCast(0xff)), getClockSeqLow(id));
}

test "get/set node" {
    var id: Uuid = 0xffeeddccbbaa99887766554433221100;
    try std.testing.expectEqual(@as(u48, @intCast(0xaabbccddeeff)), getNode(id));

    setNode(&id, 0x001122334455);
    try std.testing.expectEqual(@as(Uuid, @intCast(0x55443322110099887766554433221100)), id);
    try std.testing.expectEqual(@as(u48, @intCast(0x001122334455)), getNode(id));
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
    try std.testing.expectEqual(Version.time_based_greg, version(0xaaaaaaaaaaaaaaaa0060aaaaaaaaaaaa));
    try std.testing.expectEqual(Version.time_based_epoch, version(0xaaaaaaaaaaaaaaaa0070aaaaaaaaaaaa));
    try std.testing.expectEqual(Version.custom, version(0xaaaaaaaaaaaaaaaa0080aaaaaaaaaaaa));
}
