const std = @import("std");

const core = @import("core.zig");
const name = @import("name.zig");
const urn = @import("urn.zig");
const random = @import("random.zig");

/// Universally Unique IDentifier
///
/// A UUID is 128 bits long, and can guarantee uniqueness across space and time (RFC4122).
pub const Uuid = core.Uuid;

/// Create a version 4 Uuid using a CSPRNG
pub const v4Uuid = random.v4Uuid;

/// Parse a URN string into a Uuid
pub const parseUrn = urn.urnToUuid;

/// Get the URN representation of the given Uuid
pub const getUrn = urn.uuidToUrn;

test "tests" {
    _ = core;
    _ = urn;
    _ = random;
}
