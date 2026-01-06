shader_type canvas_item;

uniform float fade_size : hint_range(0.0, 0.5) = 0.15;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    float alpha = 1.0;

    // 上方渐隐
    if (UV.y < fade_size) {
        alpha = smoothstep(0.0, fade_size, UV.y);
    }
    // 下方渐隐
    else if (UV.y > 1.0 - fade_size) {
        alpha = smoothstep(1.0, 1.0 - fade_size, UV.y);
    }

    COLOR = vec4(tex_color.rgb, tex_color.a * alpha);
}
