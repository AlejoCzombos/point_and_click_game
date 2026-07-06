class_name NavHotspotComponent
extends Node

## Makes its parent clickable to load another level (a door / exit). Same shape
## as DraggableComponent: finds a sibling Area2D and reacts to its input_event.
## Targets a level by NAME so room scenes don't hard-reference Level resources
## (which would create scene<->resource dependency cycles).

@export var enabled: bool = true
@export var target_name: StringName = &""
@export var hotspot_type: Constants.HotspotType

var parent_node: Node2D
var input_area: Area2D

func _ready() -> void:
	parent_node = get_parent() as Node2D
	if not parent_node:
		push_error("NavHotspotComponent must be child of Node2D")
		return

	input_area = _find_area2d()
	if input_area:
		input_area.input_event.connect(_on_input_event)
	else:
		push_warning("No Area2D found for NavHotspotComponent on %s" % parent_node.name)

func _find_area2d() -> Area2D:
	for child in parent_node.get_children():
		if child is Area2D:
			return child
	return null

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not enabled or target_name == &"":
		return
	if not (event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	
	match hotspot_type:
		Constants.HotspotType.SCENE:
			var room_manager: RoomManager = Managers.current_room_manager
			if room_manager and not room_manager.is_busy():
				get_viewport().set_input_as_handled()
				room_manager.load_room_by_name(target_name)
		Constants.HotspotType.LEVEL:
			var lm : LevelManager = Managers.level_manager
			if lm and not lm.is_busy():
				get_viewport().set_input_as_handled()
				lm.load_level_by_name(target_name)
