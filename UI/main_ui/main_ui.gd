extends Control

const _BLACK_SCRIN := "res://UI/level_to_level/black_scrin.tscn"

@export var first_lvl: PackedScene
@export var level_2: PackedScene
@export var level_3: PackedScene
@export var change_scene: PackedScene

@onready var _main_menu: Control = $MainMenuScreen
@onready var _level_select: Control = $LevelSelectScreen


func _ready() -> void:
	get_tree().paused = false


func _transition_path() -> String:
	if change_scene != null:
		return change_scene.resource_path
	return _BLACK_SCRIN


func _on_play_pressed() -> void:
	UI.change_level(first_lvl, _transition_path())


func _on_choose_level_pressed() -> void:
	_main_menu.visible = false
	_level_select.visible = true


func _on_back_pressed() -> void:
	_level_select.visible = false
	_main_menu.visible = true


func _on_level_1_pressed() -> void:
	UI.change_level(first_lvl, _transition_path())


func _on_level_2_pressed() -> void:
	UI.change_level(level_2, _transition_path())


func _on_level_3_pressed() -> void:
	UI.change_level(level_3, _transition_path())
