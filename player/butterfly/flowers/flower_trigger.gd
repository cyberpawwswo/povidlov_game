extends Node2D

var count := 0

var start_tween: Tween

func _on_trigger_animation_body_entered(body: Node2D) -> void:
	if body is Butterfly and not $ProgressBar.visible:
		$ProgressBar.visible = true

		start_tween = create_tween()
		start_tween.tween_property($ProgressBar, 'value', 100, 2)
		#tween.custom_step(0.01)
		start_tween.connect('finished', tween_finished.bind(body))

func _on_trigger_animation_body_exited(body: Node2D) -> void:
	if body is Butterfly:
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
	print("as")
