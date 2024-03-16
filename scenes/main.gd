extends Node3D
class_name Main

@export var finish = false
var force_finish = false
var oldest = -1
var youngest = 1000000
var mostEaten = -1
var foodEaten = 0
var won = false
var runsCount = 0
var firstCallFinish = true

# settings for player
static var platformSize = 60.0 # meters
static var arnoldInit = 10
static var foodInit = 15


# Called when the node enters the scene tree for the first time.
func _ready():
	resetGameData()
	# Spawn initial stuff
	spawnInitialFood()
	spawnInitialMobs()


func resetGameData():
	var ground = get_node("Ground")
	ground.get_node("SuperMesh").get_active_material(0).albedo_color = Color(1.0, 1.0, 1.0)
	ground.scale.x = Main.platformSize / 60.0
	ground.scale.z = Main.platformSize / 60.0 # so they are still chained


func spawnInitialFood():
	var fx = preload("res://scenes/food1.tscn")
	var ground = get_node("Ground")
	for n in Main.foodInit:
		var f = fx.instantiate()
		f.position.x = randi_range(-20 * ground.scale.x, 20 * ground.scale.x)
		f.position.y = 2
		f.position.z += randi_range(-20 * ground.scale.x, 20 * ground.scale.x)
		add_child(f)


func spawnInitialMobs():
	var mobx = preload("res://scenes/moby.tscn")
	var ground = get_node("Ground")
	for n in Main.arnoldInit:
		var m = mobx.instantiate()
		m.position.x = randi_range(-20 * ground.scale.x, 20 * ground.scale.x) # n * 2.5 - 10
		m.position.y = n
		m.position.z += randi_range(5 * ground.scale.z, 15 * ground.scale.z)
		add_child(m)


func createFinishLabel():
	var groundMesh = get_node("Ground/SuperMesh")
	var finishLabel = get_node("FinishLabel")
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


func saveFinalState():
	var saveData = {
		"won": won,
		"oldest": oldest,
		"youngest": youngest,
		"mostEaten": mostEaten,
		"foodEaten": foodEaten,
	}
	
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("user://saveGames"):
		dir.make_dir("./saveGames")
		var file = FileAccess.open("user://saveGames/save0", FileAccess.WRITE)
		file.store_line("save version 1")
		file.close()
	
	var filex = FileAccess.open("user://saveGames/save0", FileAccess.READ_WRITE)
	filex.seek_end()
	filex.store_line(JSON.stringify(saveData))
	filex.close()


func doFinshingCode():
	if force_finish:
		queue_free()
	elif firstCallFinish:
		firstCallFinish = false
		
		if youngest >= 1000000:
			youngest = -1
		
		for m in getAllMobs():
			if mostEaten < m.hasEaten:
				mostEaten = m.hasEaten
			foodEaten += m.hasEaten
		
		var player = get_node("Player")
		if player.dead and player.hp > 0:
			var groundMesh = get_node("Ground/SuperMesh")
			groundMesh.get_active_material(0).albedo_color = Color(0.9, 0.1, 0.1)
			for m in getAllMobs():
				m.get_node("HastaLaVista").play()
		
		if won:
			get_node("won").play()
		else:
			get_node("lost").play()
		
		createFinishLabel()
		saveFinalState()



func getAllFood():
	var foods = []
	for c in get_children():
		if c.get_node_or_null("FoodSprite1") != null: # later with group or class
			foods.push_back(c)
	return foods


func getAllMobs():
	var mobs = []
	for m in get_children():
		if m.get_node_or_null("ArnoldAnim") != null: # later with group or class
			mobs.push_back(m)
	return mobs


func checkFallOver():
	for m in getAllMobs():
		if m.position.y < -5:
			get_node("Ground/oneDied").play()
			
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
	var player = get_node("Player")
	for m in allMobs:
		for index in m.get_slide_collision_count():
			var collision = m.get_slide_collision(index)
			var body = collision.get_collider()
			if body != null:
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
		if body != null:
			if "CharacterBody3D" in body.name: # check later with sub nwwwodes
				player.hit()
				if player.dead:
					finish = true


func checkFinishConditions():
	if not finish:
		var player = get_node("Player")
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
		get_tree().root.get_node("MainMenu").show()
	

