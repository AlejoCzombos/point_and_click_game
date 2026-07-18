class_name PickableComponent
extends InteractableComponent

signal picked()

func _on_mouse_entered() -> void:
	# Make hover effect
	pass

func _on_mouse_exited() -> void:
	# Make hover effect
	pass

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				picked.emit()
