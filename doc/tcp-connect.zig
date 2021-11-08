const std = @import("std");
const net = std.net;
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = &gpa.allocator;
    const connection = try net.tcpConnectToHost(allocator, "google.com", 80);

    var buf: [std.mem.page_size]u8 = undefined;

    var bytes_read = try connection.read(buf[0..]);

    while (bytes_read > 0) {
        try stdout.print("{s}", .{buf[0..bytes_read]});
        bytes_read = try connection.read(buf[0..]);
    }
}
