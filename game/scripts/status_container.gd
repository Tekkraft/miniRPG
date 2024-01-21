extends HBoxContainer

var status_indicator = preload("res://scenes/ui/status_indicator.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func draw_statuses(statuses : Dictionary):
	# Clear old child nodes
	for i in get_child_count():
		var child = get_child(0)
		remove_child(child)
		child.queue_free()
	
	# Draw new child nodes
	for status in statuses.keys():
		var new_status = status_indicator.instantiate()
		new_status.setup(status, statuses[status])
		add_child(new_status)
