const std = @import("std");

const common = @import("./common.zig");
const log = common.log;
const die = common.die;

const gl = @import("./gl.zig");

usingnamespace gl.bits;
usingnamespace gl.funcs;
//usingnamespace gl.v1_0;
//usingnamespace gl.v1_0.Funcs;

//usingnamespace gl.v2_0;
//usingnamespace gl.v2_0.Funcs;
//usingnamespace @import("./gl.zig");

var glCreateShader: PFNGLCREATESHADERPROC = undefined;
var glShaderSource: PFNGLSHADERSOURCEPROC = undefined;

usingnamespace if (std.builtin.os.tag == .windows) struct {
    pub const win = struct {
        pub usingnamespace @import("./windows.zig");
        pub usingnamespace std.os.windows;
    };
    pub const kernel32 = win.kernel32;
    pub const GetLastError = kernel32.GetLastError;
    pub const GlGetProcErrorTitle = common.T("OpenGL Get Proc Error");
    pub const GlInitErrorTitle = common.T("OpenGL Initialization Error");
    pub const glLastError = GetLastError;
} else struct {};


fn loadGlProc(comptime func: [:0]const u8) void {
    if (std.builtin.os.tag == .windows) {
        @field(@This(), func) = @ptrCast(@TypeOf(@field(@This(), func)), gl.windows.wglGetProcAddress(func)
            orelse die(GlGetProcErrorTitle, "load '{}' failed with {}", .{func, GetLastError()}));
    }
}

pub fn contextInitialized() void {
    log("OPENGL VERSION: {}", .{glGetString(GL_VERSION)});
    log("!!! TODO: parse and verify opengl version", .{});

    if (std.builtin.os.tag == .windows) {
        loadGlProc("glCreateShader");
        // TODO: comment this out to cause a NULL reference and make sure the panic handler pops up an error window
        loadGlProc("glShaderSource");
    }
}

pub fn onWindowSize(width: u32, height: u32) void {
    glViewport(0, 0, @intCast(i32, width), @intCast(i32, height));
}

pub fn renderTriangle() void {
    log("renderTriange", .{});
    // rotate a triangle around
    glClear(GL_COLOR_BUFFER_BIT);
    glBegin(GL_TRIANGLES);
    glColor3f(1.0, 0.0, 0.0);
    glVertex2i(0,  1);
    glColor3f(0.0, 1.0, 0.0);
    glVertex2i(-1, -1);
    glColor3f(0.0, 0.0, 1.0);
    glVertex2i(1, -1);
    glEnd();
    glFlush();
}

const vertex_shader_src =
    \\#version 330 core
    \\layout (location = 0) in vec3 aPos;
    \\void main()
    \\{
    \\    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    \\}
    ;

const fragment_shader_src =
    \\#version 330 core
    \\out vec4 FragColor;
    \\void main()
    \\{
    \\   FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
    \\}
    ;


pub fn init() void {
    const vertex_shader_id = glCreateShader(GL_VERTEX_SHADER);
    if (vertex_shader_id == 0)
        die(GlInitErrorTitle, "glCreateShader VERTEX failed with {}\n", .{glLastError()});

    // TODO: this isn't working, minimize it and file and issue for it
    //var src = [_][*:0]const u8 { arrayRefAsSlice(vertex_shader_src) };
    const vsrc : [:0]const u8 = vertex_shader_src;
    var src = [_][*:0]const u8 { vsrc.ptr };
    glShaderSource(vertex_shader_id, src.len, &src, null);

}




// TODO: move this somewhere else if I want to use it
pub fn ArrayRefAsSlice(comptime T: type) type {
    switch (@typeInfo(T)) {
        .Pointer => |ptr_info| {
            if (ptr_info.size == .One) {
                switch (@typeInfo(ptr_info.child)) {
                    .Array => |info| return @Type(std.builtin.TypeInfo { .Pointer = .{
                        .size = .Slice,
                        .is_const = true,
                        .is_volatile = false,
                        .alignment = @alignOf(info.child),
                        .child = info.child,
                        .is_allowzero = false,
                        .sentinel = info.sentinel,
                    }}),
                    else => {},
                }
            }
        },
        else => {},
    }
    @compileError("arrayRefAsSlice requires a pointer to an array but got " ++ @typeName(T));
}
pub fn arrayRefAsSlice(array_ref: anytype) ArrayRefAsSlice(@TypeOf(array_ref)) {
    return array_ref;
}