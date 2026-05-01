extends Control

@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CaterpillarGlobal.connect("leaf_eat", update_score)


func update_score():
	label.text = str(CaterpillarGlobal.leaves_eaten)
