const std = @import("std");
const tk = @import("Tokenizer.zig");

pub const Type = enum {
    File,
};

pub fn FileInput() type {
    return struct {
        const Self = @This();

        file: std.fs.File,
        tokenizer: tk.ExpressionTokenizer(),

        pub fn init(file: std.fs.File, tokenizer: tk.ExpressionTokenizer()) Self {
            return Self{
                .file = file,
                .tokenizer = tokenizer,
            };
        }

        fn CompileAndRunSingleLine(self: Self) []const u8 {
            var buffer: [128]u8 = undefined;
            self.file.seekTo(0) catch unreachable;
            const line = self.file.readAll(&buffer) catch unreachable;

            return self.tokenizer.getTokenizedOuput(line);
        }
    };
}
