extends CaterpillarState


func enter_state():
	player.animator.play("vert")
	
func update(delta: float):
	if Input.is_action_pressed("ui_up"):
		player.scale.x += 0.1 *delta*player.speed
	elif Input.is_action_just_released("ui_up"):
		player.reset_tween()
		player.tw.tween_property(player, "scale:x", 1, 0.3)
		await player.tw.finished
		player.change_state(states.idle)
func exit_state():
	player.animator.play("horiz")
