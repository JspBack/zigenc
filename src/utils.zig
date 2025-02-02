const std = @import("std");

pub fn toHex(allocator: std.mem.Allocator, bytes: []const u8) ![]u8 {
    const hexDigits = "0123456789abcdef";
    const hexLen = bytes.len * 2;
    var hexBuffer = try allocator.alloc(u8, hexLen);
    var j: usize = 0;
    for (bytes) |b| {
        hexBuffer[j] = hexDigits[(b >> 4) & 0xf];
        hexBuffer[j + 1] = hexDigits[b & 0xf];
        j += 2;
    }
    return hexBuffer;
}
