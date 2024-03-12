extends StaticBody3D

@export var finish = false
var force_finish = false
var oldest = 0
var youngest = 1000000
var won = false
var runsCount = 0
var firstCallFinish = true

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().get_node("backgroundMusic").play()
	# Spawn initial stuff
	spawnInitialFood()
	spawnInitialMobs()


func spawnInitialFood():
	var fx = preload("res://food1.tscn")
	for n in 20:
		var f = fx.instantiate()
		f.position.x = randi_range(-20, 20)
		f.position.y = 2
		f.position.z += randi_range(-20, 20)
		add_child(f)


func spawnInitialMobs():
	var mobx = preload("res://moby.tscn")
	for n in 10:
		var m = mobx.instantiate()
		m.position.x = randi_range(-20, 20) # n * 2.5 - 10
		m.position.y = n
		m.position.z += randi_range(5, 15)
		add_child(m)


func doFinshingCode():
	if force_finish:
		get_tree().quit()
	elif firstCallFinish:
		firstCallFinish = false
		
		var groundMesh = get_node("SuperMesh")
		var player = get_parent().get_node("Player")
		if player.dead:
			groundMesh.get_active_material(0).albedo_color = Color(0.9, 0.1, 0.1)
			for m in getAllMobs():
				m.get_node("HastaLaVista").play()
		
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
		finishLabel.text += "Food left: " + str(len(getAllFood())) + "\n"
		finishLabel.text += "Runs: " + str(runsCount) + "\n"


func getAllFood():
	var foods = []
	for c in get_children():
		if c.get_node_or_null("FoodSprite1") != null:
			foods.push_back(c)
	return foods


func getAllMobs():
	var mobs = []
	for m in get_children():
		if m.get_node_or_null("ArnoldAnim") != null:
			mobs.push_back(m)
	return mobs


func checkFallOver():
	for m in getAllMobs():
		if m.position.y < -5:
			if m.cycles < youngest:
				youngest = m.cycles
			if m.cycles > oldest:
				oldest = m.cycles
			#print("One jumped over! > ", m.get_instance_id(), " | Cycles: ", m.cycles)
			remove_child(m)


func checkCollisions():
	var allMobs = getAllMobs()
	for m in allMobs:
		for index in m.get_slide_collision_count():
			var collision = m.get_slide_collision(index)
			var body = collision.get_collider()
			if "Player" in body.name:
				finish = true
				m.get_node("Excellent").play()
			elif "StaticBody3D" in body.name:
				m.triggerEating = true
				remove_child(body)
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
			#print("All enemies are dead!")
			won = true
			finish = true
		elif player.position.y < -5:
			#print("You are dead!")
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
	

