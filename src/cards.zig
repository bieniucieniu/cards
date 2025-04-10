const std = @import("std");
const rndom = @import("std").crypto.random;
const assert = std.debug.assert;

pub const Rank = enum(u4) {
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,
    ten,
    jack,
    queen,
    king,
    ace,
    jocker,
    pub inline fn getName(self: Rank) []const u8 {
        return ranks_names[@intFromEnum(self)];
    }
    pub inline fn toInt(self: Rank) u4 {
        return @bitCast(self);
    }
};

pub const Suit = enum(u2) {
    clubs,
    diamonds,
    hearts,
    spades,
    pub inline fn getName(self: Suit) []const u8 {
        return suits_names[@intFromEnum(self)];
    }
    pub inline fn toInt(self: Suit) u2 {
        return @bitCast(self);
    }
};

pub const Card = packed struct(u8) {
    rank: Rank = .two,
    suit: Suit = .clubs,
    taken: bool = false,
    _: u1 = 0,
    pub inline fn take(self: *Card) void {
        self.taken = true;
    }
    pub inline fn put(self: *Card) void {
        self.taken = false;
    }
    pub inline fn toInt(self: Card) u8 {
        return @bitCast(self);
    }
};

pub inline fn cardFromInt(i: u8) Card {
    return @bitCast(i + (i / 14) * 2);
}
pub fn cardComp(_: void, a: Card, b: Card) bool {
    return a.toInt() < b.toInt();
}
pub const Deck = struct {
    cards: *[56]Card,
    alloc: std.mem.Allocator,
    top: usize,
    pub fn init(alloc: std.mem.Allocator) !Deck {
        const cards = try alloc.create([56]Card);
        for (cards, 0..) |*value, i|
            value.* = cardFromInt(@truncate(i));

        return .{ .cards = cards, .alloc = alloc, .top = cards.len - 1 };
    }
    pub fn deinit(self: *Deck) void {
        self.alloc.destroy(self.cards);
    }
    pub fn sort(self: *Deck) void {
        std.mem.sort(Card, self.cards, {}, cardComp);
    }
    pub fn shuffle(self: *Deck, repeat: usize) void {
        for (0..repeat) |_| {
            const idx_first: usize = std.crypto.random.int(usize) % self.cards.len;
            const idx_secend: usize = std.crypto.random.int(usize) % self.cards.len;
            const tmp: Card = self.cards[idx_first];
            self.cards[idx_first] = self.cards[idx_secend];
            self.cards[idx_secend] = tmp;
        }
    }
};

pub const ranks_names = [_][]const u8{ "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "jack", "queen", "king", "ace", "jocker" };
pub const suits_names = [_][]const u8{ "clubs", "diamonds", "hearts", "spades" };
//pub const suits_names2 = enumNames(Suit);

fn enumNames(comptime T: anytype) type {
    const field = @typeInfo(T).@"enum".fields;
    var arr = std.mem.zeroes([field.len][]const u8);
    for (0..arr.len) |i| {
        arr[i] = field[i].name;
    }
    return arr;
}
