const r = @cImport({
    @cInclude("stddef.h"); // NULL
    @cInclude("raylib.h");
    @cInclude("raygui.h"); // Required for GUI controls
    @cInclude("raymath.h");
});

const std = @import("std");

const dprint = std.debug.print;
const WATER_RANGE = 10;

fn vec3(x: f32, y: f32, z: f32) r.Vector3 {
    return r.Vector3{ .x = x, .y = y, .z = z };
}
fn vec2(x: f32, y: f32) r.Vector2 {
    return r.Vector2{ .x = x, .y = y };
}

fn to_deg(rad: f32) f32 {
    return (rad / (3.14159 * 2)) * -360;
}

fn itf(i: i32) f32 {
    return @as(f32, @floatFromInt(i));
}
fn fti(f: f32) i32 {
    return @as(i32, @intFromFloat(f));
}

fn render_water_tile(x: i32, y: i32, model: *r.Model) void {
    r.DrawModel(model.*, vec3(@as(f32, @floatFromInt(x)) * 50, 0, @as(f32, @floatFromInt(y)) * 50), 1, r.BLUE);
}

fn render_water_inf(ship_pos: r.Vector3, model: *r.Model) void {
    var x = @divFloor(fti(ship_pos.x + 25), 50);
    var z = @divFloor(fti(ship_pos.z + 25), 50);

    var i = x - WATER_RANGE;
    while (i <= x + WATER_RANGE) : (i += 1) {
        var j = z - WATER_RANGE;
        while (j <= z + WATER_RANGE) : (j += 1) {
            render_water_tile(i, j, model);
        }
    }
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
    _ = default_shader;
    var post_shader_default = r.LoadShader(0, 0);
    var totalTime: f32 = 0;
    const timeLoc = r.GetShaderLocation(water_shader, "time");
    const cameraLoc = r.GetShaderLocation(water_shader, "camera");
    var target = r.LoadRenderTexture(screen_width, screen_height);

    // Generate water mesh:
    var mesh = r.GenMeshPlane(50, 50, 150, 150);
    var watermodel = r.LoadModelFromMesh(mesh);
    watermodel.materials[0].shader = water_shader;

    var ship_dir = vec2(0, 1);
    var camera_dir = vec2(0, 1);

    var ship_pos = vec3(0.0, -0.1, 0.0);
    var ship_to_cam = vec3(0, 0, 0);

    var model = r.LoadModel("resources/models/ship1.obj");
    var town = r.LoadModel("resources/models/town1.obj");

    var sky_texture = r.LoadTexture("resources/images/sky.png");

    var speed: f32 = 0.1;

    while (!r.WindowShouldClose()) // Detect window close button or ESC key
    {
        // Do update here:
        if (r.IsKeyDown(r.KEY_LEFT)) {
            ship_dir = r.Vector2Rotate(ship_dir, -(3.14159 / 540.0));
        }
        if (r.IsKeyDown(r.KEY_RIGHT)) {
            ship_dir = r.Vector2Rotate(ship_dir, (3.14159 / 540.0));
        }
        if (r.IsKeyPressed(r.KEY_UP)) {
            speed += 0.05;
            speed = @min(speed, 0.3);
        }
        if (r.IsKeyPressed(r.KEY_DOWN)) {
            speed -= 0.05;
            speed = @max(speed, 0.0);
        }

        // Camera dir is kept in the same direction as ship dir
        // because I don't want to worry about that when calculating
        // angles.
        var angle_to_cam = r.Vector2Angle(ship_dir, camera_dir);
        camera_dir = r.Vector2Rotate(camera_dir, -angle_to_cam * 0.005);

        ship_to_cam = r.Vector3Scale(vec3(-camera_dir.x, 0.3, -camera_dir.y), 40);
        // ship_to_cam = r.Vector3Scale(vec3(-camera_dir.x, 100, -camera_dir.y), 2);
        ship_pos = r.Vector3Add(ship_pos, r.Vector3Scale(vec3(ship_dir.x, 0.0, ship_dir.y), speed));

        // Draw here:
        camera.position = r.Vector3Add(ship_pos, ship_to_cam);
        camera.target = ship_pos;
        totalTime += r.GetFrameTime();
        r.SetShaderValue(water_shader, timeLoc, &totalTime, r.SHADER_UNIFORM_FLOAT);
        r.SetShaderValue(water_shader, cameraLoc, &camera.position, r.SHADER_UNIFORM_VEC3);
        {
            r.BeginTextureMode(target);
            r.ClearBackground(r.WHITE);
            r.DrawTexture(sky_texture, 0, 0, r.WHITE);
            r.BeginMode3D(camera);
            r.DrawModelEx(model, ship_pos, vec3(0, 1, 0), to_deg(r.Vector2Angle(vec2(0, 1), ship_dir)), vec3(2.0, 2.0, 2.0), r.WHITE);
            r.DrawModel(town, vec3(125, 0.5, 45), 3, r.WHITE);
            render_water_inf(ship_pos, &watermodel);
            r.EndMode3D();
            r.EndTextureMode();
        }
        r.BeginDrawing();
        r.ClearBackground(r.WHITE);
        r.BeginShaderMode(post_shader_pixels);
        r.DrawTextureRec(target.texture, r.Rectangle{ .x = 0, .y = 0, .width = @as(f32, @floatFromInt(target.texture.width)), .height = 0 - @as(f32, @floatFromInt(target.texture.height)) }, vec2(0, 0), r.WHITE);
        r.EndShaderMode();
        r.DrawFPS(10, 10);
        r.EndDrawing();
    }
    r.UnloadShader(post_shader_pixels);
    r.UnloadShader(post_shader_default);
    r.UnloadModel(model);
    r.UnloadModel(town);
    r.UnloadModel(watermodel);
    r.UnloadShader(water_shader);
    r.UnloadMesh(mesh);
}
