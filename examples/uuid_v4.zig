const std = @import("std");
const uuid = @import("uuid-zig");

pub fn main(init: std.process.Init) !void {
    // Create a new UUIDv4
    // The new function will automatically choose a PRNg for you.
    // If you want to provide your own PRNg, check out `v4.new2()`.
    const id = uuid.v4.new(init.io);

    // The generated UUID is just a `u128`. To translate
    // it into a human readable URN, we use the serialize
    // function.
    const urn = uuid.urn.serialize(id);

    // We write the new UUID to stdout.
    //
    // Below you can see how to setup the new (stdout) writer
    // using io as introduced in 0.16.0
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;
    try stdout.print("v4: {s}\n", .{&urn});
    try stdout.flush();
}
