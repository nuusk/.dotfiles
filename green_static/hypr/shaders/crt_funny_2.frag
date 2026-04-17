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
    float row_jitter = (hash(vec2(floor(uv.y * 180.0), 0.21)) - 0.5) * 0.010;
    uv.x += row_jitter;

    float scan = sin(v_texcoord.y * 1550.0) * 0.045;
    float mask = step(0.5, fract(v_texcoord.y * 340.0)) * 0.028;
    float vignette = 1.0 - distance(v_texcoord, vec2(0.5)) * 0.38;
    vec2 ro = vec2(0.0042, 0.0);
    vec2 bo = vec2(-0.0035, 0.0);

    float r = texture(tex, uv + ro).r;
    float g = texture(tex, uv).g;
    float b = texture(tex, uv + bo).b;

    vec3 color = vec3(r, g, b);
    color *= vignette + scan - mask;
    color.g *= 1.08;
    color.b *= 1.03;

    fragColor = vec4(color, 1.0);
}
