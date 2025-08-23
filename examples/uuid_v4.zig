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
    // Create a new UUIDv4
    // The new function will automatically choose a PRNg for you.
    // If you want to provide your own PRNg, check out `v4.new2()`.
    const id = uuid.v4.new();

    // The generated UUID is just a `u128`. To translate
    // it into a human readable URN, we use the serialize
    // function.
    const urn = uuid.urn.serialize(id);

    try stdout.print("v4: {s}\n", .{&urn});
    try stdout.flush();
}
