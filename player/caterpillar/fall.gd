extends CaterpillarState


func update(delta: float):
	player.handle_gravity(delta*2)
	if player.is_on_floor():
		player.change_state(states.idle)
