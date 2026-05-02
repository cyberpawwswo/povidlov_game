extends CaterpillarState

@onready var ray_left: RayCast2D = $"../../../CanvasGroup/Lsegment/ray_left"
var bumped = false
var time = 0.0
var stretch_finish:bool = false
func enter_state():
	
	bumped = false
	time = 0.0
	stretch_finish = false
	if player.body.position != player.body_pos_left:
		player.body.position = player.body_pos_left
		player.global_position.x -= player.body_pos_left.x
	player.head.reparent(player.lsegment)
	player.head.position = Vector2.ZERO
	player.head.offset.x = -111
	player.head.flip_h = true
func exit_state():
	player.audio.stop()
func update(delta: float):
	player.audio.play()
	player.handle_gravity(delta)
	time += delta
	if ray_left.is_colliding():
		if ray_left.get_collider().is_in_group("wall"):
			stretch_finish = true
			bumped = true
	if Input.is_action_pressed("ui_left") and !stretch_finish:
		player.scale.x += 0.1 *delta*player.speed
	elif Input.is_action_just_released("ui_left"):
		stretch_finish = true
	if player.scale.x >= player.stretch_limit:
		stretch_finish = true
	if stretch_finish:
		player.change_state(states.move_left)
