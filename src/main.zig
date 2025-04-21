const std = @import("std");
const lib = @import("cards_lib");
const vaxis = @import("vaxis");
const vxfw = vaxis.vxfw;
const CardListModel = @import("./card-list-model.zig").CardListModel;

const Model = struct {
    button: vxfw.Button,
    count: usize = 0,
    card_list_model: *CardListModel,
    pub fn widget(self: *Model) vxfw.Widget {
        return .{
            .userdata = self,
            .eventHandler = Model.eventHandler,
            .drawFn = Model.drawFn,
        };
    }
    fn eventHandler(ptr: *anyopaque, ctx: *vxfw.EventContext, event: vxfw.Event) anyerror!void {
        const self: *Model = @ptrCast(@alignCast(ptr));
        switch (event) {
            .init => return ctx.requestFocus(self.card_list_model.widget()),
            .key_press => |key| {
                if (key.matches('c', .{ .ctrl = true })) {
                    ctx.quit = true;
                    return;
                }
            },
            .focus_in => return ctx.requestFocus(self.card_list_model.widget()),
            else => {},
        }
    }
    fn drawFn(ptr: *anyopaque, ctx: vxfw.DrawContext) std.mem.Allocator.Error!vxfw.Surface {
        const self: *Model = @ptrCast(@alignCast(ptr));
        const max_size = ctx.max.size();
        const index_text = try std.fmt.allocPrint(ctx.arena, "{d}", .{self.count});
        const text: vxfw.Text = .{ .text = index_text };

        const text_child: vxfw.SubSurface = .{
            .origin = .{ .row = 0, .col = 0 },
            .surface = try text.draw(ctx.withConstraints(
                ctx.min,
                ctx.max,
            )),
        };

        const button_child: vxfw.SubSurface = .{
            .origin = .{ .row = 0, .col = 0 },
            .surface = try self.button.draw(ctx.withConstraints(
                ctx.min,
                .{ .width = 16, .height = 3 },
            )),
        };

        const cards_child: vxfw.SubSurface = .{
            .origin = .{ .row = 3, .col = 0 },
            .surface = try self.card_list_model.widget().draw(ctx.withConstraints(
                ctx.min,
                .{ .width = max_size.width, .height = max_size.height - 3 },
            )),
        };

        const children = try ctx.arena.alloc(vxfw.SubSurface, 3);
        children[0] = text_child;
        children[1] = button_child;
        children[2] = cards_child;

        return .{
            .size = max_size,
            .widget = self.widget(),
            .buffer = &.{},
            .children = children,
        };
    }
};

const events = lib.unionNames(vxfw.Event);

pub fn main() !void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var app = try vxfw.App.init(alloc);
    defer app.deinit();

    const model = try alloc.create(Model);
    defer alloc.destroy(model);

    const card_list_model = try CardListModel.init(alloc);
    defer card_list_model.deinit();

    model.* = .{
        .card_list_model = card_list_model,
        .button = .{
            .label = "Click me!",
            .userdata = model,
            .onClick = struct {
                fn onClick(maybe_ptr: ?*anyopaque, ctx: *vxfw.EventContext) anyerror!void {
                    const self: *Model = if (maybe_ptr) |local| @ptrCast(@alignCast(local)) else return;
                    self.count +|= 1;
                    return ctx.consumeAndRedraw();
                }
            }.onClick,
        },
    };

    try app.run(model.widget(), .{});
}

fn printDeck(deck: *lib.card.Deck) void {
    for (deck.*.cards) |*card| {
        const card_int: u8 = @bitCast(card.*);
        std.debug.print("{}:{s}:{s}\n", .{
            card_int,
            card.suit.getName(),
            card.rank.getName(),
        });
    }
}
