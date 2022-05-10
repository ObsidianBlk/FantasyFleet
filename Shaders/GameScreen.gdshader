shader_type canvas_item;

uniform sampler2D view3d;
uniform sampler2D view2d;
uniform bool view2d_active = false;

vec4 getColor(sampler2D main, sampler2D alt, vec2 uv){
	// TODO: Calculate a "window" in which the alt sampler2D will be viewable and
	// return the pixel from the appropriate view.
	return texture(main, uv);
}

void fragment(){
	if (view2d_active){
		COLOR = getColor(view2d, view3d, UV);
	} else {
		COLOR = getColor(view3d, view2d, UV);
	}
}



