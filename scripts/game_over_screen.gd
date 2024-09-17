extends Control

@onready var label_3d = $"Total Spawns/number"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	label_3d.text = str(Global.total_spawns)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_respawn_button_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
