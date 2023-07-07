const std = @import("std");
const uuid = @import("uuid-zig");

pub fn main() !void {
    const id = uuid.v4.new();

    const urn = uuid.urn.serialize(id);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("v4: {s}\n", .{&urn});
}
