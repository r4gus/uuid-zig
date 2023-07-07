const std = @import("std");

const core = @import("core.zig");
const name = @import("name.zig");

/// Serialization and deserialization of UUIDs
pub const urn = @import("urn.zig");

/// UUID version 4 namespace
pub const v4 = @import("v4.zig");

/// UUID version 7 namespace
pub const v7 = @import("v7.zig");

/// Universally Unique IDentifier
///
/// A UUID is 128 bits long, and can guarantee uniqueness across space and time (RFC4122).
pub const Uuid = core.Uuid;

test "main tests" {
    _ = core;
    _ = urn;
    _ = v4;
    _ = v7;
}
