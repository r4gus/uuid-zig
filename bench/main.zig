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

    try stdout.print("{s}: {d} UUIDs in {s} ({d} ns). {d} ns/op.\n", .{
        args[2],
        iterations,
        try human_duration(duration),
        duration.toNanoseconds(),
        @divTrunc(duration.toNanoseconds(), iterations),
    });

    try stdout.flush();
    try stderr.flush();
}

var duration_buffer: [1024]u8 = undefined;

fn human_duration(d: std.Io.Duration) ![]const u8 {
    // there must be a much more clever way to do this.
    var w = std.Io.Writer.fixed(duration_buffer[0..]);
    const nd = d.toNanoseconds();
    if (nd > 1000000000) {
        try w.print("{d} s", .{d.toSeconds()});
    } else if (nd > 1000000) {
        try w.print("{d} ms", .{d.toMilliseconds()});
    } else
    if (nd > 1000) {
        try w.print("{d} us", .{d.toMicroseconds()});
    } else {
        try w.print("{d} ns", .{d.toNanoseconds()});
    }
    return duration_buffer[0..w.end];
}
