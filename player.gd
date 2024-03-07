extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 5
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
@export var dead = false

var target_velocity = Vector3.ZERO

var maxY = 0.25
var jumping = false
var eating = false
var eatingTimeout = 1000000

func _physics_process(delta):
	eatingTimeout -= 1
	if eating and eatingTimeout <= 0:
		eating = false
		
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("eat") and not eating:
		eating = true
		eatingTimeout = 1000

	if direction != Vector3.ZERO:
		direction = direction.normalized()

	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	if eating and eatingTimeout == 1000:
		eatingTimeout -= 1
		var spawnNewX = duplicate() # WTF is this?
		spawnNewX.position.x = position.x + 1
		spawnNewX.position.z = position.z + 1
		get_parent().add_child(spawnNewX)

	# Vertical Velocity
	if not is_on_floor() and not jumping: # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	elif Input.is_action_pressed("jump") or jumping:
		target_velocity.y = target_velocity.y + (fall_acceleration * delta)
		jumping = true
		if position.y >= maxY:
			jumping = false

	# Moving the Character
	velocity = target_velocity
	move_and_slide()