const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

const zig_gl_repo = "zig-gl-repo-placeholder";

// This no longer works because imports must be string literals
//const OpenGlCodegenStep = @import(zig_gl_repo ++ std.fs.path.sep_str ++ "codegen.zig").OpenGlCodegenStep;
const OpenGlCodegenStep = @import("zig-gl-repo-placeholder/codegen.zig").OpenGlCodegenStep;

pub fn build(b: *Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const glindex_pkg = std.build.Pkg {
        .name = "glindex",
        .path = .{ .path = zig_gl_repo ++ std.fs.path.sep_str ++ "glindex.zig" },
    };

    const exe_gl_gen = OpenGlCodegenStep.create(b, .{
        .filename = "gl.generated.zig",
        .funcs = &gl_funcs,
        .glindex_pkg_name = glindex_pkg.name,
    });

    const exe = b.addExecutable("editor", if (builtin.os.tag == .windows) "windows-main.zig" else "notwindows-main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();
    exe.subsystem = .Windows;
    exe.single_threaded = true;
    exe.step.dependOn(&exe_gl_gen.step);
    exe.addPackage(glindex_pkg);

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

const gl_funcs = [_][]const u8 {
    "glGetString",
    "glViewport",
    "glClearColor",
    "glClear",
    "glBegin",
    "glEnd",
    "glFlush",
    "glColor3f",
    "glVertex2i",
    "glCreateShader",
    "glDeleteShader",
    "glShaderSource",
    "glCompileShader",
    "glGetShaderiv",
    "glGetProgramiv",
    "glGetShaderInfoLog",
    "glGetProgramInfoLog",
    "glCreateProgram",
    "glDeleteProgram",
    "glAttachShader",
    "glLinkProgram",
    "glGenVertexArrays",
    "glGenBuffers",
    "glBindVertexArray",
    "glBindBuffer",
    "glBufferData",
    "glVertexAttribPointer",
    "glEnableVertexAttribArray",
    "glPolygonMode",
    "glUseProgram",
    "glDrawArrays",
    "glDrawElements",
    "glGetUniformLocation",
    "glUniform4f",
};
