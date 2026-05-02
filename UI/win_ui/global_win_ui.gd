extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_restart_pressed() -> void:
	UI.change_level("res://player/caterpillar/caterpillar_test.tscn")


func _on_main_ui_pressed() -> void:
	UI.change_level("res://UI/main_ui/main_ui.tscn")
