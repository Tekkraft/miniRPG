class_name UnitStats
extends Resource

signal hpChanged

var hp = 120
@export var max_hp = 120

@export var current_exp = 0
@export var current_level = 1

@export var stat_dict = {
	"STR": 10, # Physical Damage
	"DEF": 10, # Physical Defense
	"INT": 10, # Magical Damage
	"RES": 10, # Magical Defense
	"DEX": 10, # Accuracy + Crit
	"AGI": 10, # Initiative + Avoid/Crit Avoid
	"FOR": 10  # Hitpoints
}


func _init():
	hp = max_hp


# Gets and returns the base stat of the unit
func get_stat(stat : String):
	assert(stat_dict.has(stat), "Unrecognized Stat")
	return stat_dict[stat]


func take_damage(damage):
	hp -= damage
	if hp <= 0:
		hp = 0
	emit_signal("hpChanged", hp)


func get_current_hp():
	return hp


func get_max_hp():
	return max_hp

