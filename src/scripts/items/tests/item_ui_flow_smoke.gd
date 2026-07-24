extends Node

const RogueClass = preload("res://Data/Character Classes/Class_Assassin.gd")
const HumanRace = preload("res://Data/Character Races/Race_Human.gd")
const DefaultIcon = preload("res://scenes/UI/Main Menu/DefaultIcon.png")
const DefaultPortrait = preload(
	"res://scenes/UI/Main Menu/DefaultPortrait.png"
)

var failures: Array[String] = []
var assertions := 0
var _saved_players: Array = []
var _saved_shop_name := ""
var _saved_shops: Dictionary = {}
var _saved_pool: Array = []


func _ready() -> void:
	call_deferred("_run_smoke")


func _run_smoke() -> void:
	await get_tree().process_frame
	var resources: CampaignResources = NodeAccess.__Resources()
	_expect(
		resources.load_item_resources("res://shared_assets/items/"),
		"shared catalog loads for item UI flow smoke",
	)
	_saved_players = GameGlobal.player_characters.duplicate()
	_saved_shop_name = GameGlobal.currentShop
	_saved_shops = GameGlobal.shops_dict
	_saved_pool = GameGlobal.money_pool.duplicate()
	_test_inventory_equipment_ui(resources)
	_test_shop_purchase_and_sale_ui(resources)
	_test_loot_transfer_ui(resources)
	_test_storage_transfer_ui(resources)
	_test_encounter_item_selection_ui(resources)
	_restore_globals()
	_finish()


func _test_inventory_equipment_ui(resources: CampaignResources) -> void:
	var character := _player("Inventory UI")
	var dagger := resources.create_item_instance("Dagger")
	_expect(character.add_inventory_item(dagger), "inventory fixture owns dagger")
	GameGlobal.player_characters = [character]
	UI.ow_hud.selected_character = character
	var inventory: InventoryControl = UI.ow_hud.inventoryRect
	inventory.fill_inventory_Vbox(inventory.inventoryBoxRight, character)
	var row = inventory.inventoryBoxRight.get_child(0)
	_expect(row.item == dagger, "inventory row retains exact ItemInstance")
	row.equip_item()
	_expect(
		dagger.equipped
			and character.current_melee_weapon_instances.has(dagger),
		"inventory equipment action uses the row ItemInstance",
	)
	_expect(row.iconequipped.visible, "inventory row renders equipped state")
	row.equip_item()
	_expect(not dagger.equipped, "inventory row unequips the same instance")


func _test_shop_purchase_and_sale_ui(resources: CampaignResources) -> void:
	var customer := _player("Shop UI")
	customer.money[0] = 100
	GameGlobal.player_characters = [customer]
	UI.ow_hud.selected_character = customer
	GameGlobal.money_pool = [0, 0, 0]
	GameGlobal.currentShop = "Item UI Smoke Shop"
	GameGlobal.shops_dict = {
		GameGlobal.currentShop: {
			"buy_rate": 0.5,
			"sell_rate": 1.0,
			"accepted_item_names": {"Dagger": true},
			"Weapons": [["Dagger", 1, 20]],
			"Armor": [],
			"Limbs": [],
			"Magic": [],
			"Supplies": [],
			"BuyBack": [],
		},
	}
	var inventory: InventoryControl = UI.ow_hud.inventoryRect
	var shop: ShopRect = inventory.shopRect
	shop.initialize()
	shop._on_ShopButton_pressed("Weapons")
	var shop_row = shop.vbox.get_child(0)
	var stock_item: ItemInstance = shop_row.item
	_expect(
		shop_row.item == stock_item,
		"shop row retains the actual purchasable ItemInstance",
	)
	_expect(
		inventory.purchase_shop_item(customer, stock_item),
		"shop purchase succeeds through the UI service",
	)
	_expect(
		customer.item_inventory.has(stock_item),
		"purchase transfers the exact shop-button instance",
	)
	_expect_equal(customer.money[0], 80, "purchase applies listed price")
	var sold := shop.sell_item(customer, stock_item)
	_expect(bool(sold.get("ok", false)), "shop sale succeeds")
	var stock_definition := resources.get_item_definition(stock_item)
	_expect_equal(
		int(sold.get("price", -1)),
		floori(stock_definition.price * 0.5),
		"sale applies shop buy rate",
	)
	var sold_stock: Array = GameGlobal.get_shop(
		GameGlobal.currentShop
	)["Weapons"]
	_expect(
		sold_stock.back()[0] == stock_item,
		"sale preserves exact ItemInstance in shop stock",
	)


func _test_loot_transfer_ui(resources: CampaignResources) -> void:
	var looter := _player("Loot UI")
	var loot := resources.create_item_instance("Refresh Potion")
	GameGlobal.player_characters = [looter]
	UI.ow_hud.selected_character = looter
	var treasure = UI.ow_hud.treasureControl
	treasure.display([loot], [0, 0, 0], 0)
	var button: Button = treasure.itemsContainer.get_child(0)
	_expect(
		button.get_meta("item_instance") == loot,
		"loot button retains exact ItemInstance",
	)
	treasure._on_itemlootbutton_pressed(loot, button)
	_expect(
		looter.item_inventory.has(loot),
		"loot action transfers the exact button ItemInstance",
	)
	treasure.hide()


func _test_storage_transfer_ui(resources: CampaignResources) -> void:
	var character := _player("Storage UI")
	var stored_item := resources.create_item_instance("Dagger")
	_expect(character.add_inventory_item(stored_item), "storage fixture owns item")
	var storage: Honest_Storage = UI.ow_hud.honestStorageControl
	var saved_storage := storage.storage_inventory.duplicate()
	storage.storage_inventory.clear()
	storage.cur_chara = character
	var character_button := storage.create_chara_item_button(stored_item)
	_expect(
		character_button.get_meta("item_instance") == stored_item,
		"storage character button retains exact ItemInstance",
	)
	character_button.free()
	_expect(
		storage.store_item(character, stored_item),
		"storage accepts an unequipped ItemInstance",
	)
	_expect(
		storage.storage_inventory.has(stored_item)
			and not character.item_inventory.has(stored_item),
		"storage transfer preserves exact identity",
	)
	var storage_button := storage.create_storage_item_button(stored_item)
	_expect(
		storage_button.get_meta("item_instance") == stored_item,
		"stored-item button retains exact ItemInstance",
	)
	storage_button.free()
	var serialized := resources.serialize_item_inventory(
		storage.storage_inventory
	)
	_expect(
		bool(serialized.get("ok", false))
			and serialized.get("value", [])[0].get("formatVersion") == 1,
		"storage writes the versioned ItemInstance schema",
	)
	_expect(
		storage.retrieve_item(character, stored_item),
		"storage returns the item to a character",
	)
	_expect(
		character.item_inventory.has(stored_item)
			and storage.storage_inventory.is_empty(),
		"storage return preserves exact ItemInstance",
	)
	storage.storage_inventory.assign(saved_storage)


func _test_encounter_item_selection_ui(resources: CampaignResources) -> void:
	var character := _player("Encounter UI")
	var selected_item := resources.create_item_instance("Dagger")
	_expect(
		character.add_inventory_item(selected_item),
		"encounter fixture owns item",
	)
	GameGlobal.player_characters = [character]
	UI.ow_hud.selected_character = character
	var picker = UI.ow_hud.encounterControl.useitemRect
	picker.initialize_for_encounter(character)
	var button: Button = picker.itemsContainer.get_child(0)
	_expect(
		button.get_meta("item_instance") == selected_item,
		"encounter button retains exact ItemInstance",
	)
	picker._on_itembutton_pressed(selected_item, character)
	_expect(
		picker.picked_item == selected_item
			and picker.picked_character == character,
		"encounter selection returns exact item and owner",
	)


func _player(character_name: String) -> PlayerCharacter:
	return GameGlobal.playerCharacterGD.new(
		{
			"name": character_name,
			"level": 1,
			"exp_tnl": 10000,
		},
		DefaultIcon,
		DefaultPortrait,
		RogueClass,
		HumanRace,
	)


func _restore_globals() -> void:
	GameGlobal.player_characters = _saved_players
	GameGlobal.currentShop = _saved_shop_name
	GameGlobal.shops_dict = _saved_shops
	GameGlobal.money_pool = _saved_pool


func _expect(condition: bool, description: String) -> void:
	assertions += 1
	if condition:
		print("PASS: %s" % description)
		return
	failures.append(description)
	push_error("FAIL: %s" % description)


func _expect_equal(
	actual: Variant,
	expected: Variant,
	description: String,
) -> void:
	_expect(
		actual == expected,
		"%s (expected %s, got %s)" % [description, expected, actual],
	)


func _finish() -> void:
	if failures.is_empty():
		print("Item UI flow smoke passed: %d assertions." % assertions)
		get_tree().quit(0)
		return
	printerr("Item UI flow smoke failed: %s" % "; ".join(failures))
	get_tree().quit(1)
