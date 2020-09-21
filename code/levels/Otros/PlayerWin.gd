extends Node2D

func _ready():
	Main.emit_signal("FadeInBlack")
	yield(get_tree().create_timer(10.0),"timeout")
	go_Menu()

func go_Menu():
	Main.Nivel_tipo = Main.TIPO_NIVEL.MENU
	Main.emit_signal("FadeOutBlack")
