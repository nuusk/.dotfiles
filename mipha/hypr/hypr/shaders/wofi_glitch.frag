#version 300 es

precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void main() {
    vec2 uv = v_texcoord;
    float scan = sin(uv.y * 1500.0) * 0.03;
    float scanlines = step(0.5, fract(uv.y * 270.0)) * 0.025;
    float band = smoothstep(0.08, 0.92, uv.x) * 0.0022;
    float edge = distance(uv, vec2(0.5)) * 0.002;
    float jitter = (hash(vec2(floor(uv.y * 120.0), 0.37)) - 0.5) * 0.0038;
    float ghost = sin(uv.y * 110.0) * 0.0024;

    vec2 redUV = uv + vec2(band + edge + jitter, 0.0);
    vec2 blueUV = uv - vec2(band + edge + ghost, 0.0);
    vec2 greenUV = uv + vec2(jitter * 0.35, 0.0);

    float r = texture(tex, redUV).r;
    float g = texture(tex, greenUV).g;
    float b = texture(tex, blueUV).b;

    vec3 color = vec3(r, g, b);
    color *= 0.96 + scan - scanlines;
    color.r *= 0.99;
    color.g *= 1.03;
    color.b *= 1.08;

    fragColor = vec4(color, 1.0);
}
