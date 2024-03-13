extends Area3D

@export var lifetime = 500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", _on_Area_body_entered)

func _on_Area_body_entered(body:Node) -> void:
	if "Player" in body.name:
		body.hit()
		if body.dead:
			get_parent().get_node("hit").play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	lifetime -= 1
	if lifetime <= 0:
		get_parent().get_parent().remove_child(get_parent())
