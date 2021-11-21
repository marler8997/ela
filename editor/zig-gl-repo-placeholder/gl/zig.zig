///! The zig wrapper API

const std = @import("std");

const bits = @import("bits.zig");
const windows = @import("windows.zig");

pub const LoadRuntimeFuncsError = struct {
    loaded: u32,
    failed: []const u8,
};
pub fn loadRuntimeFuncs(runtime_funcs: anytype) ?LoadRuntimeFuncsError {
    inline for (@typeInfo(runtime_funcs).Struct.decls) |decl, i| {
        const export_name = toZStringLiteral("gl" ++ ([_]u8 {std.ascii.toUpper(decl.name[0])}) ++ decl.name[1..]);
        std.debug.assert(export_name.ptr[export_name.len] == 0);
        @field(runtime_funcs, decl.name) = @ptrCast(@TypeOf(@field(runtime_funcs, decl.name)), windows.wglGetProcAddress(export_name)
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
pub fn wrap(comptime gl_generated: anytype) type { return struct {
    const gl = struct {
        usingnamespace bits;
        usingnamespace gl_generated;
        usingnamespace gl_generated.runtimefuncs;
    };

    //pub fn shaderSource(shader: u32, count: u32, lines: [*]const []const u8) {
    //    // TODO: allocate an array of lengths for each line on the stack (i.e. using alloca)
    //    @panic("not impl");
    //}
    pub fn shaderSourceZ(shader: u32, lines: []const [*:0]const u8) void {
        gl.shaderSource(shader, @intCast(u32 , lines.len), lines.ptr, null);
    }

    pub fn shaderSourceSingle(shader: u32, src: [*:0]const u8) void {
        const src_array = [_][*:0]const u8 { src };
        gl.shaderSource(shader, 1, &src_array, null);
    }

    pub fn getShaderiv(shader: u32, pname: gl.Enum) i32 {
        var result : i32 = undefined;
        gl.getShaderiv(shader, pname, &result);
        return result;
    }

    pub fn getProgramiv(program: u32, pname: gl.Enum) i32 {
        var result : i32 = undefined;
        gl.getProgramiv(program, pname, &result);
        return result;
    }

    // TODO: support max length?
    pub fn getShaderInfoLogAlloc(allocator: *std.mem.Allocator, shader: u32) !?[:0]u8 {
        const log_len_i32 = getShaderiv(shader, gl.INFO_LOG_LENGTH);
        if (log_len_i32 == 0) return null;
        if (log_len_i32 < 0) @panic("is this possible?");
        const len_len_u31 = @intCast(u31, log_len_i32);

        const log_str = try allocator.alloc(u8, @intCast(usize, len_len_u31));
        errdefer allocatof.free(log_str);

        gl.getShaderInfoLog(shader, len_len_u31, null, log_str.ptr);
        std.debug.assert(log_str[@intCast(usize, len_len_u31) - 1] == 0);
        return log_str[0 .. @intCast(usize, len_len_u31) - 1 :0];
    }

    pub fn getProgramInfoLogAlloc(allocator: *std.mem.Allocator, program: u32) !?[:0]u8 {
        const log_len_i32 = getProgramiv(program, gl.INFO_LOG_LENGTH);
        if (log_len_i32 == 0) return null;
        if (log_len_i32 < 0) @panic("is this possible?");
        const len_len_u31 = @intCast(u31, log_len_i32);

        const log_str = try allocator.alloc(u8, @intCast(usize, len_len_u31));
        errdefer allocatof.free(log_str);

        gl.getProgramInfoLog(program, len_len_u31, null, log_str.ptr);
        std.debug.assert(log_str[@intCast(usize, len_len_u31) - 1] == 0);
        return log_str[0 .. @intCast(usize, len_len_u31) - 1 :0];
    }

    pub fn genVertexArrays(objs: []u32) void {
        gl.genVertexArrays(@intCast(u32, objs.len), objs.ptr);
    }
    pub fn genBuffers(objs: []u32) void {
        gl.genBuffers(@intCast(u32, objs.len), objs.ptr);
    }
    pub fn deleteBuffers(objs: []u32) void {
        gl.deleteBuffers(@intCast(u32, objs.len), objs.ptr);
    }

    pub fn bufferData(target: gl.Enum, comptime T: type, data: []const T, usage: gl.Enum) void {
        gl.bufferData(target, data.len * @sizeOf(T), data.ptr, usage);
    }
};}



///!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
/// The following is just an idea I have, but its not flushed out yet
///!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
///
/// How can I keep the shader vertex attributes and gl code that links the data to the attributes in sync?
/// In other words, how do I find errors between the shader and the program code at compile time?
///
/// One idea is to configure the vertex attributes and make them apart of the type system?
///
/// Example:
/// const shader_vertex_attrs = [_]VertexAttr {
///     .{ .type = GL_FLOAT, .count = ._3, .shader_name = "pos" },
/// };
///
///
pub const VertexAttrCount = enum { _1, _2, _3, _4 };

pub const VertexAttr = struct {
    type_: bits.gl.Enum,
    count: VertexAttrCount,
    shader_name: []const u8,

    pub fn init(type_: bits.gl.Enum, count: VertexAttrCount, shader_name: []const u8) VertexAttr {
        return .{
            .type_ = type_,
            .count = count,
            .shader_name = shader_name,
        };
    }
    pub fn shaderType(self: @This()) []const u8 {
        switch (self.type) {
            bits.GL_FLOAT => return switch (self.count) {
                ._1 => "vec1", ._2 => "vec2", ._3 => "vec3", ._4 => "vec4",
            },
            else => @panic("here"),
        }
    }
};

pub const VertexAttrs = struct {
    arr: []const VertexAttr,
    pub fn init(arr: []const VertexAttr) VertexAttrs { return .{ .arr = arr }; }
    pub fn dumpShader(self: @This(), writer: anytype) !void {
        for (self.arr) |attr, i| {
            try writer.print("layout (location = {}) in {s} {s};\n", .{i, attr.shaderType(), attr.shader_name});
        }
    }
};

test "VertexAttrs" {
    const attrs = VertexAttrs.init(&[_]VertexAttr {
        .{ .type = bits.FLOAT, .count = ._3, .shader_name = "pos" },
    });
    try attrs.dumpShader(std.io.getStdOut().writer());
}
