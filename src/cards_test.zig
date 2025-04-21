const std = @import("std");
const testing = std.testing;
const expect = std.testing.expect;

const cg = @import("./cards.zig");

test "Rank.getName() returns the correct name" {
    try testing.expectEqualStrings("two", cg.Rank.two.getName());
    try testing.expectEqualStrings("three", cg.Rank.three.getName());
    try testing.expectEqualStrings("four", cg.Rank.four.getName());
    try testing.expectEqualStrings("five", cg.Rank.five.getName());
    try testing.expectEqualStrings("six", cg.Rank.six.getName());
    try testing.expectEqualStrings("seven", cg.Rank.seven.getName());
    try testing.expectEqualStrings("eight", cg.Rank.eight.getName());
    try testing.expectEqualStrings("nine", cg.Rank.nine.getName());
    try testing.expectEqualStrings("ten", cg.Rank.ten.getName());
    try testing.expectEqualStrings("jack", cg.Rank.jack.getName());
    try testing.expectEqualStrings("queen", cg.Rank.queen.getName());
    try testing.expectEqualStrings("king", cg.Rank.king.getName());
    try testing.expectEqualStrings("ace", cg.Rank.ace.getName());
    try testing.expectEqualStrings("jocker", cg.Rank.jocker.getName());
}

test "Suit.getName() returns the correct name" {
    try testing.expectEqualStrings("clubs", cg.Suit.clubs.getName());
    try testing.expectEqualStrings("diamonds", cg.Suit.diamonds.getName());
    try testing.expectEqualStrings("hearts", cg.Suit.hearts.getName());
    try testing.expectEqualStrings("spades", cg.Suit.spades.getName());
}

test "Card struct has correct default values" {
    const card = cg.Card{};
    try testing.expectEqual(cg.Rank.two, card.rank);
    try testing.expectEqual(cg.Suit.clubs, card.suit);
    try testing.expectEqual(false, card.taken);
}

test "Stack.init() initializes and Stack.deinit() deinitializes correctly" {
    var stack = try cg.Deck.init(std.testing.allocator, 1);
    defer stack.deinit();

    try testing.expectEqual(56, stack.cards.len);

    for (0..cg.suits_names.len) |suit_i| {
        for (0..cg.ranks_names.len) |rank_i| {
            const card = stack.cards[(cg.ranks_names.len * suit_i) + rank_i];
            const suit: cg.Suit = @enumFromInt(suit_i);
            const rank: cg.Rank = @enumFromInt(rank_i);
            try expect(card.suit == suit);
            try expect(card.rank == rank);
        }
    }
}

test "Card can be created with specific values" {
    const card = cg.Card{ .rank = .king, .suit = .spades, .taken = true };
    try testing.expectEqual(cg.Rank.king, card.rank);
    try testing.expectEqual(cg.Suit.spades, card.suit);
    try testing.expectEqual(true, card.taken);
}

test "Card.take() sets taken to true" {
    var card = cg.Card{};
    card.take();
    try testing.expectEqual(true, card.taken);
}

test "Card.put() sets taken to false" {
    var card = cg.Card{ .taken = true };
    card.put();
    try testing.expectEqual(false, card.taken);
}
