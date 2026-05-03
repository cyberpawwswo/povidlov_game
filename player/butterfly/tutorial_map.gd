extends Node2D

var change := true

func _process(delta: float) -> void:
	if get_tree().get_nodes_in_group('flower_trigger').all(triger_is_active) and change:
		UI.change_level("res://player/butterfly/test_map.tscn")
		change = false


func triger_is_active(trigger):
	return not trigger.is_active
