const std = @import("std");
const uuid = @import("uuid-zig");

pub fn main(init: std.process.Init) !void {
    // Create two new UUIDv7
    // The new function will automatically choose a PRNg for you.
    // If you want to provide your own PRNg, check out `v7.new2()`.
    const id1 = uuid.v7.new(init.io);
    const id2 = uuid.v7.new(init.io);

    // The generated UUIDs are just two `u128`s. To translate
    // them into a human readable URNs, we use the serialize
    // function.
    const urn1 = uuid.urn.serialize(id1);
    const urn2 = uuid.urn.serialize(id2);

    // We write the new UUID to stdout.
    //
    // Below you can see how to setup the new (stdout) writer
    // using io as introduced in 0.16.0
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("v7: {s}\n", .{urn1});
    try stdout.print("v7: {s}\n", .{urn2});

    try stdout.flush();
}
