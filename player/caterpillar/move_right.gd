extends CaterpillarState


@onready var stretch_state: Node = $"../stretch_right"

func enter_state():
	if !stretch_state.bumped:
		player.move_right()
		await player.tw.finished
		player.change_state(states.idle)
	else:
		player.reset_scale()
		await player.tw.finished
		player.change_state(states.idle)

func exit_state():
	player.body.position = Vector2.ZERO
	player.global_position.x += player.body_pos_right.x
