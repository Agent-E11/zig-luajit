const std = @import("std");
const Lua = @import("luajit").Lua;

const Self = @This();

size: usize,
// HACK: This might not be a good idea, but it is what is in the example
items: [1]Lua.Number,

pub fn new(lua: *Lua) callconv(.c) i32 {
    const n = lua.checkInteger(1);
    const size = @sizeOf(Self) + (n - 1) * @sizeOf(Lua.Number);
    var a: *Self = @ptrCast(@alignCast(lua.newUserdata(@intCast(size))));
    a.size = @intCast(n);
    return 1;
}

pub fn set(lua: *Lua) callconv(.c) i32 {
    var a: *Self = @as(?*Self, @ptrCast(@alignCast(lua.toUserdata(1)))) orelse {
        lua.raiseErrorArgument(1, "`array` expected");
        return 0;
    };
    const index = lua.checkInteger(2);
    const value = lua.checkNumber(3);

    lua.checkArgument(
        !(1 <= index and index <= a.size),
        2,
        "index out of bounds",
    );

    // NOTE: Convert to a many-item pointer to avoid bounds checking
    const items: [*]Lua.Number = &a.items;

    items[@intCast(index - 1)] = value;
    return 0;
}

pub fn get(lua: *Lua) callconv(.c) i32 {
    const a: *Self = @as(?*Self, @ptrCast(@alignCast(lua.toUserdata(1)))) orelse {
        lua.raiseErrorArgument(1, "`array` expected");
        return 0;
    };
    const index = lua.checkInteger(2);

    lua.checkArgument(
        !(1 <= index and index <= a.size),
        2,
        "index out of bounds",
    );

    // NOTE: Convert to a many-item pointer to avoid bounds checking
    const items: [*]Lua.Number = &a.items;

    lua.pushNumber(items[@intCast(index - 1)]);
    return 1;
}

pub fn getSize(lua: *Lua) callconv(.c) i32 {
    const a: *Self = @as(?*Self, @ptrCast(@alignCast(lua.toUserdata(1)))) orelse {
        lua.raiseErrorArgument(1, "`array` expected");
        return 0;
    };
    lua.pushNumber(@floatFromInt(a.size));
    return 1;
}

const array_lib = [_]Lua.Reg{
    .{ .name = "new", .func = new },
    .{ .name = "set", .func = set },
    .{ .name = "get", .func = get },
    .{ .name = "size", .func = getSize },
    Lua.RegEnd,
};

pub fn openLib(lua: *Lua) callconv(.c) i32 {
    lua.registerLibrary("array", &array_lib);
    return 1;
}
