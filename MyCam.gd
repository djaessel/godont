extends Camera3D

var differ = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	get_window().size = DisplayServer.screen_get_size() 
	
	var player = get_parent().get_node("Player")
	differ = position.y - player.position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = get_parent().get_node("Player")
	if not player.dead:
		position.x = player.position.x
		position.y = player.position.y + differ * 2
	else:
		position.x = 0
		position.y = 10
	