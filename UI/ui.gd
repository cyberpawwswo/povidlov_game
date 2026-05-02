extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100


func change_level(next_lvl, scene_change_path, action: Callable = _empty) -> void:
	var changer_node = null

	if scene_change_path is String:
		changer_node = (load(scene_change_path) as PackedScene).instantiate()
	elif scene_change_path is PackedScene:
		changer_node = scene_change_path.instantiate()
	elif scene_change_path is Node:
		changer_node = scene_change_path
	else:
		printerr('scene_change_path должен быть String, PackedScene или Node')
		return

	if not changer_node.has_signal('change_scene'):
		printerr(scene_change_path, ' должен иметь сигнал change_scene')
		return

	add_child(changer_node)
	await changer_node.change_scene

	if next_lvl is String:
		get_tree().change_scene_to_file(next_lvl)
	elif next_lvl is Node:
		get_tree().change_scene_to_node(next_lvl)
	elif next_lvl is PackedScene:
		get_tree().change_scene_to_packed(next_lvl)
	else:
		printerr('next_lvl должен быть String, Node или PackedScene')
		return

	action.call()

func _empty() -> void:
	pass
