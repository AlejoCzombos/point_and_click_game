class_name Room
extends Resource

@export var name: StringName
@export var scene: PackedScene
@export var is_main_scene: bool
@export var right_scene: Room
@export var left_scene: Room
@export var internal_scenes: Array[Scene]
