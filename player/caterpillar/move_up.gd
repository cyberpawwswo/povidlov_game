extends CaterpillarState


func enter_state():
	player.global_position = player.right_end.global_position
	player.body.position.x = -18 
	player.reset_tween()
	player.tw.tween_property(player, "scale:x", 1, 0.3)
	await player.tw.finished
	player.change_state(states.idle)
func exit_state():
	player.animator.play("horiz")
