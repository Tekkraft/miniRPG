class_name UnitData
extends Resource

signal hpChanged
signal energyChanged

@export var unit_name : String
@export var unit_icon : Texture2D

@export var unit_class : UnitClass

@export var current_exp = 0
@export var current_level = 1

var hp = 100
@export var max_hp = 100

const starting_energy = 5

var energy = 5
var max_energy = 10

@export var stat_dict = {
	"STR": 10, # Physical Damage
	"DEF": 10, # Physical Defense
	"INT": 10, # Magical Damage
	"RES": 10, # Magical Defense
	"DEX": 10, # Accuracy + Crit
	"AGI": 10, # Initiative + Avoid/Crit Avoid
}

# Stats gained per level
@export var personal_growths_dict = {
	"STR": 1, # Physical Damage
	"DEF": 1, # Physical Defense
	"INT": 1, # Magical Damage
	"RES": 1, # Magical Defense
	"DEX": 1, # Accuracy + Crit
	"AGI": 1, # Initiative + Avoid/Crit Avoid
}


func _init():
	hp = max_hp


# Gets and returns the base stat of the unit
func get_stat(stat : String):
	assert(stat_dict.has(stat), "Unrecognized Stat")
	return stat_dict[stat]


func take_damage(damage):
	hp -= damage
	hp = max(hp, 0)
	emit_signal("hpChanged", hp)


func take_healing(healing):
	hp += healing
	hp = min(hp, max_hp)
	emit_signal("hpChanged", hp)


func use_energy(amount):
	energy -= amount
	energy = max(energy, 0)
	emit_signal("energyChanged", energy)


func gain_energy(amount):
	energy += amount
	energy = min(energy, max_energy)
	emit_signal("energyChanged", energy)


func get_current_hp():
	return hp


func get_max_hp():
	return max_hp


func get_hp_perc():
	return float(hp)/max_hp * 100

