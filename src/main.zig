const r = @cImport({
    @cInclude("stddef.h"); // NULL
    @cInclude("raylib.h");
    @cInclude("raygui.h"); // Required for GUI controls
    @cInclude("raymath.h");
});

const std = @import("std");

fn vec3(x: f32, y: f32, z: f32) r.Vector3 {
    return r.Vector3{ .x = x, .y = y, .z = z };
}
fn vec2(x: f32, y: f32) r.Vector2 {
    return r.Vector2{ .x = x, .y = y };
}

fn to_deg(rad: f32) f32 {
    return (rad / 3.141) * 360;
}

pub fn main() void {
    const screen_width = 1920;
    const screen_height = 1080;
    r.InitWindow(screen_width, screen_height, "NGN43");
    defer r.CloseWindow(); // Close window and OpenGL context
    r.SetTargetFPS(60);

    var camera = r.Camera3D{ .position = vec3(0, 20, 20), .target = vec3(0, 0, 0), .up = vec3(0, 1, 0), .fovy = 45, .projection = r.CAMERA_PERSPECTIVE };

    var post_shader_pixels = r.LoadShader("resources/shaders/default.vs", "resources/shaders/bloom.fs");
    var water_shader = r.LoadShader("resources/shaders/water.vs", "resources/shaders/water.fs");
    var default_shader = r.LoadShader("resources/shaders/default.vs", "resources/shaders/default.fs");
    var post_shader_default = r.LoadShader(0, 0);
    _ = post_shader_default;
    var totalTime: f32 = 0;
    const timeLoc = r.GetShaderLocation(water_shader, "time");
    const cameraLoc = r.GetShaderLocation(water_shader, "camera");
    var target = r.LoadRenderTexture(screen_width, screen_height);

    // Generate water mesh:
    var mesh = r.GenMeshPlane(100, 100, 150, 150);
    var watermodel = r.LoadModelFromMesh(mesh);
    watermodel.materials[0].shader = water_shader;

    var ship_dir = vec2(0, 1);

    var ship_pos = vec3(0.0, 0.0, 0.0);
    var ship_to_cam = vec3(0.0, 10.0, -20.0);

    var model = r.LoadModel("resources/models/ship1.obj");

    while (!r.WindowShouldClose()) // Detect window close button or ESC key
    {
        // Do update here:
        if (r.IsKeyPressed(r.KEY_LEFT)) {
            ship_dir = r.Vector2Rotate(ship_dir, -0.2);
        }
        if (r.IsKeyPressed(r.KEY_RIGHT)) {
            ship_dir = r.Vector2Rotate(ship_dir, 0.2);
        }
        ship_pos = r.Vector3Add(ship_pos, r.Vector3Scale(vec3(ship_dir.x, 0.0, ship_dir.y), 0.05));

        // Draw here:
        camera.position = r.Vector3Add(ship_pos, ship_to_cam);
        camera.target = ship_pos;
        totalTime += r.GetFrameTime();
        r.SetShaderValue(water_shader, timeLoc, &totalTime, r.SHADER_UNIFORM_FLOAT);
        r.SetShaderValue(water_shader, cameraLoc, &camera.position, r.SHADER_UNIFORM_VEC3);
        {
            r.BeginShaderMode(default_shader);
            r.BeginTextureMode(target);
            r.BeginMode3D(camera);
            r.ClearBackground(r.WHITE);
            r.DrawModelEx(model, ship_pos, vec3(0, 1, 0), to_deg(r.Vector2Angle(vec2(0, 1), ship_dir)), vec3(1.0, 1.0, 1.0), r.WHITE);
            r.DrawModel(watermodel, vec3(0, 0, 0), 1, r.BLUE);
            r.EndMode3D();
            r.EndTextureMode();
            r.EndShaderMode();
        }
        r.BeginDrawing();
        r.ClearBackground(r.RAYWHITE);
        r.BeginShaderMode(post_shader_pixels);
        r.DrawTextureRec(target.texture, r.Rectangle{ .x = 0, .y = 0, .width = @as(f32, @floatFromInt(target.texture.width)), .height = 0 - @as(f32, @floatFromInt(target.texture.height)) }, vec2(0, 0), r.WHITE);
        r.EndShaderMode();
        r.DrawFPS(10, 10);
        r.EndDrawing();
    }
}
