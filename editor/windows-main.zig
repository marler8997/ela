//
// Notes on creating an OpenGL context in Windows were found here:
//     https://www.khronos.org/opengl/wiki/Creating_an_OpenGL_Context_(WGL)
//
const std = @import("std");

const win = struct {
    pub usingnamespace @import("./windows.zig");
    pub usingnamespace std.os.windows;
};
const kernel32 = win.kernel32;
const user32 = win.user32;
const gdi32 = win.gdi32;

const gl = @import("gl");

const common = @import("./common.zig");
const log = common.log;
const die = common.die;
const assert = common.assert;
const L = common.L;
const T = common.T;

const mygl = @import("./mygl.zig");

const GetLastError = kernel32.GetLastError;

const LogErrorTitle = T("Log Error");
const WindowErrortitle = T("Window Setup Error");
const GraphicsErrorTitle = T("Graphics Setup Error");


pub fn panic(msg: []const u8, stacktrace: ?*std.builtin.StackTrace) noreturn {
    //const msg_buf = std.heap.page_allocator.alloc(u8, 300) catch @panic("allocation failed for panic error message");
    //const msg_a = std.fmt.bufPrint(msg_buf, msg_fmt, msg_args) catch @panic("bufPrint failed for panic error message");
    if (common.global_log_open) {
        common.global_log.writeAll(msg) catch {}; // ignore error
        // TODO: log stack trace
    }
    const msg_w = std.unicode.utf8ToUtf16LeWithNull(std.heap.page_allocator, msg) catch L("Failed to convert panic error message to UTF16");
    _ = win.MessageBoxW(null, msg_w, L("Panic"), win.MB_OK);
    // TODO: include stack trace in message box
    kernel32.ExitProcess(1);
}

// workaround: https://github.com/ziglang/zig/issues/7645
fn handleSegfault(info: *win.EXCEPTION_POINTERS) callconv(win.WINAPI) c_long {
    const desc = switch (info.ExceptionRecord.ExceptionCode) {
        win.EXCEPTION_DATATYPE_MISALIGNMENT => "Unaligned Memory Access",
        win.EXCEPTION_ACCESS_VIOLATION => "Access Violation",
        win.EXCEPTION_ILLEGAL_INSTRUCTION => "Illegal Instruction",
        win.EXCEPTION_STACK_OVERFLOW => "Stack Overflow",
        else => "???",
    };
    die(L("SegFault"), "{s} ({})", .{desc, info.ExceptionRecord.ExceptionCode});
}

pub export fn wWinMainCRTStartup() callconv(win.WINAPI) noreturn {
    _ = kernel32.AddVectoredExceptionHandler(0, handleSegfault);

    const result = init: {
        const LOG_FILENAME = "editor.log";
        common.global_log_file = std.fs.cwd().createFile(LOG_FILENAME, .{}) catch die(LogErrorTitle, "Failed to create log file '{s}' {}", .{LOG_FILENAME, GetLastError()});
        defer common.global_log_file.close();
        common.global_log = common.global_log_file.writer();
        common.global_log_open = true;
        break :init main();
    };
    if (result) {
        kernel32.ExitProcess(0);
    } else |err| switch (err) {
        //error.AlreadyReported => {
        //    return 1;
        //},
        else=> {
            _ = win.MessageBoxW(null, L("An uncaught error occurred (todo: get error message/stack)"), L("Uncaught Error"), win.MB_OK);
            kernel32.ExitProcess(1);
        },
    }
}

var global_gl_data : mygl.GLData = undefined;

fn main() !void {
    log("started", .{});
    const hInstance = @ptrCast(win.HINSTANCE, @alignCast(@alignOf(win.HINSTANCE), win.GetModuleHandleW(null)));
    const wc = win.WNDCLASSW {
        .style = user32.CS_OWNDC, // required for OpenGL context
        .lpfnWndProc = WindowProc,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = hInstance,
        .hIcon = null,
        .hCursor = null,
        .hbrBackground = null,
        .lpszMenuName = null,
        .lpszClassName = T("My Window Class"),
    };
    if(0 == win.RegisterClassW(&wc))
        die(WindowErrortitle, "RegisterClassW failed with {}", .{GetLastError()});

    const hWnd = win.CreateWindowExW(
        0,
        wc.lpszClassName,
        T("MyWindowName"),
        //win.WS_OVERLAPPEDWINDOW | win.WS_VISIBLE,
        win.WS_OVERLAPPEDWINDOW | win.WS_CLIPSIBLINGS | win.WS_CLIPCHILDREN,
        0,
        0,
        400,
        400,
        null, null,
        hInstance,
        null,
    ) orelse die(WindowErrortitle, "CreateWindowExW failed with {}", .{GetLastError()});

    const hdc = user32.GetDC(hWnd) orelse die(WindowErrortitle, "GetDC failed with {}", .{GetLastError()});
    // TODO: am I supposed to release this?
    //defer assert(1 == win.ReleaseDC(hWnd, hdc));

    // TODO: one example initialized opengl in WM_CREATE...is that better?
    _ = initOpengl(hdc, true);
    log("opengl initialized", .{});

    global_gl_data = try mygl.init();

    _ = user32.ShowWindow(hWnd, user32.SW_SHOW);

    var msg : win.MSG = undefined;
    while(win.GetMessageW(&msg, null, 0, 0 ) > 0) {
        _ = win.DispatchMessageW(&msg);
    }
    log("main loop done", .{});
}

fn WindowProc(hWnd: win.HWND, uMsg: u32, wParam: win.WPARAM, lParam: win.LPARAM) callconv(win.WINAPI) win.LRESULT
{
    switch (uMsg)
    {
        win.WM_DESTROY => {
            log("WM_DESTROY", .{});
            win.PostQuitMessage(0);
            return 0;
        },
        //win.WM_CREATE => {
        //    log("WM_CREATE", .{});
        //    return 0;
        //},
        win.WM_SIZE => {
            const width = win.LOWORD(@intCast(u32, 0xFFFFFFFF & lParam));
            const height = win.HIWORD(@intCast(u32, 0xFFFFFFFF & lParam));
            log("WM_SIZE {} x {}", .{width, height});
            mygl.onWindowSize(width, height);
            assert(0 != win.PostMessageW(hWnd, win.WM_PAINT, 0, 0));
            return 0;
        },
        win.WM_PAINT => {
            mygl.render(&global_gl_data);
            var ps: win.PAINTSTRUCT = undefined;
            const hdc = win.BeginPaint(hWnd, &ps);
            // All painting occurs here, between BeginPaint and EndPaint.
            //_ = win.FillRect(hdc, &ps.rcPaint, @intToPtr(win.HBRUSH, @as(usize, win.COLOR_WINDOW+1)));
            _ = win.EndPaint(hWnd, &ps);
            return 0;
        },
        else => {},
    }

    return win.DefWindowProcW(hWnd, uMsg, wParam, lParam);
}

fn initOpengl(hdc: win.HDC, log_pixel_format: bool) win.HGLRC {
    const pfd = gdi32.PIXELFORMATDESCRIPTOR {
        .nVersion = 1,
        // TODO: ser32.PFD_DOUBLEBUFFER?
        .dwFlags = win.PFD_DRAW_TO_WINDOW | win.PFD_SUPPORT_OPENGL,
        .iPixelType = win.PFD_TYPE_RGBA,
        .cColorBits = 32,
        .cRedBits = 0, .cRedShift = 0, .cGreenBits = 0, .cGreenShift = 0, .cBlueBits = 0, .cBlueShift = 0,
        .cAlphaBits = 0, .cAlphaShift = 0, .cAccumBits = 0,
        .cAccumRedBits = 0, .cAccumGreenBits = 0, .cAccumBlueBits = 0, .cAccumAlphaBits = 0,
        .cDepthBits = 24,
        .cStencilBits = 8,
        .cAuxBuffers = 0,
        .iLayerType = win.PFD_MAIN_PLANE,
        .bReserved = 0,
        .dwLayerMask = 0,
        .dwVisibleMask = 0,
        .dwDamageMask = 0,
    };
    const chosen = gdi32.ChoosePixelFormat(hdc, &pfd);
    if (chosen == 0)
        die(GraphicsErrorTitle, "ChoosePixelFormat failed with {}", .{GetLastError()});
    log("chosen format is {}", .{chosen});

    if (log_pixel_format) {
        var actual_pfd : gdi32.PIXELFORMATDESCRIPTOR = undefined;
        // TODO: should I verify any of these values??
        const max_pfd_index = win.DescribePixelFormat(hdc, chosen, @sizeOf(@TypeOf(actual_pfd)), &actual_pfd);
        if (max_pfd_index == 0) die(GraphicsErrorTitle, "DescribePixelFormat failed with {}", .{GetLastError()});
        inline for (@typeInfo(gdi32.PIXELFORMATDESCRIPTOR).Struct.fields) |field| {
            if (@field(pfd, field.name) == @field(actual_pfd, field.name)) {
                log("    {s} {}", .{field.name, @field(pfd, field.name)});
            } else {
                log("!!! {s} {} --> {}", .{field.name, @field(pfd, field.name), @field(actual_pfd, field.name)});
            }
        }
    }

    assert(gdi32.SetPixelFormat(hdc, chosen, &pfd));

    const gl_context = gl.windows.wglCreateContext(hdc) orelse die(GraphicsErrorTitle, "wglCreateContext failed with {}", .{GetLastError()});
    if (1 != gl.windows.wglMakeCurrent(hdc, gl_context)) {
        die(GraphicsErrorTitle, "wglMakeCurrent failed with {}", .{GetLastError()});
    }
    mygl.contextInitialized();
    return gl_context;
}
