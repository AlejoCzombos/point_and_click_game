@tool
class_name PickeableItem
extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var pickeable_component: PickableComponent = $PickableComponent

@export var item: InventoryItem

func _ready() -> void:
	if not item:
		push_error("Selectableitem: InventoryItem is not assign")
		return
	
	sprite_2d.texture = item.texture
	
	pickeable_component.picked.connect(on_item_picked)

func on_item_picked() -> void:
	Managers.inventory_manager.add_item(item)
	queue_free()
