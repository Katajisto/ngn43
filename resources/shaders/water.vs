#version 100

// Input vertex attributes
attribute vec3 vertexPosition;
attribute vec2 vertexTexCoord;
attribute vec3 vertexNormal;
attribute vec4 vertexColor;

// Input uniform values
uniform mat4 mvp;
uniform float time;
uniform vec3 camera;

// Output vertex attributes (to fragment shader)
varying vec2 fragTexCoord;
varying vec3 normal;
varying vec3 cv;
varying float stime;

vec3 wave(vec4 wave, vec3 p, inout vec3 tangent, inout vec3 binormal) {
    float steepness = wave.z;
    float wavelength = wave.w;
    float k = 2.0 * 3.141 / wavelength;
	float c = 2.0;
	vec2 d = normalize(vec2(wave.x, wave.y));
	float f = k * (dot(d, p.xz) - c * time);
	float a = steepness / k;
	
	tangent += vec3(
		-d.x * d.x * (steepness * sin(f)),
		d.x * (steepness * cos(f)),
		-d.x * d.y * (steepness * sin(f))
	);
    
	binormal += vec3(
		-d.x * d.y * (steepness * sin(f)),
		d.y * (steepness * cos(f)),
		-d.y * d.y * (steepness * sin(f))
	);
    
	return vec3(
		d.x * (a * cos(f)),
		a * sin(f),
		d.y * (a * cos(f))
	);
}

void main() {
    fragTexCoord = vertexTexCoord;
    vec3 tangent = vec3(1.0, 0.0, 0.0);
    vec3 binormal = vec3(0.0, 0.0, 1.0);
    vec3 p = vertexPosition;

    p += wave(vec4(1.0, 0.0, 0.2, 10.0), vertexPosition, tangent, binormal);
    p += wave(vec4(0.0, 1.0, 0.125, 15.0), vertexPosition, tangent, binormal);
    p += wave(vec4(1.0, 1.0, 0.225, 5.0), vertexPosition, tangent, binormal);
    
    normal = normalize(cross(normalize(binormal), normalize(tangent)));

    cv = normalize(camera - vertexPosition);
    
    gl_Position = mvp * vec4(p.x, p.y, p.z, 1.0);
	stime = time;
}