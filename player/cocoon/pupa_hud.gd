extends CanvasLayer

@onready var hp_label: Label = $Root/VBox/HP
@onready var dmg_label: Label = $Root/VBox/Damage

@export var pupa_path: NodePath = ^"../Pupa"


func _ready() -> void:
	var pupa := get_node_or_null(pupa_path) as Node
	if pupa == null:
		return
	if pupa.has_signal("hp_changed"):
		pupa.hp_changed.connect(_on_hp_changed)
	if pupa.has_signal("damaged"):
		pupa.damaged.connect(_on_damaged)
	# initial read (in case _ready on Pupa already ran)
	if pupa.get("max_hp") != null and pupa.get("hp") != null:
		_on_hp_changed(pupa.get("hp"), pupa.get("max_hp"))


func _on_hp_changed(current: int, maxhp: int) -> void:
	hp_label.text = "Pupa HP: %d / %d" % [current, maxhp]


func _on_damaged(amount: int, _current: int, _maxhp: int) -> void:
	dmg_label.text = "Last damage: %d" % [amount]
