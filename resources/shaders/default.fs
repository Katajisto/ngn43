#version 100

precision mediump float;

varying vec2 fragTexCoord;
varying vec3 normal;

void main() {
    gl_FragColor = vec4(normal, 1.0); // Set the output color
}