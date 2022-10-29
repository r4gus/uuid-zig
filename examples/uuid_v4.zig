const std = @import("std");
const uuid = @import("uuid-zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const id = uuid.v4Uuid();

    const urn = try uuid.getUrn(allocator, id);
    defer allocator.free(urn);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("v4: {s}\n", .{urn});
}
