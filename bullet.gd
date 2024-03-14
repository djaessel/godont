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
			if get_tree() != null:
				get_tree().create_timer(1).timeout
		get_parent().queue_free() # directly removes (bullet) node

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	lifetime -= 1
	if lifetime <= 0:
		get_parent().queue_free() # directly removes (bullet) node
