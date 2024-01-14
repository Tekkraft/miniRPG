@tool
class_name AbilityStep
extends Resource

enum StepType {
	DAMAGE,
	HEALING,
	CHARGE,
	STATUS,
	ANIMATION,
	WAIT,
	COMMENT,
	BOOST
}

const preserved_fields = ["step_type", "conditions", "independent_hit", "hit_rate"]

# Shared variables
@export var step_type := StepType.DAMAGE:
	set(value):
		step_type = value
		notify_property_list_changed()

@export var conditions : Array[EffectCondition]

@export var independent_hit := false:
	set(value):
		independent_hit = value
		notify_property_list_changed()
@export var hit_rate : int


# Damage step variables
@export var damage : int
@export var damage_type : DamageCalculator.DamageType


# Healing step variables
@export var healing : int


# Healing step variables
@export var charge : int


# Status step variables
@export var status : Status
@export var status_duration : int


# Animation step variables
@export var animation : String


# Wait step variables
@export var time : float


# Comment step variables
@export_multiline var comment : String


# Boost step variables
@export var boost_amount : int


func _validate_property(property: Dictionary):
	# Only display independent hit if checked
	if property.name in ["hit_rate"] and not independent_hit:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	
	# Match the step type for independent fields
	if property.name not in preserved_fields:
		match step_type:
			StepType.DAMAGE:
				if property.name not in ["damage", "damage_type"]:
					property.usage = PROPERTY_USAGE_NO_EDITOR
			StepType.HEALING:
				if property.name not in ["healing"]:
					property.usage = PROPERTY_USAGE_NO_EDITOR
			StepType.CHARGE:
				if property.name not in ["charge"]:
					property.usage = PROPERTY_USAGE_NO_EDITOR
			StepType.STATUS:
				if property.name not in ["status", "status_duration"]:
					property.usage = PROPERTY_USAGE_NO_EDITOR
			StepType.ANIMATION:
				if property.name not in ["animation"]:
					property.usage = PROPERTY_USAGE_NO_EDITOR
			StepType.WAIT:
				if property.name not in ["time"]:
					property.usage = PROPERTY_USAGE_NO_EDITOR
			StepType.COMMENT:
				if property.name not in ["comment"]:
					property.usage = PROPERTY_USAGE_NO_EDITOR
			StepType.BOOST:
				if property.name not in ["boost_amount"]:
					property.usage = PROPERTY_USAGE_NO_EDITOR
	
