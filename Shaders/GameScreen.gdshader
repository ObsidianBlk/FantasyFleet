shader_type canvas_item;

uniform sampler2D view3d;
uniform sampler2D view2d;
uniform bool view2d_active = false;

void fragment(){
	if (view2d_active){
		COLOR = texture(view2d, UV);
	} else {
		COLOR = texture(view3d, UV);
	}
}



