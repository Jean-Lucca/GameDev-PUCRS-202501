shader_type canvas_item;

uniform bool aura_enabled = false;
uniform vec4 aura_color : source_color = vec4(0.2, 0.6, 1.0, 1.0);
uniform float aura_size : hint_range(0.0, 10.0) = 1.5;
uniform float aura_intensity : hint_range(0.0, 1.0) = 0.31;
uniform float aura2_size : hint_range(0.0, 20.0) = 1.4;
uniform float aura2_intensity : hint_range(0.0, 1.0) = 0.25;

void fragment() {
	if (aura_enabled){
		
	    vec4 tex_color = texture(TEXTURE, UV);

	    if (!aura_enabled) {
	        COLOR = tex_color;
	    }

	    float alpha = tex_color.a;
	    float edge1 = 0.0;
	    float edge2 = 0.0;

	    // First (small) aura sampling radius = 2
	    for (int x = -2; x <= 2; x++) {
	        for (int y = -2; y <= 2; y++) {
	            vec2 offset = vec2(float(x), float(y)) * aura_size * TEXTURE_PIXEL_SIZE;
	            vec4 sample = texture(TEXTURE, UV + offset);
	            edge1 = max(edge1, sample.a);
	        }
	    }

	    // Second (big) aura sampling radius = 4 or 5 (bigger than first)
	    for (int x = -4; x <= 4; x++) {
	        for (int y = -4; y <= 4; y++) {
	            vec2 offset = vec2(float(x), float(y)) * aura2_size * TEXTURE_PIXEL_SIZE;
	            vec4 sample = texture(TEXTURE, UV + offset);
	            edge2 = max(edge2, sample.a);
	        }
	    }

	    // Compose the aura colors
	    vec4 aura_layer1 = aura_color;
	    aura_layer1.a = edge1 * aura_intensity;

	    vec4 aura_layer2 = aura_color;
	    aura_layer2.a = edge2 * aura2_intensity;

	    // Final aura is additive blend of both auras, clamped alpha <= 1
	    vec4 aura = aura_layer1 + aura_layer2;
	    aura.a = clamp(aura.a, 0.0, 1.0);

	    // Apply aura only outside the sprite (alpha < 0.5)
	    if (alpha < 0.5 && aura.a > 0.01) {
	        COLOR = aura;
	    } else {
	        COLOR = tex_color;
	    }	
	} 
} 