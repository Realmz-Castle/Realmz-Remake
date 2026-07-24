extends Button

@onready var colorRect: ColorRect = $colorRect
@onready var iconsprite: Sprite2D = $IconSprite
@onready var iconequipped: Sprite2D = $IconEquipped
@onready var namelabel: Label = $ItemnameLabel
@onready var infolabel: Label = $IteminfoLabel
@onready var chargesLabel: Label = $ChargesLabel
@onready var statsLabel: RichTextLabel = $ItemstatsRTLabel
@onready var selectedSprite: Sprite2D = $SpriteSelected

var belongstoally := false
var item: ItemInstance = null
var inventoryrect: Control = null


func on_viewport_size_changed(screensize: Vector2) -> void:
	chargesLabel.position = Vector2(
		floor((screensize.x - 320 - 44 - 20) / 2) - 95,
		4,
	)
	statsLabel.position = Vector2(
		floor((screensize.x - 320 - 44 - 20) / 2) - 215,
		20,
	)
	colorRect.size = Vector2(
		floor((screensize.x - 320 - 44 - 20) / 2),
		40,
	)


func set_item(new_item: ItemInstance) -> void:
	item = new_item
	if item == null:
		clear_item()
		return
	var definition := _definition()
	if definition == null:
		clear_item()
		return
	var screensize: Vector2 = ScreenUtils.get_logical_window_size(self)
	var item_width: float = floorf(
		(screensize.x - 320 - 44 - 20) / 2
	)
	colorRect.size = Vector2(item_width, 40)
	size = Vector2(item_width, 40)
	iconsprite.texture = NodeAccess.__Resources().item_texture(item)
	infolabel.text = definition.display_type
	iconequipped.visible = item.equipped
	if definition.maximum_charges > 0 and item.identified:
		chargesLabel.show()
		chargesLabel.text = "X %d / %d" % [
			item.charges,
			definition.maximum_charges,
		]
		chargesLabel.position = Vector2(item_width - 95, 4)
	else:
		chargesLabel.hide()
	if item.identified and not definition.stats_summary.is_empty():
		statsLabel.parse_bbcode(definition.stats_summary)
		statsLabel.position = Vector2(item_width - 215, 20)
	else:
		statsLabel.clear()
	namelabel.text = definition.display_name_for(item)
	namelabel.add_theme_color_override(
		"font_color",
		Color.BLACK if item.identified else Color.DIM_GRAY,
	)


func clear_item() -> void:
	item = null
	if not is_node_ready():
		return
	iconsprite.texture = null
	iconequipped.hide()
	namelabel.text = ""
	infolabel.text = ""
	chargesLabel.hide()
	statsLabel.clear()


func update_display() -> void:
	set_item(item)


func _get_drag_data(_pos: Vector2) -> Variant:
	if inventoryrect == null or belongstoally or item == null or item.equipped:
		return null
	var dragpreview := TextureRect.new()
	dragpreview.texture = NodeAccess.__Resources().item_texture(item)
	set_drag_preview(dragpreview)
	return [item, get_parent().get_parent().get_inventory_owner()]


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if belongstoally or not _valid_drag_data(data):
		return false
	var dropped_item: ItemInstance = data[0]
	var source: Variant = data[1]
	var mycharacter: Creature = get_parent().get_parent().get_inventory_owner()
	if source is Creature:
		if source == mycharacter:
			return true
		var definition := NodeAccess.__Resources().get_item_definition(dropped_item)
		if definition == null or not definition.tradeable:
			return false
		if definition.unique and GameGlobal.enforce_unique_items:
			if GameGlobal.does_party_have_same_item(dropped_item)[0]:
				return false
		return mycharacter.can_add_inventory_item(dropped_item)
	if source == "Shop":
		return inventoryrect.can_purchase_shop_item(mycharacter, dropped_item)
	return false


func _drop_data(_pos: Vector2, data: Variant) -> void:
	if inventoryrect == null or belongstoally or not _valid_drag_data(data):
		return
	var dropped_item: ItemInstance = data[0]
	var source: Variant = data[1]
	var mycharacter: Creature = get_parent().get_parent().get_inventory_owner()
	var target_index := mycharacter.item_inventory.find(item)
	var changed := false
	if source is Creature:
		if source != mycharacter:
			changed = source.transfer_inventory_item_to(
				mycharacter,
				dropped_item,
				target_index,
			)
	elif source == "Shop":
		changed = inventoryrect.purchase_shop_item(
			mycharacter,
			dropped_item,
			target_index,
		)
	if not changed:
		_play_error()
	inventoryrect.refresh_inventory_lists()


func _on_ItemSmallButton_gui_input(event: InputEvent) -> void:
	if inventoryrect == null or belongstoally or item == null:
		return
	if not (event is InputEventMouseButton) or not event.pressed:
		return
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			inventoryrect.set_selected_item_ctrl(self)
		MOUSE_BUTTON_RIGHT:
			var definition := _definition()
			if definition != null and definition.equippable:
				equip_item()
			elif _is_usable():
				var itemowner: Creature = (
					get_parent().get_parent().get_inventory_owner()
				)
				inventoryrect.use_item(item, itemowner, self)
		MOUSE_BUTTON_MIDDLE:
			if _is_usable():
				var itemowner: Creature = (
					get_parent().get_parent().get_inventory_owner()
				)
				inventoryrect.use_item(item, itemowner, self)


func equip_item() -> void:
	if item == null:
		return
	var itemowner: Creature = get_parent().get_parent().get_inventory_owner()
	var definition := _definition()
	if definition == null or not definition.equippable:
		return
	var changed := itemowner.unequip_item(item) \
		if item.equipped else itemowner.equip_item(item)
	if changed:
		GameGlobal.play_sfx(definition.sound_key)
	else:
		GameGlobal.play_sfx("target error.wav")
	set_item(item)


func _on_ItemSmallButton_mouse_entered() -> void:
	if inventoryrect == null or item == null:
		return
	inventoryrect.display_item_info(item)
	colorRect.color = Color(0.9, 0.9, 0.9, 1)
	var definition := _definition()
	infolabel.text = "Weight : %d Price : %d" % [
		definition.total_weight(item),
		definition.price,
	]
	infolabel.add_theme_color_override("font_color", Color.BLACK)


func _on_ItemSmallButton_mouse_exited() -> void:
	colorRect.color = Color.WHITE
	var definition := _definition()
	infolabel.text = definition.display_type if definition != null else ""
	infolabel.add_theme_color_override("font_color", Color.RED)


func _definition() -> ItemDefinition:
	return NodeAccess.__Resources().get_item_definition(item)


func _is_usable() -> bool:
	var definition := _definition()
	if definition == null:
		return false
	return definition.has_use("field") or definition.has_use("combat")


func _valid_drag_data(data: Variant) -> bool:
	return (
		data is Array
		and data.size() >= 2
		and data[0] is ItemInstance
	)


func _play_error() -> void:
	GameGlobal.play_sfx("generation error.ogg")
