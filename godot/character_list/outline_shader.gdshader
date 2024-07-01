shader_type canvas_item;

uniform vec3 outline_color : source_color = vec3(0.0);
uniform int outline_size = 1;
uniform int scale = 5;
uniform int shadow_size = 0;
uniform vec3 shadow_color : source_color = vec3(0.0);
uniform sampler2D shadow_gradient;

const float SQRT2 = sqrt(2.0);

#define test(x, y) if (textureLod(tex, uv + vec2(float(x), float(y)) * pixel_size, 0).a > 0.0) return true;

bool isSolidWithin(int r, vec2 uv, vec2 pixel_size, sampler2D tex) {
	const int TESTS = 32;
	for (int i = 0; i < TESTS; ++i) {
		float theta = PI * 2.0 / float(TESTS) * float(i);
		test(cos(theta) * float(r), sin(theta) * float(r))
	}
	return false;
}

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
		} else if (shadow_size > 0) {
			int distanceFromSolid = 1;
			while(distanceFromSolid <= shadow_size) {
				if (isSolidWithin(distanceFromSolid, UV, TEXTURE_PIXEL_SIZE / float(scale), TEXTURE)) {
					float alpha = texture(shadow_gradient, vec2(float(distanceFromSolid) / float(shadow_size))).a;
					COLOR = vec4(shadow_color, alpha);
					break;
				}
				distanceFromSolid++;
			}
		}
	}
}