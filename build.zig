const std = @import("std");

const zigclonedx: type = @import("zigclonedx");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const uuid_module = b.addModule("uuid", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    try b.modules.put(b.dupe("uuid"), uuid_module);

    const lib = b.addStaticLibrary(.{
        .name = "uuid-zig",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .version = .{ .major = 0, .minor = 2, .patch = 1 },
    });
    b.installArtifact(lib);

    const main_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);

    const v4_example = addExample(b, uuid_module, "v4-example", "examples/uuid_v4.zig", target);
    const v7_example = addExample(b, uuid_module, "v7-example", "examples/uuid_v7.zig", target);

    const run_v4_example = b.step("run-v4-example", "Run the v4 example");
    run_v4_example.dependOn(&v4_example.step);
    const run_v7_example = b.step("run-v7-example", "Run the v7 example");
    run_v7_example.dependOn(&v7_example.step);

    const run_bench = addBenchmark(b, uuid_module, "bench", "bench/main.zig", target);
    if (b.args) |args| {
        run_bench.addArgs(args);
    }
    const bench = b.step("bench", "Run the v7 benchmark");
    bench.dependOn(&run_bench.step);

    //var bom = try zigclonedx.CycloneDX.fromBuild(b, .{
    //    .type = .library,
    //    .name = "uuid",
    //    .group = "thesugar.de",
    //    .version = "0.2.1",
    //    .allocator = b.allocator,
    //    .authors = &.{
    //        .{
    //            .name = "David P. Sugar",
    //            .email = "david@thesugar.de",
    //        },
    //    },
    //});
    ////var bom = try sbom.generate(lib, b.allocator, null);
    //defer bom.deinit(b.allocator);
    //const bom_string = try bom.toJson(b.allocator);
    //defer b.allocator.free(bom_string);
    //std.debug.print("{s}\n", .{bom_string});
}

fn addExample(b: *std.Build, uuid_module: *std.Build.Module, exeName: []const u8, sourceFile: []const u8, target: std.Build.ResolvedTarget) *std.Build.Step.Run {
    const exe = b.addExecutable(.{
        .name = exeName,
        .root_source_file = b.path(sourceFile),
        .target = target,
    });
    exe.root_module.addImport("uuid-zig", uuid_module);
    b.installArtifact(exe);

    return b.addRunArtifact(exe);
}

fn addBenchmark(b: *std.Build, uuid_module: *std.Build.Module, exeName: []const u8, sourceFile: []const u8, target: std.Build.ResolvedTarget) *std.Build.Step.Run {
    const exe = b.addExecutable(.{
        .name = exeName,
        .root_source_file = b.path(sourceFile),
        .optimize = .ReleaseFast,
        .target = target,
    });
    exe.root_module.addImport("uuid-zig", uuid_module);
    b.installArtifact(exe);

    return b.addRunArtifact(exe);
}
