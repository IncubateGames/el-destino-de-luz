extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.get_name() == "HTML5":
		$Salir.visible = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if Main.Nivel_tipo == Main.TIPO_NIVEL.I_JUEGO:
			menu_pausa()
	if event.is_action_pressed("ui_start"):
		if Main.Nivel_tipo == Main.TIPO_NIVEL.I_JUEGO:
			menu_pausa()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		if Main.Nivel_tipo == Main.TIPO_NIVEL.I_JUEGO:
			menu_pausa()
		else:
			Main.Nivel_tipo = Main.TIPO_NIVEL.SALIR
			Main.emit_signal("FadeOutBlack")

func menu_pausa():
	if visible:
		visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false
	else:
		visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true

func _on_Reiniciar_pressed():
	menu_pausa()
	Main.Restart_Game()

func _on_Volver_pressed():
	menu_pausa()
	Main.Nivel_tipo = Main.TIPO_NIVEL.MENU
	Main.emit_signal("FadeOutBlack")

func _on_Salir_pressed():
	menu_pausa()
	Main.Nivel_tipo = Main.TIPO_NIVEL.SALIR
	Main.emit_signal("FadeOutBlack")
