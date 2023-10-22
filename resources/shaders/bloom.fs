# version 100

precision mediump float;

// Input vertex attributes (from vertex shader)
varying vec2 fragTexCoord;
varying vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// NOTE: Add here your custom variables

// NOTE: Render size values must be passed from code
const float renderWidth = 1920.0;
const float renderHeight = 1080.0;

float stitchingSize = 4.0;

vec4 PostFX(sampler2D tex, vec2 uv)
{
    vec4 c = vec4(0.0);
    float size = stitchingSize;
    vec2 cPos = uv * vec2(renderWidth, renderHeight);
    vec2 tlPos = floor(cPos / vec2(size, size));
    tlPos *= size;

    int remX = int(mod(cPos.x, size));
    int remY = int(mod(cPos.y, size));

    if (remX == 0 && remY == 0) tlPos = cPos;
    c = texture2D(tex, tlPos * vec2(1.0/renderWidth, 1.0/renderHeight)) * 1.4;

    vec2 blPos = tlPos;
    blPos.y += (size - 1.0);

    if ((remX == remY) || (((int(cPos.x) - int(blPos.x)) == (int(blPos.y) - int(cPos.y)))))
    {
        c = vec4(c.x * 0.6, c.y * 0.6, c.z * 0.6, 0.6);
    }

    return c;
}

void main()
{
    vec3 tc = PostFX(texture0, fragTexCoord).rgb;

    gl_FragColor = vec4(tc, 1.0);
}