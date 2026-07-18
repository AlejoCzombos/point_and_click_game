class_name InteractableComponent
extends Node

var parent_node: Node2D
var input_area: Area2D
var sprite_node: Node2D

func _ready() -> void:
	parent_node = get_parent() as Node2D
	if not parent_node:
		push_error("InteractableComponent must be child of Node2D")
		return
	
	sprite_node = _find_sprite()
	
	input_area = _find_area2d()
	
	if input_area:
		input_area.input_event.connect(_on_input_event)
		input_area.mouse_entered.connect(_on_mouse_entered)
		input_area.mouse_exited.connect(_on_mouse_exited)
	else:
		push_warning("No Area2D found for InteractableComponent on %s" % parent_node.name)

func _find_area2d() -> Area2D:
	for child in parent_node.get_children():
		if child is Area2D:
			return child
	return null

func _find_sprite() -> Node2D:
	for child in parent_node.get_children():
		if child is Sprite2D:
			return child
	return null

func _on_mouse_entered() -> void:
	pass

func _on_mouse_exited() -> void:
	pass

func _on_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	pass
