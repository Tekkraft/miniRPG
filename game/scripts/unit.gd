class_name Unit
extends Node2D

@export var unit_data : UnitData
@export var unit_class : UnitClass

var statuses = {}
# NOTE: Temp statuses are lost at end of turn and not drawn - use for VERY temporary buffs
var temp_statuses : Array[Status]

var player_unit = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setup(stats : UnitData, u_class : UnitClass, player : bool):
	unit_data = stats
	unit_class = u_class
	player_unit = player


func setup_from_stat(stats : UnitData):
	unit_data = stats
	unit_class = stats.unit_class
	player_unit = true


func is_player():
	return player_unit


func is_dead():
	return unit_data.get_current_hp() <= 0


func is_statused():
	return statuses.size() > 0


func add_status(new_status : Status, status_duration : int):
	if statuses.has(new_status):
		statuses[new_status] += status_duration
	else:
		statuses[new_status] = status_duration
	
	# TODO: Find optimizations
	draw_statuses()


func add_temp_status(new_status : Status):
	if not temp_statuses.has(new_status):
		temp_statuses.append(new_status)


func tick_down_status():
	temp_statuses.clear()
	
	for status in statuses.keys():
		statuses[status] -= 1
	
	for i in statuses.size():
		var status = statuses.keys()[statuses.size() - 1 - i]
		if statuses[status] <= 0:
			statuses.erase(status)
	
	draw_statuses()


func draw_statuses():
	get_node("StatusBox/StatusContainer").draw_statuses(statuses)


func get_stat(stat : String):
	var base_stat = unit_data.get_stat(stat)
	
	# Yes this looks super clunky. No I don't have a better idea
	for status in statuses.keys():
		for effect : StatusStep in status.effects:
			if effect.turn_category == StatusStep.TurnCategory.PASSIVE:
				if effect.passive_effect == StatusStep.PassiveEffect.CALC_STAT_CHANGE:
					if effect.calc_stat_changes.has(stat):
						base_stat += effect.calc_stat_changes[stat]
	
	for status in temp_statuses:
		for effect : StatusStep in status.effects:
			if effect.turn_category == StatusStep.TurnCategory.PASSIVE:
				if effect.passive_effect == StatusStep.PassiveEffect.CALC_STAT_CHANGE:
					if effect.calc_stat_changes.has(stat):
						base_stat += effect.calc_stat_changes[stat]
	
	return base_stat


func get_calc_stat(stat : String):
	var base_stat = 0
	
	match stat:
		"HIT":
			base_stat = get_stat("DEX") * 2
		"AVO":
			base_stat = get_stat("AGI") * 2
		"CRT":
			base_stat = get_stat("DEX")
		"EVA":
			base_stat = get_stat("AGI")
	
	# Yes this looks super clunky. No I don't have a better idea
	for status in statuses.keys():
		for effect : StatusStep in status.effects:
			if effect.turn_category == StatusStep.TurnCategory.PASSIVE:
				if effect.passive_effect == StatusStep.PassiveEffect.CALC_STAT_CHANGE:
					if effect.calc_stat_changes.has(stat):
						base_stat += effect.calc_stat_changes[stat]
	
	for status in temp_statuses:
		for effect : StatusStep in status.effects:
			if effect.turn_category == StatusStep.TurnCategory.PASSIVE:
				if effect.passive_effect == StatusStep.PassiveEffect.CALC_STAT_CHANGE:
					if effect.calc_stat_changes.has(stat):
						base_stat += effect.calc_stat_changes[stat]

	return base_stat


func get_damage_dealt_multiplier():
	var base_mult = 1
	
	# Yes this looks super clunky. No I don't have a better idea
	for status in statuses.keys():
		for effect : StatusStep in status.effects:
			if effect.turn_category == StatusStep.TurnCategory.PASSIVE:
				if effect.passive_effect == StatusStep.PassiveEffect.DMG_DEALT_MULTIPLIER:
					base_mult *= effect.damage_multiplier
	
	for status in temp_statuses:
		for effect : StatusStep in status.effects:
			if effect.turn_category == StatusStep.TurnCategory.PASSIVE:
				if effect.passive_effect == StatusStep.PassiveEffect.DMG_DEALT_MULTIPLIER:
					base_mult *= effect.damage_multiplier
	
	return base_mult


func get_damage_taken_multiplier():
	var base_mult = 1
	
	# Yes this looks super clunky. No I don't have a better idea
	for status in statuses.keys():
		for effect : StatusStep in status.effects:
			if effect.turn_category == StatusStep.TurnCategory.PASSIVE:
				if effect.passive_effect == StatusStep.PassiveEffect.DMG_TAKEN_MULTIPLIER:
					base_mult *= effect.damage_multiplier
	
	for status in temp_statuses:
		for effect : StatusStep in status.effects:
			if effect.turn_category == StatusStep.TurnCategory.PASSIVE:
				if effect.passive_effect == StatusStep.PassiveEffect.DMG_TAKEN_MULTIPLIER:
					base_mult *= effect.damage_multiplier
	
	return base_mult
