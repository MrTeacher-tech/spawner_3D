extends Camera3D

# Adjustable properties
@export var target_path: NodePath = NodePath("../user_creature")
@export var follow_speed: float = 5.0
@export var rotation_speed: float = 5.0
@export var offset: Vector3 = Vector3(0, 2, -10)

var target: Node3D

func _ready():
	if target_path != null:
		target = get_node(target_path) as Node3D

func _process(delta):
	if target:
		# Interpolate position
		var desired_position = target.global_transform.origin + offset
		global_transform.origin = global_transform.origin.lerp(desired_position, follow_speed * delta)
		
		# Interpolate rotation
		var direction = (target.global_transform.origin - global_transform.origin).normalized()
		var target_rotation = Transform3D().looking_at(direction, Vector3.UP).basis
		global_transform.basis = global_transform.basis.slerp(target_rotation, rotation_speed * delta)
