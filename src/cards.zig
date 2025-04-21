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

fn playCard(c: Card) void {
    switch (c.rank) {
        .ace, .jocker => {
            _ = c.rank.toInt();
        },
    }
}

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

pub inline fn cardFromIndex(i: usize, base: Card) Card {
    return @bitCast(@as(u8, @bitCast(base)) | @as(u8, @truncate(i +% (i / 14) * 2)));
}

pub fn cardComp(_: void, a: Card, b: Card) bool {
    return a.toInt() < b.toInt();
}

pub const Deck = struct {
    cards: []Card,
    alloc: std.mem.Allocator,
    top: usize,
    pub fn init(alloc: std.mem.Allocator, decks_count: usize) !Deck {
        const cards = try alloc.alloc(Card, single_deck_size * decks_count);
        for (0..cards.len) |i|
            cards[i] = cardFromIndex(i % single_deck_size, .{});

        return .{ .cards = cards, .alloc = alloc, .top = cards.len - 1 };
    }
    pub fn deinit(self: Deck) void {
        self.alloc.free(self.cards);
    }
    pub fn sort(self: Deck) void {
        std.mem.sort(Card, self.cards, {}, cardComp);
    }
    pub fn shuffle(self: Deck, repeat: usize) void {
        var idx_first: usize = undefined;
        var idx_secend: usize = undefined;
        var tmp: Card = undefined;
        for (0..repeat) |_| {
            idx_first = std.crypto.random.int(usize) % self.cards.len;
            idx_secend = std.crypto.random.int(usize) % self.cards.len;
            tmp = self.cards[idx_first];
            self.cards[idx_first] = self.cards[idx_secend];
            self.cards[idx_secend] = tmp;
        }
    }
};

pub const ranks_names = enumNames(Rank);
pub const suits_names = enumNames(Suit);
pub const single_deck_size: usize = @typeInfo(Rank).@"enum".fields.len * @typeInfo(Suit).@"enum".fields.len;

pub fn enumNames(comptime T: type) [@typeInfo(T).@"enum".fields.len][]const u8 {
    var arr: [@typeInfo(T).@"enum".fields.len][]const u8 = undefined;
    for (0..arr.len) |i|
        arr[i] = @typeInfo(T).@"enum".fields[i].name;
    return arr;
}

pub fn unionNames(comptime T: type) [@typeInfo(T).@"union".fields.len][]const u8 {
    var arr: [@typeInfo(T).@"union".fields.len][]const u8 = undefined;
    for (0..arr.len) |i|
        arr[i] = @typeInfo(T).@"union".fields[i].name;
    return arr;
}
