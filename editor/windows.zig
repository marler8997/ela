//! Windows stuff missing in the standard library
const std = @import("std");
const win32 = struct {
    usingnamespace std.os.windows;
};

pub fn LOWORD(value: u32) u16 {
    return @intCast(u16, value & 0xFFFF);
}
pub fn HIWORD(value: u32) u16 {
    return @intCast(u16, (value >> 16) & 0xFFFF);
}

// TODO: I think these used to be in zig user32.zig, but now its gone?
pub const PFD_DRAW_TO_WINDOW = 4;
pub const PFD_SUPPORT_OPENGL = 32;
pub const PFD_TYPE_RGBA = 0;
pub const PFD_MAIN_PLANE = 0;

pub extern "kernel32" fn GetModuleHandleW(
    lpModuleName: ?[*:0]u16,
) callconv(win32.WINAPI) win32.HMODULE;

pub extern "user32" fn PostQuitMessage (
    nExitCode: c_int,
) callconv(win32.WINAPI) void;

pub extern "user32" fn PostMessageW (
    hWnd: ?win32.HWND,
    Msg: win32.UINT,
    wParam: win32.WPARAM,
    lPara: win32.LPARAM,
) callconv(win32.WINAPI) win32.BOOL;

pub extern "user32" fn MessageBoxW (
    hWnd: ?win32.HWND,
    lpText: win32.LPCWSTR,
    lpCaption: win32.LPCWSTR,
    uType: win32.UINT,
) callconv(win32.WINAPI) c_int;

pub const MB_OK = 0;

pub const WM_NULL = 0x0000;
pub const WM_CREATE = 0x0001;
pub const WM_DESTROY = 0x0002;
pub const WM_MOVE = 0x0003;
pub const WM_SIZE = 0x0005;

pub const WM_ACTIVATE = 0x0006;
pub const WM_PAINT = 0x000F;
pub const WM_CLOSE = 0x0010;
pub const WM_QUIT = 0x0012;
pub const WM_SETFOCUS = 0x0007;

pub const WNDPROC = fn (win32.HWND, win32.UINT, win32.WPARAM, win32.LPARAM) callconv(win32.WINAPI) win32.LRESULT;

pub const WNDCLASSW = extern struct {
    style: win32.UINT,
    lpfnWndProc: WNDPROC,
    cbClsExtra: c_int,
    cbWndExtra: c_int,
    hInstance: win32.HINSTANCE,
    hIcon: ?win32.HICON,
    hCursor: ?win32.HCURSOR,
    hbrBackground: ?win32.HBRUSH,
    lpszMenuName: ?win32.LPCWSTR,
    lpszClassName: win32.LPCWSTR,
};

pub extern "user32" fn RegisterClassW (
    lpWndClass: *const WNDCLASSW,
) callconv(win32.WINAPI) win32.ATOM;

// WS
pub const WS_OVERLAPPED = 0x00000000;
pub const WS_CAPTION = 0x00C00000;
pub const WS_SYSMENU = 0x00080000;
pub const WS_THICKFRAME = 0x00040000;
pub const WS_MINIMIZEBOX = 0x00020000;
pub const WS_MAXIMIZEBOX = 0x00010000;
pub const WS_OVERLAPPEDWINDOW = (WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX);
pub const WS_CLIPSIBLINGS = 67108864;
pub const WS_CLIPCHILDREN = 33554432;

pub const WS_VISIBLE = 0x10000000;

pub extern "user32" fn CreateWindowExW(
    dwExStyle: win32.DWORD,
    lpClassName: [*:0]const u16,
    lpWindowName: [*:0]const u16,
    dwStyle: win32.DWORD,
    X: c_int,
    Y: c_int,
    nWidth: c_int,
    nHeight: c_int,
    hWindParent: ?win32.HWND,
    hMenu: ?win32.HMENU,
    hInstance: win32.HINSTANCE,
    lpParam: ?win32.LPVOID,
) callconv(win32.WINAPI) ?win32.HWND;

pub const MSG = extern struct {
    hWnd: ?win32.HWND,
    message: win32.UINT,
    wParam: win32.WPARAM,
    lParam: win32.LPARAM,
    time: win32.DWORD,
    pt: win32.POINT,
    lPrivate: win32.DWORD,
};

pub const PAINTSTRUCT = extern struct {
    hdc: win32.HDC ,
    fErase: win32.BOOL,
    rcPaint: win32.RECT,
    fRestore: win32.BOOL,
    fIncUpdate: win32.BOOL,
    rgbReserved: [32]u8,
};

pub extern "user32" fn GetMessageW(
    lpMsg: *MSG,
    hWnd: ?win32.HWND,
    wMsgFilterMin: win32.UINT,
    wMsgFilterMax: win32.UINT,
) callconv(win32.WINAPI) win32.BOOL;

pub extern "user32" fn DispatchMessageW(
  lpMsg: *const MSG,
) callconv(win32.WINAPI) win32.LRESULT;


pub extern "user32" fn BeginPaint(
    hWnd: win32.HWND,
    lpPaint: *PAINTSTRUCT,
) callconv(win32.WINAPI) win32.HDC;
pub extern "user32" fn EndPaint(
    hWnd: win32.HWND,
    lpPaint: *PAINTSTRUCT,
) callconv(win32.WINAPI) win32.BOOL;
pub extern "user32" fn FillRect(
  hDC: win32.HDC,
  lprc: *const win32.RECT,
  hb: win32.HBRUSH,
) callconv(win32.WINAPI) c_int;
pub extern "user32" fn DefWindowProcW(
    hWnd: win32.HWND,
    Msg: win32.UINT,
    wParam: win32.WPARAM,
    lParam: win32.LPARAM,
) callconv(win32.WINAPI) win32.LRESULT;

pub const COLOR_SCROLLBAR           =  0;
pub const COLOR_BACKGROUND          =  1;
pub const COLOR_ACTIVECAPTION       =  2;
pub const COLOR_INACTIVECAPTION     =  3;
pub const COLOR_MENU                =  4;
pub const COLOR_WINDOW              =  5;
pub const COLOR_WINDOWFRAME         =  6;
pub const COLOR_MENUTEXT            =  7;
pub const COLOR_WINDOWTEXT          =  8;
pub const COLOR_CAPTIONTEXT         =  9;
pub const COLOR_ACTIVEBORDER        = 10;
pub const COLOR_INACTIVEBORDER      = 11;
pub const COLOR_APPWORKSPACE        = 12;
pub const COLOR_HIGHLIGHT           = 13;
pub const COLOR_HIGHLIGHTTEXT       = 14;
pub const COLOR_BTNFACE             = 15;
pub const COLOR_BTNSHADOW           = 16;
pub const COLOR_GRAYTEXT            = 17;
pub const COLOR_BTNTEXT             = 18;
pub const COLOR_INACTIVECAPTIONTEXT = 19;
pub const COLOR_BTNHIGHLIGHT        = 20;

pub extern "user32" fn ReleaseDC(hWnd: ?win32.HWND, hDC: win32.HDC) callconv(win32.WINAPI) c_int;

pub extern "gdi32" fn DescribePixelFormat(
    hdc: win32.HDC,
    iPixelFormat: c_int,
    nBytes: u32,
    ppf: *win32.gdi32.PIXELFORMATDESCRIPTOR,
) callconv(win32.WINAPI) c_int;
