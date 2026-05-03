extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(3).timeout
	UI.change_level("res://player/cocoon/tutorial.tscn")
