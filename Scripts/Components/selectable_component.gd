extends Node

@export var item_name: StringName

var item : InventoryItem

var parent_node: Node2D
var input_area: Area2D
var sprite_node: Node2D

func _ready() -> void:
	print("Initializing SelectableComponent")
	parent_node = get_parent() as Node2D
	if not parent_node:
		push_error("DraggableComponent must be child of Node2D")
		return
	
	if not item_name:
		push_error("SelectableItem: item_name is not asignee")
		return
	
	item = Managers.inventory_manager.get_item_by_name(item_name)
	
	input_area = _find_area2d()
	if input_area:
		input_area.input_event.connect(_on_input_event)
	else:
		push_warning("No Area2D found for DraggableComponent on %s" % parent_node.name)

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

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				Managers.inventory_manager.add_item(item)
