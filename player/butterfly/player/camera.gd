extends Camera2D

enum ShakeType { HEAVY_IMPACT, RANDOM_RUMBLE }

# Хранилище активных трясок
var active_shakes: Array[Dictionary] = []

# Добавление новой тряски
func add_shake(type: ShakeType, strength: float, duration: float, params: Dictionary = {}) -> void:
	var shake = {
		type = type,
		strength = strength,
		duration = duration,
		time_left = duration,
		# Параметры по умолчанию + переопределение через params
		frequency = params.get("frequency", 10.0),
		damping = params.get("damping", 5.0),
		vertical_bias = params.get("vertical_bias", 2.0)
	}
	active_shakes.append(shake)
	
	# Включаем _process только если это первая тряска
	if active_shakes.size() == 1:
		set_process(true)

func _process(delta: float) -> void:
	var total_offset = Vector2.ZERO
	
	# Проходимся в обратном порядке для безопасного удаления
	for i in range(active_shakes.size() - 1, -1, -1):
		var shake = active_shakes[i]
		shake.time_left -= delta
		
		if shake.time_left <= 0:
			active_shakes.remove_at(i)
			continue
			
		var t = 1.0 - (shake.time_left / shake.duration) # 0.0 → 1.0
		total_offset += _calculate_offset(shake, t)
		
	if active_shakes.is_empty():
		offset = Vector2.ZERO
		set_process(false)
	else:
		offset = total_offset

func _calculate_offset(shake: Dictionary, t: float) -> Vector2:
	match shake.type:
		ShakeType.HEAVY_IMPACT:
			# Затухающая синусоида + вертикальный акцент
			var envelope = exp(-shake.damping * t)
			var oscillation = cos(shake.frequency * t * 2 * PI)
			var intensity = shake.strength * oscillation * envelope
			return Vector2(
				intensity * randf_range(-0.5, 0.5),
				intensity * randf_range(-0.5, 0.5) * shake.vertical_bias
			)
			
		ShakeType.RANDOM_RUMBLE:
			# Классический случайный шум с линейным затуханием
			var decay = shake.time_left / shake.duration
			return Vector2(
				randf_range(-shake.strength, shake.strength) * decay,
				randf_range(-shake.strength, shake.strength) * decay
			)
			
	return Vector2.ZERO

# Сброс всех активных трясок
func clear_shakes() -> void:
	active_shakes.clear()
	offset = Vector2.ZERO
	set_process(false)
