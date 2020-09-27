extends KinematicBody2D

# Estas cosas pueden ser constantes para el juego, pero para diseñadores no lo son
# Una ventaja extra es que al estar expuestos pueden modificarse durante el juego
# esto hace que sea muy facil ajustar valores
export(float) var GRAVEDAD := 150
export(float) var MOTION_SPEED := 300.0
export(float) var JUMP_FORCE := 1500.0
export(float) var TIMEOUT_JUMP := 500.0

var _Velocidad:Vector2 = Vector2()
export(float) var _Sensibilidad:float = 0.25
var _can_second_jump:bool = false
var _can_jump:bool = false
var _second_jump_timeout:float = 0.1

# En player tiene sentido dejar que explosiones cambien, ya que este
# es accesible desde nivels y se pueden probar muchas cosas
# es mas discutible en elementos como las balas donde las explosiones pueden ser 
# directamente parte de la escena (ya que ademas, siempre exploraran)
export(PackedScene) var Explosion_CPU
export(PackedScene) var Explosion

onready var AnimLight := ($AnimLight)
onready var ShakeCamera2D := ($Camera2D)
onready var FXDead := ($fxDead)
onready var collisionShape := ($CollisionShape2D)

var _motion = Vector2(0,0)
var _is_Jump :bool = false

func sync_Input():
	_motion = Main._motion
	_is_Jump = Main._is_Jump
	Main.Sync_Input()

func _physics_process(delta):
	
	sync_Input()
	
	_motion = _motion.normalized()
	_motion = _motion * MOTION_SPEED
	_motion += Vector2(0,GRAVEDAD)
	
	_Velocidad = _Velocidad.linear_interpolate(_motion,_Sensibilidad)
	
	_Velocidad = move_and_slide_with_snap(_Velocidad,Vector2.DOWN * 5.0 ,Vector2.UP)
	
	if is_on_floor():
		_can_jump = true
	
	if _is_Jump:
		var jump = 0.0
		if _can_jump:
			_can_jump = false
			jump = 1
			_can_second_jump = true
			_second_jump_timeout = OS.get_ticks_msec() + TIMEOUT_JUMP
		elif _can_second_jump and _second_jump_timeout >= OS.get_ticks_msec():
			_can_second_jump = false
			jump = 1
			
		if jump != 0.0:
			_Velocidad.y += jump * -JUMP_FORCE

func player_dead():
	set_physics_process(false)
	collisionShape.disabled = true
	visible = false
	explode()
	yield(get_tree().create_timer(1.5),"timeout")
	# Hay que tener cuidado con el abuso de singletons
	# Aqui esta bien ordenado como un "signal manager"
	# pueden surgir problemas cuando se agregan cosas, engordara demasiado
	# El enfoque usual (para cualquier engine que disponga de algo como observers)
	# es Señales para arriba en el arbol (parents), en este caso quien emite player dead seria player
	# Y reacciones para abajo (children) y siempre evitando romper encapsulaciones y abstracciones
	Main.emit_signal("PlayerDead")

var _stop_anim:bool = false
func player_stop_anim():
	_stop_anim = true

func on_AnimLight_finish():
	if _stop_anim:
		AnimLight.stop()

func hit():
	ShakeCamera2D.add_trauma(1.0)
	player_dead()
	
func give_hit():
	ShakeCamera2D.add_trauma(0.5)
	player_dead()

func playFXExplode():
	FXDead.play()

func explode():
	var name = OS.get_name()
	var boom
	if name == "Android" or name == "iOS" or name == "HTML5":
		boom = Explosion_CPU.instance()
	else:
		boom = Explosion.instance()
	boom.position = position
	get_parent().add_child(boom)
	playFXExplode()
	#get_tree().current_scene.add_child(boom)
