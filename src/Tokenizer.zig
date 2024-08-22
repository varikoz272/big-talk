const std = @import("std");

pub fn ExpressionTokenizer() type {
    return struct {
        const Self = @This();

        pub fn Tokenize(string: []const u8) SignError!NumValue() {
            const sign = try getSign(string);
            const nums = getNumValues(string);

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

        pub fn getSign(string: []const u8) SignError!Sign {
            return Sign.findFromString(string);
        }

        pub fn getNumValues(string: []const u8) [2]NumValue() {
            var f_start: ?usize = null;
            var f_inside: bool = false;
            var s_start: ?usize = null;
            var num_len: usize = 0;

            var out: [2]NumValue() = undefined;

            for (0..string.len + 1) |i| {
                const char: ?u8 = if (i < string.len) string[i] else null;

                if (char == null) {
                    if (num_len > 0) {
                        if (f_inside) {
                            out[0] = NumValue().fromString(string[i - num_len .. i]) catch unreachable;
                            f_inside = false;
                        } else {
                            out[1] = NumValue().fromString(string[i - num_len .. i]) catch unreachable;
                            return out;
                        }
                    }
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
                            out[0] = NumValue().fromString(string[i - num_len .. i]) catch unreachable;
                            f_inside = false;
                        } else {
                            out[1] = NumValue().fromString(string[i - num_len .. i]) catch unreachable;
                            return out;
                        }
                    }

                    num_len = 0;
                }
            }

            return out;
        }
    };
}

pub const TokenError = error{
    FoundOnlyFirst,
    FoundZero,
};

pub fn MathValue() type {
    return struct {
        const Self = @This();

        val: Sign,

        pub fn fromChar(char: u8) SignError.NotAMathSign!Self {
            return Self{
                .val = Sign.fromChar(char),
            };
        }
    };
}

pub const SignError = error{
    NotAMathSign,
    NotFound,
};

pub const Sign = enum(u8) {
    const Self = @This();

    Plus = '+',
    Minus = '-',
    Multiply = '*',
    Divide = '/',

    pub fn fromChar(char: u8) SignError!Self {
        switch (char) {
            @intFromEnum(Sign.Plus) => return .Plus,
            @intFromEnum(Sign.Minus) => return .Minus,
            @intFromEnum(Sign.Multiply) => return .Multiply,
            @intFromEnum(Sign.Divide) => return .Divide,
            else => return SignError.NotAMathSign,
        }
    }

    pub fn findFromString(string: []const u8) SignError!Self {
        for (string) |char| {
            const sign = Sign.fromChar(char) catch continue;
            return sign;
        }

        return SignError.NotFound;
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
