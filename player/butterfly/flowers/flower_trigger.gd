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
		#player.velocity = Tween.interpolate_value(
			#player.get_real_velocity(), 
			#player.get_real_velocity()-player.global_position.direction_to(global_position),
			#_time,
			#1,
			#Tween.TRANS_ELASTIC,
			#Tween.EASE_IN
		#)
		


func _on_trigger_animation_body_entered(body: Node2D) -> void:
	if body is Butterfly:
		#var tween = create_tween()
		#tween.set_trans(Tween.TRANS_CUBIC)
		#tween.tween_property(body, 'velocity', body.global_position.direction_to(self.global_position)*100, 0.5)
		#tween.tween_property(body, 'global_position', self.global_position, 1)


		_is_pollinates = true
		player = body
		player.is_pollinates = true
		#body.velocity *= 0

func finished_pollinates():
	#player.is_pollinates = false
	print(player)


func _on_stop_animation_body_entered(body: Node2D) -> void:
	if body is Butterfly:
		player.is_pollinates = false
		_is_pollinates = false
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(body, 'velocity', Vector2.ZERO, 0.5)
		_time = 0
