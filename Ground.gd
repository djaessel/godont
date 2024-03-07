extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var playerx = preload("res://player.tscn")
	for n in 10:
		var px = playerx.instantiate()
		px.position.x = n
		px.position.y = n
		add_child(px)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
