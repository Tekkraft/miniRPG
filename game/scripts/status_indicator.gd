extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setup(status : Status, duration):
	get_node("StatusIcon").texture = status.status_icon
	get_node("StatusDuration").text = str(duration)


func update_duration(new_duration):
	get_node("StatusDuration").text = str(new_duration)
