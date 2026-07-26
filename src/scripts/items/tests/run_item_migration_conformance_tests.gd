extends SceneTree

const ItemCatalogScript = preload("res://scripts/items/item_catalog.gd")
const ItemSerializationScript = preload(
	"res://scripts/items/item_serialization.gd"
)

const MIGRATED_CONSUMERS := [
	"res://Creature/Creature.gd",
	"res://Creature/PlayerCharacter.gd",
	"res://scripts/GameGlobal.gd",
	"res://scripts/ScriptHelperFuncs.gd",
	"res://scripts/battle_reward_rules.gd",
	"res://scripts/states/CbMenusState.gd",
	"res://scripts/states/ExMenusState.gd",
	"res://scripts/states/CbDecideActionState.gd",
	"res://scripts/states/CbAnimationState.gd",
	"res://scripts/classic_runtime/classic_core_identify_spell.gd",
	"res://scripts/classic_runtime/classic_magic_resistance.gd",
	"res://scripts/classic_runtime/classic_monster_decision.gd",
	"res://scripts/native_encounters/native_encounter_controller.gd",
	"res://scenes/UI/HUD/Characters Panel/CharacterSmallPanel.gd",
	"res://scenes/UI/HUD/CreatureCBRect/creature_rect.gd",
	"res://scenes/UI/HUD/Inventory/InventoryContainer.gd",
	"res://scenes/UI/HUD/Inventory/InventoryRect.gd",
	"res://scenes/UI/HUD/Inventory/ItemShopButton.gd",
	"res://scenes/UI/HUD/Inventory/ItemSmallButton.gd",
	"res://scenes/UI/HUD/Inventory/ShopInventoryContainerShop.gd",
	"res://scenes/UI/HUD/Inventory/ShopRect.gd",
	"res://scenes/UI/HUD/Looting/TreasureControl.gd",
	"res://scenes/UI/HUD/Special Encounter/EncounterControl.gd",
	"res://scenes/UI/HUD/Special Encounter/UseItemRect.gd",
	"res://scenes/UI/HUD/Storage/storage_rect.gd",
	"res://scenes/UI/HUD/TextRect.gd",
	"res://shared_assets/CreatureScripts/dumb_melee.gd",
	"res://shared_assets/CreatureScripts/runningaway.gd",
	"res://shared_assets/spells/discover_magic.gd",
]

const FORBIDDEN_MIGRATION_TOKENS := [
	"get_item_runtime_view",
	"runtime_item_view(",
	"sync_runtime_item_instance(",
	"serialize_runtime_item_inventory(",
	"deserialize_runtime_item_inventory(",
	"inventory_item_views",
	"[\"_item_instance\"]",
]

const REQUIRED_STABLE_TOKENS := {
	"res://Creature/Creature.gd": [
		"item_inventory: Array[ItemInstance]",
		"serialize_item_inventory(",
		"deserialize_item_inventory_preserving_unresolved(",
	],
	"res://Creature/PlayerCharacter.gd": [
		"item_inventory",
		"get_item_definition(",
	],
	"res://scripts/GameGlobal.gd": [
		"func generate_item(itemname : String) -> ItemInstance",
		"get_item_definition(",
	],
	"res://scripts/battle_reward_rules.gd": ["inventory_instances()"],
	"res://scenes/UI/HUD/Inventory/ItemSmallButton.gd": [
		"item: ItemInstance",
	],
	"res://scenes/UI/HUD/Looting/TreasureControl.gd": [
		"ItemInstance",
	],
	"res://scenes/UI/HUD/Storage/storage_rect.gd": [
		"serialize_item_inventory(",
		"deserialize_item_inventory(",
	],
	"res://scripts/native_encounters/native_encounter_controller.gd": [
		"_on_item_used(item: ItemInstance",
	],
	"res://scripts/states/CbDecideActionState.gd": [
		"var used_weapon: Variant =",
	],
	"res://scripts/states/CbAnimationState.gd": [
		"var weapon: Variant = msg[\"weapon\"]",
		"compatibility_weapon",
	],
}

var _assertions := 0
var _failures: Array[String] = []


func _init() -> void:
	_test_source_boundaries()
	_test_definition_and_instance_invariants()
	_test_save_and_legacy_import_boundary()
	_finish()


func _test_source_boundaries() -> void:
	for path: String in MIGRATED_CONSUMERS:
		_expect(FileAccess.file_exists(path), "audited consumer exists: %s" % path)
		if not FileAccess.file_exists(path):
			continue
		var source := FileAccess.get_file_as_string(path)
		for token: String in FORBIDDEN_MIGRATION_TOKENS:
			_expect(
				not source.contains(token),
				"%s does not use removed runtime adapter %s" % [path, token],
			)
	for path_value: Variant in REQUIRED_STABLE_TOKENS:
		var path := str(path_value)
		var source := FileAccess.get_file_as_string(path)
		for token_value: Variant in REQUIRED_STABLE_TOKENS[path_value]:
			var token := str(token_value)
			_expect(
				source.contains(token),
				"%s exposes stable item API token %s" % [path, token],
			)


func _test_definition_and_instance_invariants() -> void:
	var catalog := _fixture_catalog()
	var first := catalog.create_instance(
		"shared:Conformance%20Potion",
		{
			"charges": 2,
			"stateData": {"owner": "first"},
		},
	)
	var second := catalog.create_instance(
		"shared:Conformance%20Potion",
		{
			"charges": 1,
			"stateData": {"owner": "second"},
		},
	)
	_expect(first != null and second != null, "two instances construct")
	if first == null or second == null:
		return
	var first_definition := catalog.get_definition(first.definition_id)
	var second_definition := catalog.get_definition(second.definition_id)
	_expect(
		first_definition == second_definition,
		"matching instances share one immutable ItemDefinition",
	)
	_expect(
		first.instance_id != second.instance_id,
		"matching instances have independent stable identities",
	)
	first.charges = 0
	first.equipped = true
	first.identified = false
	first.set_state_value("owner", "changed")
	_expect_equal(second.charges, 1, "charge mutation is instance-local")
	_expect(not second.equipped, "equipment mutation is instance-local")
	_expect(second.identified, "identification mutation is instance-local")
	_expect_equal(
		second.state_value("owner"),
		"second",
		"extension-state mutation is instance-local",
	)
	var detached_definition := first_definition.to_dictionary()
	detached_definition["name"] = "Mutated copy"
	_expect_equal(
		first_definition.display_name,
		"Conformance Potion",
		"definition access returns detached data rather than mutable catalog state",
	)


func _test_save_and_legacy_import_boundary() -> void:
	var catalog := _fixture_catalog()
	var serializer := ItemSerializationScript.new(catalog)
	var native_item := catalog.create_instance(
		"shared:Conformance%20Potion",
		{
			"charges": 2,
			"equipped": true,
			"identified": false,
			"stateData": {"note": "round trip"},
		},
	)
	var saved := serializer.serialize_inventory([native_item])
	_expect(bool(saved.get("ok", false)), "native inventory serializes")
	var saved_values: Array = saved.get("value", [])
	_expect_equal(saved_values.size(), 1, "native inventory writes one item")
	if not saved_values.is_empty():
		_expect_equal(
			saved_values[0].get("format"),
			"realmz-remake-item-instance",
			"native save uses the public versioned schema",
		)
		_expect_equal(
			saved_values[0].get("formatVersion"),
			1,
			"native save declares serializer version",
		)
		_expect(
			not saved_values[0].has("name")
				and not saved_values[0].has("texture")
				and not saved_values[0].has("_item_instance"),
			"native save contains no dictionary mirror or runtime object fields",
		)
	var restored := serializer.import_inventory(saved_values)
	_expect(bool(restored.get("ok", false)), "native versioned inventory restores")
	var restored_values: Array = restored.get("instances", [])
	_expect_equal(restored_values.size(), 1, "native restore returns one instance")
	if not restored_values.is_empty():
		var restored_item: ItemInstance = restored_values[0]
		_expect_equal(
			restored_item.instance_id,
			native_item.instance_id,
			"native save round trip preserves instance identity",
		)
		_expect_equal(restored_item.charges, 2, "native save preserves charges")
		_expect(restored_item.equipped, "native save preserves equipment")
		_expect(not restored_item.identified, "native save preserves identification")

	var legacy_item := _definition_source("Conformance Potion")
	legacy_item["charges"] = 1
	legacy_item["equipped"] = 1
	legacy_item["is_identified"] = 0
	var legacy_import := serializer.import_inventory([legacy_item])
	_expect(bool(legacy_import.get("ok", false)), "old-save dictionary imports")
	var legacy_instances: Array = legacy_import.get("instances", [])
	_expect_equal(legacy_instances.size(), 1, "old-save import returns one instance")
	if not legacy_instances.is_empty():
		var imported_item: ItemInstance = legacy_instances[0]
		_expect_equal(
			imported_item.definition_id,
			"shared:Conformance%20Potion",
			"old-save exact name is resolved only inside the import boundary",
		)
		var migrated_save := serializer.serialize_inventory([imported_item])
		_expect(
			bool(migrated_save.get("ok", false))
				and migrated_save.get("value", [])[0].get("formatVersion") == 1,
			"old-save item is rewritten in the versioned schema",
		)

	var custom_legacy := _definition_source("Uninstalled Custom Relic")
	custom_legacy["KEY"] = "Uninstalled Custom Relic"
	custom_legacy["charges"] = 4
	custom_legacy["charges_max"] = 5
	custom_legacy["customField"] = {"portable": true}
	var custom_import := serializer.import_inventory([custom_legacy])
	_expect(
		bool(custom_import.get("ok", false)),
		"uninstalled old-campaign custom item imports",
	)
	var custom_instances: Array = custom_import.get("instances", [])
	_expect_equal(custom_instances.size(), 1, "custom import returns one instance")
	if not custom_instances.is_empty():
		var custom_item: ItemInstance = custom_instances[0]
		_expect(
			custom_item.definition_id.begins_with("embedded:sha256:"),
			"uninstalled custom item receives content-addressed identity",
		)
		var custom_save := serializer.serialize_inventory([custom_item])
		var custom_saved_values: Array = custom_save.get("value", [])
		_expect(
			bool(custom_save.get("ok", false))
				and custom_saved_values.size() == 1
				and custom_saved_values[0].has("embeddedDefinition"),
			"custom item remains self-contained in the versioned save",
		)


func _fixture_catalog() -> ItemCatalog:
	var catalog := ItemCatalogScript.new()
	var item_book := {
		"Conformance Potion": _definition_source("Conformance Potion"),
	}
	var loaded := catalog.load_book(
		item_book,
		"shared",
		"",
		"fixture/conformance/stuff_book.json",
		{"ITEM_Test": true},
	)
	_expect(loaded, "conformance shared catalog loads: %s" % [catalog.last_errors])
	if loaded:
		var definition_id := catalog.resolve_catalog_key(
			"shared",
			"",
			"Conformance Potion",
		)
		_expect(
			catalog.bind_legacy_template(
				definition_id,
				item_book["Conformance Potion"],
			),
			"conformance legacy import template binds",
		)
	return catalog


func _definition_source(item_name: String) -> Dictionary:
	return {
		"name": item_name,
		"description": "Conformance fixture",
		"type": "Misc. Item",
		"img_ptr": "ITEM_Test",
		"sound": "",
		"price": 5,
		"stats": {},
		"slots": [],
		"weight": 1,
		"charges": 3,
		"charges_max": 3,
		"charges_weight": 0,
	}


func _expect(condition: bool, message: String) -> void:
	_assertions += 1
	if not condition:
		_failures.append(message)


func _expect_equal(actual: Variant, expected: Variant, message: String) -> void:
	_expect(
		actual == expected,
		"%s; expected %s, got %s" % [message, expected, actual],
	)


func _finish() -> void:
	if _failures.is_empty():
		print(
			"ITEM_MIGRATION_CONFORMANCE PASS: %d assertions." % _assertions
		)
		quit(0)
		return
	for failure: String in _failures:
		printerr("ITEM_MIGRATION_CONFORMANCE FAIL: %s" % failure)
	printerr(
		"ITEM_MIGRATION_CONFORMANCE FAILURES: %d/%d"
		% [_failures.size(), _assertions]
	)
	quit(1)
