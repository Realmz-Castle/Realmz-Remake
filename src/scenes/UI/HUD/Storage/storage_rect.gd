extends NinePatchRect
class_name Honest_Storage

@onready var itemLootButtonTSCN: PackedScene = preload(
	"res://scenes/UI/HUD/Looting/ItemLootButton.tscn"
)

@export var profilenameLabel: Label
@export var charanameLabel: Label
@export var charaGrid: GridContainer
@export var storageGrid: GridContainer

var selected_item_type := "All"
var cur_chara: Creature
var storage_inventory: Array[ItemInstance] = []


func initialize() -> void:
	selected_item_type = "All"
	if not GameGlobal.honest_mode:
		UI.ow_hud.set_charactersRect_type(0, false)
		UI.ow_hud.close_storage_rect()
		return
	if GameGlobal.cur_save_name.is_empty():
		UI.ow_hud._on_q_save_button_pressed()
	profilenameLabel.text = GameGlobal.currentprofile + "'s Storage"
	_on_character_selected(UI.ow_hud.selected_character)
	load_storage_inventory()
	set_selected_type(selected_item_type)
	UI.ow_hud.set_charactersRect_type(1, false)


func load_storage_inventory() -> void:
	storage_inventory.clear()
	var save_path := Paths.profilesfolderpath + GameGlobal.currentprofile
	var storage_path := save_path.path_join("storage.json")
	if not FileAccess.file_exists(storage_path):
		var storage_file := FileAccess.open(
			storage_path,
			FileAccess.ModeFlags.WRITE,
		)
		if storage_file == null:
			push_error(
				"Could not create honest storage: %s"
				% error_string(FileAccess.get_open_error())
			)
			return
		storage_file.store_string('{"schemaVersion":1,"storage":[]}')
		storage_file.close()
	var root := Utils.FileHandler.read_json_dic_from_file(storage_path)
	var saved_items: Variant = root.get("storage", [])
	if not (saved_items is Array):
		push_error("Honest storage inventory must be an array")
		return
	var restored := NodeAccess.__Resources().deserialize_item_inventory(
		saved_items
	)
	if not bool(restored.get("ok", false)):
		for message: Variant in restored.get("errors", []):
			push_error(str(message))
		return
	for instance: Variant in restored.get("instances", []):
		if instance is ItemInstance:
			instance.equipped = false
			storage_inventory.append(instance)


func set_selected_type(type: String) -> void:
	selected_item_type = type
	_on_character_selected(cur_chara)


func _on_character_selected(creature: Creature) -> void:
	if creature == null or not creature.get("classgd"):
		UI.ow_hud.called_on_CharPanel_SelectButton_pressed(
			UI.ow_hud.charsVContainer.get_child(0)
		)
		creature = GameGlobal.player_characters[0]
	cur_chara = creature
	charanameLabel.text = cur_chara.name + "'s inventory"
	fill_grids(cur_chara, selected_item_type)


func is_item_of_type(item: ItemInstance, type: String) -> bool:
	if type == "All":
		return true
	var definition := NodeAccess.__Resources().get_item_definition(item)
	if definition == null:
		return false
	var slots := definition.slots()
	if slots.is_empty():
		return type == "Supplies"
	match type:
		"Weapons":
			return (
				slots.has("Melee Weapon")
				or slots.has("Ranged Weapon")
				or slots.has("Ammunition")
			)
		"Armor":
			return slots.has("Armor")
		"Limbs":
			return (
				slots.has("Shield")
				or slots.has("Head")
				or slots.has("Legs")
			)
	return false


func fill_grids(_chara: Creature, type: String) -> void:
	for child: Node in charaGrid.get_children():
		child.queue_free()
	for child: Node in storageGrid.get_children():
		child.queue_free()
	for item: ItemInstance in cur_chara.inventory_instances():
		if is_item_of_type(item, type):
			charaGrid.add_child(create_chara_item_button(item))
	for item: ItemInstance in storage_inventory:
		if is_item_of_type(item, type):
			storageGrid.add_child(create_storage_item_button(item))


func create_chara_item_button(item: ItemInstance) -> Button:
	var button: Button = _create_item_button(item)
	button.pressed.connect(
		_on_itembutton_pressed.bind(item, true, cur_chara, button)
	)
	button.disabled = item.equipped
	return button


func create_storage_item_button(item: ItemInstance) -> Button:
	var button: Button = _create_item_button(item)
	button.pressed.connect(
		_on_itembutton_pressed.bind(item, false, null, button)
	)
	return button


func _create_item_button(item: ItemInstance) -> Button:
	var button: Button = itemLootButtonTSCN.instantiate()
	button.set_meta("item_instance", item)
	button.find_child("ItemTextureRect").texture = (
		NodeAccess.__Resources().item_texture(item)
	)
	button.mouse_entered.connect(_on_itembutton_mouse_entered.bind(item))
	button.mouse_exited.connect(_on_itembutton_mouse_exited)
	return button


func _on_itembutton_pressed(
	item: ItemInstance,
	from_character: bool,
	character: Creature,
	button: Button,
) -> void:
	var transferred := store_item(character, item) \
		if from_character else retrieve_item(cur_chara, item)
	if not transferred:
		GameGlobal.play_sfx("generation error.ogg")
		return
	button.queue_free()
	fill_grids(cur_chara, selected_item_type)
	GameGlobal.gamescreenInstance.updateCharPanelDisplay()


func store_item(character: Creature, item: ItemInstance) -> bool:
	if character == null or item == null or item.equipped:
		return false
	if not character.remove_inventory_item(item):
		return false
	storage_inventory.append(item)
	return true


func retrieve_item(character: Creature, item: ItemInstance) -> bool:
	if character == null or item == null or not storage_inventory.has(item):
		return false
	if not character.add_inventory_item(item):
		return false
	storage_inventory.erase(item)
	return true


func _on_itembutton_mouse_entered(item: ItemInstance) -> void:
	UI.ow_hud.textRect.set_item_info(item)


func _on_itembutton_mouse_exited() -> void:
	UI.ow_hud.textRect.set_text("", false, "")


func _on_exit_button_pressed() -> void:
	var serialized := NodeAccess.__Resources().serialize_item_inventory(
		storage_inventory
	)
	if not bool(serialized.get("ok", false)):
		for message: Variant in serialized.get("errors", []):
			push_error(str(message))
		return
	var save_path := (
		Paths.profilesfolderpath
		+ GameGlobal.currentprofile
		+ "/storage.json"
	)
	var storage_file := FileAccess.open(save_path, FileAccess.ModeFlags.WRITE)
	if storage_file == null:
		push_error(
			"Could not save honest storage: %s"
			% error_string(FileAccess.get_open_error())
		)
		return
	storage_file.store_string(JSON.stringify({
		"schemaVersion": 1,
		"storage": serialized.get("value", []),
	}))
	storage_file.close()
	UI.ow_hud._on_q_save_button_pressed()
	UI.ow_hud.set_charactersRect_type(0, false)
	UI.ow_hud.close_storage_rect()
