#version 300 es

precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;

void main() {
    vec2 uv = v_texcoord;
    vec2 center = uv - 0.5;
    float curve = dot(center, center) * 0.030;
    uv += center * curve;

    float scan = sin(v_texcoord.y * 1400.0) * 0.040;
    float mask = step(0.5, fract(v_texcoord.y * 320.0)) * 0.024;
    float vignette = 1.0 - distance(v_texcoord, vec2(0.5)) * 0.42;
    vec2 offset = vec2(0.0020, 0.0);

    float r = texture(tex, uv + offset).r;
    float g = texture(tex, uv).g;
    float b = texture(tex, uv - offset).b;

    vec3 color = vec3(r, g, b);
    color *= vignette + scan - mask;
    color.r *= 1.02;
    color.g *= 1.06;
    color.b *= 1.01;

    fragColor = vec4(color, 1.0);
}
