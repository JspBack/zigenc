const std = @import("std");

const rot13 = @import("algo.zig").rot13;
const reverse = @import("algo.zig").reverse;
const upper = @import("algo.zig").upper;
const sha256 = @import("algo.zig").sha256;
const sha512 = @import("algo.zig").sha512;
const blake256 = @import("algo.zig").blake256;

const toHex = @import("utils.zig").toHex;

pub fn main() !void {
    var allocator = std.heap.page_allocator;
    const argv = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);

    var input: ?[]const u8 = null;
    var algo: ?[]const u8 = null;
    var readFromFile = false;
    var compareHash: ?[]const u8 = null;

    var i: usize = 1;
    while (i < argv.len) : (i += 1) {
        const arg = argv[i];
        if (std.mem.eql(u8, arg, "--list") or std.mem.eql(u8, arg, "ls")) {
            std.debug.print("Usage:\n  {s} <input> [--algo|-a <algorithm>] [--file|-f <file loc>] [--compare|-c <hash>]\n\nSupported algorithms:\n  rot13   : Apply ROT13 cipher (not for files)\n  reverse : Reverse the input (not for files)\n  upper   : Convert letters to uppercase (not for files)\n  sha256  : Compute SHA-256 hash (32-byte output in hex)\n  sha512  : Compute SHA-512 hash (64-byte output in hex)\n  blake256: Compute BLAKE2s-256 hash (32-byte output in hex)\n", .{argv[0]});
            return;
        } else if (std.mem.eql(u8, arg, "--compare") or std.mem.eql(u8, arg, "-c")) {
            i += 1;
            if (i >= argv.len) {
                std.debug.print("Error: missing value for --compare flag\n", .{});
                return;
            }
            compareHash = argv[i];
        } else if (std.mem.eql(u8, arg, "--algo") or std.mem.eql(u8, arg, "-a")) {
            i += 1;
            if (i >= argv.len) {
                std.debug.print("Error: missing value for --algo flag\n", .{});
                return;
            }
            algo = argv[i];
        } else if (std.mem.eql(u8, arg, "--file") or std.mem.eql(u8, arg, "-f")) {
            i += 1;
            if (i >= argv.len) {
                std.debug.print("Error: missing value for --file flag\n", .{});
                return;
            }

            const file = try std.fs.cwd().openFile(argv[i], .{});
            defer file.close();

            const file_size = (try file.stat()).size;

            const buffer = try allocator.alloc(u8, file_size);
            defer allocator.free(buffer);

            try file.reader().readNoEof(buffer);
            input = buffer;
            readFromFile = true;
        } else {
            if (input != null) {
                // that means we have multiple inputs (probably input with spaces) so we merge them into one
                const u_input = input.?;
                const new_len = u_input.len + 1 + arg.len;
                var concatenated = try allocator.alloc(u8, new_len);
                std.mem.copyForwards(u8, concatenated[0..u_input.len], u_input);
                concatenated[u_input.len] = ' ';
                std.mem.copyForwards(u8, concatenated[u_input.len + 1 .. new_len], arg);
                input = concatenated;
            } else {
                input = arg;
            }
        }
    }
    if (input == null) {
        std.debug.print("Usage:\n  {s} <input> [--algo|-a <algorithm>]\nUse '--list' to see supported algorithms.\n", .{argv[0]});
        return;
    }
    if (algo == null) {
        algo = "sha256";
    }
    const inStr = input.?;
    const selectedAlgo = algo.?;
    if (readFromFile and !(std.mem.eql(u8, selectedAlgo, "sha256") or std.mem.eql(u8, selectedAlgo, "sha512") or std.mem.eql(u8, selectedAlgo, "blake256"))) {
        std.debug.print("Error: only sha256, sha512, blake256 are allowed with --file\n", .{});
        return;
    }

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
    } else if (std.mem.eql(u8, selectedAlgo, "rot13") or std.mem.eql(u8, selectedAlgo, "reverse") or std.mem.eql(u8, selectedAlgo, "upper")) {
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
        const hexResult = try toHex(allocator, result);
        defer allocator.free(hexResult);
        if (compareHash != null) {
            if (std.mem.eql(u8, hexResult, compareHash.?)) {
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
