shader_type canvas_item;

uniform sampler2D view3d;
uniform sampler2D view2d;
uniform bool view2d_active = false;

uniform float window_rel_scale : hint_range(0.0, 1.0, 0.01) = 0.25;
uniform float window_offset_x : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float window_offset_y : hint_range(0.0, 1.0, 0.01) = 0.1;

vec4 avgColor(sampler2D tex, vec2 uv, vec2 tex_pixel_size){
	// Code adapted from...
	// https://godotshaders.com/shader/box-blur/
	vec2 pixel = uv / tex_pixel_size;
	float pix = 0.0;
	vec4 total = vec4(0., 0., 0., 0.);
	for(int i = int(pixel.x - 1.); i < int(pixel.x + 1.); i++){
		for(int j = int(pixel.y - 1.); j < int(pixel.y + 1.); j++){
			if (i < 0 || i > int(1. / tex_pixel_size.x) || j < 0 || j > int(1. / tex_pixel_size.y)){
				pix += 1.0;
				total += vec4(1.,0.,0.,1.);
				/*
				if (i < 100){
					total += vec4(1.,0.,0.,1.);
				} else {
					total += texture(tex, vec2(float(i), float(j)) * tex_pixel_size);
				}
				*/
			}
		}
	}
	if (pix > 0.)
		return total /= pix;
	return vec4(0.,0.,0.,1.);
}

vec4 getColor(sampler2D main, sampler2D alt, vec2 uv, vec2 tex_pixel_size){
	float win_x = window_offset_x;
	if (win_x + window_rel_scale > 1.0)
		win_x = window_offset_x - window_rel_scale;
	float win_y = window_offset_y;
	if (win_y + window_rel_scale > 1.0)
		win_y = window_offset_y - window_rel_scale;
	float win_x2 = win_x + window_rel_scale;
	float win_y2 = win_y + window_rel_scale;
	
	if (uv.x >= win_x && uv.x <= win_x2 && uv.y >= win_y && uv.y <= win_y2){
		float uv2x = (uv.x - win_x) / window_rel_scale;
		float uv2y = (uv.y - win_y) / window_rel_scale;
		//return texture(alt, vec2(uv2x, uv2y));
		return avgColor(alt, vec2(uv2x, uv2y), tex_pixel_size);
	}
	
	return texture(main, uv);
}

void fragment(){
	if (view2d_active){
		COLOR = getColor(view2d, view3d, UV, TEXTURE_PIXEL_SIZE);
	} else {
		COLOR = getColor(view3d, view2d, UV, TEXTURE_PIXEL_SIZE);
	}
}



