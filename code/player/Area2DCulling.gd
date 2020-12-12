extends Area2D

func _on_Area2D_body_entered(body):
	if body.is_in_group("Entidad"):
		if body.has_method("Add_my"):
			body.Add_my()

func _on_Area2D_body_exited(body):
	if body.is_in_group("Entidad"):
		if body.has_method("Remove_my"):
			body.Remove_my()
		
