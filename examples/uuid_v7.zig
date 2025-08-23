const std = @import("std");
const uuid = @import("uuid-zig");

// We write the new UUID to stdout.
//
// Below you can see how to setup the new (stdout) writer
// introduced in 0.15.1.
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

pub fn main() !void {
    // Create two new UUIDv7
    // The new function will automatically choose a PRNg for you.
    // If you want to provide your own PRNg, check out `v7.new2()`.
    const id1 = uuid.v7.new();
    const id2 = uuid.v7.new();

    // The generated UUIDs are just two `u128`s. To translate
    // them into a human readable URNs, we use the serialize
    // function.
    const urn1 = uuid.urn.serialize(id1);
    const urn2 = uuid.urn.serialize(id2);

    try stdout.print("v7: {s}\n", .{urn1});
    try stdout.print("v7: {s}\n", .{urn2});
    try stdout.flush();
}
