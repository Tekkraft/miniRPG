class_name Status
extends Resource

@export var status_name : String
@export var status_icon : Texture2D
@export_multiline var status_description : String

@export var passive_effects : Array[StatusStep]
@export var start_of_turn_effects : Array[StatusStep]
@export var end_of_turn_effects : Array[StatusStep]
