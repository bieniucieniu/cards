const std = @import("std");
const lib = @import("cards_lib");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const Key = vaxis.Key;

const txt = "asjkdha";

pub const CardListModel = struct {
    deck: lib.card.Deck,
    cards_view: vxfw.ListView,
    cards_faces_widgets: std.AutoHashMap(lib.card.Card, vxfw.RichText),
    arena: std.heap.ArenaAllocator,
    pub fn deinit(self: *CardListModel) void {
        self.arena.deinit();
    }
    pub fn init(allocator: std.mem.Allocator) !*CardListModel {
        var arena = std.heap.ArenaAllocator.init(allocator);
        var alloc = arena.allocator();
        const deck: lib.card.Deck = try .init(alloc, 1);
        const styles: vaxis.Style = .{ .fg = .{ .rgb = .{ 'f', '0', 'f' } } };
        var cards_faces_widgets: std.AutoHashMap(lib.card.Card, vxfw.RichText) = .init(alloc);
        for (0..lib.card.single_deck_size) |i| {
            const card = lib.card.cardFromIndex(i, .{});
            const entry = try cards_faces_widgets.getOrPut(card);
            if (!entry.found_existing) {
                var segements = try alloc.alloc(vaxis.Segment, 3);
                segements[0] = .{ .text = card.rank.getName() };
                segements[1] = .{ .text = " : ", .style = styles };
                segements[2] = .{ .text = card.suit.getName() };
                entry.value_ptr.* = .{ .text = segements };
            }
        }

        const model = try alloc.create(CardListModel);
        model.* = .{
            .arena = arena,
            .deck = deck,
            .cards_faces_widgets = cards_faces_widgets,
            .cards_view = .{
                .scroll = .{ .wants_cursor = true },
                .children = .{
                    .builder = .{
                        .userdata = model,
                        .buildFn = struct {
                            fn buildFn(localPtr: *const anyopaque, idx: usize, cursor: usize) ?vxfw.Widget {
                                const self: *const CardListModel = @ptrCast(@alignCast(localPtr));
                                if (idx > self.deck.cards.items.len - 1) return null;
                                const card = self.cards_faces_widgets.getPtr(self.deck.cards.items[idx]) orelse return null;
                                card.base_style = if (idx == cursor) .{ .bg = .{ .rgb = .{ 'f', 'f', 'f' } } } else .{};
                                return card.widget();
                            }
                        }.buildFn,
                    },
                },
            },
        };
        return model;
    }

    pub fn widget(self: *CardListModel) vxfw.Widget {
        return .{
            .userdata = self,
            .eventHandler = CardListModel.eventHandler,
            .drawFn = CardListModel.drawFn,
        };
    }
    fn eventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
        const self: *CardListModel = @ptrCast(@alignCast(ptr));
        switch (event) {
            .key_press => |key| {
                if (key.matches('j', .{}) or key.matches(Key.down, .{})) {
                    self.cards_view.nextItem(ctx);
                } else if (key.matches('k', .{}) or key.matches(Key.up, .{})) {
                    self.cards_view.prevItem(ctx);
                }
                ctx.redraw = true;
            },
            .focus_in => return ctx.requestFocus(self.cards_view.widget()),
            else => {},
        }
    }
    fn drawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
        const self: *CardListModel = @ptrCast(@alignCast(ptr));

        const children = try ctx.arena.alloc(vxfw.SubSurface, 1);

        children[0] = .{
            .origin = .{ .row = 0, .col = 0 },
            .surface = try self.cards_view.draw(ctx),
        };

        return .{
            .size = ctx.max.size(),
            .widget = self.widget(),
            .buffer = &.{},
            .children = children,
        };
    }
};
