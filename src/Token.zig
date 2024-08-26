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

pub fn areEqualOneOfStrings(target: []const u8, strings: std.ArrayList([]const u8)) bool {
    // var valid_strings_ids: [strings.items.len]?usize = null ** strings.len;
    var valid_strings_ids = strings.allocator.alloc(?usize, strings.items.len) catch unreachable;
    for (valid_strings_ids) |*id| id.* = null;
    defer strings.allocator.free(valid_strings_ids);

    var valid_strings_len: usize = 0;

    for (strings.items, 0..) |cur_string, i| {
        if (cur_string.len == target.len) {
            valid_strings_ids[valid_strings_len] = i;
            valid_strings_len += 1;
        }
    }

    // var are_valid: [valid_strings_len]bool = true ** valid_strings_len;
    var are_valid = strings.allocator.alloc(bool, valid_strings_len) catch unreachable;
    for (are_valid) |*is_valid| is_valid.* = true;
    defer strings.allocator.free(are_valid);

    var are_valid_trues_count = valid_strings_len;

    for (0..target.len) |char_i| {
        if (are_valid_trues_count <= 0) return false;

        for (0..valid_strings_len) |string_i| {
            if (!are_valid[string_i]) continue;

            if (target[char_i] != strings.items[string_i][char_i]) {
                are_valid[string_i] = false;
                are_valid_trues_count -= 1;
            }
        }
    }

    return are_valid_trues_count > 0;
}

pub fn areEqualStrings(string1: []const u8, string2: []const u8) bool {
    if (string1.len != string2.len) return false;

    for (string1, string2) |c1, c2| if (c1 != c2) return false;

    return true;
}
