tool
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.editor_hint:
		return
	Main.Nivel_tipo = Main.TIPO_NIVEL.I_JUEGO
	Main.emit_signal("FadeInBlack")

