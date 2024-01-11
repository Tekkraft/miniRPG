class_name InitiativeQueue
extends Node

var initiative_order = {}

const initiative_threshold = 100

func add_to_initiative(unit : Unit):
	initiative_order[unit] = 0


func remove_from_initiative(unit : Unit):
	initiative_order.erase(unit)


func step_initiative():
	#Advance initiative counts
	for unit in initiative_order:
		initiative_order[unit] += unit.unit_stats.get_stat("AGI")


func next_active_unit():
	for unit in initiative_order:
		if initiative_order[unit] >= initiative_threshold:
			initiative_order[unit] -= initiative_threshold
			return unit
	return null


func has_ready_unit():
	for unit in initiative_order:
		if initiative_order[unit] >= initiative_threshold:
			return true
	return false


func step_until_ready():
	while not has_ready_unit():
		step_initiative()
	(get_parent() as BattleHandler).set_active_unit(next_active_unit())
