@tool
class_name UsableObject
extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var usable_component: UsableComponent = $UsableComponent

@export var interactions: Array[Interaction]

func _ready() -> void:
	if interactions.is_empty():
		push_error("UsableObject: interactions is empty")
		return
	
	usable_component.used.connect(_on_used)

func _on_used() -> void:
	var selected: InventoryItem = Managers.inventory_manager.selected_item
	if selected == null:
		return
	
	for interaction in interactions:
		if interaction.required_item != selected:
			prints("UsableObject: selected item dont have a interaction with item: ", interaction.required_item)
			continue
		#if interaction.consume_item:
		#	Managers.inventory_manager.delete_item(selected)
		if interaction.result_item:
			Managers.inventory_manager.replace_item(interaction.required_item, interaction.result_item)
		if interaction.event_name:
			call(interaction.event_name, interaction)
