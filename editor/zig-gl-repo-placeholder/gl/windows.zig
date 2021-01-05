const std = @import("std");
const win = std.os.windows;
const WINAPI = win.WINAPI;

usingnamespace @import("../gl.zig").bits;

pub extern "opengl32" fn wglCreateContext(win.HDC) callconv(WINAPI) ?win.HGLRC;
pub extern "opengl32" fn wglMakeCurrent(win.HDC, win.HGLRC) callconv(WINAPI) win.BOOL;
pub extern "opengl32" fn wglGetProcAddress([*:0]const u8) ?*c_void;

pub extern "opengl32" fn glGetString(name: GLenum) callconv(WINAPI) [*:0]u8;
pub extern "opengl32" fn glViewport(x: GLint, y: GLint, width: GLsizei, height: GLsizei) callconv(WINAPI) void;
pub extern "opengl32" fn glClear(mask: GLbitfield) callconv(WINAPI) void;
pub extern "opengl32" fn glBegin(mode: GLenum) callconv(WINAPI) void;
pub extern "opengl32" fn glColor3f(red: GLfloat, green: GLfloat, blue: GLfloat) callconv(WINAPI) void;
pub extern "opengl32" fn glVertex2i(x: GLint, y: GLint) callconv(WINAPI) void;
pub extern "opengl32" fn glEnd() callconv(WINAPI) void;
pub extern "opengl32" fn glFlush() callconv(WINAPI) void;

/// Function pointer types for functions that must be loaded at runtime
pub const RuntimeFnTypes = struct {
    pub const glCreateShader = fn(shaderType: GLenum) callconv(WINAPI) GLuint;
    pub const glDeleteShader = fn(shader: GLuint) callconv(WINAPI) void;
    pub const glShaderSource = fn(shader: GLuint, count: GLsizei, string: [*]const [*]const GLchar, length: ?[*]const GLint) callconv(WINAPI) void;
    pub const glCompileShader = fn(shader: GLuint) callconv(WINAPI) void;
    pub const glGetShaderiv = fn(shader: GLuint, pname: GLenum, out_parm: *GLint) callconv(WINAPI) void;
    pub const glGetProgramiv = fn(program: GLuint, pname: GLenum, out_parm: *GLint) callconv(WINAPI) void;
    pub const glGetShaderInfoLog = fn(shader: GLuint, capacity: GLsizei, len_ref: ?*GLsizei, info_log: [*]GLchar) callconv(WINAPI) void;
    pub const glGetProgramInfoLog = fn(program: GLuint, capacity: GLsizei, len_ref: ?*GLsizei, info_log: [*]GLchar) callconv(WINAPI) void;
    pub const glCreateProgram = fn() callconv(WINAPI) GLuint;
    pub const glDeleteProgram = fn(program: GLuint) callconv(WINAPI) void;
    pub const glAttachShader = fn(program: GLuint, shader: GLuint) callconv(WINAPI) void;
    pub const glLinkProgram = fn(program: GLuint) callconv(WINAPI) void;
};
