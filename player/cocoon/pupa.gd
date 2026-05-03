extends Node2D

signal hp_changed(current: int, max_hp: int)
signal damaged(amount: int, current: int, max_hp: int)
signal died

@export var max_hp := 100

var hp := 100
var _dead := false

@onready var hp_bar: ProgressBar = $HpBar


func _ready() -> void:
	hp = max_hp
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = hp
	hp_changed.emit(hp, max_hp)


func take_damage(amount: int) -> void:
	if amount <= 0 or _dead:
		return
	hp -= amount
	if hp < 0:
		hp = 0
	damaged.emit(amount, hp, max_hp)
	hp_changed.emit(hp, max_hp)
	if hp_bar:
		hp_bar.value = hp
	if hp <= 0:
		_dead = true
		died.emit()
