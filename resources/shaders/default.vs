#version 100

// Input vertex attributes
attribute vec3 vertexPosition;
attribute vec2 vertexTexCoord;
attribute vec3 vertexNormal;
attribute vec4 vertexColor;
attribute vec3 vertexTangent;


// Input uniform values
uniform mat4 mvp;
uniform float time;
uniform vec3 camera;

// Output vertex attributes (to fragment shader)
varying vec2 fragTexCoord;
varying vec3 normal;

void main() {
    fragTexCoord = vertexTexCoord;
    normal = (mvp * vec4(vertexNormal, 1.0)).xyz;
    gl_Position = mvp * vec4(vertexPosition, 1.0);
}