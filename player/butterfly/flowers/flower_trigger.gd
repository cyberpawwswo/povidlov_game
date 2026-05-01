extends Node2D

var _is_pollinates := false
var player: Butterfly

var _time := 0.0

func _physics_process(delta: float) -> void:
	if _is_pollinates:
		_time += delta
		player.velocity = lerp(
			player.get_real_velocity(),
			player.global_position.direction_to(global_position)*200,
			delta
		)

		


func _on_trigger_animation_body_entered(body: Node2D) -> void:
	if body is Butterfly:
		_is_pollinates = true
		player = body
		player.is_pollinates = true

func finished_pollinates():
	print(player)


func _on_stop_animation_body_entered(body: Node2D) -> void:
	if body is Butterfly:
		player.is_pollinates = false
		_is_pollinates = false
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(body, 'velocity', Vector2.ZERO, 0.5)
		_time = 0
