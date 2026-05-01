extends CaterpillarState

@onready var ray_right: RayCast2D = $"../../../CanvasGroup/Rsegment/ray_right"

var time = 0.0
var stretch_finish = false
var bumped = false
func enter_state():
	time = 0.0
	stretch_finish = false
	bumped = false
	player.animator.play("vert")
	player.head.reparent(player.rsegment)
	player.head.position = Vector2.ZERO
	player.head.offset.x = 111
	player.head.flip_h = false
func update(delta: float):
	time += delta

	if time >= player.stretch_limit:
		stretch_finish = true
	if ray_right.is_colliding():
		if ray_right.get_collider().is_in_group("wall"):
			stretch_finish = true
			bumped = true
	player.handle_gravity(delta)
	if Input.is_action_pressed("ui_up") and !stretch_finish:
		player.scale.x += 0.1 *delta*player.speed
	elif Input.is_action_just_released("ui_up"):
		stretch_finish = true
	if stretch_finish:
		player.change_state(states.move_up)
		#player.reset_tween()
		#player.tw.tween_property(player, "scale:x", 1, 0.3)
		#await player.tw.finished
		#player.change_state(states.idle)
	
