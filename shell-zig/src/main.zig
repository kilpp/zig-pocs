const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const stdin = std.fs.File.stdin();
    var buffer: [1024]u8 = undefined;

    print("Simple Shell v1.0\n", .{});
    print("Type 'exit' to quit\n", .{});

    while (true) {
        print("$ ", .{});

        // Read input from stdin
        if (stdin.read(buffer[0..])) |bytes_read| {
            if (bytes_read == 0) {
                print("\nGoodbye!\n", .{});
                break;
            }

            // Find newline and create input string
            var input_len = bytes_read;
            if (bytes_read > 0 and buffer[bytes_read - 1] == '\n') {
                input_len = bytes_read - 1;
            }

            const input = buffer[0..input_len];

            // Trim whitespace
            const trimmed_input = std.mem.trim(u8, input, " \t\r\n");

            // Check for exit command
            if (std.mem.eql(u8, trimmed_input, "exit")) {
                print("Goodbye!\n", .{});
                break;
            }

            // If input is not empty, parse and execute command
            if (trimmed_input.len > 0) {
                executeCommand(trimmed_input);
            }
        } else |err| {
            print("Error reading input: {}\n", .{err});
            break;
        }
    }
}

fn executeCommand(input: []const u8) void {
    var parts = std.mem.splitSequence(u8, input, " ");
    const command = parts.next() orelse return;
    var args = parts;

    if (std.mem.eql(u8, command, "echo")) {
        var first_arg = true;
        while (args.next()) |arg| {
            if (!first_arg) {
                print(" ", .{});
            }
            print("{s}", .{arg});
            first_arg = false;
        }
        print("\n", .{});
    } else if (std.mem.eql(u8, command, "pwd")) {
        var dir_buffer: [1024]u8 = undefined;
        const dir = std.fs.cwd().realpath(".", dir_buffer[0..]) catch |err| {
            print("Error getting current directory: {}\n", .{err});
            return;
        };
        print("{s}\n", .{dir});
    } else if (std.mem.eql(u8, command, "ls")) {
        const path = args.next() orelse ".";
        var dir = std.fs.cwd().openDir(path, .{}) catch |err| {
            print("Error opening directory: {}\n", .{err});
            return;
        };
        defer dir.close();

        var it = dir.iterate();
        while (it.next()) |maybe_entry| {
            if (maybe_entry) |entry| {
                print("{s}\n", .{entry.name});
            }
        } else |err| {
            print("Error iterating directory: {}\n", .{err});
        }
    } else if (std.mem.eql(u8, command, "cat")) {
        const filename = args.next() orelse {
            print("Usage: cat [filename]\n", .{});
            return;
        };

        const file = std.fs.cwd().openFile(filename, .{}) catch |err| {
            print("Error opening file: {}\n", .{err});
            return;
        };
        defer file.close();

        var buffer: [4096]u8 = undefined;
        while (file.read(buffer[0..])) |bytes_read| {
            print("{s}", .{buffer[0..bytes_read]});
        } else |err| {
            if (err != error.EndOfStream) {
                print("\nError reading file: {}\n", .{err});
            }
        }
    } else {
        print("{s}: command not found\n", .{command});
    }
}
