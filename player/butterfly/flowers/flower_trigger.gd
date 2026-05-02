extends Node2D

var count := 0

var start_tween: Tween

var is_active := true

func _ready() -> void:
	global_rotation = 0
	for i in get_children():
		if i is CollisionShape2D:
			i.reparent($TriggerAnimation)

func _on_trigger_animation_body_entered(body: Node2D) -> void:
	if body is Butterfly and not $ProgressBar.visible and is_active:
		$ProgressBar.visible = true

		start_tween = create_tween()
		start_tween.tween_property($ProgressBar, 'value', 100, 2)
		#tween.custom_step(0.01)
		start_tween.connect('finished', tween_finished.bind(body))

func _on_trigger_animation_body_exited(body: Node2D) -> void:
	if body is Butterfly and is_active:
		start_tween.kill()
		var tween = create_tween()
		tween.tween_property($ProgressBar, 'value', 0, 0.5)
		#tween.custom_step(0.01)
		tween.connect('finished', tween_reset)

func tween_reset():
	$ProgressBar.visible = false

func tween_finished(player: Butterfly):
	player.chroma_point += get_parent().chroma_point
	$ProgressBar.visible = false
	$GPUParticles2D.emitting = false
	is_active = false
	print("as")
