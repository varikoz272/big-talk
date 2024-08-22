const std = @import("std");

pub fn AskingTokenizer() type {
    return struct {
        const Self = @This();
    };
}

pub fn ExpressionTokenizer() type {
    return struct {
        const Self = @This();

        pub fn Tokenize(string: []const u8) TokenError!NumValue() {
            const sign = try getSign(string);
            const nums = try getNumValues(string);

            return merge(nums, sign);
        }

        fn merge(nums: [2]NumValue(), sign: Sign) NumValue() {
            switch (sign) {
                .Plus => return NumValue().init(nums[0].zig_val + nums[1].zig_val),
                .Minus => return NumValue().init(nums[0].zig_val - nums[1].zig_val),
                .Multiply => return NumValue().init(nums[0].zig_val * nums[1].zig_val),
                .Divide => return NumValue().init(@divTrunc(nums[0].zig_val, nums[1].zig_val)),
            }
        }

        pub fn getSign(string: []const u8) TokenError!Sign {
            return Sign.findFromString(string);
        }

        pub fn getNumValues(string: []const u8) TokenError![2]NumValue() {
            var f_start: ?usize = null;
            var f_inside: bool = false;
            var s_start: ?usize = null;
            var num_len: usize = 0;

            var out_f: ?NumValue() = null;
            var out_s: ?NumValue() = null;

            for (0..string.len + 1) |i| {
                const char: ?u8 = if (i < string.len) string[i] else null;

                if (char == null) {
                    if (num_len > 0) {
                        if (f_inside) {
                            out_f = NumValue().fromString(string[i - num_len .. i]) catch unreachable;
                            f_inside = false;
                        } else {
                            out_s = NumValue().fromString(string[i - num_len .. i]) catch unreachable;
                            return [2]NumValue(){ out_f.?, out_s.? };
                        }
                    }

                    continue;
                }

                if (std.ascii.isDigit(char.?)) {
                    num_len += 1;

                    if (f_start == null) {
                        f_start = i;
                        f_inside = true;
                    } else if (s_start == null and !f_inside) s_start = i;
                } else {
                    if (num_len > 0) {
                        if (f_inside) {
                            out_f = NumValue().fromString(string[i - num_len .. i]) catch unreachable;
                            f_inside = false;
                        } else {
                            out_s = NumValue().fromString(string[i - num_len .. i]) catch unreachable;
                            return [2]NumValue(){ out_f.?, out_s.? };
                        }
                    }

                    num_len = 0;
                }
            }

            return if (out_f == null) TokenError.FoundZero else TokenError.FoundOnlyFirst;
        }
    };
}

pub const TokenError = error{
    FoundOnlyFirst,
    FoundZero,
    NotAMathSign,
    SignNotFound,
};

pub fn Message(err: TokenError) []const u8 {
    switch (err) {
        .FoundOnlyFirst => return "Only first token found",
        .FoundZero => return "No tokens found",
        .NotAMathSign => return "This is not a math sign",
        .SignNotFound => return "No math signs found",
    }
}

pub fn MathValue() type {
    return struct {
        const Self = @This();

        val: Sign,

        pub fn fromChar(char: u8) TokenError.NotAMathSign!Self {
            return Self{
                .val = Sign.fromChar(char),
            };
        }
    };
}

pub const Sign = enum(u8) {
    const Self = @This();

    Plus = '+',
    Minus = '-',
    Multiply = '*',
    Divide = '/',

    pub fn fromChar(char: u8) TokenError!Self {
        switch (char) {
            @intFromEnum(Sign.Plus) => return .Plus,
            @intFromEnum(Sign.Minus) => return .Minus,
            @intFromEnum(Sign.Multiply) => return .Multiply,
            @intFromEnum(Sign.Divide) => return .Divide,
            else => return TokenError.NotAMathSign,
        }
    }

    pub fn findFromString(string: []const u8) TokenError!Self {
        for (string) |char| {
            const sign = Sign.fromChar(char) catch continue;
            return sign;
        }

        return TokenError.SignNotFound;
    }
};

pub fn NumValue() type {
    return struct {
        const Self = @This();

        zig_val: i32,

        pub fn init(zig_val: i32) Self {
            return Self{
                .zig_val = zig_val,
            };
        }

        pub fn fromString(string: []const u8) std.fmt.ParseIntError!Self {
            return Self{
                .zig_val = std.fmt.parseInt(i32, string, 10) catch |err| return err,
            };
        }
    };
}

pub fn Location() type {
    return struct {
        const Self = @This();

        start: usize,
        len: usize,

        pub fn init(start: usize, len: usize) Self {
            return Self{
                .start = start,
                .len = len,
            };
        }
    };
}
