// Replication of wave logic from water.vs shader in order to calculate ship angle.
const r = @import("ray.zig").r;

fn vec4(x: f32, y: f32, z: f32, w: f32) r.Vector4 {
    return r.Vector4{ .x = x, .y = y, .z = z, .w = w };
}

fn wave_height(wavedata: r.Vector4, p: r.Vector3, time: f32) f32 {
    var steepness = wavedata.z;
    var wavelength = wavedata.w;
    var k: f32 = 2.0 * 3.141 / wavelength;
    var c: f32 = 2.0;
    var a = steepness / k;
    var d = r.Vector2Normalize(r.Vector2{ .x = wavedata.x, .y = wavedata.y });
    var f = k * (r.Vector2DotProduct(d, r.Vector2{ .x = p.x, .y = p.z }) - c * time);

    return a * @sin(f);
}

pub const WaveResult = struct {
    h_delta: f32,
    binormal: r.Vector3,
    tangent: r.Vector3,
};

pub fn getWaveHeight(point: r.Vector3, time: f32) f32 {
    var delta: f32 = 0;
    // delta += wave_height(vec4(1, 0, 0.2, 10), point, time);
    delta += wave_height(vec4(0, 1.0, 0.125, 15), point, time);
    // delta += wave_height(vec4(1, 1, 0.225, 5), point, time);
    delta += wave_height(vec4(1.0, 0.3, 0.1, 20), point, time);
    // delta += wave_height(vec4(0.6, 0.2, 0.2, 1.0), point, time);
    return delta;
}

// void main() {
//     vec3 tangent = vec3(1.0, 0.0, 0.0);
//     vec3 binormal = vec3(0.0, 0.0, 1.0);
// 	vec3 p = vertexPosition;
// 	vec4 world_pos = matModel * vec4(vertexPosition, 1.0);
// 	vec3 world_vertex_pos = vec3(world_pos.x, world_pos.y, world_pos.z);
// 	fragPos = world_vertex_pos;
// 	fragTexCoord = vec2(world_vertex_pos.x, world_vertex_pos.y);
//     p += wave(vec4(1.0, 0.0, 0.2, 10.0), world_vertex_pos, tangent, binormal);
//     p += wave(vec4(0.0, 1.0, 0.125, 15.0), world_vertex_pos, tangent, binormal);
//     p += wave(vec4(1.0, 1.0, 0.225, 5.0), world_vertex_pos, tangent, binormal);

//     normal = normalize(cross(normalize(binormal), normalize(tangent)));

//     cv = normalize(camera - world_vertex_pos);
// 	dist = length(camera - world_vertex_pos);

//     gl_Position = mvp * vec4(p.x, p.y, p.z, 1.0);
// 	stime = time;
// }

// vec3 wave(vec4 wave, vec3 p, inout vec3 tangent, inout vec3 binormal) {
//     float steepness = wave.z;
//     float wavelength = wave.w;
//     float k = 2.0 * 3.141 / wavelength;
// 	float c = 2.0;
// 	vec2 d = normalize(vec2(wave.x, wave.y));
// 	float f = k * (dot(d, p.xz) - c * time);
// 	float a = steepness / k;

// 	tangent += vec3(
// 		-d.x * d.x * (steepness * sin(f)),
// 		d.x * (steepness * cos(f)),
// 		-d.x * d.y * (steepness * sin(f))
// 	);

// 	binormal += vec3(
// 		-d.x * d.y * (steepness * sin(f)),
// 		d.y * (steepness * cos(f)),
// 		-d.y * d.y * (steepness * sin(f))
// 	);

// 	return vec3(
// 		d.x * (a * cos(f)),
// 		a * sin(f),
// 		d.y * (a * cos(f))
// 	);
// }
