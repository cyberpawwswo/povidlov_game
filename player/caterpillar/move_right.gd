extends CaterpillarState


func enter_state():
	player.move_right()
	await player.tw.finished
	player.change_state(states.idle)
	

func exit_state():
	player.body.position = Vector2.ZERO
	player.global_position.x += player.body_pos_right.x
