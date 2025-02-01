const std = @import("std");
const testing = std.testing;

pub fn demo(a: []const u8) ?[]const u8 {
    if (std.mem.eql(u8, a, "i hate unit tests")) {
        return "fr";
    }
    return "nahhh";
}

test "test :/" {
    try testing.expect(std.mem.eql(u8, "fr", demo("i hate unit tests").?));
}
