# How to establish tcp connection in Zig

We will need to establish a tcp connection with a matrix server before 
communicating via HTTP. As I don't know how, I'm going to figure out here.

std.net offers the following as pub:
 - const has_unix_sockets
 - const Address = extern union
 - - parseIp()
 - - resolveIp()
 - - parseExpectingFamily()
 - - parseIp6()
 - - resolveIp6()
 - - parseIP4()
 - - initIP4()
 - - initIP6()
 - - initUnix()
 - - getPort()
 - - setPort()
 - - initPosix()
 - - format()
 - - eql()
 - - getOsSockLen()
 - const Ip4Address = extern struct
 - - parse()
 - - resolveIp()
 - - init()
 - - getPort()
 - - setPort()
 - - format()
 - - getOsSockLen()
 - const Ip6Address = extern struct
 - - parse()
 - - resolve()
 - - init()
 - - getPort()
 - - setPort()
 - - format()
 - fn connectUnixSocket()
 - const AddressList = struct
 - - deinit()
 - fn tcpConnectToAddress()
 - fn tcpConnectToHost()
 - fn getAddressList()
 - isValidHostName()
 - const Stream = struct
 - - close()
 - - ReadError
 - - WriteError
 - - Reader
 - - Writer
 - - reader()
 - - writer()
 - - read()
 - - write()
 - - writev()
 - - writevAll()
 - const StreamServer = struct
 - - const Options = struct
 - - init()
 - - deinit()
 - - listen()
 - - close()
 - - const AcceptError = error
 - - const Connection = struct
 - - accept()

Based on that hierarchy, to be crude, std.net is concerned with Addresses,
Ip4Addresses, Ip6Addresses, Streams, StreamServers, and performing 
connectUnixSocket, tcpConnectToAddress, getAddressList, isValidHostName on those
things.

My first interest is to check whether a hostname is valid. Let's look at 
isValidHostname.

    lang: zig esc: [[]] tag: #isValidHostName
    -----------------------------------------

    const std = @import("std");
    const net = std.net;

    pub fn main() anyerror!void {
        try std.testing.expect(net.isValidHostName("www.google.com")
    }

This works, but it's not what I wanted to try. This is not testing if the host
can be resolved, only that the string is up to spec. The next thing to try is
probably tcpConnectToAddress.

tcpConnectToAddress() expects an Address. I'm going to make an Ip4Address to
try and connect to it.

    lang: zig esc: [[]] file: tcp-connect.zig
    -----------------------------------------

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

And time to troubleshoot that. Troubleshooting was actually pretty easy. Time
to recognize what 'try' errors look like in the future. Read returns the size
of whatever was read. Setting var to a union looks funny.

I still didn't get dns to work. I may need to adjust somehow for that. Either
find or make(no clue how that would go) a function to fetch an ip from domain
name.

DNS is working after changing over to net.tcpConnectToHost() and creating an
allocator to pass into that function. Turns out that I don't need to create an
arena as net.getAddressList() creates an arena internally.

# The Next Big Step

Now that we can connect to a host, it's time to start speaking the protocol. I
don't want to worry abour parsing just yet, I just want to send a request over
http and read a response. At that point I also want to give stunnel a quick
test run so we get https for free, and can wait until later to deal with it
correctly.
