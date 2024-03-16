extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 5
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
# Player should be dead when true
@export var dead = false
# player health points
@export var hp = 5

var target_velocity = Vector3.ZERO

var maxY = 0.25
var jumping = false
var eating = false
var eatingTimeout = 1000000


func movement(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()

	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

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


func handleEating():
	eatingTimeout -= 1
	if eating and eatingTimeout <= 0:
		eating = false

	if eating and eatingTimeout == 1000:
		eatingTimeout -= 1
		var spawnNewX = duplicate() # WTF is this?
		spawnNewX.position.x = position.x + 1
		spawnNewX.position.z = position.z + 1
		get_parent().add_child(spawnNewX)


func handleHP():
	if not self.dead and self.hp <= 0:
		self.dead = true


func hit():
	self.hp -= 1
	if self.hp <= 0:
		self.dead = true


func _physics_process(delta):
	if not get_parent().get_node("Ground").finish:
		#handleEating()
		handleHP()
		movement(delta)

