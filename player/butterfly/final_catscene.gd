extends Control

var a = 0.0

# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	if a == 0:
		var tween = create_tween()
		tween.tween_property(self, 'a', 10, 2)
		tween.tween_property($HBoxContainer/TextureRect3, 'modulate:a', 1, 1)
		tween.tween_property($HBoxContainer/TextureRect, 'modulate:a', 1, 1)
		tween.tween_property($HBoxContainer/TextureRect2, 'modulate:a', 1, 1)
		await tween.finished
		UI.change_level("res://UI/win_ui/global_win_ui.tscn")
		print('as')
