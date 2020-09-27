extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var name = OS.get_name()
	if !(name == "Android" or name == "iOS"):
		#queue_free()
		pass
