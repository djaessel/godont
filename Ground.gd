extends StaticBody3D

var mobs = []
var finish = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var mobx = preload("res://moby.tscn")
	for n in 10:
		var m = mobx.instantiate()
		m.position.x = n * 2.5 - 10
		m.position.y = n
		m.position.z += 10
		mobs.push_back(m)
		add_child(m)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if finish:
		get_tree().quit()
	
	#var ground = get_node("SuperMesh")
	var player = get_parent().get_node("Player")
	for m in mobs:
		if m.position.y < -4.5:
			print("One jumped over! > ", m.get_instance_id())
			remove_child(m)
			mobs.erase(m)
	
	if not finish and len(mobs) <= 0:
		print("All enemies are dead!")
		finish = true
		
	if finish:
		print("Game Finished!")
		
