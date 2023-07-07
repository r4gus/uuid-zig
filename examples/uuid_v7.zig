const std = @import("std");
const uuid = @import("uuid-zig");

pub fn main() !void {
    const id1 = uuid.v7.new();
    const id2 = uuid.v7.new();

    const urn1 = uuid.urn.serialize(id1);
    const urn2 = uuid.urn.serialize(id2);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("v7: {s}\n", .{urn1});
    try stdout.print("v7: {s}\n", .{urn2});
}
