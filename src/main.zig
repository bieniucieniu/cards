const std = @import("std");
const lib = @import("cards_lib");

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    const allocator = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var deck = try lib.card.Deck.init(alloc);
    defer deck.deinit();
    deck.shuffle(deck.cards.len);
    printDeck(&deck);
    std.debug.print("\n", .{});
    deck.sort();
    printDeck(&deck);
}

fn printDeck(deck: *lib.card.Deck) void {
    for (deck.*.cards) |*card| {
        const card_int: u8 = @bitCast(card.*);
        std.debug.print("{}:{s}:{s}\n", .{
            card_int,
            card.*.suit.getName(),
            card.*.rank.getName(),
        });
    }
}
