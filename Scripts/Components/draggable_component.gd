class_name DraggableComponent
extends InteractableComponent

@export var enabled: bool = true
@export var return_on_invalid_drop: bool = true

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO
var original_z_index: int = 0
var original_scale: Vector2 = Vector2.ONE
var original_rotation: float = 0.0

# For sway effect
var previous_mouse_pos: Vector2 = Vector2.ZERO
var mouse_velocity: Vector2 = Vector2.ZERO
var target_rotation: float = 0.0

# Hover state
var is_hovered: bool = false

func _ready() -> void:
	super._ready()
	original_scale = parent_node.scale
	original_rotation = parent_node.rotation

func _process(_delta: float) -> void:
	if is_dragging and enabled:
		var mouse_pos := get_viewport().get_mouse_position()
		parent_node.global_position = mouse_pos + drag_offset

func _on_mouse_entered() -> void:
	if not enabled or is_dragging:
		return

func _on_mouse_exited() -> void:
	if not enabled or is_dragging:
		return

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not enabled:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Consume the event to prevent it from propagating to overlapping socks
				get_viewport().set_input_as_handled()
				_start_drag()
			else:
				if is_dragging:
					get_viewport().set_input_as_handled()
					_end_drag()

func _start_drag() -> void:
	is_dragging = true
	original_position = parent_node.global_position
	original_z_index = parent_node.z_index
	previous_mouse_pos = get_viewport().get_mouse_position()
	
	drag_offset = parent_node.global_position - previous_mouse_pos
	
	# Bring to front
	parent_node.z_index = 99

func _end_drag() -> void:
	is_dragging = false

func reset_z_index() -> void:
	if parent_node:
		parent_node.z_index = original_z_index
