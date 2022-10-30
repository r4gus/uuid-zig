const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("uuid-zig", "src/main.zig");
    lib.setBuildMode(mode);
    lib.setTarget(target);
    lib.install();

    const main_tests = b.addTest("src/main.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);

    //const exe = b.addExecutable("v4-example", "examples/uuid_v4.zig");
    //exe.setBuildMode(mode);
    //exe.setTarget(target);
    //exe.addPackagePath("uuid-zig", "src/main.zig");
    //exe.install();

    //const run_cmd = exe.run();
    //run_cmd.step.dependOn(b.getInstallStep());
    //if (b.args) |args| {
    //    run_cmd.addArgs(args);
    //}

    const v4_example = addExample(b, "v4-example", "examples/uuid_v4.zig");
    const v7_example = addExample(b, "v7-example", "examples/uuid_v7.zig");

    const run_v4_example = b.step("run-v4-example", "Run the v4 example");
    run_v4_example.dependOn(&v4_example.step);
    const run_v7_example = b.step("run-v7-example", "Run the v7 example");
    run_v7_example.dependOn(&v7_example.step);

    const run_bench = addBenchmark(b, "bench", "bench/main.zig");
    if (b.args) |args| {
        run_bench.addArgs(args);
    }
    const bench = b.step("bench", "Run the v7 benchmark");
    bench.dependOn(&run_bench.step);
}

fn addExample(b: *std.build.Builder, exeName: []const u8, sourceFile: []const u8) *std.build.RunStep {
    const exe = b.addExecutable(exeName, sourceFile);
    exe.addPackagePath("uuid-zig", "src/main.zig");
    exe.install();

    const run_cmd = exe.run();
    //run_cmd.step.dependOn(b.getInstallStep());

    return run_cmd;
}

fn addBenchmark(b: *std.build.Builder, exeName: []const u8, sourceFile: []const u8) *std.build.RunStep {
    const exe = b.addExecutable(exeName, sourceFile);
    exe.addPackagePath("uuid-zig", "src/main.zig");
    exe.setBuildMode(std.builtin.Mode.ReleaseFast);
    exe.install();

    const run_cmd = exe.run();
    //run_cmd.step.dependOn(b.getInstallStep());

    return run_cmd;
}
