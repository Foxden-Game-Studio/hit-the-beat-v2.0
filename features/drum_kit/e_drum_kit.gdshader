shader_type spatial;

uniform vec3 drum_color : source_color = vec3(0.1, 0.1, 0.1);
uniform vec3 flash_color : source_color = vec3(0.0, 0.0, 0.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = drum_color + flash_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
