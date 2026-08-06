#version 300 es

precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;

void main() {
    vec2 uv = v_texcoord;
    float scan = sin(v_texcoord.y * 1600.0) * 0.035;
    float mask = step(0.5, fract(v_texcoord.y * 360.0)) * 0.020;
    float shadow = 1.0 - distance(v_texcoord, vec2(0.5)) * 0.30;
    vec2 red = vec2(0.0010, 0.0);
    vec2 blue = vec2(-0.0050, 0.0);

    float r = texture(tex, uv + red).r;
    float g = texture(tex, uv).g;
    float b = texture(tex, uv + blue).b;

    vec3 color = vec3(r, g, b);
    color *= shadow + scan - mask;
    color.g *= 1.03;
    color.b *= 1.08;

    fragColor = vec4(color, 1.0);
}
