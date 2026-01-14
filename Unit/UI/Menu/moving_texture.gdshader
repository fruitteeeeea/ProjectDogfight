shader_type canvas_item;
uniform float speed = 0.8;

void vertex() {
	// Called for every vertex the material is visible on.
}


void fragment() {
	COLOR = texture(TEXTURE,UV + vec2(TIME * -speed, TIME * -speed));
	// Called for every pixel the material is visible on.
}

