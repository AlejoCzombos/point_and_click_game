class_name InventoryUIManager
extends VBoxContainer

@export var slot_scene: PackedScene
@export var total_slots: int = 6

var _slots: Array[InventorySlot] = []
var _slot_items: Array[InventoryItem] = []
var selected_slot: InventorySlot = null

func _ready() -> void:
	_clear_placeholder_slots()
	_create_slots()

	var inventory_manager: InventoryManager = Managers.inventory_manager
	inventory_manager.item_added.connect(_on_item_added)
	inventory_manager.item_replaced.connect(_on_item_replaced)
	inventory_manager.item_removed.connect(_on_item_removed)

func _clear_placeholder_slots() -> void:
	for child in get_children():
		child.queue_free()

func _create_slots() -> void:
	for i in total_slots:
		var slot: InventorySlot = slot_scene.instantiate()
		add_child(slot)
		slot.item_texture.texture = null
		slot.slot_clicked.connect(_on_slot_clicked)
		slot.slot_hovered.connect(_on_slot_hovered)
		slot.slot_unhovered.connect(_on_slot_unhovered)
		_slots.append(slot)
		_slot_items.append(null)

func _on_item_added(item: InventoryItem) -> void:
	for i in _slots.size():
		if _slot_items[i] == null:
			_slot_items[i] = item
			_slots[i].item_texture.texture = item.texture
			return

func _on_item_removed(item: InventoryItem) -> void:
	for i in _slots.size():
		if _slot_items[i] == item:
			if _slots[i] == selected_slot:
				_deselect()
			_slot_items[i] = null
			_slots[i].item_texture.texture = null
			return

func _on_item_replaced(old_item: InventoryItem, new_item: InventoryItem) -> void:
	_on_item_removed(old_item)
	_on_item_added(new_item)

func _on_slot_clicked(slot: InventorySlot) -> void:
	var index := _slots.find(slot)
	if index == -1 or _slot_items[index] == null:
		return
	if selected_slot == slot:
		_deselect()
		return
	_select(slot, _slot_items[index])

func _on_slot_hovered(slot: InventorySlot) -> void:
	if slot != selected_slot:
		slot.modulate = Color(1.2, 1.2, 1.2)

func _on_slot_unhovered(slot: InventorySlot) -> void:
	if slot != selected_slot:
		slot.modulate = Color.WHITE

func _select(slot: InventorySlot, item: InventoryItem) -> void:
	if selected_slot:
		selected_slot.modulate = Color.WHITE
	selected_slot = slot
	selected_slot.modulate = Color(1.5, 1.5, 1.5)
	Managers.inventory_manager.select_item(item)

func _deselect() -> void:
	if selected_slot:
		selected_slot.modulate = Color.WHITE
	selected_slot = null
	Managers.inventory_manager.select_item(null)
