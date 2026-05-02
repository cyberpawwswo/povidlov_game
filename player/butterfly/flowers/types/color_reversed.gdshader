shader_type canvas_item;

// Godot 4: объявляем текстуру экрана как униформу (как подсказал редактор)
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Режим: false = цветокоррекция, true = инверсия
uniform bool invert_mode = false;

// Общая сила эффекта (0.0 — нет эффекта, 1.0 — полный)
uniform float effect_strength = 1.0;

// Начало затухания от центра к краям (0.0 — сразу от центра, 0.8 — почти до краёв)
uniform float edge_fade_start = 0.4;
// Ширина плавного перехода (чем больше, тем мягче границы)
uniform float fade_width = 0.3;

// Параметры цветокоррекции (множитель и смещение каналов)
uniform vec3 color_multiplier = vec3(1.0, 1.0, 1.0);
uniform vec3 color_offset     = vec3(0.0, 0.0, 0.0);

void fragment() {
	// Читаем пиксели того, что находится под объектом
	vec4 bg_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	// Вычисляем маску затухания к краям (прямоугольная форма)
	vec2 center_dist = abs(UV - 0.5) * 2.0;
	float max_dist   = max(center_dist.x, center_dist.y);
	
	// Плавное затухание: 1.0 в центре → 0.0 на краях
	float fade_mask = 1.0 - smoothstep(edge_fade_start, edge_fade_start + fade_width, max_dist);
	
	// Применяем выбранный эффект
	vec3 processed_color;
	if (invert_mode) {
		processed_color = 1.0 - bg_color.rgb;
	} else {
		processed_color = bg_color.rgb * color_multiplier + color_offset;
	}
	
	// Смешиваем оригинал и обработанный цвет
	float final_strength = effect_strength * fade_mask;
	vec3 final_color = mix(bg_color.rgb, processed_color, final_strength);
	
	// Записываем результат, сохраняя исходную прозрачность
	COLOR = vec4(final_color, bg_color.a);
}
