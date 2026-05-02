extends CaterpillarState

@onready var stretch_state: Node = $"../stretch_up"

func enter_state():

	if !stretch_state.bumped:
		player.global_position = player.right_end.global_position
		player.body.position.x = -18 
		player.reset_tween()
		player.tw.tween_property(player, "scale:x", 1, 0.3)
		await player.tw.finished
		player.change_state(states.idle)
	else:
		player.reset_scale()
		await player.tw.finished
		player.change_state(states.idle)

func exit_state():
	player.animator.play("horiz")
