extends Control
class_name LevelToLevel
signal change_scene

var animation_player: AnimationPlayer

func _ready() -> void:
	for i in get_children():
		if i is AnimationPlayer:
			animation_player = i
	animation_player.play('trn')


func transition_to_next_level():
	#print(next_level)
	#get_tree().change_scene_to_packed(next_level)
	change_scene.emit()
#	last_lvl.queue_free()
