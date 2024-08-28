const std = @import("std");
const tok = @import("Token.zig");

/// call init(std.mem.Allocator) before (or else catch unreachable).
pub fn isStdClass(target: []const u8) bool {
    const classes = stdClasses() catch unreachable;

    return tok.areEqualOneOfStrings(target, classes);
}

const StdError = error{StdClassesNotInitialized};

var std_classes: ?std.ArrayList([]const u8) = null;

fn initStdClasses(allocator: std.mem.Allocator) void {
    std_classes = std.ArrayList([]const u8).init(allocator);

    std_classes.?.append("Num") catch @panic("Out of memory");
    std_classes.?.append("Char") catch @panic("Out of memory");
}

fn deinitStdClasses() void {
    std_classes.?.deinit();
}

pub fn stdClasses() StdError!std.ArrayList([]const u8) {
    return std_classes orelse StdError.StdClassesNotInitialized;
}

pub fn init(allocator: std.mem.Allocator) void {
    initStdClasses(allocator);
}

pub fn deinit() void {
    deinitStdClasses();
}
