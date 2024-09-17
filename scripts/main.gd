extends Node3D

const NUM_TREES = 40  # Number of trees to spawn
const NUM_CREATURES = 3  # Number of trees to spawn
const NUM_FRUIT = 40

@onready var population_node = $population
@onready var label_spawn = $spawn_label/Control/Label
@onready var label_berry = $berry_label/Control/Label


@onready var forest_node = get_node("/root/Main/forest")
@onready var fruit_node = get_node("/root/Main/fruit")

#@onready var user_node = get_node("/root/Main/user_creature")

@onready var sun_node = $sun

@onready var bird = $bird
@onready var pop_node = get_node("/root/Main/population")

var child_count = 0

var total_spawns = 0

var fruited = false


func _ready():
	spawn_trees()
	spawn_creatures()
	

func _process(delta):
	var nearest_spawn = find_nearest_spawn()
	if nearest_spawn != null:
		bird.update_target_location(nearest_spawn.global_transform.origin)
	print(sun_node.position)	
	if sun_node.position.y < -30 and fruited == false:
		spawn_fruit()
		fruited = true
	elif sun_node.position.y > 20 and fruited:
		fruited = false
		remove_fruit()

func find_nearest_spawn() -> Node3D:
	var nearest_spawn = null
	var shortest_distance = INF
	for spawn in pop_node.get_children():
		var distance = bird.global_transform.origin.distance_to(spawn.global_transform.origin)
		if distance < shortest_distance:
			shortest_distance = distance
			nearest_spawn = spawn
	return nearest_spawn
	
func game_over():
	var error = get_tree().change_scene_to_file("res://game_over.tscn")
	if error != OK:
		print("Error changing scene: ", error)
	

func spawn_trees():
	 # Get the 'forest' node from the main scene
	
	for i in range(NUM_TREES):
		var tree_instance = preload("res://assets/Tree.tscn").instantiate()
		var random_position = Vector3(randf_range(-35, 35), .5, randf_range(-35, 35))
		tree_instance.global_transform.origin = random_position
		tree_instance.scale *= 3 + randf_range(-.3, +.35)
		forest_node.add_child(tree_instance)

func get_random_tree_position() -> Vector3:
	var trees = forest_node.get_children()
	if trees.size() == 0:
		return Vector3()  # Return a default value if there are no children
	var random_index = randi() % trees.size()  # Get a random index
	var random_tree = trees[random_index]

	if random_tree is Node3D:
		return random_tree.global_transform.origin  # Return the position of the tree

	return Vector3()
				
func spawn_creatures():
	
	for i in range(NUM_CREATURES):
		var creature_instance = preload("res://assets/creature.tscn").instantiate()
		var random_position = Vector3(randf_range(-15, 15), 1.3, randf_range(-15, 15))
		creature_instance.global_transform.origin = random_position
		creature_instance.scale *= 1.5
		pop_node.add_child(creature_instance)

func spawn_fruit():
	
	for i in range(NUM_FRUIT):
		var fruit_instance = preload("res://assets/berry.tscn").instantiate()
		randomize()  # Ensure random seed is initialized
		var random_position = get_random_tree_position()
		var x = random_position.x + randi_range(3,6)
		var z = random_position.z + randi_range(3,6)	
		#print("Random Fruit Position: ", x, z)
		fruit_instance.global_transform.origin = Vector3(x, 2, z)
		#fruit_instance.scale *= 1.5
		fruit_node.add_child(fruit_instance)
func remove_fruit():
	var children = fruit_node.get_children()  # Get all children of the 'fruit' node
	for child in children:
		child.queue_free()  # Queue each child for deletion
				
func update_population_count():
	
	
	var child_count = population_node.get_child_count()
	print("kids: ",child_count)
	
	
	label_spawn.text = "Spawn Count: " + str(child_count)
	
	if child_count == 1:
		game_over()

func update_berry_count(value: int):
	
	
	
	label_berry.text = "Berry Count: " + str(value)
