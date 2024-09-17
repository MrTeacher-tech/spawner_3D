extends CharacterBody3D

const SPEED = 3.0
const JUMP_VELOCITY = 4.5

const LIFESPAN = 8
const DEATH_CHANCE = .75
const COLOR_VARIANCE = .20

@onready var pop_node = get_node("/root/Main/population")

@onready var animation_player =   $CanvasLayer/ColorRect/spawn_anime# Reference to the AnimationPlayer node
@onready var color_rect = $CanvasLayer/ColorRect
var life_cycle = 0

var LEVEL = 0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction = Vector3()

var is_walking = true
var has_rotated = false

var has_spawned = false

var berry_count = 0

#var creature = preload("res://assets/creature.tscn")


var random_index

var target_rotation = 0


func _ready():
	
	#print("CREATURE READY!")
	
	color_rect.visible = false
	
	change_direction()

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	if life_cycle > LIFESPAN or position.y < 0:
		if randf() < DEATH_CHANCE:
			self.queue_free()
			print("Removed creature")
			
			update_population_count_in_main_scene()

	if is_walking:
		# Move in the current direction
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		#print("Direction (x,y): ", direction.x, direction.y)

		# Rotate the player to face the movement direction
		if direction.length_squared() > 0.1:
			target_rotation = atan2(direction.x, direction.z) + PI / 2
			rotation.y = lerp_angle(rotation.y, target_rotation, 0.1)
			
			
	else:
		
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func timer_set_up():
	'''new creatures start walking on spawn because is_walking 
	is not set to false in this function. Set is_walikng = to false
	if you want spawned creatures to function like original creature'''
	$PauseTimer.start()
	$WalkTimer.stop()

func _on_WalkTimer_timeout():
	# Stop walking and start pausing
	life_cycle += 1
	#print("New Life Cycle: ", life_cycle)
	is_walking = false
	$PauseTimer.start()
	$WalkTimer.stop()

func _on_PauseTimer_timeout():
	# Start walking again
	is_walking = true
	has_spawned = false
	change_direction()
	$WalkTimer.start()
	$PauseTimer.stop()
	
	set_physics_process(true)
	#print("Physics Resumed")

func change_direction():
	# Pick a random direction to walk in
	direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
func play_animation(animation_name: String):
	if animation_player.has_animation(animation_name):
		animation_player.play(animation_name)
	else:
		print("Animation not found: ", animation_name)


func _on_sex_zone_body_entered(body):
	#print("Body is ", body.get_class())	
	# Create an instance of the selected scene
	
	#var creature_instance = creature.instantiate()
	
	var creature_instance = self.duplicate()
	if body.name == "bird":
		self.queue_free()
		print("Removed creature via bird")
		
		update_population_count_in_main_scene()
	
	elif body.name == "user_creature" or body.name == "creature":
		# Ensure the instance is valid before adding it to the scene tree
		#ensure creature is not walking and has not just spawned (no spam)
		if has_spawned == false and is_walking == false:
			set_physics_process(false)
			#print("Physics Paused!")
			pop_node.add_child(creature_instance)
			color_rect.visible = true
			play_animation("spawn_success")
			
			creature_instance.position = Vector3(randf_range(-35, 35), .5, randf_range(-35, 35))
			creature_instance.scale = self.scale
			creature_instance.change_direction()
			
			#change color code below
			var new_torso = creature_instance.get_node("torso")
			var material = new_torso.get_active_material(0)
			
			# Make a unique copy of the material for the child instance and set it
			#this prevents making the parent surface color change as well
			var new_material = material.duplicate()
			# Now change the color of the new material
			#based on parent color
			var parent_torso = self.get_node("torso")
			var parent_material = parent_torso.get_active_material(0)
			
			print(parent_material.albedo_color[0], parent_material.albedo_color[1], parent_material.albedo_color[2])
			var new_r = 1
			var new_g = 1
			var new_b = 1
			
			while new_r > .95 or new_b > .95 or new_g > .95 or new_r < .05 or new_b < .05 or new_g < .05:
			
				new_r = parent_material.albedo_color[0] + randf_range(-1*COLOR_VARIANCE, COLOR_VARIANCE)
				new_g = parent_material.albedo_color[1] + randf_range(-1*COLOR_VARIANCE, COLOR_VARIANCE)
				new_b = parent_material.albedo_color[2] + randf_range(-1*COLOR_VARIANCE, COLOR_VARIANCE)
			
			#print('NEW COLOR = ', "r:", new_r, " g:",new_g, " b:",new_b)
			new_material.albedo_color = Color(new_r, new_g, new_b)
			new_torso.set_surface_override_material(0, new_material)
			
			
			# Rotate the new creature by -90 degrees on the y-axis
			#creature_instance.rotate_y(deg_to_rad(-90))
				
		
			print("Added Creature")
			
			Global.total_spawns += 1
			#print("Updated value of total_spawns: ", Global.total_spawns)
			has_spawned = true
			creature_instance.timer_set_up()
			update_population_count_in_main_scene()
		else:
			#print("Failed to instance creature")
			color_rect.visible = false
		
# Function to update the population count in the main scene
func update_population_count_in_main_scene():
	var main_scene = get_tree().root.get_node("Main")
	if main_scene:
		main_scene.update_population_count()
		


func _on_berry_contact(area):
	print("CREATURE BOD ENTERED BY: ", area.name)
	if area.name == "berry_bod":
			berry_count += 1
			print("USER Ate Fruit")
			print("USER berries = ", berry_count)
	else:
		return
