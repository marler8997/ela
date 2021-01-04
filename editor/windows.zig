//! Windows stuff missing in the standard library
const std = @import("std");
usingnamespace std.os.windows;

pub fn LOWORD(value: u32) u16 {
    return @intCast(u16, value & 0xFFFF);
}
pub fn HIWORD(value: u32) u16 {
    return @intCast(u16, (value >> 16) & 0xFFFF);
}

pub extern "kernel32" fn GetModuleHandleW(
    lpModuleName: ?[*:0]u16,
) callconv(WINAPI) HMODULE;

pub extern "user32" fn PostQuitMessage (
    nExitCode: c_int,
) callconv(WINAPI) void;

pub extern "user32" fn PostMessageW (
    hWnd: ?HWND,
    Msg: UINT,
    wParam: WPARAM,
    lPara: LPARAM,
) callconv(WINAPI) BOOL;

pub extern "user32" fn MessageBoxW (
    hWnd: ?HWND,
    lpText: LPCWSTR,
    lpCaption: LPCWSTR,
    uType: UINT,
) callconv(WINAPI) c_int;

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

pub const WNDPROC = fn (HWND, UINT, WPARAM, LPARAM) callconv(WINAPI) LRESULT;

pub const WNDCLASSW = extern struct {
    style: UINT,
    lpfnWndProc: WNDPROC,
    cbClsExtra: c_int,
    cbWndExtra: c_int,
    hInstance: HINSTANCE,
    hIcon: ?HICON,
    hCursor: ?HCURSOR,
    hbrBackground: ?HBRUSH,
    lpszMenuName: ?LPCWSTR,
    lpszClassName: LPCWSTR,
};

pub const ATOM = u16;

pub extern "user32" fn RegisterClassW (
    lpWndClass: *const WNDCLASSW,
) callconv(WINAPI) ATOM;

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
    dwExStyle: DWORD,
    lpClassName: [*:0]const u16,
    lpWindowName: [*:0]const u16,
    dwStyle: DWORD,
    X: c_int,
    Y: c_int,
    nWidth: c_int,
    nHeight: c_int,
    hWindParent: ?HWND,
    hMenu: ?HMENU,
    hInstance: HINSTANCE,
    lpParam: ?LPVOID,
) callconv(WINAPI) ?HWND;

pub const POINT = extern struct {
    x: c_long, y: c_long
};

pub const MSG = extern struct {
    hWnd: ?HWND,
    message: UINT,
    wParam: WPARAM,
    lParam: LPARAM,
    time: DWORD,
    pt: POINT,
    lPrivate: DWORD,
};

pub const PAINTSTRUCT = extern struct {
    hdc: HDC ,
    fErase: BOOL,
    rcPaint: RECT,
    fRestore: BOOL,
    fIncUpdate: BOOL,
    rgbReserved: [32]u8,
};

pub extern "user32" fn GetMessageW(
    lpMsg: *MSG,
    hWnd: ?HWND,
    wMsgFilterMin: UINT,
    wMsgFilterMax: UINT,
) callconv(WINAPI) BOOL;

pub extern "user32" fn DispatchMessageW(
  lpMsg: *const MSG,
) callconv(WINAPI) LRESULT;

pub const RECT = extern struct {
    left: LONG,
    top: LONG,
    right: LONG,
    bottom: LONG,
};

pub extern "user32" fn BeginPaint(
    hWnd: HWND,
    lpPaint: *PAINTSTRUCT,
) callconv(WINAPI) HDC;
pub extern "user32" fn EndPaint(
    hWnd: HWND,
    lpPaint: *PAINTSTRUCT,
) callconv(WINAPI) BOOL;
pub extern "user32" fn FillRect(
  hDC: HDC,
  lprc: *const RECT,
  hb: HBRUSH,
) callconv(WINAPI) c_int;
pub extern "user32" fn DefWindowProcW(
    hWnd: HWND,
    Msg: UINT,
    wParam: WPARAM,
    lParam: LPARAM,
) callconv(WINAPI) LRESULT;

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

pub extern "user32" fn ReleaseDC(hWnd: ?HWND, hDC: HDC) callconv(WINAPI) c_int;

pub extern "gdi32" fn DescribePixelFormat(
    hdc: HDC,
    iPixelFormat: c_int,
    nBytes: u32,
    ppf: *gdi32.PIXELFORMATDESCRIPTOR,
) callconv(WINAPI) c_int;
