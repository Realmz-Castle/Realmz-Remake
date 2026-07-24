extends NinePatchRect
class_name ShopRect

@onready var inventoryrect = $"../../../.."
@onready var vbox: VBoxContainer = $InvScrollContainerShop/VBoxContainerL
@onready var itemShopButtonTSCN: PackedScene = preload(
	"res://scenes/UI/HUD/Inventory/ItemShopButton.tscn"
)
@onready var resources = NodeAccess.__Resources()
@onready var goldLabel: Label = $MoneyRect/GoldnLabel
@onready var poolLabel: Label = $MoneyRect/PoolnLabel

var buy_rate := 1.0
var sell_rate := 1.0
var weapons: Array = []
var armor: Array = []
var limbs: Array = []
var magic: Array = []
var supplies: Array = []
var buyback: Array = []
var types := {
	"Weapons": weapons,
	"Armor": armor,
	"Limbs": limbs,
	"Magic": magic,
	"Supplies": supplies,
	"BuyBack": buyback,
}
var current_shop_category := "Weapons"


func initialize() -> void:
	var chara: Creature = inventoryrect.hud.selected_character
	goldLabel.text = str(chara.money[0])
	poolLabel.text = str(GameGlobal.money_pool[0])
	for category: String in types:
		types[category].clear()
	var shop_name := GameGlobal.currentShop
	if shop_name.is_empty():
		return
	var shop: Dictionary = GameGlobal.get_shop(shop_name)
	buy_rate = float(shop["buy_rate"])
	sell_rate = float(shop["sell_rate"])
	for category: String in types:
		var source_stock: Array = shop.get(category, [])
		for source_index: int in source_stock.size():
			var entry: Array = source_stock[source_index]
			if entry.size() < 3:
				continue
			var instance := _stock_instance(entry[0], category != "BuyBack")
			if instance == null:
				continue
			var definition := resources.get_item_definition(instance)
			var price := int(entry[2])
			if price <= 0 and definition != null:
				price = int(sell_rate * definition.price)
			types[category].append([
				instance,
				int(entry[1]),
				price,
				source_index,
			])


func _on_LeaveShopButton_pressed() -> void:
	if not visible:
		return
	for category: String in types:
		types[category].clear()
	inventoryrect.hud.set_charactersRect_type(0)
	hide()
	inventoryrect.hud.moneyControl._on_ShareButton_pressed()
	inventoryrect.buttonIdenPay.hide()


func _on_character_selected(chara: Creature) -> void:
	goldLabel.text = str(chara.money[0])
	poolLabel.text = str(GameGlobal.money_pool[0])


func _on_PoolButton_pressed() -> void:
	inventoryrect.hud.moneyControl.initialize(GameGlobal.player_characters)
	inventoryrect.hud.moneyControl._on_PoolButton_pressed()
	goldLabel.text = "0"
	poolLabel.text = str(GameGlobal.money_pool[0])


func _on_ShopButton_pressed(category: String) -> void:
	current_shop_category = category
	fillVbox(category)


func fillVbox(category: String) -> void:
	for child: Node in vbox.get_children():
		child.queue_free()
	for stock_value: Variant in types.get(category, []):
		var stock: Array = stock_value
		if int(stock[1]) <= 0:
			continue
		var item_button = itemShopButtonTSCN.instantiate()
		vbox.add_child(item_button)
		item_button.set_item(stock[0], stock[1], inventoryrect, stock[2])


func price_for(item: ItemInstance) -> int:
	for stock_value: Variant in types.get(current_shop_category, []):
		var stock: Array = stock_value
		if stock[0] == item and int(stock[1]) > 0:
			return int(stock[2])
	return -1


func purchase_item(
	customer: Creature,
	item: ItemInstance,
	target_index := -1,
) -> Dictionary:
	if customer == null or item == null:
		return {"ok": false, "price": 0}
	var category_stock: Array = types.get(current_shop_category, [])
	for stock_value: Variant in category_stock:
		var stock: Array = stock_value
		if stock[0] != item or int(stock[1]) <= 0:
			continue
		if not customer.add_inventory_item(item, target_index):
			return {"ok": false, "price": int(stock[2])}
		stock[1] = int(stock[1]) - 1
		var saved_stock: Array = GameGlobal.get_shop(
			GameGlobal.currentShop
		).get(current_shop_category, [])
		var source_index := int(stock[3])
		if source_index >= 0 and source_index < saved_stock.size():
			saved_stock[source_index][1] = stock[1]
		if int(stock[1]) > 0:
			var replacement := resources.copy_item_instance(
				item,
				{"equipped": false},
			)
			if replacement == null:
				customer.remove_inventory_item(item)
				stock[1] = int(stock[1]) + 1
				if source_index >= 0 and source_index < saved_stock.size():
					saved_stock[source_index][1] = stock[1]
				return {"ok": false, "price": int(stock[2])}
			stock[0] = replacement
			if source_index >= 0 \
					and source_index < saved_stock.size() \
					and saved_stock[source_index][0] is ItemInstance:
				saved_stock[source_index][0] = replacement
		return {"ok": true, "price": int(stock[2]), "item": item}
	return {"ok": false, "price": 0}


func sell_item(owner: Creature, item: ItemInstance) -> Dictionary:
	if owner == null or item == null or item.equipped:
		return {"ok": false, "price": 0}
	var definition := resources.get_item_definition(item)
	if definition == null or not definition.tradeable:
		return {"ok": false, "price": 0}
	var category := _category_for_definition(definition)
	if not GameGlobal.get_shop(GameGlobal.currentShop).has(category):
		category = "BuyBack"
	var price := int(definition.price * buy_rate)
	if not owner.remove_inventory_item(item):
		return {"ok": false, "price": 0}
	var saved_stock: Array = GameGlobal.get_shop(
		GameGlobal.currentShop
	)[category]
	saved_stock.append([item, 1, price])
	types[category].append([item, 1, price, saved_stock.size() - 1])
	return {
		"ok": true,
		"price": price,
		"category": category,
		"item": item,
	}


func _stock_instance(source_value: Variant, refill_charges: bool) -> ItemInstance:
	var instance: ItemInstance = null
	if source_value is ItemInstance:
		instance = source_value
	elif source_value is String:
		instance = resources.create_item_instance(source_value)
	else:
		instance = resources.import_item_instance(source_value)
	if instance == null:
		return null
	var definition := resources.get_item_definition(instance)
	if refill_charges and definition != null and definition.maximum_charges > 0:
		instance.charges = definition.maximum_charges
	instance.equipped = false
	return instance


func _category_for_definition(definition: ItemDefinition) -> String:
	var item_type := definition.item_type
	if item_type in ShopInventoryContainer.WEAPON_TYPES:
		return "Weapons"
	if item_type in ShopInventoryContainer.ARMOR_TYPES:
		return "Armor"
	if item_type in ShopInventoryContainer.LIMB_TYPES:
		return "Limbs"
	if item_type in ShopInventoryContainer.SUPPLY_TYPES:
		return "Supplies"
	return "BuyBack"
