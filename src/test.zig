const std = @import("std");
const tok = @import("Token.zig");
const expect = std.testing.expect;

test "[SPLIT] \"hello world\"" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var words = tok.splitByWords("hello world", gpa.allocator());
    defer words.deinit();

    std.debug.print("Result: ", .{});
    for (words.items) |cur_word| std.debug.print("{s}, ", .{cur_word});
    std.debug.print("                 | Expected: hello, world\n", .{});

    try expect(words.items.len == 2);
    try expect(tok.areEqualStrings(words.items[0], "hello"));
    try expect(tok.areEqualStrings(words.items[1], "world"));
}

test "[SPLIT]\" 1 2 3   4 5  6   7  8  9 0\"" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var words = tok.splitByWords(" 1 2 3   4 5  6   7  8  9 0", gpa.allocator());
    defer words.deinit();

    std.debug.print("Result: ", .{});
    for (words.items) |cur_word| std.debug.print("{s}, ", .{cur_word});
    std.debug.print(" | Expected: 1, 2, 3, 4, 5, 6, 7, 8, 9, 0\n", .{});

    try expect(words.items.len == 10);
    try expect(tok.areEqualStrings(words.items[0], "1"));
    try expect(tok.areEqualStrings(words.items[1], "2"));
    try expect(tok.areEqualStrings(words.items[2], "3"));
    try expect(tok.areEqualStrings(words.items[3], "4"));
    try expect(tok.areEqualStrings(words.items[4], "5"));
    try expect(tok.areEqualStrings(words.items[5], "6"));
    try expect(tok.areEqualStrings(words.items[6], "7"));
    try expect(tok.areEqualStrings(words.items[7], "8"));
    try expect(tok.areEqualStrings(words.items[8], "9"));
    try expect(tok.areEqualStrings(words.items[9], "0"));
}

test "[SPLIT]\"\"" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var words = tok.splitByWords("", gpa.allocator());
    defer words.deinit();

    std.debug.print("Result: ", .{});
    for (words.items) |cur_word| std.debug.print("{s}, ", .{cur_word});
    std.debug.print("                               | Expected: \n", .{});

    try expect(words.items.len == 0);
}

test "[STRINGS MATCHING] \"asd\" in {\"bsd\", \"b3d\", \"bs6\", \"asd\", \"bd\"}" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var words = std.ArrayList([]const u8).init(gpa.allocator());
    defer words.deinit();

    try words.append("bsd");
    try words.append("b3d");
    try words.append("bs6");
    try words.append("asd");
    try words.append("db");

    const target = "asd";
    const result = tok.areEqualOneOfStrings(target, words);

    std.debug.print("Result: {}", .{result});
    std.debug.print("                           | Expected: {}", .{true});
    std.debug.print(" (\"asd\" in \"bsd\", \"b3d\", \"bs6\", \"asd\", \"bd\")\n", .{});
}
