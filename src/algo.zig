const std = @import("std");
const assert = std.debug.assert;

pub fn rot13(s: []const u8, out: []u8) void {
    var i: usize = 0;
    while (i < s.len) : (i += 1) {
        const c = s[i];
        if (c >= 'A' and c <= 'Z') {
            out[i] = 'A' + ((c - 'A' + 13) % 26);
        } else if (c >= 'a' and c <= 'z') {
            out[i] = 'a' + ((c - 'a' + 13) % 26);
        } else {
            out[i] = c;
        }
    }
}

pub fn reverse(s: []const u8, out: []u8) void {
    var i: usize = 0;
    while (i < s.len) : (i += 1) {
        out[i] = s[s.len - i - 1];
    }
}

pub fn upper(s: []const u8, out: []u8) void {
    var i: usize = 0;
    while (i < s.len) : (i += 1) {
        const c = s[i];
        if (c >= 'a' and c <= 'z') {
            out[i] = c - 32;
        } else {
            out[i] = c;
        }
    }
}

pub fn sha256(s: []const u8, out: []u8) void {
    assert(out.len == 32);
    var digest: [32]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(s, &digest, .{});
    std.mem.copyForwards(u8, out, &digest);
}

pub fn sha512(s: []const u8, out: []u8) void {
    assert(out.len == 64);
    var digest: [64]u8 = undefined;
    std.crypto.hash.sha2.Sha512.hash(s, &digest, .{});
    std.mem.copyForwards(u8, out, &digest);
}

pub fn blake256(s: []const u8, out: []u8) void {
    assert(out.len == 32);
    var digest: [32]u8 = undefined;
    std.crypto.hash.blake2.Blake2s256.hash(s, &digest, .{});
    std.mem.copyForwards(u8, out, &digest);
}
