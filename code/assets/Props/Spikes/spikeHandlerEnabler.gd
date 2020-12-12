extends Node2D



func _ready():
	my = get_node("_spike")

var my : Node
var isAdded : bool = true

func _process(delta):
	if  Main.culling(global_position) :
		Add_my()
	else:
		Remove_my()

func Add_my():
	if !isAdded:
		add_child(my)
		isAdded = true

func Remove_my():
	if isAdded:
		remove_child(my)
		isAdded = false

