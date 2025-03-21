const std = @import("std");

const zon: Zon = @import("build.zig.zon");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const uuid_module = b.addModule("uuid", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    try b.modules.put(b.dupe("uuid"), uuid_module);

    const uuid_c_module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "uuid",
        .root_module = uuid_c_module,
        .version = try std.SemanticVersion.parse(zon.version),
    });

    lib.linkLibC();

    lib.installHeader(b.path("src/uuid.h"), "uuid.h");

    b.installArtifact(lib);

    const main_tests = b.addTest(.{
        .root_module = uuid_module,
    });

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&b.addRunArtifact(main_tests).step);

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

    const cexample_mod = b.addModule("cexample", .{
        .target = target,
        .optimize = optimize,
    });
    cexample_mod.addCSourceFiles(.{
        .files = &.{
            "examples/cexample.c",
        },
        .flags = &.{
            "-Wall",
            "-Wextra",
        },
    });

    const cexample_exe = b.addExecutable(.{
        .name = "cexample",
        .root_module = cexample_mod,
    });

    cexample_exe.linkLibC();

    cexample_exe.linkLibrary(lib);

    b.installArtifact(cexample_exe);
}

fn addExample(b: *std.Build, uuid_module: *std.Build.Module, exeName: []const u8, sourceFile: []const u8, target: std.Build.ResolvedTarget) *std.Build.Step.Run {
    const exe_mod = b.createModule(.{
        .root_source_file = b.path(sourceFile),
        .target = target,
    });

    const exe = b.addExecutable(.{
        .name = exeName,
        .root_module = exe_mod,
    });

    exe.root_module.addImport("uuid-zig", uuid_module);

    b.installArtifact(exe);

    return b.addRunArtifact(exe);
}

fn addBenchmark(b: *std.Build, uuid_module: *std.Build.Module, exeName: []const u8, sourceFile: []const u8, target: std.Build.ResolvedTarget) *std.Build.Step.Run {
    const exe_mod = b.createModule(.{
        .root_source_file = b.path(sourceFile),
        .target = target,
        .optimize = .ReleaseFast,
    });

    const exe = b.addExecutable(.{
        .name = exeName,
        .root_module = exe_mod,
    });

    exe.root_module.addImport("uuid-zig", uuid_module);

    b.installArtifact(exe);

    return b.addRunArtifact(exe);
}

const Zon = struct {
    // TODO: defining the name this way is BS
    name: enum { uuid },
    version: []const u8,
    fingerprint: usize,
    // TODO same goes for the dependencies
    dependencies: struct {},
    paths: []const []const u8,
};
