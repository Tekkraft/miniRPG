extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setup(defeat_encounter):
	var game_over_detail = get_node("UILayer/GameOverUI/GameOverDetail") as Label
	game_over_detail.text = "You were defeated by:\n"
	for name in defeat_encounter.keys():
		game_over_detail.text += name + ": " + defeat_encounter[name]


func _on_restart_button_pressed():
	SceneHandler.change_state(SceneHandler.GameState.MAIN_MENU, null)
