class_name LevelManager
extends Node2D

signal level_changed(level: Level)

@export var levels: Array[Level]

var _current_level: Level = null
var _current_instance: Node = null
var _is_loading: bool = false

func _ready() -> void:
	Managers.level_manager = self
	if not levels.is_empty():
		_instance_level(levels[0])
		level_changed.emit(_current_level)

func is_busy() -> bool:
	return _is_loading

func get_current_level() -> Level:
	return _current_level

func load_level(level: Level) -> void:
	if _is_loading or level == null:
		return
	if not level.scene:
		push_error("LevelManager: level '%s' has no scene" % level.name)
		return
	_is_loading = true

	await Transition.cover()

	if _current_instance:
		remove_child(_current_instance)
		_current_instance.queue_free()
		_current_instance = null

	_instance_level(level)

	await Transition.reveal()
	_is_loading = false
	level_changed.emit(_current_level)

func load_level_by_name(level_name: StringName) -> void:
	for level in levels:
		if level and level.name == level_name:
			load_level(level)
			return
	push_error("LevelManager: no level named '%s'" % level_name)

func _instance_level(level: Level) -> void:
	print("🫃 Instanciating level'%s'" % level.name)
	_current_level = level
	_current_instance = level.scene.instantiate()
	Managers.current_room_manager = _current_instance
	add_child(_current_instance)
