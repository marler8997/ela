const std = @import("std");

pub const L = std.unicode.utf8ToUtf16LeStringLiteral;

pub const TChar = if (std.builtin.os.tag == .windows) u16 else u8;
fn utf8PassThru(comptime utf8: []const u8) []const u8 {
    return utf8;
}
pub const T = if (std.builtin.os.tag  == .windows) L else utf8PassThru;

pub var global_log_file : std.fs.File = undefined;
pub var global_log : std.fs.File.Writer = undefined;
pub var global_log_open = false;

pub fn die(title: [:0]const TChar, comptime msg_fmt: [:0]const u8, msg_args: anytype) noreturn {
    const win = @import("./windows.zig");
    const msg_buf = std.heap.page_allocator.alloc(u8, 300) catch @panic("allocation failed for panic error message");
    const msg_a = std.fmt.bufPrint(msg_buf, msg_fmt, msg_args) catch @panic("bufPrint failed for panic error message");
    if (global_log_open) {
        global_log.writeAll(msg_a) catch {}; // ignore error
    }
    const msg_w = std.unicode.utf8ToUtf16LeWithNull(std.heap.page_allocator, msg_a) catch @panic("utf8 to utf16 failed for panic error message");
    _ = win.MessageBoxW(null, msg_w, title, win.MB_OK);
    win.kernel32.ExitProcess(1);
}
pub fn log(comptime fmt: []const u8, args: anytype) void {
    global_log.print(fmt ++ "\n", args) catch die(L("Log Failed"), "log failed, the format message is: {s}", .{fmt});
}
pub fn assert(cond: bool) void {
    if (!cond) die(L("Assertion Failed"), "an assert failed (todo: more info)", .{});
}
