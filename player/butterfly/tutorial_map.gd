extends Node2D

var change := true

func _ready() -> void:
	pulse_labels()

func _process(delta: float) -> void:
	if get_tree().get_nodes_in_group('flower_trigger').all(triger_is_active) and change:
		UI.change_level("res://player/butterfly/test_map.tscn")
		change = false


func triger_is_active(trigger):
	return not trigger.is_active

func pulse_labels():
	var label = $ChromaLabel
	var labelR = $FrogLabel

	var _pulse_tween = create_tween()
	_pulse_tween.set_loops()
	_pulse_tween.tween_property(label, "scale", Vector2(1.05, 1.05), 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	_pulse_tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var _pulse_tween_R = create_tween().set_loops()
	_pulse_tween_R.tween_property(labelR, "scale", Vector2(1.05, 1.05), 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pulse_tween_R.tween_property(labelR, "scale", Vector2(1.0, 1.0), 0.6)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
