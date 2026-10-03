const std = @import("std");
const uuid = @import("uuid-zig");

pub fn main(init: std.process.Init) !void {
    // Create a new UUIDv4
    // The new function will automatically choose a RNG for you.
    const id0 = uuid.v4.new(init.io);

    // If you want to provide your own RNG, check out `v4.new2()`.
    const rng: std.Random.IoSource = .{ .io = init.io };
    const id1 = uuid.v4.new2(rng.interface());

    // The generated UUID is just a `u128`. To translate
    // it into a human readable URN, we use the serialize
    // function.
    const urn0 = uuid.urn.serialize(id0);
    const urn1 = uuid.urn.serialize(id1);

    // We write the new UUID to stdout.
    //
    // Below you can see how to setup the new (stdout) writer
    // using io as introduced in 0.16.0
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;
    try stdout.print("v4: {s}\n", .{&urn0});
    try stdout.print("v4: {s}\n", .{&urn1});
    try stdout.flush();
}
