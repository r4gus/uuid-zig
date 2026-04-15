const std = @import("std");
const uuid = @import("uuid-zig");

pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    var stderr_buffer: [1024]u8 = undefined;
    var stderr_writer = std.Io.File.stderr().writer(init.io, &stderr_buffer);
    const stderr = &stderr_writer.interface;

    const args = try init.minimal.args.toSlice(init.gpa);

    if (args.len < 3) {
        try stderr.print("usage: {s} <nr-of-UUIDs> <version>\n", .{args[0]});
        try stderr.flush();
        return;
    }

    const iterations = try std.fmt.parseInt(usize, args[1], 10);

    var i: usize = 0;
    var duration: std.Io.Duration = undefined;
    switch (if (args[2].len < 2) args[2][0] else args[2][1]) {
        '4' => {
            const start = std.Io.Timestamp.now(init.io, .real);

            while (i < iterations) : (i += 1) {
                const id = uuid.v4.new(init.io);
                std.mem.doNotOptimizeAway(id);
            }

            const end = std.Io.Timestamp.now(init.io, .real);

            duration = start.durationTo(end);
        },
        '7' => {
            const start = std.Io.Timestamp.now(init.io, .real);

            while (i < iterations) : (i += 1) {
                const id = uuid.v7.new(init.io);
                std.mem.doNotOptimizeAway(id);
            }

            const end = std.Io.Timestamp.now(init.io, .real);

            duration = start.durationTo(end);
        },
        else => {
            try stderr.print("unsupported version!\nversions: v4, v7\nusage: {s} <nr-of-UUIDs> <version>\n", .{args[0]});
            return;
        },
    }

    try stdout.print("{s}: {d} UUIDs in {d} ns\n", .{
        args[2],
        iterations,
        duration.toMicroseconds(),
    });

    try stdout.flush();
    try stderr.flush();
}
