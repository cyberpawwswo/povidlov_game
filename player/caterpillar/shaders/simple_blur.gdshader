shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur = 2.0;

void fragment() {
	if (FRAGCOORD.x > 1920.) { // I'm on a 4k display so this would cover the right side of the screen
		COLOR = texture(screen_texture, SCREEN_UV, blur);
	} else { // this covers the left side of the screen
		COLOR = texture(screen_texture, SCREEN_UV);
	}
}
