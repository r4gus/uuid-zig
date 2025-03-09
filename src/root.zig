const std = @import("std");
const core = @import("core.zig");
const urn = @import("urn.zig");
const v4 = @import("v4.zig");
const v7 = @import("v7.zig");

pub export fn uuid_v4() core.Uuid {
    return v4.new();
}

pub export fn uuid_v7() core.Uuid {
    return v4.new();
}

/// Caller is responsible for freeing the URN.
pub export fn to_urn(id: core.Uuid) [*c]u8 {
    const urn_ = urn.serialize(id);
    const mem = std.heap.c_allocator.alloc(u8, 37) catch return 0;
    for (mem[0..36], urn_) |*v1, v2| v1.* = v2;
    mem[36] = 0;
    return mem.ptr;
}
