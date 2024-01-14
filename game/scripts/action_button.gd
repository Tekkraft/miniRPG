class_name ActionButton
extends PanelContainer

signal actionSelected

var action

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setup(new_action):
	(get_node("ActionSelect") as Button).text = new_action.name
	action = new_action


func _on_action_select_pressed():
	emit_signal("actionSelected", action)
