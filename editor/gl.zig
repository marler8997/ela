const std = @import("std");

//pub const corearb = @import("./gl/corearb.zig");
//pub const ext = @import("./gl/ext.zig");
//
//pub const v1_0 = struct {
//    pub usingnamespace corearb.v1_0;
//};
//pub const v1_1 = struct {
//    pub usingnamespace corearb.v1_1;
//};
//pub const v1_2 = struct {
//    pub usingnamespace corearb.v1_2;
//    pub usingnamespace ext.v1_2;
//};

pub const bits = struct {
    pub const GLvoid     = c_void;
    pub const GLenum     = u32;
    pub const GLfloat    = f32;
    pub const GLint      = i32;
    pub const GLsizei    = i32;
    pub const GLbitfield = u32;
    pub const GLdouble   = f64;
    pub const GLuint     = u32;
    pub const GLboolean  = u8;
    pub const GLubyte    = u8;
    pub const GLchar     = u8;

    pub const GL_VERSION = 0x1F02;
    pub const GL_COLOR_BUFFER_BIT = 16384;
    pub const GL_TRIANGLES = 4;
    pub const GL_VERTEX_SHADER = 0x8B31;
    pub const GL_DELETE_STATUS = 0x8B80;
    pub const GL_COMPILE_STATUS = 0x8B81;
    pub const GL_LINK_STATUS = 0x8B82;
};

pub const windows = if (std.builtin.os.tag == .windows) @import("./windows.zig").opengl32 else @compileError("windows only supported on Windows");

fn toZStringLiteral(comptime s: []const u8) [:0]const u8 {
    return (s ++ "\x00")[0 .. s.len :0];
}

pub usingnamespace if (std.builtin.os.tag == .windows) struct {
    pub const GetProcsError = struct {
        loaded: u32,
        // TODO: include ':0' when issue fixed: https://github.com/ziglang/zig/issues/7644
        //failed: [:0]const u8,
        failed: []const u8,
    };
    pub fn getProcs(dynamic_funcs: anytype) ?GetProcsError {
        @import("./common.zig").log("loading {} OpenGL functions...", .{@typeInfo(dynamic_funcs).Struct.decls.len});
        inline for (@typeInfo(dynamic_funcs).Struct.decls) |decl, i| {
            @import("./common.zig").log("  loading '{}'...", .{decl.name});
            const decl_name_z = toZStringLiteral(decl.name);
            std.debug.assert(decl_name_z.ptr[decl_name_z.len] == 0);
            @field(dynamic_funcs, decl.name) = @ptrCast(@TypeOf(@field(dynamic_funcs, decl.name)), windows.wglGetProcAddress(decl_name_z)
                orelse return GetProcsError { .loaded = i, .failed = decl.name });
        }
        return null;
    }
} else struct {};

pub const funcs = if (std.builtin.os.tag == .windows) struct {

    pub const glGetString = windows.glGetString;
    pub const glViewport = windows.glViewport;
    pub const glClear = windows.glClear;
    pub const glBegin = windows.glBegin;
    pub const glColor3f = windows.glColor3f;
    pub const glVertex2i = windows.glVertex2i;
    pub const glEnd = windows.glEnd;
    pub const glFlush = windows.glFlush;

    pub const PFNGLCREATESHADERPROC = windows.PFNGLCREATESHADERPROC;
    pub const PFNGLSHADERSOURCEPROC = windows.PFNGLSHADERSOURCEPROC;
    pub const PFNGLCOMPILESHADERPROC = windows.PFNGLCOMPILESHADERPROC;
    pub const PFNGLGETSHADERIVPROC = windows.PFNGLGETSHADERIVPROC;
    pub const PFNGLGETSHADERINFOLOGPROC = windows.PFNGLGETSHADERINFOLOGPROC;

} else @compileError("unsupported platform");
