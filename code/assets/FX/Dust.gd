extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if Main.isGLES2():
		remove_child($Particles2D)
	else:
		remove_child($Particles2D2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
