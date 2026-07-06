class_name RoomManager
extends Node2D

signal room_changed(room: Room)

@export var transition_type: Constants.TransitionType

var start_room: Room

var _rooms: Array[Room]
var _current: Room = null
var _history: Array[Dictionary] = [] # [{ id, transition, dir }]
var _is_transitioning: bool = false

@onready var _viewport_width: float = get_viewport_rect().size.x

func _ready() -> void:
	_rooms = await _find_rooms()

	for child in get_children():
		if child is Room:
			var room := child as Room
			room.visible = false
			room.position = Vector2(_viewport_width, 0)
	
	var first_room : Room = _rooms.filter(func(room: Room): return room.is_main_scene)[0]
	
	if first_room:
		_current = first_room
		_current.position = Vector2.ZERO
		_current.visible = true
		room_changed.emit(_current)
	else:
		push_error("RoomManager: start room '%s' not found" % first_room.name)
	
	room_changed.emit(_current)

func _find_rooms() -> Array[Room]:
	var level_rooms: Array[Room]
	for child in self.get_children():
		if child is Room:
			level_rooms.append(child)
	return level_rooms

func is_busy() -> bool:
	return _is_transitioning

func get_current_room() -> Room:
	return _current

# --- Navigation API --------------------------------------------------------

func has_right() -> bool:
	return _current.right_scene != null

func has_left() -> bool:
	return _current.left_scene != null

func go_left() -> void:
	if _current and _current.has_left():
		go_to(_current.left_scene, transition_type, Constants.Direction.LEFT)

func go_right() -> void:
	if _current and _current.has_right():
		go_to(_current.right_scene, transition_type, Constants.Direction.RIGHT)

func load_room_by_name(room_name: StringName) -> void:
	var target_rooms: Array[Room] = _current.internal_scenes.filter(func(room): return room.scene_name == room_name)
	if target_rooms.is_empty():
		push_error("RoomManager: target_room is not a valid name for hotspot")
		return
	go_to(target_rooms[0], Constants.TransitionType.FADE)

## Navigate to a room in THIS level. `direction` only matters for slide types.
func go_to(
	target_room: Room, 
	transition_type: Constants.TransitionType,
	direction: Constants.Direction = Constants.Direction.RIGHT,
	record_history: bool = true
	) -> void:
	if _is_transitioning:
		push_warning("RoomManager: is tarnsitioning")
		return
	if not target_room:
		push_error("RoomManager: unknown room '%s'" % target_room.name)
		return

	if record_history and _current:
		_history.push_back({
			"id": _current.scene_name,
			"transition": int(transition_type),
			"dir": int(_opposite(direction)),
		})

	await _run_transition(_current, target_room, int(transition_type), int(direction))

func can_go_back() -> bool:
	return not _history.is_empty()

func go_back() -> void:
	if _is_transitioning or _history.is_empty():
		return
	var entry: Dictionary = _history.pop_back()
	var target : Room = _rooms.filter(func(room: Room): return room.scene_name == entry["id"])[0]
	if not target:
		return
	await _run_transition(_current, target, int(entry["transition"]), int(entry["dir"]))

# --- Internals -------------------------------------------------------------

func _opposite(direction: int) -> int:
	return Constants.Direction.RIGHT if direction == Constants.Direction.LEFT else Constants.Direction.LEFT

func _run_transition(from_room: Room, to_room: Room, transition_type: int, direction: int) -> void:
	_is_transitioning = true

	match transition_type:
		Constants.TransitionType.FADE:
			await _fade_swap(from_room, to_room)
		Constants.TransitionType.SLIDE_BLACK:
			await _slide(from_room, to_room, direction, true)
		_: # SLIDE
			await _slide(from_room, to_room, direction, false)
	
	_current = to_room
	_current.position = Vector2.ZERO
	_current.visible = true
	if from_room and from_room != to_room:
		from_room.visible = false
		from_room.position = Vector2(_viewport_width, 0) # park off-screen again
	
	_is_transitioning = false
	room_changed.emit(_current)

func _fade_swap(from_room: Room, to_room: Room) -> void:
	await Transition.cover(Constants.slide_duration / 2.0)
	if from_room:
		from_room.visible = false
	to_room.position = Vector2.ZERO
	to_room.visible = true
	await Transition.reveal(Constants.slide_duration / 2.0)

func _slide(from_room: Room, to_room: Room, direction: int, with_black: bool) -> void:
	var w := _viewport_width
	# `direction` is the side the NEW room enters from.
	var enter_from := -w if direction == Constants.Direction.LEFT else w
	var exit_to := w if direction == Constants.Direction.LEFT else -w

	if with_black:
		# Slide the current room out while covering to black.
		if from_room:
			var t1 := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			t1.tween_property(from_room, "position", Vector2(exit_to, 0), Constants.slide_duration / 2.0)
		await Transition.cover(Constants.slide_duration / 2.0)
		if from_room:
			from_room.visible = false
		# Slide the new room in from the opposite side while revealing.
		to_room.position = Vector2(enter_from, 0)
		to_room.visible = true
		var t2 := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		t2.tween_property(to_room, "position", Vector2.ZERO, Constants.slide_duration / 2.0)
		await Transition.reveal(Constants.slide_duration / 2.0)
		if t2.is_valid() and t2.is_running():
			await t2.finished
	else:
		to_room.position = Vector2(enter_from, 0)
		to_room.visible = true
		var tween := create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(to_room, "position", Vector2.ZERO, Constants.slide_duration)
		if from_room:
			tween.tween_property(from_room, "position", Vector2(exit_to, 0), Constants.slide_duration)
		await tween.finished
