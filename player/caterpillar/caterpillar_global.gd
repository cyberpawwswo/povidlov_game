extends Node
signal leaf_eat
var leaves_eaten:int = 0



func add_leaf(value):
	leaves_eaten += value
	emit_signal("leaf_eat")
