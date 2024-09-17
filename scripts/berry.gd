extends Node3D  # Change this to the appropriate base class of your node

# Rotation speed in degrees per second
 
var rotation_speed = 90.0

func _process(delta):
	# Rotate around the Y-axis (you can change the axis if needed)
	rotation.y += deg_to_rad(rotation_speed) * delta


func _on_static_body_3d_body_entered(body):
	print("BERRY BOD:", body.name)
	if body.name == "creature" or body.name == "user_creature":
		self.queue_free()
		print("Removed Berry")
