tool
extends Node2D

export(bool) var ocultar_spikes = false
export(bool) var is_fire_3_bullets = false

onready var _spawn_bullet_left := ($spawn_left)
onready var _spawn_bullet_right := ($spawn_right)
onready var _bullet := preload("res://assets/Props/Bullets/Bullet.tscn")
onready var _player := ($AnimationPlayer)
onready var _collision_mask :int= ($Area2D).collision_mask
onready var _spikes :=  ($Cara/Spikes)
onready var _fx_fire := ($fx_fire)

var _curreny_animation_name = "Idle"
var _is_body_left := true
var _spawn : Vector2 = Vector2.ZERO
var _ang :float = 0.0

var _current_body:Node = null
var _is_armed := false

func _ready():
	if Engine.editor_hint: 
		return
	if ocultar_spikes:
		$Cara.remove_child(_spikes)
		_spikes.queue_free()
	else:
		_spikes.visible = true
	_player.play(_curreny_animation_name)

func _process(delta):
	if Engine.editor_hint:
		if !ocultar_spikes:
			if _spikes:
				_spikes.visible = true
		update()

func __physics_process(delta):
	if Engine.editor_hint: 
		return

func fire():
	var count:int = 1
	if is_fire_3_bullets:
		count = 3
	for i in count:
		var bullet = _bullet.instance()
		bullet.global_position = _spawn
		bullet.global_rotation_degrees = _ang
		get_tree().current_scene.add_child(bullet)
		_fx_fire.play()
		yield(get_tree().create_timer(0.15),"timeout")


func preFire():
	_curreny_animation_name = "Angry"
	_player.play(_curreny_animation_name)

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		_current_body = body
		if body.global_position.x > global_position.x:
			_spawn = _spawn_bullet_right.global_position
			_ang = 0
		else:
			_spawn = _spawn_bullet_left.global_position
			_ang = 180.0
		verificarEnemigo()
		

func verificarEnemigo():
	var space_state = get_world_2d().direct_space_state
	var target = _current_body.global_position
	var result = space_state.intersect_ray(_spawn,target,[self])
	if result:
		var b = result.collider
		var isPlayer = b.is_in_group("player")
		if isPlayer:
			preFire()

func _on_Area2D_body_exited(body):
	if body.is_in_group("player"):
		_current_body = null
		_curreny_animation_name = "Idle"

func _on_AnimationPlayer_animation_finished(anim_name):
	_player.play(_curreny_animation_name)
