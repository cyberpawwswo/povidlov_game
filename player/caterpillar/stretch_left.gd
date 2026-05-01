extends CaterpillarState

var time = 0.0
var stretch_finish:bool = false
func enter_state():
	time = 0.0
	stretch_finish = false
	if player.body.position != player.body_pos_left:
		player.body.position = player.body_pos_left
		player.global_position.x -= player.body_pos_left.x
	player.head.reparent(player.lsegment)
	player.head.position = Vector2.ZERO
	player.head.offset.x = -111
	player.head.flip_h = true
func update(delta: float):
	time += delta
	if Input.is_action_pressed("ui_left") and !stretch_finish:
		player.scale.x += 0.1 *delta*player.speed
	elif Input.is_action_just_released("ui_left"):
		stretch_finish = true
	if time >= player.stretch_limit:
		player.change_state(states.move_left)
