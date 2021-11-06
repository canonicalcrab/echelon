# Echelon Matrix Client

Echelon is a matrix client.

As of 6 Nov 2021:
First goal of Echelon is established, a "Hello, world!".

    lang: zig esc: none file: src/main.zig
    --------------------------------------

    const std = @import("std");

    pub fn main() anyerror!void {
        std.log.info("All your codebase are belong to us.", .{});
    }

Just a starting point^

And a build file:

    lang: zig esc: none file: build.zig
    -----------------------------------

    const std = @import("std");
    pub fn build(b: *std.build.Builder) void {
        const target = b.standardTargetOptions(.{});
        const mode = b.standardReleaseOptions();
        const exe = b.addExecutable("echelon", "src/main.zig");
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }

And that's it so far.

