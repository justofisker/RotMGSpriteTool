shader_type canvas_item;

uniform vec3 outline_color : source_color = vec3(0.0);
uniform int outline_size = 1;
uniform int scale = 5;

void fragment() {
	if (COLOR.a == 0.0) {
		vec2 check_size = TEXTURE_PIXEL_SIZE / vec2(float(scale)) * vec2(float(outline_size));
		if (textureLod(TEXTURE, UV + vec2(check_size.x, 0), 0).a > 0.0
		 || textureLod(TEXTURE, UV + vec2(0, check_size.y), 0).a > 0.0
		 || textureLod(TEXTURE, UV + vec2(-check_size.x, 0), 0).a > 0.0
		 || textureLod(TEXTURE, UV + vec2(0, -check_size.y), 0).a > 0.0
		 || textureLod(TEXTURE, UV + vec2(check_size.x, check_size.y), 0).a > 0.0
		 || textureLod(TEXTURE, UV + vec2(-check_size.x, check_size.y), 0).a > 0.0
		 || textureLod(TEXTURE, UV + vec2(-check_size.x, -check_size.y), 0).a > 0.0
		 || textureLod(TEXTURE, UV + vec2(check_size.x, -check_size.y), 0).a > 0.0) {
			COLOR = vec4(outline_color, 1.0);
		}
	}
}