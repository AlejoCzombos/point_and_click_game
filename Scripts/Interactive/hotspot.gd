extends Node2D

@onready var nav_hotspot_component: NavHotspotComponent = $NavHotspotComponent

@export var enabled: bool = true
@export var target_name: StringName = &""
@export var hotspot_type: Constants.HotspotType = Constants.HotspotType.SCENE

func _ready() -> void:
	nav_hotspot_component.target_name = target_name
	nav_hotspot_component.enabled = enabled
	nav_hotspot_component.hotspot_type = hotspot_type 
	
