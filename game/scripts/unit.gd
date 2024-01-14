class_name Unit
extends Node2D

@export var unit_stats : UnitStats
@export var unit_class : UnitClass

var statuses = Array[Status]

var player_unit = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setup(stats : UnitStats, u_class : UnitClass, player : bool):
	unit_stats = stats
	unit_class = u_class
	player_unit = player


func is_player():
	return player_unit


func is_dead():
	return unit_stats.get_current_hp() <= 0


func add_status(new_status : Status, status_duration : int):
	statuses.append(new_status)
