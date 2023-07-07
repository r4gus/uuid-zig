const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const uuid_module = b.addModule("uuid", .{
        .source_file = .{ .path = "src/main.zig" },
    });

    try b.modules.put(b.dupe("uuid"), uuid_module);

    const lib = b.addStaticLibrary(.{
        .name = "uuid-zig",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);

    const v4_example = addExample(b, uuid_module, "v4-example", "examples/uuid_v4.zig");
    const v7_example = addExample(b, uuid_module, "v7-example", "examples/uuid_v7.zig");

    const run_v4_example = b.step("run-v4-example", "Run the v4 example");
    run_v4_example.dependOn(&v4_example.step);
    const run_v7_example = b.step("run-v7-example", "Run the v7 example");
    run_v7_example.dependOn(&v7_example.step);

    const run_bench = addBenchmark(b, uuid_module, "bench", "bench/main.zig");
    if (b.args) |args| {
        run_bench.addArgs(args);
    }
    const bench = b.step("bench", "Run the v7 benchmark");
    bench.dependOn(&run_bench.step);
}

fn addExample(b: *std.build.Builder, uuid_module: *std.build.Module, exeName: []const u8, sourceFile: []const u8) *std.build.RunStep {
    const exe = b.addExecutable(.{
        .name = exeName,
        .root_source_file = .{ .path = sourceFile },
    });
    exe.addModule("uuid-zig", uuid_module);
    b.installArtifact(exe);

    return b.addRunArtifact(exe);
}

fn addBenchmark(b: *std.build.Builder, uuid_module: *std.build.Module, exeName: []const u8, sourceFile: []const u8) *std.build.RunStep {
    const exe = b.addExecutable(.{
        .name = exeName,
        .root_source_file = .{ .path = sourceFile },
        .optimize = .ReleaseFast,
    });
    exe.addModule("uuid-zig", uuid_module);
    b.installArtifact(exe);

    return b.addRunArtifact(exe);
}
