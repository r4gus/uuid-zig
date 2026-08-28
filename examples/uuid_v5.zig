const std = @import("std");
const uuid = @import("uuid-zig");

pub fn main(init: std.process.Init) !void {
    // UUIDv5 needs a namespace uuid.
    const namespace = try uuid.urn.deserialize("c1df9566-ad1e-4c5c-a4e2-a47d49ea3687");
    // You could use any uuid for this, try using one of these 2 lines:
    // const namespace = uuid.v4.new(init.io);
    // const namespace = uuid.v7.new(init.io);

    // Create a new UUIDv5.
    // Use uuid.v5.newNoIo if you don't have access to a std.Io instance.
    const id = uuid.v5.new(init.io, namespace, "Any list of bytes can be used as a name");

    // The generated UUID is just a `u128`. To translate
    // it into a human readable URN, we use the serialize
    // function.
    const namespace_urn = uuid.urn.serialize(namespace);
    const urn = uuid.urn.serialize(id);

    // We write the new UUID to stdout.
    //
    // Below you can see how to setup the new (stdout) writer
    // using io as introduced in 0.16.0
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;
    try stdout.print("namespace: {s}\n", .{&namespace_urn});
    try stdout.print("v5: {s}\n", .{&urn});
    try stdout.flush();
}
