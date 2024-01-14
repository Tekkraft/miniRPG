@tool
class_name EffectCondition
extends Resource

enum ConditionType {
	STATUS,
	HP_THRESHOLD
}

const preserved_fields = ["condition_type", "check_user"]

@export var condition_type : ConditionType :
	set(value):
		condition_type = value
		notify_property_list_changed()

@export var check_user := false

# Status condition fields
@export var has_status := true
@export var statuses : Array[Status]


# HP threshold fields
@export var above_threshold := true
@export var hp_percent : int


func _validate_property(property: Dictionary):
	# Match the step type for independent fields
	if property.name not in preserved_fields:
		match condition_type:
			ConditionType.STATUS:
				if property.name not in ["has_status", "statuses"]:
					property.usage = PROPERTY_USAGE_NO_EDITOR
			ConditionType.HP_THRESHOLD:
				if property.name not in ["above_threshold", "hp_percent"]:
					property.usage = PROPERTY_USAGE_NO_EDITOR

