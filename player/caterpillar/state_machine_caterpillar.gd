extends Node

@onready var idle: CaterpillarState = $idle
@onready var stretch_right: CaterpillarState = $stretch_right
@onready var stretch_left: Node = $stretch_left
@onready var stretch_up: Node = $stretch_up
@onready var move_right: Node = $move_right
@onready var move_left: Node = $move_left
@onready var move_up: Node = $move_up
@onready var fall: Node = $fall
@onready var die: Node = $die
@onready var pupa: Node = $pupa
