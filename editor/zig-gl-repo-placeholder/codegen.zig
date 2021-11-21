const std = @import("std");
const Builder = std.build.Builder;
const Step = std.build.Step;
const StringHashMap = std.StringHashMap;

//const windowsopengl32 = @import("windowsopengl32.zig");
const glindex = @import("glindex.zig");

pub const OpenGlCodegenStep = struct {
    step: Step,
    b: *Builder,
    filename: []const u8,
    funcs: []const []const u8,
    glindex_pkg_name: []const u8,
    // TODO: OpenGL Debugging
    //       maybe I can add a parameter like "check_errors" which will generate code that
    //       checks every opengl function for errors?
    pub fn create(b: *Builder, named: struct {
        filename: []const u8,
        funcs: []const []const u8,
        glindex_pkg_name: []const u8,
    }) *OpenGlCodegenStep {
        // verify there are no duplicates in funcs
        {
            var func_map = StringHashMap(struct{}).init(b.allocator);
            defer func_map.deinit();
            for (named.funcs) |func| {
                if (func_map.get(func)) |_| {
                    std.debug.panic("OpenGL function '{s}' was given more than once in OpenGlCodegenStep", .{func});
                }
                func_map.put(func, .{}) catch @panic("Out Of Memory");
            }
        }
        var result = b.allocator.create(OpenGlCodegenStep) catch @panic("Out Of Memory");
        result.* = .{
            .step = Step.init(.custom, "generate OpenGL bindings", b.allocator, make),
            .b = b,
            .filename = named.filename,
            .funcs = named.funcs,
            .glindex_pkg_name = named.glindex_pkg_name,
        };
        return result;
    }
    fn make(step: *Step) anyerror!void {
        const self = @fieldParentPtr(OpenGlCodegenStep, "step", step);

        // TODO: check if the source needs to be regenerated???

        var build_root = try std.fs.cwd().openDir(self.b.build_root, .{});
        defer build_root.close();
        const file = try build_root.createFile(self.filename, .{});
        defer file.close();
        const writer = file.writer();
        try writer.writeAll(
            \\//! WARNING: This code is autogenerated from OpenGlCodegenStep in build.zig.
            \\const builtin = @import("builtin");
            \\const std = @import("std");
            \\
        );
        try writer.print("const glindex = @import(\"{s}\");\n", .{self.glindex_pkg_name});
        try writer.writeAll(
            \\
            \\pub fn loadRuntimeFuncs() ?glindex.zig.LoadRuntimeFuncsError {
            \\    return glindex.zig.loadRuntimeFuncs(@This().runtimefuncs);
            \\}
            \\pub usingnamespace if (builtin.os.tag == .windows) struct {
            \\
        );

        // setup a lookup for the windows functions
        {
            // gather linkable and runtime function
            var linkable_funcs = std.ArrayList([]const u8).init(self.b.allocator);
            defer linkable_funcs.deinit();
            var runtime_funcs = std.ArrayList([]const u8).init(self.b.allocator);
            defer runtime_funcs.deinit();
            {
                const Nothing = struct {};
                var linkable_func_map = StringHashMap(Nothing).init(self.b.allocator);
                defer linkable_func_map.deinit();
                var runtime_func_map = StringHashMap(Nothing).init(self.b.allocator);
                defer runtime_func_map.deinit();
                inline for (@typeInfo(glindex.windows).Struct.decls) |decl| {
                    try linkable_func_map.put(decl.name, .{});
                }
                inline for (@typeInfo(glindex.windows.RuntimeFnTypes).Struct.decls) |decl| {
                    try runtime_func_map.put(decl.name, .{});
                }
                for (self.funcs) |func| {
                    if (linkable_func_map.get(func)) |_| {
                        try linkable_funcs.append(func);
                    } else if (runtime_func_map.get(func)) |_| {
                        try runtime_funcs.append(func);
                    } else {
                        std.debug.warn("Error: unknown OpenGL function '{s}' added to OpenGlCodegenStep in build.zig\n", .{func});
                    }
                }
            }

            for (linkable_funcs.items) |func| {
                try enforceGlPrefix(func, "function");
                try writer.print("    pub const {s} = glindex.windows.{s};\n", .{fmtFirstLower(func[2..]), func});
            }
            try writer.print("    pub const runtimefuncs = struct {{\n", .{});
            for (runtime_funcs.items) |func| {
                // TODO: set to a function that asserts an error?
                try enforceGlPrefix(func, "function");
                try writer.print("        pub var {s} : glindex.windows.RuntimeFnTypes.{s} = undefined;\n", .{fmtFirstLower(func[2..]), func});
            }
            try writer.print("    }}; // end of runtimefuncs\n", .{});

            try writer.print("}} else struct {{ }}; // end of windows bindings\n", .{});
        }
    }
};

fn enforceGlPrefix(str: []const u8, what: []const u8) !void {
    if (!std.mem.startsWith(u8, str, "gl")) {
        std.log.err("{s} '{s}' does not start with 'gl'", .{what, str});
        return error.UnexpectedOpenglFunctionPrefix;
    }
    if (str.len < 3) {
        std.log.err("'gl' is not a valid {s}'", .{what});
        return error.ItsJustGl;
    }
}

const FirstLowerFormatter = struct {
    s: []const u8,
    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        if (self.s.len > 0) {
            {
                var buf: [1]u8 = undefined;
                buf[0] = std.ascii.toLower(self.s[0]);
                try writer.writeAll(&buf);
            }
            try writer.writeAll(self.s[1..]);
        }
    }
};
pub fn fmtFirstLower(s: []const u8) FirstLowerFormatter {
    return .{ .s = s };
}


// TODO: I'm not using this anymore, but it should go somewhere, like standard lib
//const UpperFormatter = struct {
//    s: []const u8,
//    pub fn format(
//        self: @This(),
//        comptime fmt: []const u8,
//        options: std.fmt.FormatOptions,
//        writer: anytype,
//    ) std.os.WriteError!void {
//        var printed : usize = 0;
//        var i : usize = 0;
//        while (i < self.s.len) : (i += 1 ){
//            if (self.s[i] >= 'a' and self.s[i] <= 'z') {
//                if (i > printed)
//                    try writer.writeAll(self.s[printed .. i]);
//                try writer.writeByte(self.s[i] - ('a' - 'A'));
//                printed = i + 1;
//            }
//        }
//        if (i > printed)
//            try writer.writeAll(self.s[printed .. i]);
//    }
//};
//pub fn fmtUpper(s: []const u8) UpperFormatter {
//    return .{ .s = s };
//}
//
