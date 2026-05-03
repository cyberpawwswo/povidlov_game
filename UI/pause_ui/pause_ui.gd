extends CanvasLayer

@onready var lvl_to_lvl = preload('res://UI/level_to_level/black_scrin.tscn')

var is_lose := false

func _ready() -> void:
	hide()

func request_open_pause() -> void:
	if get_tree().current_scene == null or get_tree().current_scene.name == "MainUI":
		return
	if get_tree().paused:
		return
	get_tree().paused = true
	show()
	if not is_lose:
		%Continue.visible = true
		%PauseName.text = "Пауза"


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_pause"):
		if get_tree().current_scene == null or get_tree().current_scene.name == "MainUI":
			return
		if not get_tree().paused:
			request_open_pause()
		else:
			get_tree().paused = false
			hide()
	if not is_lose and not %Continue.visible:
		%Continue.visible = true
		%PauseName.text = 'Пауза'

func open_lose_ui():
	is_lose = true
	
	%Continue.visible = false
	%PauseName.text = 'Ты проиграл...'
	
	show()
	get_tree().paused = true

func _on_continue_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	UI.change_level("res://UI/main_ui/main_ui.tscn", lvl_to_lvl.resource_path, hide)


func _on_restart_level_pressed() -> void:
	UI.change_level(null, lvl_to_lvl.resource_path, reload_current_scene)

func reload_current_scene():
	hide()
	get_tree().paused = false
	get_tree().reload_current_scene()
	print('ass')


func _on_visibility_changed() -> void:
	if not visible:
		is_lose = false
