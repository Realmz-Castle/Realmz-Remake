extends ScrollContainer
class_name CharacterInventoryContainer

@export var is_hud_selected := false

@onready var mybox = get_child(0)
var inventoryrect = null
var belongstoally := false:
	set(value):
		belongstoally = value
		modulate = Color(1, 1, 1, 0.75) if value else Color.WHITE


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if belongstoally or not _valid_drag_data(data):
		return false
	var item: ItemInstance = data[0]
	var source: Variant = data[1]
	var mycharacter: Creature = get_inventory_owner()
	if source is Creature:
		if source == mycharacter:
			return true
		var definition := NodeAccess.__Resources().get_item_definition(item)
		if definition == null or not definition.tradeable:
			return false
		if definition.unique and GameGlobal.enforce_unique_items:
			if GameGlobal.does_party_have_same_item(item)[0]:
				return false
		return mycharacter.can_add_inventory_item(item)
	if source == "Shop":
		return inventoryrect.can_purchase_shop_item(mycharacter, item)
	return false


func _drop_data(_pos: Vector2, data: Variant) -> void:
	if belongstoally or not _valid_drag_data(data):
		return
	var item: ItemInstance = data[0]
	var source: Variant = data[1]
	var mycharacter: Creature = get_inventory_owner()
	var changed := false
	if source is Creature:
		if source != mycharacter:
			changed = source.transfer_inventory_item_to(mycharacter, item)
	elif source == "Shop":
		changed = inventoryrect.purchase_shop_item(mycharacter, item)
	if not changed:
		GameGlobal.play_sfx("generation error.ogg")
	inventoryrect.refresh_inventory_lists()


func get_inventory_owner() -> Creature:
	if is_hud_selected:
		return inventoryrect.hud.selected_character
	return inventoryrect.selectedTradeCharacter


func _valid_drag_data(data: Variant) -> bool:
	return (
		data is Array
		and data.size() >= 2
		and data[0] is ItemInstance
	)
