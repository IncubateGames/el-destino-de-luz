extends Node2D

func _ready():
	var name = OS.get_name()
	if name == "Android" or name == "iOS":
		$CanvasLayer/Skip.visible = true
	else:
		$CanvasLayer/Skip.visible = false
		
	Main.emit_signal("FadeInBlack")

func _on_AnimationPlayer_animation_finished(anim_name):
	Skip_Intro()

func Skip_Intro():
	$Fuego.stop()
	Main.Nivel_tipo = Main.TIPO_NIVEL.JUEGO
	Main.emit_signal("FadeOutBlack")
