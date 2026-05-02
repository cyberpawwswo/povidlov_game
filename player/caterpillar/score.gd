extends Control

@onready var label: Label = $Label
@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var hp_2: TextureProgressBar = $hp2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CaterpillarGlobal.connect("leaf_eat", update_score)
	#update_score()

func update_score():
	#label.text = str(CaterpillarGlobal.leaves_eaten)
	progress_bar.value += 1
	#progress_bar.value = CaterpillarGlobal.leaves_eaten
func update_health():
	var tw = create_tween()
	tw.tween_property(hp_2, "value", $"../../caterpillar_container/caterpillar".HP, 0.1)
