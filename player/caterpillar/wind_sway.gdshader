shader_type canvas_item;

uniform float wind_start_threshold : hint_range(0,1) = 0.1;
uniform float wind_end_threshold : hint_range(0,10) = 2;
uniform float wind_end_threshold_2 : hint_range(0,2) = 0.1;
uniform float wind_strength : hint_range(0,1.5) = 0.2;
uniform float wind_speed  : hint_range(0.2,5) = 1.0;
uniform float scale = 2.0;

// 🌿 Фаза колебаний (0..2π). Сдвигает "начальную точку" волны для каждого объекта.
uniform float wind_phase : hint_range(0, 6.28318530718) = 0.0;

void vertex() {
	VERTEX *= scale;
}

void fragment() {
	vec2 uv = (UV - REGION_RECT.xy) / REGION_RECT.zw * scale;
	uv -= (scale - 1.) / scale;
	
	// Вычисляем один раз для производительности и читаемости
	float height_factor = pow(1.0 - uv.y, wind_end_threshold);
	float dist_amount = smoothstep(wind_start_threshold * height_factor, wind_end_threshold_2, 1.0 - uv.y);
	
	// ✅ Добавлен wind_phase к аргументу sin()
	uv.x += sin(TIME * wind_speed + wind_phase) * height_factor * dist_amount * wind_strength;
	
	COLOR = texture(TEXTURE, uv * REGION_RECT.zw + REGION_RECT.xy);
	
	// Обрезка по границам UV
	vec2 border = step(vec2(0.0), uv) * step(uv, vec2(1.0));
	COLOR.a *= border.x * border.y;
}