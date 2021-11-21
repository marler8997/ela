const builtin = @import("builtin");
const std = @import("std");

const common = @import("./common.zig");
const log = common.log;
const die = common.die;

const glindex = @import("glindex");
const gl = struct {
    usingnamespace glindex.bits;

    const gl_generated = @import("gl.generated.zig");
    usingnamespace gl_generated;
    usingnamespace gl_generated.runtimefuncs;
};
const zgl = glindex.zig.wrap(gl);

const platform = if (builtin.os.tag == .windows) struct {
    const win = struct {
        pub usingnamespace @import("./windows.zig");
        pub usingnamespace std.os.windows;
    };
    const kernel32 = win.kernel32;
    pub const lastError = kernel32.GetLastError;
    pub const GlGetProcErrorTitle = common.T("OpenGL Get Proc Error");
    pub const GlInitErrorTitle = common.T("OpenGL Initialization Error");
    pub const glLastError = win.kernel32.GetLastError;
} else struct {};


pub fn contextInitialized() void {
    log("OPENGL VERSION: {s}", .{gl.getString(gl.VERSION)});
    log("!!! TODO: parse and verify opengl version", .{});

    if (gl.loadRuntimeFuncs()) |err| {
        die(platform.GlGetProcErrorTitle, "after loading {} OpenGL functions, failed to load '{s}' with {}", .{err.loaded, err.failed, platform.lastError()});
    }
}

pub fn onWindowSize(width: u32, height: u32) void {
    gl.viewport(0, 0, width, height);
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
        prog: u32,
        triangle: Triangle,
        rect0: Rect,
        rect1: Rect,
    },
    vec3_uniform: struct {
        prog: u32,
        color_loc: i32,
        rect0: Rect,
    },
};

pub fn init() !GLData {
    const programs = init: {
        const vec3_vertex_shader = try compileShader(.vertex, vec3_vertex_shader_src);
        defer gl.deleteShader(vec3_vertex_shader);

        const orange_fragment_shader = try compileShader(.fragment, orange_fragment_shader_src);
        defer gl.deleteShader(orange_fragment_shader);

        const uniform_fragment_shader = try compileShader(.fragment, uniform_fragment_shader_src);
        defer gl.deleteShader(uniform_fragment_shader);

        break :init .{
            .vec3_orange = try makeProgram(vec3_vertex_shader, orange_fragment_shader),
            .vec3_uniform = try makeProgram(vec3_vertex_shader, uniform_fragment_shader),
        };
    };

    // uncomment this call to draw in wireframe polygons.
    //glPolygonMode(gl.FRONT_AND_BACK, gl.LINE);

    const uniform_color_loc = gl.getUniformLocation(programs.vec3_uniform, "uniformColor");
    common.assert(uniform_color_loc != -1);

    return GLData {
        .random = std.rand.DefaultPrng.init(0),
        .vec3_orange = .{
            .prog = programs.vec3_orange,
            .triangle = Triangle.init(),
            .rect0 = Rect.init(.{
                .left = 0.6,
                .top  = 0.8,
                .right = 0.8,
                .bottom = 0.6,
            }),
            .rect1 = Rect.init(.{
                .left = 0.6,
                .top  = 0.4,
                .right = 0.8,
                .bottom = 0.2,
            }),
        },
        .vec3_uniform = .{
            .prog = programs.vec3_uniform,
            .color_loc = uniform_color_loc,
            .rect0 = Rect.init(.{
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

    gl.clearColor(0.2, 0.3, 0.3, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.useProgram(gl_data.vec3_orange.prog);
    //gl_data.triangle.render();
    gl_data.vec3_orange.rect0.render();
    gl_data.vec3_orange.rect1.render();

    gl.useProgram(gl_data.vec3_uniform.prog);
    gl.uniform4f(gl_data.vec3_uniform.color_loc,
        gl_data.random.random().float(f32),
        gl_data.random.random().float(f32),
        gl_data.random.random().float(f32),
        1
    );
    gl_data.vec3_uniform.rect0.render();
    gl.flush();
}

const do_unbinds = true;


pub const Triangle = struct {
    vao: u32,
    vbo: u32,
    pub fn init() Triangle {
        var self : Triangle = .{
            .vao = undefined,
            .vbo = undefined,
        };
        zgl.genVertexArrays(singleItemSlice(u32, &self.vao));
        gl.bindVertexArray(self.vao);
        defer if (do_unbinds) gl.bindVertexArray(0);

        zgl.genBuffers(singleItemSlice(u32, &self.vbo));
        gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo);
        defer if (do_unbinds) gl.bindBuffer(gl.ARRAY_BUFFER, 0);
        zgl.bufferData(gl.ARRAY_BUFFER, f32, &[_]f32 {
            -0.5, -0.5, 0.0, // left
             0.5, -0.5, 0.0, // right
             0.0,  0.5, 0.0, // top
        }, gl.STATIC_DRAW);
        gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * @sizeOf(f32), null);
        gl.enableVertexAttribArray(0);
        return self;
    }
    pub fn deinitTriangle(self: @This()) void {
        zgl.deleteBuffers(singleItemSlice(u32, &self.vbo));
        zgl.deleteVertexArrays(singleItemSlice(u32, &self.vao));
    }
    pub fn render(self: @This()) void {
        gl.bindVertexArray(self.vao);
        defer if (do_unbinds) gl.bindVertexArray(0);
        gl.drawArrays(gl.TRIANGLES, 0, 3);
    }
};

const Rect2d = struct {
    left: f32, top: f32, right: f32, bottom: f32,
};

pub const Rect = struct {
    vao: u32,
    buf_objs: [2]u32,
    pub fn init(coord: Rect2d) Rect {
        var self : Rect = .{
            .vao = undefined,
            .buf_objs = undefined,
        };
        zgl.genVertexArrays(singleItemSlice(u32, &self.vao));
        gl.bindVertexArray(self.vao);
        defer if (do_unbinds) gl.bindVertexArray(0);

        zgl.genBuffers(structSlice(u32, &self.buf_objs));
        gl.bindBuffer(gl.ARRAY_BUFFER, self.buf_objs[0]);
        // NOTE: cannot unbind this until after calling gl.enableVertexAttribArray?
        defer if (do_unbinds) gl.bindBuffer(gl.ARRAY_BUFFER, 0);
        zgl.bufferData(gl.ARRAY_BUFFER, f32, &[_]f32 {
            coord.left,  coord.bottom, 0.0,
            coord.left,  coord.top   , 0.0,
            coord.right, coord.bottom, 0.0,
            coord.right, coord.top   , 0.0,
        }, gl.STATIC_DRAW);
        gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * @sizeOf(f32), null);
        gl.enableVertexAttribArray(0);

        // TODO: I don't need this element buffer, remove it, but I'm keeping it as an example for now
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.buf_objs[1]);
        // NOTE: cannot unbind this for some reason?
        // I saw this: do NOT unbind the EBO while a VAO is active as the bound element buffer object IS stored in the VAO; keep the EBO bound.
        // however, it seems I can't unbind it even after unbinding the current VAO?
        //defer if (do_unbinds) gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);
        zgl.bufferData(gl.ELEMENT_ARRAY_BUFFER, u32, &[_]u32 {
            0, 1, 2, 3,
        }, gl.STATIC_DRAW);
        return self;
    }
    pub fn deinitTriangle(self: @This()) void {
        zgl.deleteBuffers(&self.buf_objs);
        zgl.deleteVertexArrays(singleItemSlice(u32, &self.vao));
    }
    pub fn render(self: @This()) void {
        gl.bindVertexArray(self.vao);
        defer if (do_unbinds) gl.bindVertexArray(0);
        gl.drawElements(gl.TRIANGLE_STRIP, 4, gl.UNSIGNED_INT, null);
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


fn makeProgram(vertex_shader: u32, fragment_shader: u32) !u32 {
    const prog = gl.createProgram();
    if (prog == 0) die(platform.GlInitErrorTitle, "gl.createProgram failed", .{});
    errdefer gl.deleteProgram(prog);

    gl.attachShader(prog, vertex_shader);
    gl.attachShader(prog, fragment_shader);
    gl.linkProgram(prog);
    try enforceProgramLinked(prog);
    return prog;
}

fn compileShader(kind: ShaderKind, shader_src: [*:0]const u8) !u32 {
    const shader = gl.createShader(switch (kind) { .vertex => gl.VERTEX_SHADER, .fragment => gl.FRAGMENT_SHADER });
    if (shader == 0)
        die(platform.GlInitErrorTitle, "gl.createShader {} failed with {}\n", .{kind, platform.glLastError()});
    errdefer gl.deleteShader(shader);

    zgl.shaderSourceSingle(shader, shader_src);
    gl.compileShader(shader);
    try enforceShaderCompiled(kind, shader);
    return shader;
}

fn enforceShaderCompiled(kind: ShaderKind, shader: u32) !void {
    const compile_status = zgl.getShaderiv(shader, gl.COMPILE_STATUS);
    if (compile_status == 0) {
        log("Error: failed to compile {} shader", .{kind});
        if (try zgl.getShaderInfoLogAlloc(std.heap.page_allocator, shader)) |log_str| {
            log("{s}", .{log_str});
            die(platform.GlInitErrorTitle, "failed to compile {} shader, see log for details", .{kind});
        }
        die(platform.GlInitErrorTitle, "failed to compile {} shader, unable to retrieve error log", .{kind});
    }
}

fn enforceProgramLinked(program: u32) !void {
    const link_status = zgl.getProgramiv(program, gl.LINK_STATUS);
    if (link_status == 0) {
        log("Error: failed to link shaders", .{});
        if (try zgl.getProgramInfoLogAlloc(std.heap.page_allocator, program)) |log_str| {
            log("{s}", .{log_str});
            die(platform.GlInitErrorTitle, "failed to link shaders, see log for details", .{});
        }
        die(platform.GlInitErrorTitle, "failed to link shaders, unable to retrieve error log", .{});
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
