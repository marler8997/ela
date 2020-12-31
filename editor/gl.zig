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

    pub const GL_VERSION = 0x1F02;
    pub const GL_COLOR_BUFFER_BIT = 16384;
    pub const GL_TRIANGLES = 4;
};

pub const funcs = if (std.builtin.os.tag == .windows) struct {
    const wgl = @import("./windows.zig").opengl32;
    pub const glGetString = wgl.glGetString;
    pub const glViewport = wgl.glViewport;
    pub const glClear = wgl.glClear;
    pub const glBegin = wgl.glBegin;
    pub const glColor3f = wgl.glColor3f;
    pub const glVertex2i = wgl.glVertex2i;
    pub const glEnd = wgl.glEnd;
    pub const glFlush = wgl.glFlush;
    pub const glCreateShader = wgl.glCreateShader;
} else @compileError("unsupported platform");
