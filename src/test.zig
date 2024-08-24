const std = @import("std");
const expext = std.testing.expect;
const tk = @import("Tokenizer.zig");

test "1" {
    const tokenized = try tk.NumValue().fromString("1");

    std.debug.print("\n[TEST] \"1\" returned {}\n", .{tokenized.zig_val});
    try expext(tokenized.zig_val == 1);
}

test "1 + 1 tokenizing" {
    const tokenized = try tk.ExpressionTokenizer().getNumValues("1 + 1");

    std.debug.print("\n[TEST] \"1 + 1\" numValues() == {}, {}\n", .{ tokenized[0].zig_val, tokenized[1].zig_val });
    try expext(tokenized[0].zig_val == 1);
    try expext(tokenized[1].zig_val == 1);
}

test "1 + 1" {
    const tokenized = try tk.ExpressionTokenizer().Tokenize("1 + 1");

    std.debug.print("\n[TEST] \"1 + 1\" returned {}\n", .{tokenized.zig_val});
    try expext(tokenized.zig_val == 2);
}

test "1 - 1" {
    const tokenized = try tk.ExpressionTokenizer().Tokenize("1 - 1");

    std.debug.print("\n[TEST] \"1 - 1\" returned {}\n", .{tokenized.zig_val});
    try expext(tokenized.zig_val == 0);
}

test "11 +  0" {
    const tokenized = try tk.ExpressionTokenizer().Tokenize("11 +  0");

    std.debug.print("\n[TEST] \"11 +  0\" returned {}\n", .{tokenized.zig_val});
    try expext(tokenized.zig_val == 11);
}

test "4/ 2" {
    const tokenized = try tk.ExpressionTokenizer().Tokenize("4/ 2");

    std.debug.print("\n[TEST] \"4/ 2\" returned {}\n", .{tokenized.zig_val});
    try expext(tokenized.zig_val == 2);
}

test "  2 * 4" {
    const tokenized = try tk.ExpressionTokenizer().Tokenize("  2 * 4");

    std.debug.print("\n[TEST] \"  2 * 4\" returned {}\n", .{tokenized.zig_val});
    try expext(tokenized.zig_val == 8);
}

test "5/2" {
    const tokenized = try tk.ExpressionTokenizer().Tokenize("5/2");

    std.debug.print("\n[TEST] \"5/2\" returned {}\n", .{tokenized.zig_val});
    try expext(tokenized.zig_val == 2);
}

test "   5          + " {
    const err = tk.ExpressionTokenizer().Tokenize("   5          + ");

    std.debug.print("\n[TEST] \"   5          + \" returned {!}\n", .{err});
    try expext(err == tk.TokenError.FoundOnlyFirst);
}

test "/" {
    const err = tk.ExpressionTokenizer().Tokenize("/");

    std.debug.print("\n[TEST] \"/\" returned {!}\n", .{err});
    try expext(err == tk.TokenError.FoundZero);
}

test "5 2" {
    const err = tk.ExpressionTokenizer().Tokenize("5 2");

    std.debug.print("\n[TEST] \"5 2\" returned {!}\n", .{err});
    try expext(err == tk.TokenError.SignNotFound);
}
