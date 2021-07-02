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

// TODO: does this fix line numbers in shader log? gl.zig.toZLinesStringLiteral ???
// NOTE: this is pretty much the simplest 3d vertex shader we can write, it just passes
//       the points it gets through to the next stage of the pipeline.
const vec3_vertex_shader_src =
    \\#version 330 core
    \\layout (location = 0) in vec3 aPos;
    \\void main()
    \\{
    \\    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    \\}
;

const orange_fragment_shader_src =
    \\#version 330 core
    \\out vec4 FragColor;
    \\void main()
    \\{
    \\   FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
    \\}
;
const uniform_fragment_shader_src =
    \\#version 330 core
    \\out vec4 FragColor;
    \\uniform vec4 uniformColor;
    \\void main()
    \\{
    \\   FragColor = uniformColor;
    \\}
;

pub const GLData = struct {
    random: std.rand.DefaultPrng,
    vec3_orange: struct {
        prog: GLuint,
        triangle: GLTriangle,
        rect0: GLRect,
        rect1: GLRect,
    },
    vec3_uniform: struct {
        prog: GLuint,
        color_loc: GLint,
        rect0: GLRect,
    },
};

pub fn init() !GLData {
    const programs = init: {
        const vec3_vertex_shader = try compileShader(.vertex, vec3_vertex_shader_src);
        defer glDeleteShader(vec3_vertex_shader);

        const orange_fragment_shader = try compileShader(.fragment, orange_fragment_shader_src);
        defer glDeleteShader(orange_fragment_shader);

        const uniform_fragment_shader = try compileShader(.fragment, uniform_fragment_shader_src);
        defer glDeleteShader(uniform_fragment_shader);

        break :init .{
            .vec3_orange = try makeProgram(vec3_vertex_shader, orange_fragment_shader),
            .vec3_uniform = try makeProgram(vec3_vertex_shader, uniform_fragment_shader),
        };
    };

    // uncomment this call to draw in wireframe polygons.
    //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

    const uniform_color_loc = glGetUniformLocation(programs.vec3_uniform, "uniformColor");
    common.assert(uniform_color_loc != -1);

    return GLData {
        .random = std.rand.DefaultPrng.init(0),
        .vec3_orange = .{
            .prog = programs.vec3_orange,
            .triangle = GLTriangle.init(),
            .rect0 = GLRect.init(.{
                .left = 0.6,
                .top  = 0.8,
                .right = 0.8,
                .bottom = 0.6,
            }),
            .rect1 = GLRect.init(.{
                .left = 0.6,
                .top  = 0.4,
                .right = 0.8,
                .bottom = 0.2,
            }),
        },
        .vec3_uniform = .{
            .prog = programs.vec3_uniform,
            .color_loc = uniform_color_loc,
            .rect0 = GLRect.init(.{
                .left = 0.2,
                .top  = 0.7,
                .right = 0.4,
                .bottom = 0.5,
            }),
        },
    };
}


pub fn render(gl_data: *GLData) void {
    log("render", .{});

    glClearColor(0.2, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glUseProgram(gl_data.vec3_orange.prog);
    //gl_data.triangle.render();
    gl_data.vec3_orange.rect0.render();
    gl_data.vec3_orange.rect1.render();

    glUseProgram(gl_data.vec3_uniform.prog);
    glUniform4f(gl_data.vec3_uniform.color_loc,
        gl_data.random.random.float(f32),
        gl_data.random.random.float(f32),
        gl_data.random.random.float(f32),
        1
    );
    gl_data.vec3_uniform.rect0.render();
    glFlush();
}

const do_unbinds = true;


pub const GLTriangle = struct {
    vao: GLuint,
    vbo: GLuint,
    pub fn init() GLTriangle {
        var self : GLTriangle = .{
            .vao = undefined,
            .vbo = undefined,
        };
        zgl.genVertexArrays(singleItemSlice(GLuint, &self.vao));
        glBindVertexArray(self.vao);
        defer if (do_unbinds) glBindVertexArray(0);

        zgl.genBuffers(singleItemSlice(GLuint, &self.vbo));
        glBindBuffer(GL_ARRAY_BUFFER, self.vbo);
        defer if (do_unbinds) glBindBuffer(GL_ARRAY_BUFFER, 0);
        zgl.bufferData(GL_ARRAY_BUFFER, GLfloat, &[_]GLfloat {
            -0.5, -0.5, 0.0, // left
             0.5, -0.5, 0.0, // right
             0.0,  0.5, 0.0, // top
        }, GL_STATIC_DRAW);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * @sizeOf(GLfloat), null);
        glEnableVertexAttribArray(0);
        return self;
    }
    pub fn deinitTriangle(self: @This()) void {
        zgl.deleteBuffers(singleItemSlice(GLuint, &self.vbo));
        zgl.deleteVertexArrays(singleItemSlice(GLuint, &self.vao));
    }
    pub fn render(self: @This()) void {
        glBindVertexArray(self.vao);
        defer if (do_unbinds) glBindVertexArray(0);
        glDrawArrays(GL_TRIANGLES, 0, 3);
    }
};

const Rect2d = struct {
    left: f32, top: f32, right: f32, bottom: f32,
};

pub const GLRect = struct {
    vao: GLuint,
    buf_objs: [2]GLuint,
    pub fn init(coord: Rect2d) GLRect {
        var self : GLRect = .{
            .vao = undefined,
            .buf_objs = undefined,
        };
        zgl.genVertexArrays(singleItemSlice(GLuint, &self.vao));
        glBindVertexArray(self.vao);
        defer if (do_unbinds) glBindVertexArray(0);

        zgl.genBuffers(structSlice(GLuint, &self.buf_objs));
        glBindBuffer(GL_ARRAY_BUFFER, self.buf_objs[0]);
        // NOTE: cannot unbind this until after calling glEnableVertexAttribArray?
        defer if (do_unbinds) glBindBuffer(GL_ARRAY_BUFFER, 0);
        zgl.bufferData(GL_ARRAY_BUFFER, GLfloat, &[_]GLfloat {
            coord.left,  coord.bottom, 0.0,
            coord.left,  coord.top   , 0.0,
            coord.right, coord.bottom, 0.0,
            coord.right, coord.top   , 0.0,
        }, GL_STATIC_DRAW);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * @sizeOf(GLfloat), null);
        glEnableVertexAttribArray(0);

        // TODO: I don't need this element buffer, remove it, but I'm keeping it as an example for now
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.buf_objs[1]);
        // NOTE: cannot unbind this for some reason?
        // I saw this: do NOT unbind the EBO while a VAO is active as the bound element buffer object IS stored in the VAO; keep the EBO bound.
        // however, it seems I can't unbind it even after unbinding the current VAO?
        //defer if (do_unbinds) glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        zgl.bufferData(GL_ELEMENT_ARRAY_BUFFER, GLuint, &[_]GLuint {
            0, 1, 2, 3,
        }, GL_STATIC_DRAW);
        return self;
    }
    pub fn deinitTriangle(self: @This()) void {
        zgl.deleteBuffers(&self.buf_objs);
        zgl.deleteVertexArrays(singleItemSlice(GLuint, &self.vao));
    }
    pub fn render(self: @This()) void {
        glBindVertexArray(self.vao);
        defer if (do_unbinds) glBindVertexArray(0);
        glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_INT, null);
    }
};


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


fn makeProgram(vertex_shader: GLuint, fragment_shader: GLuint) !GLuint {
    const prog = glCreateProgram();
    if (prog == 0) die(GlInitErrorTitle, "glCreateProgram failed", .{});
    errdefer glDeleteProgram(prog);

    glAttachShader(prog, vertex_shader);
    glAttachShader(prog, fragment_shader);
    glLinkProgram(prog);
    try enforceProgramLinked(prog);
    return prog;
}

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
