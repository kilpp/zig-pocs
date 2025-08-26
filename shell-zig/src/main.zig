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
    // Split input into command and arguments
    var parts = std.mem.splitSequence(u8, input, " ");
    const command = parts.next() orelse return;

    if (std.mem.eql(u8, command, "echo")) {
        // Handle echo command
        var first_arg = true;
        while (parts.next()) |arg| {
            if (!first_arg) {
                print(" ", .{});
            }
            print("{s}", .{arg});
            first_arg = false;
        }
        print("\n", .{});
    } else {
        // Unknown command
        print("{s}: command not found\n", .{command});
    }
}
