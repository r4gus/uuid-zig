const std = @import("std");
const uuid = @import("uuid-zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const id = uuid.v4.new();

    const urn = try uuid.urn.serialize(id, allocator);
    defer allocator.free(urn);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("v4: {s}\n", .{urn});
}
