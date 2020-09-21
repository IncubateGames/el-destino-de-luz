extends Node2D

func _ready():
	Main.emit_signal("FadeInBlack")
	yield(get_tree().create_timer(5.0),"timeout")
	start_Game()

func start_Game():
	Main.Nivel_tipo = Main.TIPO_NIVEL.INTRO
	Main.emit_signal("FadeOutBlack")
