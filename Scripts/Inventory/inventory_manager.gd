class_name InventoryManager
extends Node

const ITEMS_DIR_PATH = "res://Resources/Inventory/"
var log = Logger.new()
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
	selected_item = item

func select_item_by_name(item_name: StringName) -> void:
	var item: InventoryItem = items.find_key(item_name)
	if item != null:
		selected_item = item
	else:
		push_error("InventoryManager: InventoryItem didn't exist")

func add_item(item: InventoryItem) -> void:
	Logger.
	prints("InventoryManager: adding item to inventory: ", item)
	items.get_or_add(item.name, item)

func add_item_by_name(name: StringName) -> void:
	var item: InventoryItem = all_items.get(name)
	if item != null:
		items.get_or_add(item.name, item)
	else:
		push_error("InventoryManager: InventoryItem didn't exist")

func delete_item(item: InventoryItem) -> void:
	items.erase(item.name)

func delete_item_by_name(item_name: StringName) -> void:
	items.erase(item_name)

func get_item_by_name(name: StringName) -> InventoryItem:
	var item: InventoryItem = all_items.get(name)
	if item != null:
		return item
	else:
		push_error("InventoryManager: InventoryItem didn't exist")
		return null
