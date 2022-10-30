const std = @import("std");
const uuid = @import("uuid-zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const id1 = uuid.v7.new();
    const id2 = uuid.v7.new();

    const urn1 = try uuid.getUrn(allocator, id1);
    defer allocator.free(urn1);
    const urn2 = try uuid.getUrn(allocator, id2);
    defer allocator.free(urn2);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("v7: {s}\n", .{urn1});
    try stdout.print("v7: {s}\n", .{urn2});
}
