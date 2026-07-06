extends CanvasLayer

## Persistent overlay: ◀ ▶ arrows + ▼ back. Re-binds to whichever RoomManager is
## current (levels are loaded/unloaded by the LevelManager). Arrow/back visibility
## follows the current room's exits (from its Room resource) and the history.

@export var level_manager_path: NodePath

@onready var _left_button: Button = $LeftButton
@onready var _right_button: Button = $RightButton
@onready var _back_button: Button = $BackButton

var _level_manager: LevelManager
var _room_manager: RoomManager

func _ready() -> void:
	_left_button.pressed.connect(_on_left_pressed)
	_right_button.pressed.connect(_on_right_pressed)
	_back_button.pressed.connect(_on_back_pressed)

	_level_manager = get_node_or_null(level_manager_path) as LevelManager
	if not _level_manager:
		push_error("NavHUD: level_manager_path is not set to a LevelManager")
		return

	_level_manager.level_changed.connect(_on_level_changed)
	# The first level is loaded during LevelManager._ready (before we connected).
	_bind_room_manager(Managers.current_room_manager)

func _on_level_changed(_level: Level) -> void:
	_bind_room_manager(Managers.current_room_manager)

func _bind_room_manager(room_manager: RoomManager) -> void:
	if _room_manager and _room_manager.room_changed.is_connected(_on_room_changed):
		_room_manager.room_changed.disconnect(_on_room_changed)

	_room_manager = room_manager
	if _room_manager:
		_room_manager.room_changed.connect(_on_room_changed)
	_update_buttons()

func _on_room_changed(_room: Room) -> void:
	_update_buttons()

func _update_buttons() -> void:
	_left_button.visible = _room_manager != null and _room_manager.has_left()
	_right_button.visible = _room_manager != null and _room_manager.has_right()
	_back_button.visible = _room_manager != null and _room_manager.can_go_back()

func _on_left_pressed() -> void:
	if _room_manager:
		_room_manager.go_left()

func _on_right_pressed() -> void:
	if _room_manager:
		_room_manager.go_right()

func _on_back_pressed() -> void:
	if _room_manager:
		_room_manager.go_back()
