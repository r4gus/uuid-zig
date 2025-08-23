const std = @import("std");
const uuid = @import("uuid-zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    var stderr_buffer: [1024]u8 = undefined;
    var stderr_writer = std.fs.File.stdout().writer(&stderr_buffer);
    const stderr = &stderr_writer.interface;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 3) {
        try stderr.print("usage: {s} <nr-of-UUIDs> <version>\n", .{args[0]});
        return;
    }

    const iterations = try std.fmt.parseInt(usize, args[1], 10);

    var i: usize = 0;
    var duration: u64 = 0;
    switch (if (args[2].len < 2) args[2][0] else args[2][1]) {
        '4' => {
            var timer = try std.time.Timer.start();

            while (i < iterations) : (i += 1) {
                const id = uuid.v4.new();
                std.mem.doNotOptimizeAway(id);
            }

            duration = timer.read();
        },
        '7' => {
            var timer = try std.time.Timer.start();

            while (i < iterations) : (i += 1) {
                const id = uuid.v7.new();
                std.mem.doNotOptimizeAway(id);
            }

            duration = timer.read();
        },
        else => {
            try stderr.print("unsupported version!\nversions: v4, v7\nusage: {s} <nr-of-UUIDs> <version>\n", .{args[0]});
            return;
        },
    }

    try stdout.print("{s}: {d} UUIDs in ", .{ args[2], iterations });
    try stdout.printDurationUnsigned(duration);
    try stdout.print("\n", .{});

    try stdout.flush();
    try stderr.flush();
}
