const std = @import("std");

pub fn main() !void {
    try appendFile();
}

pub fn readFile() !void {
    var file = try std.fs.cwd().openFile("test.txt", .{});
    defer file.close();

    var buffer: [1024]u8 = undefined;
    var file_reader = file.reader(&buffer);
    const reader = &file_reader.interface;

    while (reader.takeDelimiterExclusive('\n')) |line| {
        std.debug.print("{s}\n", .{line});
    } else |_| {}
}

pub fn appendFile() !void {
    var file = try std.fs.cwd().openFile("test.txt", .{ .mode = .read_write });
    var buffer: [1024]u8 = undefined;
    var file_writer = file.writer(&buffer);
    const writer = &file_writer.interface;
    try writer.print("\nHello, this is a new line!", .{});
    file.close();
}
