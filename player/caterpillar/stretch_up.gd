extends CaterpillarState

@onready var ray_right: RayCast2D = $"../../../CanvasGroup/Rsegment/ray_right"

var time = 0.0
var stretch_finish = false
var anim_finish = false
var bumped = false
func enter_state():
	
	time = 0.0
	stretch_finish = false
	bumped = false
	anim_finish = false
	player.animator.play("vert")
	player.head.reparent(player.rsegment)
	player.head.position = Vector2.ZERO
	player.head.offset.x = 111
	player.head.flip_h = false
	await player.animator.animation_finished
	anim_finish = true
func exit_state():
	player.audio.stop()
func update(delta: float):
	player.audio.play()
	if !stretch_finish:
		player.handle_gravity(delta)
	if !anim_finish:
		return
	time += delta
	if player.scale.x >= player.stretch_limit:
		stretch_finish = true
	if ray_right.is_colliding():
		if ray_right.get_collider().is_in_group("wall"):
			stretch_finish = true
			bumped = true
	
	if Input.is_action_pressed("ui_up") and !stretch_finish:
		player.scale.x += 0.1 *delta*player.speed
		$"../../../../CanvasLayer/Score/ProgressBar".value -= time*player.stretch_limit*1.35
	elif Input.is_action_just_released("ui_up") or !Input.is_action_pressed("ui_up"):
		stretch_finish = true
	if stretch_finish:
		player.change_state(states.move_up)
		#player.reset_tween()
		#player.tw.tween_property(player, "scale:x", 1, 0.3)
		#await player.tw.finished
		#player.change_state(states.idle)
	
