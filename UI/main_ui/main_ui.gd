extends Control

@export var first_lvl: PackedScene
@export var change_scene: PackedScene

func _on_play_pressed() -> void:
	UI.change_level(first_lvl, "res://UI/level_to_level/black_scrin.tscn")
