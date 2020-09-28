tool
extends Node2D

export var idle_duration: float = 1.0

export(NodePath) var move_to 
var _move_to:Vector2 = Vector2()

export(bool) var _spike:= false
export(bool) var _destruible:= true
export(bool) var _restart:=true
export(bool) var _center_zona_dection:=false

onready var platform = ($plataform)
onready var tween := ($move_tween)
onready var anim := ($plataform/AnimationPlayer)
onready var area := ($plataform/Area2D)
onready var spikes :=  ($plataform/Spikes)
onready var timerAparecer := ($plataform/TimerAparecer)
onready var fxMover := ($fxMover)
onready var fxDead := ($fxDead)

var Explosion

export var _time: float = 5.0
var follow: Vector2 = Vector2.ZERO
var _is_tween_complete:bool = true

enum TipoPlataforma {Movil, Fija, Fragil, Inversa, Especial, Floja}
export(TipoPlataforma) var _tipo_plataforma := TipoPlataforma.Movil

var _Posicion_Original := Vector2()

func _ready():
	if Engine.editor_hint:
		return
	
	if Main.isGLES2():
		Explosion = preload("res://assets/FX/amazingexplosion_plataforma_cpu.tscn")
	else:
		Explosion = preload("res://assets/FX/amazingexplosion_plataforma.tscn")

	_Posicion_Original = platform.global_position
	if move_to:
		var node = get_node(move_to)
		if node:
			_move_to = node.global_position
			if _tipo_plataforma == TipoPlataforma.Inversa  or _tipo_plataforma == TipoPlataforma.Especial:
					area.global_position = _move_to
					if _center_zona_dection:
						var col = area.get_node("CollisionShape2D")
						col.position.y = 0.0
					
	if !_spike:
		platform.remove_child(spikes)
		spikes.queue_free()
	else:
		spikes.visible = true

func _process(delta):
	if Engine.editor_hint:
		if move_to:
			var node = get_node(move_to)
			if node:
				_move_to = node.global_position
				if _tipo_plataforma == TipoPlataforma.Inversa or _tipo_plataforma == TipoPlataforma.Especial:
					area.global_position = _move_to
					if _center_zona_dection:
						var col = area.get_node("CollisionShape2D")
						col.position.y = 0.0
		if !_spike:
			pass
		else:
			spikes.visible = true
		update()

func _init_tween(loop:=true,idle:=0.0) -> void:
	tween.interpolate_property(self, "follow", Vector2.ZERO, 
								transform.xform_inv(_move_to), _time, Tween.TRANS_LINEAR,
								Tween.EASE_IN_OUT,idle)
	if loop:
		tween.interpolate_property(self, "follow", transform.xform_inv(_move_to), Vector2.ZERO, 
									_time, Tween.TRANS_LINEAR, 
									Tween.EASE_IN_OUT, idle_duration + _time)

func _physics_process(delta):
	if Engine.editor_hint: 
		return
	if !_is_tween_complete:
		platform.position = follow

func _on_Area2D_body_entered(body):
	if _tipo_plataforma == TipoPlataforma.Movil:
		if body.is_in_group("player"):
			if _is_tween_complete:
				_is_tween_complete = false
				_init_tween()
				tween.start()
	elif _tipo_plataforma == TipoPlataforma.Floja:
		if body.is_in_group("player"):
			if _is_tween_complete:
				_is_tween_complete = false
				_init_tween(_restart,idle_duration)
				tween.start()
			else:
				tween.resume_all()
		else:
			if _destruible:
				tween.stop_all()
				anim.play("Desaparecer")
	elif _tipo_plataforma == TipoPlataforma.Inversa:
		if body.is_in_group("player"):
			if _is_tween_complete:
				_is_tween_complete = false
				_init_tween()
				tween.start()
	elif _tipo_plataforma == TipoPlataforma.Especial:
		if body.is_in_group("player"):
			if _is_tween_complete:
				_is_tween_complete = false
				_init_tween(_restart,idle_duration)
				tween.start()
	elif _tipo_plataforma == TipoPlataforma.Fragil:
		if body.is_in_group("player"):
			if _is_tween_complete:
				_is_tween_complete = false
				_init_tween(false,idle_duration)
				tween.start()
		else:
			tween.stop_all()
			anim.play("Desaparecer")

func play_fx():
	fxMover.play()
	pass

func stop_fx():
	fxMover.stop()
	pass


func Destruir():
	explode()
	var col = platform.get_node("collision")
	col.disabled = true
	if _destruible:
		queue_free()
	else:
		timerAparecer.start()

func _on_Area2D_body_exited(body):
	if _tipo_plataforma == TipoPlataforma.Floja:
		if body.is_in_group("player"):
				tween.stop_all()

func _on_move_tween_tween_all_completed():
	_is_tween_complete = true

func _draw():
	if Engine.editor_hint:
		if platform and _move_to:
			draw_line(transform.xform_inv(platform.global_position),transform.xform_inv(_move_to),Color(1,0,0),3.0)

func _on_Timer_timeout():
	platform.global_position = _Posicion_Original
	_is_tween_complete = true
	anim.play("Aparecer")
	fxMover.stop()
	fxDead.stop()
	var col = platform.get_node("collision")
	col.disabled = true

func explode():
	var boom = Explosion.instance()
	boom.position = platform.global_position
	get_parent().add_child(boom)
	fxMover.stop()
	fxDead.play()

func _on_move_tween_tween_completed(object, key):
	stop_fx()

func _on_move_tween_tween_started(object, key):
	play_fx()
