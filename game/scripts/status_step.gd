@tool
class_name StatusStep
extends Resource

enum TurnCategory {
	PASSIVE,
	START_OF_TURN,
	END_OF_TURN
}

enum PassiveEffect {
	STAT_CHANGE,
	CALC_STAT_CHANGE,
	DMG_TAKEN_MULTIPLIER,
	DMG_DEALT_MULTIPLIER
}

enum TimedEffect {
	DAMAGE_OVER_TIME,
	HEALING_OVER_TIME
}

const preserved_fields = ["turn_category"]

# Shared variables
@export var turn_category := TurnCategory.PASSIVE:
	set(value):
		turn_category = value
		notify_property_list_changed()


@export var passive_effect := PassiveEffect.STAT_CHANGE:
	set(value):
		passive_effect = value
		notify_property_list_changed()


@export var timed_effect := TimedEffect.DAMAGE_OVER_TIME:
	set(value):
		timed_effect = value
		notify_property_list_changed()

#Stat change variables
@export var stat_changes = {
	"STR" : 0,
	"DEF" : 0,
	"INT" : 0,
	"RES" : 0,
	"DEX" : 0,
	"AGI" : 0
}


#Calc stat change variables
@export var calc_stat_changes = {
	"HIT" : 0,
	"AVO" : 0,
	"CRT" : 0,
	"EVA" : 0
}


#Damage multiplier variables (used for attack and defense)
@export var damage_multiplier = 0.0


#Damage over time variables
@export var damage_per_turn = 0


#Healing over time variables
@export var healing_per_turn = 0


func _validate_property(property: Dictionary):
	property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name in preserved_fields:
		property.usage = PROPERTY_USAGE_EDITOR
	
	# First show the correct selector for the turn category
	match turn_category:
		TurnCategory.PASSIVE:
			if property.name == "passive_effect":
				property.usage = PROPERTY_USAGE_EDITOR
		TurnCategory.START_OF_TURN, TurnCategory.END_OF_TURN:
			if property.name == "timed_effect":
				property.usage = PROPERTY_USAGE_EDITOR

	# Match the step type for independent fields
	if turn_category == TurnCategory.PASSIVE:
		match passive_effect:
			PassiveEffect.STAT_CHANGE:
				if property.name in ["stat_changes"]:
					property.usage = PROPERTY_USAGE_EDITOR
			PassiveEffect.CALC_STAT_CHANGE:
				if property.name in ["calc_stat_changes"]:
					property.usage = PROPERTY_USAGE_EDITOR
			PassiveEffect.DMG_TAKEN_MULTIPLIER:
				if property.name in ["damage_multiplier"]:
					property.usage = PROPERTY_USAGE_EDITOR
			PassiveEffect.DMG_DEALT_MULTIPLIER:
				if property.name in ["damage_multiplier"]:
					property.usage = PROPERTY_USAGE_EDITOR
	
	if turn_category in [TurnCategory.START_OF_TURN, TurnCategory.END_OF_TURN]:
		match timed_effect:
			TimedEffect.DAMAGE_OVER_TIME:
				if property.name in ["damage_per_turn"]:
					property.usage = PROPERTY_USAGE_EDITOR
			TimedEffect.HEALING_OVER_TIME:
				if property.name in ["healing_per_turn"]:
					property.usage = PROPERTY_USAGE_EDITOR
	
