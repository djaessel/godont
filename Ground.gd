extends StaticBody3D

@export var finish = false
var force_finish = false
var oldest = -1
var youngest = 1000000
var mostEaten = -1
var foodEaten = 0
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


func createFinishLabel():
	var groundMesh = get_node("SuperMesh")
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
	finishLabel.text += "MostEaten: " + str(mostEaten) + "\n" 
	finishLabel.text += "Food eaten: " + str(foodEaten) + "\n"


func doFinshingCode():
	if force_finish:
		get_tree().quit()
	elif firstCallFinish:
		firstCallFinish = false
		
		if youngest >= 1000000:
			youngest = -1
		
		for m in getAllMobs():
			if mostEaten < m.hasEaten:
				mostEaten = m.hasEaten
			foodEaten += m.hasEaten
		
		var player = get_parent().get_node("Player")
		if player.dead and player.hp > 0:
			var groundMesh = get_node("SuperMesh")
			groundMesh.get_active_material(0).albedo_color = Color(0.9, 0.1, 0.1)
			for m in getAllMobs():
				m.get_node("HastaLaVista").play()
		
		if won:
			get_parent().get_node("won").play()
		else:
			get_parent().get_node("lost").play()
		
		createFinishLabel()



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
			get_node("oneDied").play()
			
			if m.cycles < youngest:
				youngest = m.cycles
			if m.cycles > oldest:
				oldest = m.cycles
			if mostEaten < m.hasEaten:
				mostEaten = m.hasEaten
			foodEaten += m.hasEaten
			
			remove_child(m)


func checkCollisions():
	var allMobs = getAllMobs()
	var player = get_parent().get_node("Player")
	for m in allMobs:
		for index in m.get_slide_collision_count():
			var collision = m.get_slide_collision(index)
			var body = collision.get_collider()
			if "Player" in body.name:
				while player.hp > 0:
					player.hit()
				if player.dead: # irrelevant
					finish = true
				m.get_node("GoodBye").play()
			elif "StaticBody3D" in body.name: # check later with sub nodes
				m.triggerEating = true
				remove_child(body)
	for index in player.get_slide_collision_count():
		var collision = player.get_slide_collision(index)
		var body = collision.get_collider()
		if "CharacterBody3D" in body.name: # check later with sub nodes
			player.hit()
			if player.dead:
				finish = true


func checkFinishConditions():
	if not finish:
		var player = get_parent().get_node("Player")
		if len(getAllMobs()) <= 0:
			won = true
			finish = true
		elif player.position.y < -5:
			player.dead = true
		else:
			checkCollisions()
		if player.dead:
			finish = true


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
	

