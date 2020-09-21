extends Node2D

export(bool) var SonidoActivo = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if !SonidoActivo:
		$AudioStreamPlayer2D.stop()
