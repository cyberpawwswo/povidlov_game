extends CaterpillarState
@onready var canvas_group: CanvasGroup = $"../../../CanvasGroup"
@onready var container: Node2D = $"../../.."

func enter_state():
	%head.rotation = 0
		#for i in canvas_group.get_children():
			#var tw = create_tween().set_trans(Tween.TRANS_BOUNCE)
			#var init_scale = i.scale
			#tw.tween_property(i,"scale:x", (i.scale.x*1.5), 0.1)
			#tw.parallel().tween_property(i, "scale:y", (i.scale.y*0.5),0.05)
			#tw.tween_property(i,"scale", init_scale, 0.05)
			#i.scale = init_scale
	

func update(delta):
	player.handle_gravity(delta)
	if player.is_on_floor() and !player.animator.is_playing():
		if Input.is_action_pressed("ui_right"):
			player.change_state(states.stretch_right)
		elif Input.is_action_pressed("ui_left"):
			player.change_state(states.stretch_left)
		elif Input.is_action_pressed("ui_up"):
			player.change_state(states.stretch_up)
	if !player.is_on_floor():
		player.change_state(states.fall)
