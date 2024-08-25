const std = @import("std");

pub fn splitByWords(string: []const u8, allocator: std.mem.Allocator) std.ArrayList([]const u8) {
    var words = std.ArrayList([]const u8).init(allocator);

    var cur_len: u8 = 0;

    for (string, 0..) |char, i| {
        if (std.ascii.isWhitespace(char)) {
            if (cur_len > 0) {
                const cur_len_usize: usize = @intCast(cur_len);
                words.append(string[i - cur_len_usize .. i]) catch unreachable;
            }

            cur_len = 0;
            continue;
        } else cur_len += 1;
    }

    if (cur_len > 0) {
        const cur_len_usize: usize = @intCast(cur_len);
        words.append(string[string.len - cur_len_usize .. string.len]) catch unreachable;
    }

    return words;
}

pub fn areEqualStrings(string1: []const u8, string2: []const u8) bool {
    if (string1.len != string2.len) return false;

    for (string1, string2) |c1, c2| if (c1 != c2) return false;

    return true;
}
