shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}


const float a=1.0;
const float b=.1759;
float spiralSDF(vec2 p,vec2 c){
    // t = theta
    p = p - c;
    float t=atan(p.y, p.x) + TIME * 2.;
    // t=(t+PI)/(2.*PI);
    float r=length(p.xy);

    float n=(log(r/a)/b-t)/(2.*PI);

    // Cap the spiral
    // float nm = (log(0.11)/b-t)/(2.0*PI);
    // n = min(n,nm);
    // return (n+1.0)/100.0;
    float upper_r=a*exp(b*(t+2.*PI*ceil(n)));
    float lower_r=a*exp(b*(t+2.*PI*floor(n)));
    // float lower_r = 0.0;

    return min(abs(upper_r-r),abs(r-lower_r));
}
uniform vec4 color_a : source_color = vec4(1.0);
uniform vec4 color_b : source_color = vec4(1.0);

void fragment() {
	vec4 current_pixel = texture(TEXTURE, UV);
	COLOR = current_pixel;
	if (all(greaterThan(current_pixel, vec4(.5)))) {
	    vec2 clip_space_uv = fract(vec2(UV.x * 6., UV.y * 5.)) * 2.0 - 1.0;
		vec2 c = vec2(0.0,0.0);
		// Uncomment for more swirl
		// vec2 c = vec2(0.7*sin(iTime*1.3), 0.3*sin(iTime)*2.0);
		float r = length(clip_space_uv);
		float d = spiralSDF(clip_space_uv,vec2(c));

	    // Alter distance for a satisfying visual
		float v = min(1., d * 9.);
		COLOR = mix(color_a, color_b, v);
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
