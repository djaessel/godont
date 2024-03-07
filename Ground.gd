extends StaticBody3D

@export var finish = false
var force_finish = false
var oldest = 0
var youngest = 1000000
var won = false
var runsCount = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().get_node("backgroundMusic").play()
	
	var mobx = preload("res://moby.tscn")
	for n in 10:
		var m = mobx.instantiate()
		m.position.x = n * 2.5 - 10
		m.position.y = n
		m.position.z += 10
		add_child(m)


func doFinshingCode():
	if force_finish:
		get_tree().quit()
	
	var groundMesh = get_node("SuperMesh")
	var player = get_parent().get_node("Player")
	if player.dead:
		groundMesh.get_active_material(0).albedo_color = Color(0.9, 0.1, 0.1)
	
	var finishLabel = get_parent().get_node("FinishLabel")
	if won:
		finishLabel.text = "You WON!\n"
		groundMesh.get_active_material(0).albedo_color = Color(0.1, 0.5, 0.1)
	else:
		finishLabel.text = "You LOST!\n"
		finishLabel.modulate = Color(1.0, 0.2, 0.0)
		groundMesh.get_active_material(0).albedo_color = Color(0.5, 0.1, 0.1)
	finishLabel.text += "Oldest: " + str(oldest) + "\n"
	finishLabel.text += "Youngest: " + str(youngest) + "\n"
	finishLabel.text += "Runs: " + str(runsCount) + "\n"


func getAllMobs():
	var mobs = []
	for m in get_children():
		if m.get_node_or_null("MobyMesh") != null:
			mobs.push_back(m)
	return mobs


func checkFallOver():
	for m in getAllMobs():
		if m.position.y < -5:
			if m.cycles < youngest:
				youngest = m.cycles
			if m.cycles > oldest:
				oldest = m.cycles
			print("One jumped over! > ", m.get_instance_id(), " | Cycles: ", m.cycles)
			remove_child(m)


func checkCollisions():
	var allMobs = getAllMobs()
	for m in allMobs:
		for index in m.get_slide_collision_count():
			var collision = m.get_slide_collision(index)
			var body = collision.get_collider()
			if body.name == "Player":
				finish = true
	var player = get_parent().get_node("Player")
	for index in player.get_slide_collision_count():
		var collision = player.get_slide_collision(index)
		var body = collision.get_collider()
		if "CharacterBody3D" in body.name:
			finish = true


func checkFinishConditions():
	if not finish:
		var player = get_parent().get_node("Player")
		if len(getAllMobs()) <= 0:
			print("All enemies are dead!")
			won = true
			finish = true
		elif player.position.y < -5:
			print("You are dead!")
			player.dead = true
			finish = true
		else:
			checkCollisions()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if finish:
		doFinshingCode()
	else:
		checkFallOver()
		checkFinishConditions()
		runsCount += 1
	
	if Input.is_action_pressed("exit"):
		finish = true
		force_finish = true
	

