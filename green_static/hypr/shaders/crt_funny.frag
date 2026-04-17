#version 300 es

precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;

void main() {
    vec2 uv = v_texcoord;
    vec2 center = uv - 0.5;
    float curve = dot(center, center) * 0.035;
    uv += center * curve;

    float scan = sin(v_texcoord.y * 1350.0) * 0.028;
    float mask = step(0.5, fract(v_texcoord.y * 300.0)) * 0.022;
    float vignette = 1.0 - distance(v_texcoord, vec2(0.5)) * 0.35;
    vec2 offset = vec2(0.0018, 0.0);

    float r = texture(tex, uv + offset).r;
    float g = texture(tex, uv).g;
    float b = texture(tex, uv - offset).b;

    vec3 color = vec3(r, g, b);
    color *= vignette + scan - mask;
    color.r *= 0.98;
    color.g *= 1.045;
    color.b *= 1.015;

    fragColor = vec4(color, 1.0);
}
