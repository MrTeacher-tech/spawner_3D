extends CharacterBody3D

var SPEED = 3.0

const LUNGE_ENERGY = 3
const LUNGE_FORCE = 10.0
const LUNGE_DURATION = 0.8  # Duration of the lunge in seconds
const ROTATION_SPEED = 2.0

var berry_count = 0

var is_lunging = false
var lunge_timer = 0.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	randomize()
	print("USER READY!")

func _physics_process(delta):
	var input_dir = Vector3()
	if position.y < -10:
		self.queue_free()
		print("Removed user")
		get_parent().game_over()

	if not is_on_floor():
		velocity.y -= gravity * delta

	

	# Handle rotation
	if Input.is_action_pressed("left"):
		rotation.y += ROTATION_SPEED * delta
	elif Input.is_action_pressed("right"):
		rotation.y -= ROTATION_SPEED * delta

	# Handle forward and backward movement
	
	if Input.is_action_pressed("up"):
		input_dir.z -= 1
	if Input.is_action_pressed("down"):
		input_dir.z += 1

	# Apply movement direction
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		var forward_dir = -transform.basis.z.normalized()
		velocity.x = forward_dir.x * input_dir.z * SPEED
		velocity.z = forward_dir.z * input_dir.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# Handle Lunge
	if Input.is_action_just_pressed("lunge") and berry_count >= LUNGE_ENERGY: 
		if not is_lunging:
			is_lunging = true
			berry_count -= 3
			lunge_timer = LUNGE_DURATION
			SPEED = 6.0  # Apply lunge force

	if is_lunging:
		lunge_timer -= delta
		if lunge_timer <= 0:
			is_lunging = false
	else:
		SPEED = 3.0
	move_and_slide()
	


func _on_berry_zone_area_entered(area):
	print("USER BOD ENTERED BY: ", area.name)
	if area.name == "berry_bod":
			berry_count += 1
			print("USER Ate Fruit")
			print("USER berries = ", berry_count)
			get_parent().update_berry_count(berry_count)
	else:
		return
