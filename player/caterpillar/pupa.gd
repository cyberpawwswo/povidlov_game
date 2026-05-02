extends CaterpillarState


func enter_state():
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
	UI.change_level("res://player/cocoon/Cocoon_defence.tscn")
