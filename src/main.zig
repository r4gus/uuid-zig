const std = @import("std");

const core = @import("core.zig");
const time = @import("time.zig");
const name = @import("name.zig");
const urn = @import("urn.zig");
const random = @import("random.zig");

/// Universally Unique IDentifier
///
/// A UUID is 128 bits long, and can guarantee uniqueness across space and time (RFC4122).
pub const Uuid = core.UUID;

/// Create a version 4 Uuid using a CSPRNG
pub const v4Uuid = random.v4Uuid;

/// Parse a URN string into a Uuid
pub const parseUrn = urn.urnToUuid;

/// Get the URN representation of the given Uuid
pub const getUrn = urn.uuidToUrn;

test "tests" {
    _ = core;
    _ = time;
    _ = urn;
    _ = random;
}
