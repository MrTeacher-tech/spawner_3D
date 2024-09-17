extends CharacterBody3D

var SPEED = 3

var is_hunting = false

var is_ascending = false

var is_chilling = true

var target_rotation = 0

var direction = Vector3()

var direction_changed = false

var OB_happened = false

var BOUNDARY_MIN = -35
var BOUNDARY_MAX = 35

@onready var nav_agent = $NavigationAgent3D

func diagnostic():
	if is_hunting:
		print("Hunt", is_hunting)
	if is_chilling:
		print("Chill", is_chilling)
	if is_ascending:
		print("Ascend", is_ascending)

func _physics_process(delta):
	
	var current_loc = global_transform.origin
	#diagnostic()
	if is_hunting:
		if is_hunting:
			direction_changed = true
			var next_loc = nav_agent.get_next_path_position()
			var new_velocity = (next_loc - current_loc).normalized() * SPEED
				
			velocity = velocity.move_toward(new_velocity, .25)
			
			if new_velocity.length_squared() > 0.1:
				target_rotation = atan2(new_velocity.x, new_velocity.z) + PI
				rotation.y = lerp_angle(rotation.y, target_rotation, 0.1)
				
			move_and_slide()
	elif is_ascending:
		#print("Cur Loc:", current_loc)
		var up_speed = randi_range(30, 45)
		velocity.y = up_speed*SPEED*delta
		#velocity.x = direction.x * SPEED
		#reset direction_changed
		direction_changed = false
		move_and_slide()
	elif is_chilling:
				
			if direction_changed == false:
				change_direction()
				move_and_slide()
				direction_changed = true
			velocity.y = 0
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			#print("Direction (x,y): ", direction.x,",", direction.y)

			# Rotate the player to face the movement direction
			if direction.length_squared() > 0.1:
					target_rotation = atan2(direction.x, direction.z) + PI
					rotation.y = lerp_angle(rotation.y, target_rotation, 0.1)

			
			move_and_slide()

func _on_HuntTimer_timeout():
	# Stop walking and start pausing
	
	#print("New Life Cycle: ", life_cycle)
	is_hunting = false
	is_chilling = false
	is_ascending = true
	$AscendTimer.start()
	$HuntTimer.stop()

func _on_AscendTimer_timeout():
	
	is_hunting = false
	is_ascending = false
	is_chilling = true
	
	$AscendTimer.stop()
	$ChillTimer.start()

func _on_ChillTimer_timeout():
	# Start walking again
	is_hunting = true
	is_chilling = false
	
	$HuntTimer.start()
	$ChillTimer.stop()
	
func change_direction():
	# Pick a random direction to walk in
	direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	
	

func update_target_location(target_location):
	#print("Target Updated!")
	nav_agent.target_position = target_location
	#print(nav_agent.target_position)
