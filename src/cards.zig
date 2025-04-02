const Allocator = @import("std").mem.Allocator;
const Random = @import("std").crypto.random;
const print = @import("std").debug.print;

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
    pub fn getName(self: Rank) []const u8 {
        return ranks_names[@intFromEnum(self)];
    }
};

pub const Suit = enum(u2) {
    clubs,
    diamonds,
    hearts,
    spades,
    pub fn getName(self: Suit) []const u8 {
        return suits_names[@intFromEnum(self)];
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
};

pub const Deck = struct {
    cards: []Card,
    alloc: Allocator,
    top: usize,
    pub fn init(alloc: Allocator) !Deck {
        const cards = init: {
            var val = try alloc.alloc(Card, 56);
            for (0..suits_names.len) |suit_i| {
                for (0..ranks_names.len) |rank_i| {
                    const idx = (ranks_names.len * suit_i) + rank_i;
                    val[idx] = .{
                        .suit = @enumFromInt(suit_i),
                        .rank = @enumFromInt(rank_i),
                    };
                    // print(" {} {s} {s}\n ", .{ idx, cards[idx].rank.getName(), cards[idx].suit.getName() });
                }
            }
            break :init val;
        };

        return .{ .cards = cards, .alloc = alloc, .top = cards.len - 1 };
    }
    pub fn deinit(self: Deck) void {
        self.alloc.free(self.cards);
    }
    pub fn sort() void {}
    pub fn shuffle(self: Deck, repeat: usize) void {
        for (0..repeat) |_| {
            const random_idx_first: usize = Random.int(usize) % self.cards.len;
            const random_idx_secend: usize = Random.int(usize) % self.cards.len;
            const tmp: Card = self.cards[random_idx_first];
            self.cards[random_idx_first] = self.cards[random_idx_secend];
            self.cards[random_idx_secend] = tmp;
        }
    }
};

pub const ranks_names = [_][]const u8{ "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "jack", "queen", "king", "ace", "jocker" };
pub const suits_names = [_][]const u8{ "clubs", "diamonds", "hearts", "spades" };
