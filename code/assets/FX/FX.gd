extends CanvasLayer

onready var Explosion := preload("res://assets/FX/amazingexplosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Main.connect("fxExplode",self,"fxExplode")

func fxExplode(position):
	var boom = Explosion.instance()
	boom.position = position
	add_child(boom)


