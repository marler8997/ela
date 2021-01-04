///! The zig wrapper API

const std = @import("std");

const gl = @import("../gl.zig");

// TODO: move this somewhere else (standard lib)
fn toZStringLiteral(comptime s: []const u8) [:0]const u8 {
    return (s ++ "\x00")[0 .. s.len :0];
}

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