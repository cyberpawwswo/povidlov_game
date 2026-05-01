extends CaterpillarState
@onready var ray_right: RayCast2D = $"../../../CanvasGroup/Rsegment/ray_right"

var bumped = false
var time = 0.0
var stretch_finish:bool = false
func enter_state():
	bumped = false
	stretch_finish = false
	time = 0.0
	if player.body.position != player.body_pos_right:
		player.body.position = player.body_pos_right
		player.global_position.x -= player.body_pos_right.x
	player.head.reparent(player.rsegment)
	player.head.position = Vector2.ZERO
	player.head.offset.x = 111
	player.head.flip_h = false
func update(delta: float):
	time += delta
	if ray_right.is_colliding():
		if ray_right.get_collider().is_in_group("wall"):
			stretch_finish = true
			bumped = true
	if Input.is_action_pressed("ui_right") and !stretch_finish:
		player.scale.x += 0.1 *delta*player.speed
	elif Input.is_action_just_released("ui_right"):
		stretch_finish = true
	if time >= player.stretch_limit:
		stretch_finish = true
	if stretch_finish:
		player.change_state(states.move_right)
