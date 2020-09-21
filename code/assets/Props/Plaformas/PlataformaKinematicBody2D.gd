extends KinematicBody2D

export var move_to: Vector2
export var cell_size: Vector2
export var speed: float = 3.0

onready var platform = $platform
onready var tween = $move_tween

# Called when the node enters the scene tree for the first time.
func _ready():
	init_tween()
	
func _init_tween() -> void:
	move_to = move_to * cell_size
	var duration = move_to.length() / speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
