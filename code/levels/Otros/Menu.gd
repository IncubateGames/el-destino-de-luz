extends Node2D

func _ready():
	$Fade/UI/GUI/Idioma/HBoxContainer/OptionButton.selected = Main.settings["idioma"]["index"]	
	Main.Nivel_tipo = Main.TIPO_NIVEL.I_MENU
	Main.emit_signal("FadeInBlack")

func _on_Button_pressed():
	start_Game()

func start_Game():
	Main.Nivel_tipo = Main.TIPO_NIVEL.INPUT
	Main.emit_signal("FadeOutBlack")

func _on_OptionButton_item_selected(index):
	Main.cambiar_idioma(index)
