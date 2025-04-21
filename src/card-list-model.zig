const std = @import("std");
const lib = @import("cards_lib");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;

pub const CardListModel = struct {
    deck: lib.card.Deck,
    cards_view: vxfw.ListView,
    cards: std.ArrayList(vxfw.RichText),
    alloc: std.mem.Allocator,
    pub fn deinit(self: *CardListModel) void {
        self.deck.deinit();
        self.cards.deinit();
        self.alloc.destroy(self);
    }
    pub fn init(alloc: std.mem.Allocator) !*CardListModel {
        const model = try alloc.create(CardListModel);
        const deck: lib.card.Deck = try .init(alloc, 1);
        var cards: std.ArrayList(vxfw.RichText) = .init(alloc);
        const styles: vaxis.Style = .{ .fg = .{ .rgb = .{ 'f', '0', 'f' } } };

        for (try cards.addManyAsSlice(deck.cards.len), 0..) |*item, i| {
            var segements = try alloc.alloc(vaxis.Segment, 3);
            segements[0] = .{ .text = deck.cards[i].rank.getName() };
            segements[1] = .{ .text = " : ", .style = styles };
            segements[2] = .{ .text = deck.cards[i].suit.getName() };
            item.* = .{ .text = segements };
        }

        model.* = .{
            .alloc = alloc,
            .deck = deck,
            .cards = cards,
            .cards_view = .{ .children = .{
                .builder = .{
                    .userdata = model,
                    .buildFn = struct {
                        fn buildFn(localPtr: *const anyopaque, idx: usize, cursor: usize) ?vxfw.Widget {
                            const self: *const CardListModel = @ptrCast(@alignCast(localPtr));
                            if (idx >= self.cards.items.len) return null;
                            self.cards.items[idx].base_style = if (idx == cursor) .{ .bg = .{ .rgb = .{ 'f', 'f', 'f' } } } else .{};
                            return self.cards.items[idx].widget();
                        }
                    }.buildFn,
                },
            } },
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
                if (key.matches('j', .{})) {
                    self.*.cards_view.nextItem(ctx);
                } else if (key.matches('k', .{})) {
                    self.*.cards_view.prevItem(ctx);
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
