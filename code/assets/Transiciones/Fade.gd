extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	Main.connect("FadeOutWhite",self,"on_FadeOutWhite")
	Main.connect("FadeInBlack",self,"on_FadeInBlack")
	Main.connect("FadeOutBlack",self,"on_FadeOutBlack")
	Main.connect("FadeWhiteBlack",self,"on_FadeWhiteBlack")
	$AnimationPlayer.play("Normal")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func on_FadeOutWhite():
	$AnimationPlayer.play("FadeOut-White")

func on_FadeInBlack():
	$AnimationPlayer.play("FadeIn-Black")
	
func on_FadeOutBlack():
	$AnimationPlayer.play("FadeOut-Black")

func on_FadeWhiteBlack():
	$AnimationPlayer.play("FadeWhite-Black")

func _on_AnimationPlayer_animation_finished(anim_name):
	Main.emit_signal("FadeEnd")

