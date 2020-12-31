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
const opengl32 = win.opengl32;

usingnamespace @import("./common.zig");
const mygl = @import("./mygl.zig");

const GetLastError = kernel32.GetLastError;

const LogErrorTitle = T("Log Error");
const WindowErrortitle = T("Window Setup Error");
const GraphicsErrorTitle = T("Graphics Setup Error");

pub export fn wWinMainCRTStartup() callconv(win.WINAPI) noreturn {
    const result = init: {
        const LOG_FILENAME = "editor.log";
        globalLogFile = std.fs.cwd().createFile(LOG_FILENAME, .{}) catch dieMaybeLog(false, LogErrorTitle, "Failed to create log file '{}' {}", .{LOG_FILENAME, GetLastError()});
        defer globalLogFile.close();
        globalLog = globalLogFile.writer();
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
        256,
        256,
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

    mygl.init();

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
            return null;
        },
        //win.WM_CREATE => {
        //    log("WM_CREATE", .{});
        //    return null;
        //},
        win.WM_SIZE => {
            const width = win.LOWORD(@intCast(u32, 0xFFFFFFFF & @ptrToInt(lParam)));
            const height = win.HIWORD(@intCast(u32, 0xFFFFFFFF & @ptrToInt(lParam)));
            log("WM_SIZE {} x {}", .{width, height});
            mygl.onWindowSize(width, height);
            assert(0 != win.PostMessageW(hWnd, win.WM_PAINT, 0, null));
            return null;
        },
        win.WM_PAINT => {
            mygl.renderTriangle();
            var ps: win.PAINTSTRUCT = undefined;
            const hdc = win.BeginPaint(hWnd, &ps);
            // All painting occurs here, between BeginPaint and EndPaint.
            //_ = win.FillRect(hdc, &ps.rcPaint, @intToPtr(win.HBRUSH, @as(usize, win.COLOR_WINDOW+1)));
            _ = win.EndPaint(hWnd, &ps);
            return null;
        },
        else => {},
    }

    return win.DefWindowProcW(hWnd, uMsg, wParam, lParam);
}

fn initOpengl(hdc: win.HDC, log_pixel_format: bool) win.HGLRC {
    const pfd = gdi32.PIXELFORMATDESCRIPTOR {
        .nVersion = 1,
        // TODO: ser32.PFD_DOUBLEBUFFER?
        .dwFlags = user32.PFD_DRAW_TO_WINDOW | user32.PFD_SUPPORT_OPENGL,
        .iPixelType = user32.PFD_TYPE_RGBA,
        .cColorBits = 32,
        .cRedBits = 0, .cRedShift = 0, .cGreenBits = 0, .cGreenShift = 0, .cBlueBits = 0, .cBlueShift = 0,
        .cAlphaBits = 0, .cAlphaShift = 0, .cAccumBits = 0,
        .cAccumRedBits = 0, .cAccumGreenBits = 0, .cAccumBlueBits = 0, .cAccumAlphaBits = 0,
        .cDepthBits = 24,
        .cStencilBits = 8,
        .cAuxBuffers = 0,
        .iLayerType = user32.PFD_MAIN_PLANE,
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
                log("    {} {}", .{field.name, @field(pfd, field.name)});
            } else {
                log("!!! {} {} --> {}", .{field.name, @field(pfd, field.name), @field(actual_pfd, field.name)});
            }
        }
    }

    assert(gdi32.SetPixelFormat(hdc, chosen, &pfd));

    const gl_context = opengl32.wglCreateContext(hdc) orelse die(GraphicsErrorTitle, "wglCreateContext failed with {}", .{GetLastError()});
    if (1 != opengl32.wglMakeCurrent(hdc, gl_context)) {
        die(GraphicsErrorTitle, "wglMakeCurrent failed with {}", .{GetLastError()});
    }
    mygl.contextInitialized();
    return gl_context;
}
