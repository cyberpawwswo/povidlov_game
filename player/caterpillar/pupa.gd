extends CaterpillarState
@onready var caterpillar_container: Node2D = $"../../.."
@onready var canvas_group: CanvasGroup = $"../../../CanvasGroup"
@onready var caterpillar: Caterpillar = $"../.."


func enter_state():
	caterpillar_container.global_position = caterpillar.global_position
	caterpillar.position = Vector2.ZERO
	canvas_group.position = Vector2.ZERO
	if player.scale.x != 1.0:
		player.reset_scale()
		await get_tree().create_timer(0.5).timeout
		pupa()
	else:
		pupa()
	#if player.current_state == states.stretch_right:
		#player.change_state(states.move_right)
		#await get_tree().create_timer(1).timeout
		#pupa()
	#elif player.current_state == states.move_right:
		#await get_tree().create_timer(1).timeout
		#pupa()
	#else:
		#pupa()

func update(delta: float):
	player.handle_gravity(delta)
func pupa():
	player.cutscene = true
	player.animator.play("vert")
	await player.animator.animation_finished
	player.reset_tween()
	player.tw.tween_property($"../../../CanvasGroup","scale:x", 1.25, 0.5)
	player.tw.parallel().tween_property($"../../../CanvasGroup", "scale:y",0.5,0.5)
	player.tw.tween_property($"../../../CanvasGroup", "scale:y",1.25,1)
	player.tw.parallel().tween_property($"../../../CanvasGroup", "scale:x",0.5,1)
	player.tw.tween_property($"../../../CanvasGroup", "scale:y",0.4,0.5)
	player.tw.parallel().tween_property($"../../../CanvasGroup", "scale:x",1.6,0.5)
	await get_tree().create_timer(1.8).timeout
	$"../../../CanvasGroup".set_deferred("visible", false)
	$"../../../pupa_sprite".global_position = player.global_position+Vector2(0, -50)
	$"../../../pupa_sprite".set_deferred("visible",true)
	await get_tree().create_timer(2).timeout
	UI.change_level("res://player/cocoon/tutorial.tscn")
