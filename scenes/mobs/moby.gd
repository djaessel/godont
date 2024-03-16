extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 5
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
# how long is it around
@export var cycles = 0
# can trigger eating
@export var triggerEating = false

@export var hasEaten = 0

var target_velocity = Vector3.ZERO

# jumping
var maxY = 5
var jumping = false

# shooting
var bullet = false

var eating = false
var timeout = 50


#func _ready():
#	get_node("ArnoldAnim").play()


func handleEating():
	var topText = get_node("TopText")
	if triggerEating:
		triggerEating = false
		eating = true
		get_node("ArnoldAnim").play()
		get_node("NoProblemo").play()
		topText.text = "Es isst"
		var spawnNew = preload("res://scenes/mobs/moby.tscn")
		var spawnNewX = spawnNew.instantiate()
		spawnNewX.position.x = position.x + 1
		spawnNewX.position.z = position.z + 1
		spawnNewX.position.y = 5
		get_parent().add_child(spawnNewX)
		await get_tree().create_timer(2).timeout
		get_node("ArnoldAnim").stop()
		if get_tree() != null: # safety since sometimes tree is null for some reason
			await get_tree().create_timer(3).timeout
		eating = false
		hasEaten += 1
	elif eating:
		target_velocity = Vector3.ZERO;
	else:
		topText.text = "Es ist " + str(cycles)


func handleBullet():
	if bullet:
		bullet = false
		var spawnNew = preload("res://scenes/missiles/bullet.tscn")
		var spawnNewX = spawnNew.instantiate()
		spawnNewX.position.x = position.x + 0.5
		spawnNewX.position.z = position.z + 0.5
		var velo = Vector3.ZERO
		#Unit vector pointing at the target position from the characters position
		var player = get_parent().get_node("Player")
		var direction = global_position.direction_to(player.global_position)
		velo = direction * speed
		velo.y += 1
		if velo != Vector3.ZERO:
			velo.normalized()
		spawnNewX.add_constant_force(velo, spawnNewX.global_position)
		spawnNewX.look_at(player.global_position)
		get_parent().add_child(spawnNewX)


func makingDecision():
	var direction = Vector3.ZERO

	if timeout <= 0:
		var randomx = randi_range(1,20)
		match randomx:
			11, 1: # move right
				direction.x += 55
			12, 2: # move left
				direction.x -= 55
			13, 3: # move back
				direction.z += 55
			14, 4: # move forward
				direction.z -= 55
			15, 5, 16, 6: # jump
				jumping = true
			17, 18, 19, 7, 8, 9: # bullet
				bullet = true
			#16, 6: # eat
			#	triggerEating = true
		timeout = 100
		cycles += 1
		
	return direction


func handleVelocity(direction, delta):
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Ground Velocity
		target_velocity.x = direction.x * speed
		target_velocity.z = direction.z * speed

	# Vertical Velocity
	if not is_on_floor() and not jumping: # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	elif jumping:
		target_velocity.y = target_velocity.y + (fall_acceleration * delta)
		jumping = true
		if position.y >= maxY:
			jumping = false


func handleMovement():
	velocity = target_velocity
	move_and_slide()


func _physics_process(delta):
	if not get_parent().finish:
		timeout -= 1
		
		# has to be called before the handling code
		var direction = makingDecision()
		
		handleEating()
		handleBullet()
		handleVelocity(direction, delta)
		handleMovement() # Moving the Character

