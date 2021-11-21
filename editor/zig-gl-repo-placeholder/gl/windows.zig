const std = @import("std");
const win = std.os.windows;
const WINAPI = win.WINAPI;

const gl = struct {
    usingnamespace @import("bits.zig");
};

pub extern "opengl32" fn wglCreateContext(win.HDC) callconv(WINAPI) ?win.HGLRC;
pub extern "opengl32" fn wglMakeCurrent(win.HDC, win.HGLRC) callconv(WINAPI) win.BOOL;
pub extern "opengl32" fn wglGetProcAddress([*:0]const u8) ?*c_void;

pub extern "opengl32" fn glGetString(name: gl.Enum) callconv(WINAPI) [*:0]u8;
pub extern "opengl32" fn glViewport(x: i32, y: i32, width: u32, height: u32) callconv(WINAPI) void;
pub extern "opengl32" fn glClearColor(red: gl.Clamp32, green: gl.Clamp32, blue: gl.Clamp32, alpha: gl.Clamp32) void;
pub extern "opengl32" fn glClear(mask: gl.Bitfield) callconv(WINAPI) void;
pub extern "opengl32" fn glBegin(mode: gl.Enum) callconv(WINAPI) void;
pub extern "opengl32" fn glColor3f(red: f32, green: f32, blue: f32) callconv(WINAPI) void;
pub extern "opengl32" fn glVertex2i(x: i32, y: i32) callconv(WINAPI) void;
pub extern "opengl32" fn glEnd() callconv(WINAPI) void;
pub extern "opengl32" fn glFlush() callconv(WINAPI) void;
pub extern "opengl32" fn glPolygonMode(face: gl.Enum, mode: gl.Enum) void;

pub extern "opengl32" fn glDrawArrays(mode: gl.Enum, first: i32, count: u32) void;
pub extern "opengl32" fn glDrawElements(mode: gl.Enum, count: u32, type: gl.Enum, indices: ?*const c_void) void;

/// Function pointer types for functions that must be loaded at runtime
pub const RuntimeFnTypes = struct {
    pub const glCreateShader = fn(shaderType: gl.Enum) callconv(WINAPI) u32;
    pub const glDeleteShader = fn(shader: u32) callconv(WINAPI) void;
    pub const glShaderSource = fn(shader: u32, count: u32, string: [*]const [*]const gl.Char, length: ?[*]const i32) callconv(WINAPI) void;
    pub const glCompileShader = fn(shader: u32) callconv(WINAPI) void;
    pub const glGetShaderiv = fn(shader: u32, pname: gl.Enum, out_parm: *i32) callconv(WINAPI) void;
    pub const glGetProgramiv = fn(program: u32, pname: gl.Enum, out_parm: *i32) callconv(WINAPI) void;
    pub const glGetShaderInfoLog = fn(shader: u32, capacity: u32, len_ref: ?*u32, info_log: [*]gl.Char) callconv(WINAPI) void;
    pub const glGetProgramInfoLog = fn(program: u32, capacity: u32, len_ref: ?*u32, info_log: [*]gl.Char) callconv(WINAPI) void;
    pub const glCreateProgram = fn() callconv(WINAPI) u32;
    pub const glDeleteProgram = fn(program: u32) callconv(WINAPI) void;
    pub const glAttachShader = fn(program: u32, shader: u32) callconv(WINAPI) void;
    pub const glLinkProgram = fn(program: u32) callconv(WINAPI) void;
    pub const glGenVertexArrays = fn(n: u32, arrays: [*]u32) callconv(WINAPI) void;
    pub const glGenBuffers = fn(n: u32, buffers: [*]u32) callconv(WINAPI) void;
    pub const glBindVertexArray = fn(array: u32) callconv(WINAPI) void;
    pub const glBindBuffer = fn(target: gl.Enum, buffer: u32) void;
    pub const glBufferData = fn(target: gl.Enum, size: usize, data: *const c_void, usage: gl.Enum) void;
    pub const glVertexAttribPointer = fn(index: u32, size: i32, type: gl.Enum, normalized: gl.Boolean, stride: u32, pointer: ?*c_void) void;

    pub const glEnableVertexAttribArray = fn(index: u32) void;
    pub const glDisableVertexAttribArray = fn(index: u32) void;
    pub const glEnableVertexArrayAttrib = fn(vaobj: u32, index: u32) void;
    pub const glDisableVertexArrayAttrib = fn(vaobj: u32, index: u32) void;
    pub const glUseProgram = fn(program: u32) void;

    pub const glGetUniformLocation = fn(program: u32, name: [*:0]const gl.Char) i32;
    pub const glUniform1f = fn(location: i32, v0: f32) void;
    pub const glUniform2f = fn(location: i32, v0: f32, v1: f32) void;
    pub const glUniform3f = fn(location: i32, v0: f32, v1: f32, v2: f32) void;
    pub const glUniform4f = fn(location: i32, v0: f32, v1: f32, v2: f32, v3: f32) void;
    pub const glUniform1i = fn(location: i32, v0: i32) void;
    pub const glUniform2i = fn(location: i32, v0: i32, v1: i32) void;
    pub const glUniform3i = fn(location: i32, v0: i32, v1: i32, v2: i32) void;
    pub const glUniform4i = fn(location: i32, v0: i32, v1: i32, v2: i32, v3: i32) void;
    pub const glUniform1ui = fn(location: i32, v0: u32) void;
    pub const glUniform2ui = fn(location: i32, v0: u32, v1: u32) void;
    pub const glUniform3ui = fn(location: i32, v0: u32, v1: u32, v2: u32) void;
    pub const glUniform4ui = fn(location: i32, v0: u32, v1: u32, v2: u32, v3: u32) void;
    pub const glUniform1fv = fn(location: i32, count: u32, value: [*]const f32) void;
    pub const glUniform2fv = fn(location: i32, count: u32, value: [*]const f32) void;
    pub const glUniform3fv = fn(location: i32, count: u32, value: [*]const f32) void;
    pub const glUniform4fv = fn(location: i32, count: u32, value: [*]const f32) void;
    pub const glUniform1iv = fn(location: i32, count: u32, value: [*]const i32) void;
    pub const glUniform2iv = fn(location: i32, count: u32, value: [*]const i32) void;
    pub const glUniform3iv = fn(location: i32, count: u32, value: [*]const i32) void;
    pub const glUniform4iv = fn(location: i32, count: u32, value: [*]const i32) void;
    pub const glUniform1uiv = fn(location: i32, count: u32, value: [*]const u32) void;
    pub const glUniform2uiv = fn(location: i32, count: u32, value: [*]const u32) void;
    pub const glUniform3uiv = fn(location: i32, count: u32, value: [*]const u32) void;
    pub const glUniform4uiv = fn(location: i32, count: u32, value: [*]const u32) void;
    pub const glUniformMatrix2fv = fn(location: i32, count: u32, transpose: gl.Boolean, value: [*]const f32) void;
    pub const glUniformMatrix3fv = fn(location: i32, count: u32, transpose: gl.Boolean, value: [*]const f32) void;
    pub const glUniformMatrix4fv = fn(location: i32, count: u32, transpose: gl.Boolean, value: [*]const f32) void;
    pub const glUniformMatrix2x3fv = fn(location: i32, count: u32, transpose: gl.Boolean, value: [*]const f32) void;
    pub const glUniformMatrix3x2fv = fn(location: i32, count: u32, transpose: gl.Boolean, value: [*]const f32) void;
    pub const glUniformMatrix2x4fv = fn(location: i32, count: u32, transpose: gl.Boolean, value: [*]const f32) void;
    pub const glUniformMatrix4x2fv = fn(location: i32, count: u32, transpose: gl.Boolean, value: [*]const f32) void;
    pub const glUniformMatrix3x4fv = fn(location: i32, count: u32, transpose: gl.Boolean, value: [*]const f32) void;
    pub const glUniformMatrix4x3fv = fn(location: i32, count: u32, transpose: gl.Boolean, value: [*]const f32) void;
};
