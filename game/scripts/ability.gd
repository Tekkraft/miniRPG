class_name Ability
extends Resource

enum AbilityTargets {
	SELF,
	ALLY,
	ENEMY,
	ALL_ALLY,
	ALL_ENEMY,
	EVERYONE
}

@export var name: String
@export_multiline var description : String
@export var energy_cost : int
@export var hit := 999
@export var ability_target : AbilityTargets
@export var effects: Array[AbilityStep]
