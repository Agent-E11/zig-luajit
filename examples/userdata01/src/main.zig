//! Copyright (c) 2024-2025 Theodore Sackos
//! SPDX-License-Identifier: AGPL-3.0-or-later

const std = @import("std");
const print = std.debug.print;
const Lua = @import("luajit").Lua;

const NumArray = @import("NumArray.zig");

pub fn main() !void {
    // Boilerplate
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    const lua = try Lua.init(allocator);
    defer lua.deinit();
    // End boilerplate

    lua.openBaseLib();

    _ = NumArray.openLib(lua);

    print("[Zig] Running Lua script\n", .{});

    lua.doFile("./src/script.lua") catch |err| switch (err) {
        error.Runtime => {
            print("[Zig] Runtime error: {s}\n", .{lua.toString(-1) catch "unknown"});
            return;
        },
        error.FileOpenOrFileRead => {
            print("[Zig] Can't find the file 'src/script.lua'. Are you in the correct directory?\n", .{});
            return;
        },
        else => {
            print("[Zig] Unknown error: {!}\n", .{err});
            return;
        },
    };

    print("[Zig] Successfully ran Lua script\n", .{});
}
