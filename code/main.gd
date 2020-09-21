extends Node2D

signal PlayerDead
signal PlayerWin
signal FadeInWhite
signal FadeInBlack
signal FadeOutWhite
signal FadeOutBlack
signal FadeWhiteBlack
signal FadeBlackWhite

signal FadeEnd

signal fxExplode(position)

enum TIPO_NIVEL {NA,RELOAD, SALIR, MENU, I_MENU, I_INPUT, INPUT, I_INTRO, INTRO, I_JUEGO, JUEGO, I_WIN, WIN, I_LOSE, LOSE}
var Nivel_tipo :int = TIPO_NIVEL.NA

#INPUT indica que se toma por eventos, PROCESS indica que se lee el estado en un loop
enum TIPO_INPUT {PROCESS, INPUT}
#Esta variable cambia la forma en que se procesan los eventos del manejo de personaje
export(TIPO_INPUT) var _tipo_input = TIPO_INPUT.PROCESS

onready var UI_Pausa := preload("res://levels/Otros/Pausa.tscn")
var _pausa_menu :Node= null

onready var UI_Touchpad := preload("res://levels/Otros/TouchPad.tscn")
var _touchpad :Node=null

var _config_file = ConfigFile.new()
const SAVE_PATH = "user://settings.cfg"
var settings = {
	"idioma":{
		"lenguaje":"es",
		"index":0
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	
	init_preferencias()

	clear_input()
	connect("PlayerDead",self,"on_Player_Dead")
	connect("PlayerWin",self,"on_Player_Win")
	connect("FadeEnd",self,"on_FadeEnd")
	
	connect("TouchpadUpPressed",self,"on_Touchpad_Up_Pressed")
	connect("TouchpadLeftPressed",self,"on_Touchpad_Left_Pressed")
	connect("TouchpadRightPressed",self,"on_Touchpad_Right_Pressed")
	connect("TouchpadDownPressed",self,"on_Touchpad_Down_Pressed")
	
	_pausa_menu = UI_Pausa.instance()
	_pausa_menu.get_child(0).visible = false
	add_child(_pausa_menu)
	
	_touchpad = UI_Touchpad.instance()
	_touchpad.get_child(0).visible = false
	add_child(_touchpad)
	_touchpad = _touchpad.get_child(0)
	leer_preferencias()

var _motion = Vector2(0,0)
var _is_Jump :bool = false
var _old_pos = Vector2(0,0)

func _process(delta):
	if _tipo_input == TIPO_INPUT.PROCESS:
		if Nivel_tipo == TIPO_NIVEL.I_JUEGO:
			if (Input.is_action_pressed("move_left")):
				_motion += Vector2(-1, 0)
			if (Input.is_action_pressed("move_right")):
				_motion += Vector2(1, 0)
			
			if _old_pos.x != 0:
				if abs(_old_pos.x) - 5 > 0:
					_motion.x = clamp(_old_pos.x,-1,1)
				
			_old_pos = Vector2(0,0)

			if (Input.is_action_just_pressed("move_up")):
				_is_Jump = true

func Sync_Input():
	if _tipo_input == TIPO_INPUT.PROCESS:
		_motion = Vector2(0,0)
	_is_Jump = false

func clear_input():
	_motion = Vector2(0,0)
	_is_Jump = false
	_left = false
	_right = false

var _left:bool = false
var _right:bool = false

func _input(event):
	if _tipo_input == TIPO_INPUT.INPUT:
		if Nivel_tipo == TIPO_NIVEL.I_JUEGO:
			if (event.is_action_pressed("move_left")):
				_left = true
			elif (event.is_action_released("move_left")):
				_left = false
				
			if (event.is_action_pressed("move_right")):
				_right = true
			elif (event.is_action_released("move_right")):
				_right = false
			
			_motion = Vector2()
			
			if _left:
				_motion.x += -1
			if _right:
				_motion.x += 1

			if (event.is_action_just_pressed("move_up")):
				_is_Jump = true

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_old_pos = event.relative;

	if event.is_action_pressed("ui_start"):
		match Nivel_tipo:
			TIPO_NIVEL.I_JUEGO:
				pass
			TIPO_NIVEL.I_MENU:
				if get_tree().current_scene.has_method("start_Game"):
					get_tree().current_scene.call("start_Game")
			TIPO_NIVEL.I_INTRO:
				if get_tree().current_scene.has_method("Skip_Intro"):
					get_tree().current_scene.call("Skip_Intro")
	if event.is_action_pressed("ui_cancel"):
		match Nivel_tipo:
			TIPO_NIVEL.I_JUEGO:
				pass
			TIPO_NIVEL.I_INTRO:
				if get_tree().current_scene.has_method("Skip_Intro"):
					get_tree().current_scene.call("Skip_Intro")
			TIPO_NIVEL.I_MENU:
				salir_juego()

func menu_pausa():
	if _pausa_menu.visible:
		_pausa_menu.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false
	else:
		_pausa_menu.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		set_process_unhandled_input(true)

func Restart_Game():
	clear_input()
	if Nivel_tipo == TIPO_NIVEL.I_JUEGO:
		Nivel_tipo = TIPO_NIVEL.RELOAD
		Main.emit_signal("FadeOutBlack")
		yield(get_tree().create_timer(2.0),"timeout")
		get_tree().reload_current_scene()

func salir_juego():
	get_tree().quit()

func on_Player_Dead():
	if Nivel_tipo == TIPO_NIVEL.I_JUEGO:
		Restart_Game()

func on_Player_Win():
	clear_input()
	Nivel_tipo = TIPO_NIVEL.WIN
	Main.emit_signal("FadeWhiteBlack")

func on_FadeEnd():
	clear_input()
	#seudo implementacion de maquina de estados. Hay que reimplementar
	match Nivel_tipo:
		TIPO_NIVEL.MENU:
			hide_touchPad()
			Nivel_tipo = TIPO_NIVEL.I_MENU
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().change_scene("res://levels/Otros/Menu.tscn")
		TIPO_NIVEL.INPUT:
			hide_touchPad()
			Nivel_tipo = TIPO_NIVEL.I_INPUT
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			var name = OS.get_name()
			if name == "Android" or name == "iOS":
				Nivel_tipo = TIPO_NIVEL.I_INTRO
				get_tree().change_scene("res://levels/Otros/Intro.tscn")
			else:
				get_tree().change_scene("res://levels/Otros/Input.tscn")
		TIPO_NIVEL.INTRO:
			hide_touchPad()
			Nivel_tipo = TIPO_NIVEL.I_INTRO
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().change_scene("res://levels/Otros/Intro.tscn")
		TIPO_NIVEL.WIN:
			hide_touchPad()
			Nivel_tipo = TIPO_NIVEL.I_WIN
			get_tree().change_scene("res://levels/Otros/PlayerWin.tscn")
		TIPO_NIVEL.JUEGO:
			show_touchPad()
			Nivel_tipo = TIPO_NIVEL.I_JUEGO
			get_tree().change_scene("res://levels/Nivel1/Nivel1.tscn")
		TIPO_NIVEL.SALIR:
			hide_touchPad()
			salir_juego()

func hide_touchPad():
	if _touchpad:
		_touchpad.visible = false

func show_touchPad():
	if _touchpad:
		_touchpad.visible = true
		
func cambiar_idioma(index:int)-> void:
	set_preferencias("idioma","index",index)
	if index == 0:
		TranslationServer.set_locale("es")
		set_preferencias("idioma","lenguaje","es")
	elif index == 1:
		TranslationServer.set_locale("en")
		set_preferencias("idioma","lenguaje","en")
		
	guadar_preferencias()
	
func init_preferencias():
	var err = _config_file.load(SAVE_PATH)
	if err != OK:
		guadar_preferencias()
		_config_file.load(SAVE_PATH)
		if err != OK:
			_config_file = null
	
	leer_preferencias()

func leer_preferencias():
	if _config_file:
		for section in settings.keys():
			for key in settings[section]:
				var val = settings[section][key]
				settings[section][key] = _config_file.get_value(section,key,val)
				
		cargar_configuracion()

func set_preferencias(seccion,clave,valor):
	if _config_file:
		settings[seccion][clave] = valor

func guadar_preferencias():
	for section in settings.keys():
		for key in settings[section]:
			_config_file.set_value(section,key,settings[section][key])
	_config_file.save(SAVE_PATH)

func cargar_configuracion():
	TranslationServer.set_locale(settings["idioma"]["lenguaje"])
