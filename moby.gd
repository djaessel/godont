extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 5
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

var target_velocity = Vector3.ZERO

var maxY = 0.15
var jumping = false

var timeout = 5


func _physics_process(delta):
	var direction = Vector3.ZERO

	if timeout <= 0:
		var randomx = randi_range(1,5)
		match randomx:
			1: # move right
				direction.x += 55
			2: # move left
				direction.x -= 55
			3: # move back
				direction.z += 55
			4: # move forward
				direction.z -= 55
			5: # jump
				jumping = true
		timeout = 100
		
	timeout -= 1

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

	# Moving the Character
	velocity = target_velocity
	move_and_slide()

