const r = @cImport({
    @cInclude("stddef.h"); // NULL
    @cInclude("raylib.h");
    //@cDefine("RAYGUI_IMPLEMENTATION", {}); - Moved to raygui_impl.c
    //                                         Here we only need raygui declarations, not actual function bodies.
    @cInclude("raygui.h"); // Required for GUI controls
});

pub fn main() void {
    const screen_width = 800;
    const screen_height = 450;
    r.InitWindow(screen_width, screen_height, "NGN43");
    defer r.CloseWindow(); // Close window and OpenGL context
    r.SetTargetFPS(60);

    while (!r.WindowShouldClose()) // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // NOTE: All variables update happens inside GUI control functions
        //----------------------------------------------------------------------------------

        // Draw
        //---------------------------------------------------------------------------------
        r.BeginDrawing();
        defer r.EndDrawing();

        r.ClearBackground(r.RAYWHITE);

        r.DrawLine(500, 0, 500, r.GetScreenHeight(), r.Fade(r.LIGHTGRAY, 0.6));
        r.DrawRectangle(500, 0, r.GetScreenWidth() - 500, r.GetScreenHeight(), r.Fade(r.LIGHTGRAY, 0.3));

        if (draw_ring)
            r.DrawRing(center, inner_radius, outer_radius, start_angle, end_angle, @intFromFloat(segments), r.Fade(r.MAROON, 0.3));
        if (draw_ring_lines)
            r.DrawRingLines(center, inner_radius, outer_radius, start_angle, end_angle, @intFromFloat(segments), r.Fade(r.BLACK, 0.4));
        if (draw_circle_lines)
            r.DrawCircleSectorLines(center, outer_radius, start_angle, end_angle, @intFromFloat(segments), r.Fade(r.BLACK, 0.4));

        // Draw GUI controls
        //------------------------------------------------------------------------------
        _ = r.GuiSliderBar(.{ .x = 600, .y = 40, .width = 120, .height = 20 }, "StartAngle", null, &start_angle, -450, 450);
        _ = r.GuiSliderBar(.{ .x = 600.0, .y = 70.0, .width = 120.0, .height = 20.0 }, "EndAngle", null, &end_angle, -450, 450);

        _ = r.GuiSliderBar(.{ .x = 600.0, .y = 140.0, .width = 120.0, .height = 20.0 }, "InnerRadius", null, &inner_radius, 0, 100);
        _ = r.GuiSliderBar(.{ .x = 600.0, .y = 170.0, .width = 120.0, .height = 20.0 }, "OuterRadius", null, &outer_radius, 0, 200);

        _ = r.GuiSliderBar(.{ .x = 600.0, .y = 240.0, .width = 120.0, .height = 20.0 }, "Segments", null, &segments, 0, 100);

        _ = r.GuiCheckBox(.{ .x = 600, .y = 320, .width = 20, .height = 20 }, "Draw Ring", &draw_ring);
        _ = r.GuiCheckBox(.{ .x = 600, .y = 350, .width = 20, .height = 20 }, "Draw RingLines", &draw_ring_lines);
        _ = r.GuiCheckBox(.{ .x = 600, .y = 380, .width = 20, .height = 20 }, "Draw CircleLines", &draw_circle_lines);
        //------------------------------------------------------------------------------

        var min_segments: i32 = @intFromFloat(@ceil((end_angle - start_angle) / 90.0));
        // @ptrCast -> [*c]const u8: https://github.com/ziglang/zig/issues/16234
        // -- This code causes Zig compiler (0.11.0-dev.3859+88284c124) to segfault, see
        // -- https://github.com/ziglang/zig/issues/16197
        //c.DrawText(c.TextFormat("MODE: %s", if (@as(i32, @intFromFloat(segments)) >= min_segments) "MANUAL"
        //                                    else "AUTO"),
        //           600, 270, 10, if (@as(i32, @intFromFloat(segments)) >= min_segments) c.MAROON else c.DARKGRAY);
        const text = if (@as(i32, @intFromFloat(segments)) >= min_segments) "MODE: MANUAL" else "MODE: AUTO";
        r.DrawText(text, 600, 270, 10, if (@as(i32, @intFromFloat(segments)) >= min_segments) r.MAROON else r.DARKGRAY);
        r.DrawFPS(10, 10);
        //---------------------------------------------------------------------------------
    }
}
