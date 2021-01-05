///! The zig wrapper API

const std = @import("std");

const gl = @import("../gl.zig");

pub const LoadRuntimeFuncsError = struct {
    loaded: u32,
    failed: []const u8,
};
pub fn loadRuntimeFuncs(runtime_funcs: anytype) ?LoadRuntimeFuncsError {
    inline for (@typeInfo(runtime_funcs).Struct.decls) |decl, i| {
        const decl_name_z = toZStringLiteral(decl.name);
        std.debug.assert(decl_name_z.ptr[decl_name_z.len] == 0);
        @field(runtime_funcs, decl.name) = @ptrCast(@TypeOf(@field(runtime_funcs, decl.name)), gl.windows.wglGetProcAddress(decl_name_z)
            orelse return LoadRuntimeFuncsError { .loaded = i, .failed = decl.name });
    }
    return null;
}

// TODO: move this somewhere else (standard lib)
fn toZStringLiteral(comptime s: []const u8) [:0]const u8 {
    return (s ++ "\x00")[0 .. s.len :0];
}

pub fn toZLinesStringLiteral(comptime str: []const u8) []const [*:0]const u8 {
    comptime {
        comptime var lines: []const [*:0]const u8 = &[_][*:0]const u8{};
        var it = std.mem.tokenize(str, "\n");
        while (it.next()) |line| {
            lines = lines ++ &[_][*:0]const u8{toZStringLiteral(line).ptr};
        }
        return lines;
    }
}

/// Return a module of wrapping functions meant for Zig use.
pub fn wrap(comptime generated_gl: anytype) type { return struct {
    usingnamespace generated_gl.bits;
    usingnamespace generated_gl.runtimefuncs;

    //pub fn shaderSource(shader: GLuint, count: GLsizei, lines: [*]const []const u8) {
    //    // TODO: allocate an array of lengths for each line on the stack (i.e. using alloca)
    //    @panic("not impl");
    //}
    pub fn shaderSourceZ(shader: GLuint, lines: []const [*:0]const u8) void {
        glShaderSource(shader, @intCast(GLsizei , lines.len), lines.ptr, null);
    }

    pub fn shaderSourceSingle(shader: GLuint, src: [*:0]const u8) void {
        const src_array = [_][*:0]const u8 { src };
        glShaderSource(shader, 1, &src_array, null);
    }

    pub fn getShaderiv(shader: GLuint, pname: GLenum) GLint {
        var result : GLint = undefined;
        glGetShaderiv(shader, pname, &result);
        return result;
    }

    pub fn getProgramiv(program: GLuint, pname: GLenum) GLint {
        var result : GLint = undefined;
        glGetProgramiv(program, pname, &result);
        return result;
    }

    // TODO: support max length?
    pub fn getShaderInfoLogAlloc(allocator: *std.mem.Allocator, shader: GLuint) !?[:0]u8 {
        const log_len = getShaderiv(shader, GL_INFO_LOG_LENGTH);
        if (log_len == 0) return null;

        const log_str = try allocator.alloc(u8, @intCast(usize, log_len));
        errdefer allocatof.free(log_str);

        var info_len : GLsizei = 0;
        glGetShaderInfoLog(shader, log_len, null, log_str.ptr);
        std.debug.assert(log_str[@intCast(usize, log_len) - 1] == 0);
        return log_str[0 .. @intCast(usize, log_len) - 1 :0];
    }

    pub fn getProgramInfoLogAlloc(allocator: *std.mem.Allocator, program: GLuint) !?[:0]u8 {
        const log_len = getProgramiv(program, GL_INFO_LOG_LENGTH);
        if (log_len == 0) return null;

        const log_str = try allocator.alloc(u8, @intCast(usize, log_len));
        errdefer allocatof.free(log_str);

        var info_len : GLsizei = 0;
        glGetProgramInfoLog(program, log_len, null, log_str.ptr);
        std.debug.assert(log_str[@intCast(usize, log_len) - 1] == 0);
        return log_str[0 .. @intCast(usize, log_len) - 1 :0];
    }
};}
