#version 100

precision mediump float;

// Input vertex attributes (from vertex shader)
varying vec2 fragTexCoord;
varying vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// NOTE: Add here your custom variables

float pixelWidth = 5.0;
float pixelHeight = 5.0;

const vec2 size = vec2(1920.0, 1080.0);   // render size
const float samples = 5.0;          // pixels per axis; higher = bigger glow, worse performance
const float quality = 0.2;             // lower = smaller glow, better quality

void main()
{
    float dx = pixelWidth*(1.0/size.x);
    float dy = pixelHeight*(1.0/size.y);
    vec2 coord = vec2(dx*floor(fragTexCoord.x/dx), dy*floor(fragTexCoord.y/dy));
    vec3 tc = texture2D(texture0, coord).rgb;
    gl_FragColor = vec4(tc, 1.0);
}