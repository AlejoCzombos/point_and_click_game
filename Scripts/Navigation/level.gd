class_name Level
extends Resource

## Data for a level: a container scene (root has a RoomManager) plus the rooms
## that make it up. Runtime node instances live in the LevelManager, NOT here
## (a Resource can be shared/cached, so it must stay pure data).

@export var name: StringName
@export var scene: PackedScene
