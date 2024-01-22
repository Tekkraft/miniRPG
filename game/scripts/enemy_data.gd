class_name EnemyData
extends UnitData

@export var spectrum_threshold = 5
@export var exp_yield = 25

# NOTE: Call this function only ONCE
func autolevel_unit(target_level):
	current_level = target_level
	var level_difference = target_level - 1
	for i in level_difference:
		if i % 5 == 0:
			for stat in stat_dict.keys():
				stat_dict[stat] += 1
		for stat in stat_dict.keys():
			stat_dict[stat] += personal_growths_dict[stat]
		max_hp += stat_dict["DEF"] + stat_dict["RES"]/2
	
	hp = max_hp

func calculate_exp_gain(player_level):
	var multiplier = float(current_level)/player_level
	return ceili(multiplier * exp_yield)
