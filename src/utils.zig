const std = @import("std");

const Options = struct {
    input: []const u8,
    algo: []const u8,
    readFromFile: bool,
    compareHash: ?[]const u8,
};

pub fn toHex(allocator: *std.mem.Allocator, bytes: []const u8) ![]u8 {
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

pub fn parseArgs(allocator: *std.mem.Allocator, argv: [][]const u8) !Options {
    var opt = Options{
        .input = "",
        .algo = "sha256",
        .readFromFile = false,
        .compareHash = null,
    };

    var i: usize = 1;
    while (i < argv.len) : (i += 1) {
        const arg = argv[i];
        if (std.mem.eql(u8, arg, "--list") or std.mem.eql(u8, arg, "ls")) {
            std.debug.print("Usage:\n  {s} <input> [--algo|-a <algorithm>] [--file|-f <file loc>] [--compare|-c <hash>]\n\nSupported algorithms:\n  rot13   : Apply ROT13 cipher (not for files)\n  reverse : Reverse the input (not for files)\n  upper   : Convert letters to uppercase (not for files)\n  sha256  : Compute SHA-256 hash (32-byte output in hex)\n  sha512  : Compute SHA-512 hash (64-byte output in hex)\n  blake256: Compute BLAKE2s-256 hash (32-byte output in hex)\n", .{argv[0]});
            return error.InvalidUsage;
        } else if (std.mem.eql(u8, arg, "--compare") or std.mem.eql(u8, arg, "-c")) {
            i += 1;
            if (i >= argv.len) {
                std.debug.print("Error: missing value for --compare flag\n", .{});
                return error.InvalidUsage;
            }
            opt.compareHash = argv[i];
        } else if (std.mem.eql(u8, arg, "--algo") or std.mem.eql(u8, arg, "-a")) {
            i += 1;
            if (i >= argv.len) {
                std.debug.print("Error: missing value for --algo flag\n", .{});
                return error.InvalidUsage;
            }
            opt.algo = argv[i];
        } else if (std.mem.eql(u8, arg, "--file") or std.mem.eql(u8, arg, "-f")) {
            i += 1;
            if (i >= argv.len) {
                std.debug.print("Error: missing value for --file flag\n", .{});
                return error.InvalidUsage;
            }

            const file = try std.fs.cwd().openFile(argv[i], .{});
            defer file.close();

            const file_size = (try file.stat()).size;

            const buffer = try allocator.alloc(u8, file_size);
            defer allocator.free(buffer);

            try file.reader().readNoEof(buffer);
            opt.input = buffer;
            opt.readFromFile = true;
        } else {
            if (!std.mem.eql(u8, opt.input, "")) {
                // that means we have multiple inputs (probably input with spaces) so we merge them into one
                const u_input = opt.input;
                const new_len = u_input.len + 1 + arg.len;
                var concatenated = try allocator.alloc(u8, new_len);
                std.mem.copyForwards(u8, concatenated[0..u_input.len], u_input);
                concatenated[u_input.len] = ' ';
                std.mem.copyForwards(u8, concatenated[u_input.len + 1 .. new_len], arg);
                opt.input = concatenated;
            } else {
                opt.input = arg;
            }
        }
    }
    if (std.mem.eql(u8, opt.input, "")) {
        std.debug.print("Usage:\n  {s} <input> [--algo|-a <algorithm>]\nUse '--list' to see supported algorithms.\n", .{argv[0]});
        return error.InvalidUsage;
    }
    return opt;
}
