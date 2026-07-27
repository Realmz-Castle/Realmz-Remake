extends Control

@export var itemLootButton: PackedScene

@onready var itemsRect = $itemsRect
@onready var expRect = $ExpRect
@onready var botrightpanel = $BotRightLootInfo
@onready var itemsContainer: GridContainer = (
	$itemsRect/ScrollContainer/ItemContainer
)
@onready var itemTextureRect: TextureRect = (
	$BotRightLootInfo/ItemInfoRect/ItemTextureRect
)
@onready var itemNameLabel: Label = $BotRightLootInfo/ItemInfoRect/ItemNameLabel
@onready var itemStatsLabel: Label = (
	$BotRightLootInfo/ItemInfoRect/ItemStatsLabel
)
@onready var itemsWeightLabel: Label = (
	$BotRightLootInfo/ItemInfoRect/ItemWeightLabel
)
@onready var explabel: Label = $ExpRect/ExpLabel
@onready var moneyLabel: Label = $BotRightLootInfo/ItemInfoRect/MoneynLabel
@onready var detect_button: Button = $BotRightLootInfo/DetectButton

var exp_gain := 0
var exp_receivers: Array = []
var classic_battle_reward := false
var already_identified := false
var pending_items: Array[ItemInstance] = []

signal done_looting


func on_viewport_size_changed(screensize: Vector2) -> void:
	itemsRect.size = Vector2(screensize.x - 320, screensize.y - 24)
	expRect.position = Vector2(0, screensize.y - 24)
	expRect.size = Vector2(screensize.x - 320, 24)
	botrightpanel.position = Vector2(screensize.x - 320, screensize.y - 200)
	itemsContainer.columns = floori((screensize.x - 320) / 50.0) - 1


func display(
	items: Array,
	money: Array,
	experience: int,
	is_classic_battle_reward := false,
) -> void:
	exp_gain = experience
	classic_battle_reward = is_classic_battle_reward
	exp_receivers.clear()
	pending_items.clear()
	detect_button.disabled = false
	already_identified = false
	for child: Node in itemsContainer.get_children():
		child.queue_free()
	for pc: PlayerCharacter in GameGlobal.player_characters:
		if pc.get_stat("curHP") > 0 \
				and GameGlobal.can_character_receive_experience(pc):
			exp_receivers.append(pc)
	explabel.text = " Experience : %d, split among %d characters" % [
		exp_gain,
		exp_receivers.size(),
	]
	for currency_index: int in mini(3, money.size()):
		GameGlobal.money_pool[currency_index] += int(money[currency_index])
	update_money_label()
	var resources = NodeAccess.__Resources()
	for item_value: Variant in items:
		var instance := resources.import_item_instance(item_value)
		if instance == null:
			continue
		instance.equipped = false
		pending_items.append(instance)
		var button: Button = itemLootButton.instantiate()
		button.set_meta("item_instance", instance)
		button.find_child("ItemTextureRect").texture = (
			resources.item_texture(instance)
		)
		button.pressed.connect(_on_itemlootbutton_pressed.bind(instance, button))
		button.mouse_entered.connect(
			_on_itemlootbutton_mouse_entered.bind(instance, button)
		)
		button.mouse_exited.connect(_on_itemlootbutton_mouse_exited)
		itemsContainer.add_child(button)
	show()


func _on_itemlootbutton_mouse_entered(
	item: ItemInstance,
	button: Button,
) -> void:
	if button.disabled:
		_on_itemlootbutton_mouse_exited()
		return
	var resources = NodeAccess.__Resources()
	var definition := resources.get_item_definition(item)
	if definition == null:
		return
	itemTextureRect.show()
	itemNameLabel.show()
	itemStatsLabel.show()
	itemsWeightLabel.show()
	itemTextureRect.texture = resources.item_texture(item)
	var item_name := definition.display_name_for(item)
	if item.identified and definition.maximum_charges > 0:
		item_name += " X%d" % item.charges
	itemNameLabel.text = "%s (%s)" % [item_name, definition.display_type]
	itemStatsLabel.text = definition.stats_summary if item.identified else ""
	itemsWeightLabel.text = "Weight : %d" % definition.total_weight(item)


func _on_itemlootbutton_mouse_exited() -> void:
	itemTextureRect.hide()
	itemNameLabel.hide()
	itemStatsLabel.hide()
	itemsWeightLabel.hide()


func _on_itemlootbutton_pressed(
	item: ItemInstance,
	button: Button,
) -> void:
	var looter: Creature = UI.ow_hud.selected_character
	if not looter.add_inventory_item(item):
		return
	pending_items.erase(item)
	button.disabled = true
	button.release_focus()
	for child: Node in button.get_children():
		child.queue_free()
	UI.ow_hud.updateCharPanelDisplay()


func close() -> void:
	if not exp_receivers.is_empty():
		await GameGlobal.give_exp_to_pcs(
			floori(float(exp_gain) / exp_receivers.size()),
			exp_receivers,
			classic_battle_reward,
		)
	for child: Node in itemsContainer.get_children():
		child.queue_free()
	pending_items.clear()
	get_parent().set_charactersRect_type(0)
	get_parent().moneyControl.close()
	NodeAccess.__Map().show()
	StateMachine.exit_ex_menu_state()
	hide()
	done_looting.emit()


func _on_ButtonDone_pressed() -> void:
	close()


func update_money_label() -> void:
	var lines: Array[String] = []
	for amount: Variant in GameGlobal.money_pool:
		lines.append(str(amount))
	moneyLabel.text = "\n".join(lines)


func _on_PoolButton_pressed() -> void:
	get_parent().moneyControl._on_PoolButton_pressed()
	update_money_label()


func _on_ShareButton_pressed() -> void:
	get_parent().moneyControl._on_ShareButton_pressed()
	update_money_label()


func _on_money_button_pressed() -> void:
	get_parent()._on_MoneyButton_pressed()


func _on_detect_button_pressed() -> void:
	if already_identified:
		return
	var character: Creature = UI.ow_hud.selected_character
	var resources = NodeAccess.__Resources()
	var discover_spell = resources.spells_book["Discover Magic"]["script"]
	var sp_cost: int = character.get_spell_resource_cost(discover_spell, 1)
	if not (
		character.does_crea_know_spell_named("Discover Magic")
		and character.get_stat("curSP") >= sp_cost
	):
		GameGlobal.play_sfx("generation error.wav")
		return
	for button: Button in itemsContainer.get_children():
		var item: Variant = button.get_meta("item_instance")
		if item is ItemInstance:
			var definition := resources.get_item_definition(item)
			if definition != null and definition.magical:
				button.find_child("GlowTextureRect").show()
	character.change_cur_sp(-sp_cost)
	detect_button.disabled = true
	already_identified = true
