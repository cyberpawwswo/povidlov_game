extends Node2D

@export var max_time: float
@export var min_time: float

@export var attack_height: float

@export var start_distance := 1000
@export var bird: PackedScene

@export var enable := true


@onready var timer := $Timer

var player: Butterfly

func _ready() -> void:
	for i in get_parent().get_children():
		if i is Butterfly:
			player = i
			break
	
	timer.wait_time = randf_range(min_time, max_time)
	timer.start()


#func get_position_for_notification(bd_pos: Vector2):
	#var viewport = get_viewport_rect()
	#print(viewport.position, " ", player.global_position)
	#var points = [viewport.position, Vector2(viewport.end.x, viewport.position.y), 
		#viewport.end, Vector2(viewport.position.x, viewport.end.y)]
	#var point: Vector2
	#for p in points.size()-1:
 		#point = Geometry2D.line_intersects_line(
			#points[p], points[p]-points[p+1], 
			#player.global_position, player.global_position-bd_pos
		#)
		#if point != null:
			#return point

func _on_timer_timeout() -> void:
	print("attack")
	if get_player_height() >= attack_height and enable:
		var vec_at = (Vector2.RIGHT*start_distance).rotated(randf_range(0, 2*PI))
		var start_pos = player.global_position + vec_at
		var bd = bird.instantiate() as Bird
		get_parent().add_child(bd)
		bd.global_position = start_pos
		bd.look_at(player.global_position)



func get_player_height() -> float:
	return attack_height
