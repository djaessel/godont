extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 5
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
# how long is it around
@export var cycles = 0

var target_velocity = Vector3.ZERO

var maxY = 0.15
var jumping = false
var eating = false
var timeout = 50


func handleEating():
	if eating:
		eating = false
		var topText = get_node("TopText")
		topText.text = "Es isst"
		var spawnNew = preload("res://moby.tscn")
		var spawnNewX = spawnNew.instantiate()
		spawnNewX.position.x = position.x + 1
		spawnNewX.position.z = position.z + 1
		spawnNewX.position.y = 5
		get_parent().add_child(spawnNewX)
		await get_tree().create_timer(5).timeout


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
			15, 5: # jump
				jumping = true
			6: # eat
				eating = true
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


func _physics_process(delta):
	if not get_parent().finish:
		timeout -= 1
		
		var direction = makingDecision()
		
		handleEating()
		handleVelocity(direction, delta)
		
		var topText = get_node("TopText")
		topText.text = "Es ist " + str(cycles)
		
		# Moving the Character
		velocity = target_velocity
		move_and_slide()

