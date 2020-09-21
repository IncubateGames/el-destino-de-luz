extends CanvasModulate


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Main.connect("CambiarColorBlanco",self,"on_CambiarColorBlanco")

func on_CambiarColorBlanco():
	set_color(Color( 1, 1, 1, 1 ))
