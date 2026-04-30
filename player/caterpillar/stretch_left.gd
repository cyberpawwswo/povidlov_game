extends CaterpillarState


func enter_state():
	if player.body.position != player.body_pos_left:
		player.body.position = player.body_pos_left
		player.global_position.x -= player.body_pos_left.x
func update(delta: float):
	if Input.is_action_pressed("ui_left"):
		player.scale.x += 0.1 *delta*player.speed
	elif Input.is_action_just_released("ui_left"):
		player.move_left()
		await player.tw.finished
		player.change_state(states.idle)

func exit_state():
	player.body.position = Vector2.ZERO
	player.global_position.x += player.body_pos_left.x
