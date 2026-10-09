const std = @import("std");
const core = @import("core.zig");
const urn = @import("urn.zig");
const v4 = @import("v4.zig");
const v5 = @import("v5.zig");
const v7 = @import("v7.zig");

pub export fn uuid_v4() core.Uuid {
    var io_impl = std.Io.Threaded.init_single_threaded;
    const io = io_impl.io();

    return v4.fromIo(io);
}

pub export fn uuid_v5(namespace: core.Uuid, name: ?[*:0]const u8) core.Uuid {
    const zig_name: []const u8 = if (name) |n| std.mem.span(n) else "";
    return v5.new(namespace, zig_name);
}

pub export fn uuid_v7() core.Uuid {
    var io_impl = std.Io.Threaded.init_single_threaded;
    const io = io_impl.io();

    return v4.fromIo(io);
}

/// Caller is responsible for freeing the URN.
pub export fn to_urn(id: core.Uuid) [*c]u8 {
    const urn_ = urn.serialize(id);
    const mem = std.heap.c_allocator.alloc(u8, 37) catch return 0;
    for (mem[0..36], urn_) |*v1, v2| v1.* = v2;
    mem[36] = 0;
    return mem.ptr;
}
