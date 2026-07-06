class_name RoomManager
extends Node2D

signal room_changed(room: Room)

@export var roomsTest: Array[Room] = null

var start_room: Room

var _rooms: Array[Room]
var _current: Room = null
var _history: Array[Dictionary] = [] # [{ id, transition, dir }]
var _is_transitioning: bool = false

@onready var _viewport_width: float = get_viewport_rect().size.x

func _ready() -> void:
	_rooms = Managers.level_manager._current_level.rooms
	
	for child in get_children():
		if child.is_in_group("Rooms"):
			var room := child as RoomView
			_rooms[room.room_id] = room
			room.visible = false
			room.position = Vector2(_viewport_width, 0)

	var first := start_room if start_room != &"" else _first_room_id()
	if _rooms.has(first):
		_current = _rooms[first]
		_current.position = Vector2.ZERO
		_current.visible = true
		room_changed.emit(_current)
	else:
		push_error("RoomManager: start room '%s' not found" % first)

func _first_room_id() -> StringName:
	for id in _rooms:
		return id
	return &""

func is_busy() -> bool:
	return _is_transitioning

func get_current_room() -> RoomView:
	return _current

# --- Navigation API --------------------------------------------------------

func go_left() -> void:
	if _current and _current.has_left():
		go_to(_current.left_room, arrow_transition, Constants.Direction.LEFT)

func go_right() -> void:
	if _current and _current.has_right():
		go_to(_current.right_room, arrow_transition, Constants.Direction.RIGHT)

## Navigate to a room in THIS level. `direction` only matters for slide types.
func go_to(target_id: StringName, transition_type: Constants.TransitionType,
		direction: Constants.Direction = Constants.Direction.RIGHT,
		record_history: bool = true) -> void:
	if _is_transitioning:
		return
	if not _rooms.has(target_id):
		push_error("RoomManager: unknown room '%s'" % target_id)
		return
	var target: RoomView = _rooms[target_id]
	if target == _current:
		return

	if record_history and _current:
		_history.push_back({
			"id": _current.room_id,
			"transition": int(transition_type),
			"dir": int(_opposite(direction)),
		})

	await _run_transition(_current, target, int(transition_type), int(direction))

func can_go_back() -> bool:
	return not _history.is_empty()

func go_back() -> void:
	if _is_transitioning or _history.is_empty():
		return
	var entry: Dictionary = _history.pop_back()
	if not _rooms.has(entry["id"]):
		return
	await _run_transition(_current, _rooms[entry["id"]], int(entry["transition"]), int(entry["dir"]))

# --- Internals -------------------------------------------------------------

func _opposite(direction: int) -> int:
	return Constants.Direction.RIGHT if direction == Constants.Direction.LEFT else Constants.Direction.LEFT

func _run_transition(from_room: RoomView, to_room: RoomView, transition_type: int, direction: int) -> void:
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

func _fade_swap(from_room: RoomView, to_room: RoomView) -> void:
	await Transition.cover(slide_duration / 2.0)
	if from_room:
		from_room.visible = false
	to_room.position = Vector2.ZERO
	to_room.visible = true
	await Transition.reveal(slide_duration / 2.0)

func _slide(from_room: RoomView, to_room: RoomView, direction: int, with_black: bool) -> void:
	var w := _viewport_width
	# `direction` is the side the NEW room enters from.
	var enter_from := -w if direction == Constants.Direction.LEFT else w
	var exit_to := w if direction == Constants.Direction.LEFT else -w

	if with_black:
		# Slide the current room out while covering to black.
		if from_room:
			var t1 := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			t1.tween_property(from_room, "position", Vector2(exit_to, 0), slide_duration / 2.0)
		await Transition.cover(slide_duration / 2.0)
		if from_room:
			from_room.visible = false
		# Slide the new room in from the opposite side while revealing.
		to_room.position = Vector2(enter_from, 0)
		to_room.visible = true
		var t2 := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		t2.tween_property(to_room, "position", Vector2.ZERO, slide_duration / 2.0)
		await Transition.reveal(slide_duration / 2.0)
		await t2.finished
	else:
		to_room.position = Vector2(enter_from, 0)
		to_room.visible = true
		var tween := create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(to_room, "position", Vector2.ZERO, slide_duration)
		if from_room:
			tween.tween_property(from_room, "position", Vector2(exit_to, 0), slide_duration)
		await tween.finished
