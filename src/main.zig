const std = @import("std");

const core = @import("core.zig");
const time = @import("time.zig");
const name = @import("name.zig");
const urn = @import("urn.zig");

pub const UUID = core.UUID;

test "tests" {
    _ = core;
    _ = time;
    _ = urn;
}
