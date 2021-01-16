const std = @import("std");

const common = @import("./common.zig");
const log = common.log;
const die = common.die;

const gl = @import("gl.generated.zig");
usingnamespace gl;
usingnamespace gl.bits;
usingnamespace gl.runtimefuncs;

const zgl = @import("gl").zig.wrap(gl);

//usingnamespace gl.bits;
//usingnamespace gl.funcs;
//usingnamespace gl.v1_0;
//usingnamespace gl.v1_0.Funcs;

//usingnamespace gl.v2_0;
//usingnamespace gl.v2_0.Funcs;
//usingnamespace @import("./gl.zig");

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


pub fn contextInitialized() void {
    log("OPENGL VERSION: {s}", .{glGetString(GL_VERSION)});
    log("!!! TODO: parse and verify opengl version", .{});

    if (gl.loadRuntimeFuncs()) |err| {
        die(GlGetProcErrorTitle, "after loading {} OpenGL functions, failed to load '{s}' with {}", .{err.loaded, err.failed, GetLastError()});
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

// TODO: does this fix line numbers in shader log? gl.zig.toZLinesStringLiteral ???
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


pub fn init() !void {
    const vertex_shader = try compileShader(.vertex, vertex_shader_src);
    defer glDeleteShader(vertex_shader);

    const fragment_shader = try compileShader(.fragment, fragment_shader_src);
    defer glDeleteShader(fragment_shader);

    const prog = glCreateProgram();
    errdefer glDeleteProgram(prog);

    if (prog == 0) die(GlInitErrorTitle, "glCreateProgram failed", .{});
    glAttachShader(prog, vertex_shader);
    glAttachShader(prog, fragment_shader);
    glLinkProgram(prog);
    try enforceProgramLinked(prog);



    //
    // hardcoded vertex objects for now
    //
    var vao : GLuint = undefined;
    zgl.genVertexArrays(singleItemSlice(GLuint, &vao));
    log("vao = {}", .{vao});
    var buf_obj : extern struct { v: GLuint, e: GLuint } = undefined;
    log("vbo = {}, ebo = {}", .{buf_obj.v, buf_obj.e});
    zgl.genBuffers(structSlice(GLuint, &buf_obj));

    {
        glBindVertexArray(vao);
        defer glBindVertexArray(0);

        glBindBuffer(GL_ARRAY_BUFFER, buf_obj.v);
        defer glBindBuffer(GL_ARRAY_BUFFER, 0);
        zgl.bufferData(GL_ARRAY_BUFFER, GLfloat, &[_]GLfloat {
            0.5,   0.5, 0.0, // top right
            0.5,  -0.5, 0.0, // bottom right
            -0.5, -0.5, 0.0, // bottom left
            -0.5,  0.5, 0.0, // top left
        }, GL_STATIC_DRAW);

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buf_obj.e);
        zgl.bufferData(GL_ELEMENT_ARRAY_BUFFER, GLuint, &[_]GLuint {
            0, 1, 2, // first triangle
            1, 2, 3, // second triangle
        }, GL_STATIC_DRAW);

        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * @sizeOf(GLfloat), null);
        //glEnableVertexAttribArray(0);
    }
}

// TODO: this should be somewhere else, like std library
fn singleItemSlice(comptime T: type, ref: *T) []T {
    return @ptrCast([*]T, ref)[0..1];
}
// TODO: this should be somewhere else, like std library
fn structSlice(comptime T: type, ref: anytype) []T {
    const RefT = @TypeOf(ref.*);
    std.debug.assert(@alignOf(RefT) >= @alignOf(T));
    const len = @sizeOf(RefT) / @sizeOf(T);
    std.debug.assert(len * @sizeOf(T) == @sizeOf(RefT));
    return @ptrCast([*]T, ref)[0 .. len];
}

const ShaderKind = enum { vertex, fragment };

fn compileShader(kind: ShaderKind, shader_src: [*:0]const u8) !GLuint {
    const shader = glCreateShader(switch (kind) { .vertex => GL_VERTEX_SHADER, .fragment => GL_FRAGMENT_SHADER });
    if (shader == 0)
        die(GlInitErrorTitle, "glCreateShader {} failed with {}\n", .{kind, glLastError()});
    errdefer glDeleteShader(shader);

    zgl.shaderSourceSingle(shader, shader_src);
    glCompileShader(shader);
    try enforceShaderCompiled(kind, shader);
    return shader;
}

fn enforceShaderCompiled(kind: ShaderKind, shader: GLuint) !void {
    const compile_status = zgl.getShaderiv(shader, GL_COMPILE_STATUS);
    if (compile_status == 0) {
        log("Error: failed to compile {} shader", .{kind});
        if (try zgl.getShaderInfoLogAlloc(std.heap.page_allocator, shader)) |log_str| {
            log("{s}", .{log_str});
            die(GlInitErrorTitle, "failed to compile {} shader, see log for details", .{kind});
        }
        die(GlInitErrorTitle, "failed to compile {} shader, unable to retrieve error log", .{kind});
    }
}

fn enforceProgramLinked(program: GLuint) !void {
    const link_status = zgl.getProgramiv(program, GL_LINK_STATUS);
    if (link_status == 0) {
        log("Error: failed to link shaders", .{});
        if (try zgl.getProgramInfoLogAlloc(std.heap.page_allocator, program)) |log_str| {
            log("{s}", .{log_str});
            die(GlInitErrorTitle, "failed to link shaders, see log for details", .{});
        }
        die(GlInitErrorTitle, "failed to link shaders, unable to retrieve error log", .{});
    }
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
