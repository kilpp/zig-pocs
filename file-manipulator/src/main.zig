const std = @import("std");

pub fn main() !void {
    try readFile();
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
