const std = @import("std");

const rot13 = @import("algo.zig").rot13;
const reverse = @import("algo.zig").reverse;
const upper = @import("algo.zig").upper;
const sha256 = @import("algo.zig").sha256;
const sha512 = @import("algo.zig").sha512;
const blake256 = @import("algo.zig").blake256;

const toHex = @import("utils.zig").toHex;
const parseArgs = @import("utils.zig").parseArgs;

pub fn main() !void {
    var allocator = std.heap.page_allocator;
    const argv = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);

    const options = try parseArgs(&allocator, argv);

    const inStr = options.input;
    const selectedAlgo = options.algo;

    var outLen: usize = 0;
    var hashOutput: bool = false;
    if (std.mem.eql(u8, selectedAlgo, "sha256")) {
        outLen = 32;
        hashOutput = true;
    } else if (std.mem.eql(u8, selectedAlgo, "sha512")) {
        outLen = 64;
        hashOutput = true;
    } else if (std.mem.eql(u8, selectedAlgo, "blake256")) {
        outLen = 32;
        hashOutput = true;
    } else if (std.mem.eql(u8, selectedAlgo, "rot13") or
        std.mem.eql(u8, selectedAlgo, "reverse") or
        std.mem.eql(u8, selectedAlgo, "upper"))
    {
        outLen = inStr.len;
    } else {
        std.debug.print("Unrecognized algorithm: {s}\n", .{selectedAlgo});
        return;
    }

    const result = try allocator.alloc(u8, outLen);
    defer allocator.free(result);

    if (std.mem.eql(u8, selectedAlgo, "sha256")) {
        sha256(inStr, result);
    } else if (std.mem.eql(u8, selectedAlgo, "sha512")) {
        sha512(inStr, result);
    } else if (std.mem.eql(u8, selectedAlgo, "blake256")) {
        blake256(inStr, result);
    } else if (std.mem.eql(u8, selectedAlgo, "rot13")) {
        rot13(inStr, result);
    } else if (std.mem.eql(u8, selectedAlgo, "reverse")) {
        reverse(inStr, result);
    } else if (std.mem.eql(u8, selectedAlgo, "upper")) {
        upper(inStr, result);
    }

    if (hashOutput) {
        const hexResult = try toHex(&allocator, result);
        defer allocator.free(hexResult);
        if (options.compareHash != null) {
            if (std.mem.eql(u8, hexResult, options.compareHash.?)) {
                std.debug.print("Hashes match\n", .{});
            } else {
                std.debug.print("Hashes differ\n", .{});
            }
        } else {
            std.debug.print("Result ({s} in hex): {s}\n", .{ selectedAlgo, hexResult });
        }
    } else {
        std.debug.print("Result: {s}\n", .{result});
    }
}
