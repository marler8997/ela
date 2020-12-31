
usingnamespace @import("./common.zig");
const gl = @import("./gl.zig");

usingnamespace gl.bits;
usingnamespace gl.funcs;
//usingnamespace gl.v1_0;
//usingnamespace gl.v1_0.Funcs;

//usingnamespace gl.v2_0;
//usingnamespace gl.v2_0.Funcs;
//usingnamespace @import("./gl.zig");

pub fn contextInitialized() void {
    log("OPENGL VERSION: {}", .{glGetString(GL_VERSION)});
    log("!!! TODO: parse and verify opengl version", .{});
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
    //const vertex_shader_id = glCreateShader(GL_VERTEX_SHADER);
    //if (vertex_shader_id == 0) {
    //}

}
