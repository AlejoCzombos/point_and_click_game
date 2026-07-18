class_name InventoryManager
extends Node

signal item_added(item: InventoryItem)
signal item_removed(item: InventoryItem)
signal item_replaced(old_item: InventoryItem, new_item: InventoryItem)

const ITEMS_DIR_PATH = "res://Resources/Inventory/"
var all_items: Dictionary[StringName, InventoryItem]

var items: Dictionary[StringName, InventoryItem]
var selected_item: InventoryItem = null

func _ready() -> void:
	print("Initializing InventoryManager")
	Managers.inventory_manager = self
	get_all_items()

func get_all_items() -> void:
	var file_paths = ResourceLoader.list_directory(ITEMS_DIR_PATH)
	for file_path in file_paths:
		var absolute_res_path: String = ITEMS_DIR_PATH.path_join(file_path)
		if absolute_res_path.ends_with(".tres"): 
			var res = load(absolute_res_path)
			if res:
				all_items.get_or_add(res.name, res)
	prints("InventoryManager: All items loaded", all_items)

func select_item(item: InventoryItem) -> void:
	#prints("InventoryManager: selecting item: ", item)
	selected_item = item

func select_item_by_name(item_name: StringName) -> void:
	#prints("InventoryManager: selecting item by name: ", item_name)
	var item: InventoryItem = items.find_key(item_name)
	if item != null:
		selected_item = item
	else:
		push_error("InventoryManager: InventoryItem didn't exist")

func add_item(item: InventoryItem) -> void:
	prints("InventoryManager: adding item to inventory: ", item)
	items.get_or_add(item.name, item)
	item_added.emit(item)

func add_item_by_name(item_name: StringName) -> void:
	prints("InventoryManager: adding item to inventory by name: ", item_name)
	var item: InventoryItem = all_items.get(item_name)
	if item != null:
		items.get_or_add(item.name, item)
		item_added.emit(item)
	else:
		push_error("InventoryManager: InventoryItem didn't exist")

func replace_item(old_item: InventoryItem, new_item: InventoryItem) -> void:
	prints("InventoryManager: replacing item: ", old_item, " for item: ", new_item)
	delete_item(old_item)
	add_item(new_item)
	#item_replaced.emit(old_item, new_item)

func delete_item(item: InventoryItem) -> void:
	prints("InventoryManager: deleting item to inventory: ", item)
	items.erase(item.name)
	item_removed.emit(item)

func delete_item_by_name(item_name: StringName) -> void:
	prints("InventoryManager: deleting item to inventory by name: ", item_name)
	var item: InventoryItem = all_items.get(item_name)
	if item != null:
		items.erase(item_name)
		item_removed.emit(item)
	else:
		push_error("InventoryManager: InventoryItem didn't exist")

func get_item_by_name(item_name: StringName) -> InventoryItem:
	var item: InventoryItem = all_items.get(item_name)
	if item != null:
		return item
	else:
		push_error("InventoryManager: InventoryItem didn't exist")
		return null
