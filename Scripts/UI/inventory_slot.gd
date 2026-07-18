class_name InventorySlot
extends NinePatchRect

signal slot_clicked(slot: InventorySlot)
signal slot_hovered(slot: InventorySlot)
signal slot_unhovered(slot: InventorySlot)

@onready var item_texture: TextureRect = $ItemTexture

func _on_mouse_entered() -> void:
	#prints("InventorySlot: on_mouse_entered")
	slot_hovered.emit(self)

func _on_mouse_exited() -> void:
	#prints("InventorySlot: on_mouse_exited")
	slot_unhovered.emit(self)

func _gui_input(event: InputEvent) -> void:
	#prints("InventorySlot: mouse_gui_input")
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#prints("InventorySlot: on_mouse_clicked")
		slot_clicked.emit(self)
