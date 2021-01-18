const std = @import("std");
const win = std.os.windows;
const WINAPI = win.WINAPI;

usingnamespace @import("../gl.zig").bits;

pub extern "opengl32" fn wglCreateContext(win.HDC) callconv(WINAPI) ?win.HGLRC;
pub extern "opengl32" fn wglMakeCurrent(win.HDC, win.HGLRC) callconv(WINAPI) win.BOOL;
pub extern "opengl32" fn wglGetProcAddress([*:0]const u8) ?*c_void;

pub extern "opengl32" fn glGetString(name: GLenum) callconv(WINAPI) [*:0]u8;
pub extern "opengl32" fn glViewport(x: GLint, y: GLint, width: GLsizei, height: GLsizei) callconv(WINAPI) void;
pub extern "opengl32" fn glClearColor(red: GLclampf, green: GLclampf, blue: GLclampf, alpha: GLclampf) void;
pub extern "opengl32" fn glClear(mask: GLbitfield) callconv(WINAPI) void;
pub extern "opengl32" fn glBegin(mode: GLenum) callconv(WINAPI) void;
pub extern "opengl32" fn glColor3f(red: GLfloat, green: GLfloat, blue: GLfloat) callconv(WINAPI) void;
pub extern "opengl32" fn glVertex2i(x: GLint, y: GLint) callconv(WINAPI) void;
pub extern "opengl32" fn glEnd() callconv(WINAPI) void;
pub extern "opengl32" fn glFlush() callconv(WINAPI) void;
pub extern "opengl32" fn glPolygonMode(face: GLenum, mode: GLenum) void;

pub extern "opengl32" fn glDrawArrays(mode: GLenum, first: GLint, count: GLsizei) void;
pub extern "opengl32" fn glDrawElements(mode: GLenum, count: GLsizei, type: GLenum, indices: ?*const c_void) void;

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
    pub const glGenVertexArrays = fn(n: GLsizei, arrays: [*]GLuint) callconv(WINAPI) void;
    pub const glGenBuffers = fn(n: GLsizei, buffers: [*]GLuint) callconv(WINAPI) void;
    pub const glBindVertexArray = fn(array: GLuint) callconv(WINAPI) void;
    pub const glBindBuffer = fn(target: GLenum, buffer: GLuint) void;
    pub const glBufferData = fn(target: GLenum, size: GLsizeiptr, data: *const c_void, usage: GLenum) void;
    pub const glVertexAttribPointer = fn(index: GLuint, size: GLint, type: GLenum, normalized: GLboolean, stride: GLsizei, pointer: ?*c_void) void;

    pub const glEnableVertexAttribArray = fn(index: GLuint) void;
    pub const glDisableVertexAttribArray = fn(index: GLuint) void;
    pub const glEnableVertexArrayAttrib = fn(vaobj: GLuint, index: GLuint) void;
    pub const glDisableVertexArrayAttrib = fn(vaobj: GLuint, index: GLuint) void;
    pub const glUseProgram = fn(program: GLuint) void;

    pub const glGetUniformLocation = fn(program: GLuint, name: [*:0]const GLchar) GLint;const glUniform1f = fn(location: GLint, v0: GLfloat) void;
    pub const glUniform2f = fn(location: GLint, v0: GLfloat, v1: GLfloat) void;
    pub const glUniform3f = fn(location: GLint, v0: GLfloat, v1: GLfloat, v2: GLfloat) void;
    pub const glUniform4f = fn(location: GLint, v0: GLfloat, v1: GLfloat, v2: GLfloat, v3: GLfloat) void;
    pub const glUniform1i = fn(location: GLint, v0: GLint) void;
    pub const glUniform2i = fn(location: GLint, v0: GLint, v1: GLint) void;
    pub const glUniform3i = fn(location: GLint, v0: GLint, v1: GLint, v2: GLint) void;
    pub const glUniform4i = fn(location: GLint, v0: GLint, v1: GLint, v2: GLint, v3: GLint) void;
    pub const glUniform1ui = fn(location: GLint, v0: GLuint) void;
    pub const glUniform2ui = fn(location: GLint, v0: GLuint, v1: GLuint) void;
    pub const glUniform3ui = fn(location: GLint, v0: GLuint, v1: GLuint, v2: GLuint) void;
    pub const glUniform4ui = fn(location: GLint, v0: GLuint, v1: GLuint, v2: GLuint, v3: GLuint) void;
    pub const glUniform1fv = fn(location: GLint, count: GLsizei, value: [*]const GLfloat) void;
    pub const glUniform2fv = fn(location: GLint, count: GLsizei, value: [*]const GLfloat) void;
    pub const glUniform3fv = fn(location: GLint, count: GLsizei, value: [*]const GLfloat) void;
    pub const glUniform4fv = fn(location: GLint, count: GLsizei, value: [*]const GLfloat) void;
    pub const glUniform1iv = fn(location: GLint, count: GLsizei, value: [*]const GLint) void;
    pub const glUniform2iv = fn(location: GLint, count: GLsizei, value: [*]const GLint) void;
    pub const glUniform3iv = fn(location: GLint, count: GLsizei, value: [*]const GLint) void;
    pub const glUniform4iv = fn(location: GLint, count: GLsizei, value: [*]const GLint) void;
    pub const glUniform1uiv = fn(location: GLint, count: GLsizei, value: [*]const GLuint) void;
    pub const glUniform2uiv = fn(location: GLint, count: GLsizei, value: [*]const GLuint) void;
    pub const glUniform3uiv = fn(location: GLint, count: GLsizei, value: [*]const GLuint) void;
    pub const glUniform4uiv = fn(location: GLint, count: GLsizei, value: [*]const GLuint) void;
    pub const glUniformMatrix2fv = fn(location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
    pub const glUniformMatrix3fv = fn(location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
    pub const glUniformMatrix4fv = fn(location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
    pub const glUniformMatrix2x3fv = fn(location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
    pub const glUniformMatrix3x2fv = fn(location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
    pub const glUniformMatrix2x4fv = fn(location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
    pub const glUniformMatrix4x2fv = fn(location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
    pub const glUniformMatrix3x4fv = fn(location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
    pub const glUniformMatrix4x3fv = fn(location: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void;
};
