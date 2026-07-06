class_name Room
extends Node

@export var scene_name: StringName
@export var is_main_scene: bool
@export var right_scene: Room
@export var left_scene: Room
@export var internal_scenes: Array[Room]

func _ready() -> void:
	pass

func has_right() -> bool:
	return right_scene != null

func has_left() -> bool:
	return left_scene != null
