extends CharacterBody3D

const SPEED = 3.0
const JUMP_VELOCITY = 4.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var direction = Vector3()

var has_spawned = false

var is_walking = false



func _ready():
	randomize()
	print("USER READY!")

func _physics_process(delta):
	
	if position.y < -10:
		self.queue_free()
		print("Removed user")
		get_parent().game_over()
	
	var input_dir = Input.get_vector("left", "right", "up", "down")
	#print("Input direction: ", input_dir)  # Debugging line
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	#print("Transformed direction: ", direction)  # Debugging line
	if direction:
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		# Rotate the player to face the movement direction
		if direction.length_squared() > 0.1:
			var target_rotation = atan2(direction.x, direction.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, 0.1)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	'''
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# User input handling
	direction = Vector3()
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_up"):
		direction.z -= 1
	if Input.is_action_pressed("ui_down"):
		direction.z += 1
	
	direction = direction.normalized()
	
	if direction != Vector3():
		# Move in the current direction
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		# Rotate the player to face the movement direction
		if direction.length_squared() > 0.1:
			var target_rotation = atan2(direction.x, direction.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, 0.1)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	'''
