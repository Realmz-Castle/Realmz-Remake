extends SceneTree

const ItemCatalogScript = preload("res://scripts/items/item_catalog.gd")
const ItemInstanceScript = preload("res://scripts/items/item_instance.gd")
const ItemSerializationScript = preload(
	"res://scripts/items/item_serialization.gd"
)

var _assertions := 0
var _failures: Array[String] = []


func _init() -> void:
	_test_catalog_backed_round_trips()
	_test_deferred_catalog_item_preservation()
	_test_legacy_inventory_import()
	_test_embedded_custom_item_round_trip()
	_test_transactional_rejection()
	_finish()


func _test_deferred_catalog_item_preservation() -> void:
	var serializer := ItemSerializationScript.new(ItemCatalogScript.new())
	var saved_item := {
		"format": "realmz-remake-item-instance",
		"formatVersion": 1,
		"instanceId": "44444444-4444-4444-8444-444444444444",
		"definitionId": "classic:scenario-fixture:901",
		"state": {
			"charges": 4,
			"equipped": false,
			"identified": true,
			"data": {"questState": "carried"},
		},
	}
	var strict_result := serializer.import_inventory([saved_item])
	_expect(
		not bool(strict_result.get("ok", true)),
		"strict import still rejects an unavailable catalog definition",
	)
	var deferred_result := serializer.import_inventory([saved_item], "", true)
	_expect(
		bool(deferred_result.get("ok", false)),
		"portable character import can defer an unavailable catalog definition",
	)
	_expect_equal(
		deferred_result.get("instances", []).size(),
		0,
		"deferred catalog items are not materialized without their definition",
	)
	_expect_equal(
		deferred_result.get("deferred", []),
		[saved_item],
		"deferred catalog items preserve their exact serialized payload",
	)
	var malformed_item := saved_item.duplicate(true)
	malformed_item["state"].erase("charges")
	var malformed_result := serializer.import_inventory(
		[malformed_item],
		"",
		true,
	)
	_expect(
		not bool(malformed_result.get("ok", true)),
		"deferral does not accept a malformed item payload",
	)
	var duplicate_result := serializer.import_inventory(
		[saved_item, saved_item.duplicate(true)],
		"",
		true,
	)
	_expect(
		not bool(duplicate_result.get("ok", true)),
		"deferred inventory still rejects duplicate instance identities",
	)


func _test_catalog_backed_round_trips() -> void:
	var source_catalog := _catalog_with_fixture_books()
	var source_serializer := ItemSerializationScript.new(source_catalog)
	var sword := source_catalog.create_instance(
		"shared:Fixture%20Sword",
		{
			"charges": 0,
			"equipped": true,
			"identified": true,
			"stateData": {"ownerNote": "front line"},
		},
	)
	var potion := source_catalog.create_instance(
		"shared:Fixture%20Potion",
		{
			"charges": 2,
			"identified": false,
		},
	)
	var classic := source_catalog.create_instance(
		"classic:scenario-fixture:901",
		{
			"charges": 4,
			"equipped": true,
		},
	)
	var saved_result := source_serializer.serialize_inventory(
		[sword, potion, classic]
	)
	_expect(
		bool(saved_result.get("ok", false)),
		"catalog-backed inventory serializes: %s" % [saved_result.get("errors", [])],
	)
	if not bool(saved_result.get("ok", false)):
		return
	var saved: Array = saved_result.get("value", [])
	_expect_equal(saved.size(), 3, "all catalog-backed items serialize")
	_expect_equal(
		saved[0].get("format"),
		"realmz-remake-item-instance",
		"save format identity is explicit",
	)
	_expect_equal(saved[0].get("formatVersion"), 1, "save format is versioned")
	_expect_equal(
		saved[0].get("definitionId"),
		"shared:Fixture%20Sword",
		"shared identity is serialized instead of display name",
	)
	_expect_equal(
		saved[0].get("state"),
		{
			"charges": 0,
			"equipped": true,
			"identified": true,
			"data": {"ownerNote": "front line"},
		},
		"equipment state is isolated from immutable definition data",
	)
	_expect(
		not saved[0].has("embeddedDefinition"),
		"catalog-backed items do not duplicate their definitions",
	)
	_expect(
		not _contains_key_recursive(saved, "texture"),
		"serialized inventory excludes runtime textures",
	)

	var restored_catalog := _catalog_with_fixture_books()
	var restored_serializer := ItemSerializationScript.new(restored_catalog)
	var restored_result := restored_serializer.import_inventory(
		saved,
		"scenario-fixture",
	)
	_expect(
		bool(restored_result.get("ok", false)),
		"catalog-backed inventory restores: %s" % [restored_result.get("errors", [])],
	)
	if not bool(restored_result.get("ok", false)):
		return
	var restored: Array = restored_result.get("instances", [])
	_expect_equal(restored.size(), 3, "all catalog-backed instances restore")
	_expect_equal(
		restored[0].instance_id,
		sword.instance_id,
		"shared instance identity survives round trip",
	)
	_expect_equal(
		restored[0].state_value("ownerNote"),
		"front line",
		"mutable extension state survives round trip",
	)
	_expect(restored[0].equipped, "equipment state survives round trip")
	_expect_equal(restored[1].charges, 2, "consumable charges survive round trip")
	_expect(not restored[1].identified, "identification survives round trip")
	_expect_equal(
		restored[2].definition_id,
		"classic:scenario-fixture:901",
		"campaign-local Classic identity survives round trip",
	)
	_expect_equal(restored[2].charges, 4, "Classic charged item state survives")
	var views: Array = restored_result.get("legacyViews", [])
	_expect_equal(
		views[0].get("name"),
		"Fixture Sword",
		"temporary runtime view rebuilds catalog display data",
	)
	_expect_equal(
		views[0].get("instanceId"),
		sword.instance_id,
		"temporary runtime view retains stable instance identity",
	)


func _test_legacy_inventory_import() -> void:
	var catalog := _catalog_with_fixture_books()
	var serializer := ItemSerializationScript.new(catalog)
	var legacy_sword := _definition_source(
		"Fixture Sword",
		"Longsword",
		10,
	)
	legacy_sword["charges"] = 0
	legacy_sword["charges_max"] = 0
	legacy_sword["equipped"] = 2
	legacy_sword["is_identified"] = 0
	legacy_sword["classicItemId"] = 31
	legacy_sword["stateData"] = {"nickname": "Old Reliable"}
	legacy_sword["texture"] = RefCounted.new()
	var legacy_classic := _definition_source(
		"Old scenario blade name",
		"Longsword",
		12,
	)
	legacy_classic["classicItemId"] = -901
	legacy_classic["charges"] = 9
	legacy_classic["charges_max"] = 5
	legacy_classic["equipped"] = 1
	var source_copy := legacy_sword.duplicate(true)
	var imported := serializer.import_inventory(
		[legacy_sword, legacy_classic],
		"scenario-fixture",
	)
	_expect(
		bool(imported.get("ok", false)),
		"legacy inventory imports: %s" % [imported.get("errors", [])],
	)
	_expect_equal(
		legacy_sword,
		source_copy,
		"legacy import does not mutate the source dictionary",
	)
	if not bool(imported.get("ok", false)):
		return
	var instances: Array = imported.get("instances", [])
	_expect_equal(
		instances[0].definition_id,
		"shared:Fixture%20Sword",
		"exact legacy display-name fallback resolves the installed definition",
	)
	_expect(instances[0].equipped, "legacy transient equipped marker imports as true")
	_expect(not instances[0].identified, "legacy identification state is preserved")
	_expect_equal(
		instances[0].state_value("nickname"),
		"Old Reliable",
		"legacy mutable state is preserved",
	)
	_expect_equal(
		imported.get("legacyViews", [])[0].get("classicItemId"),
		31,
		"legacy Classic identity survives exact-name catalog resolution",
	)
	var migrated_sword := serializer.serialize_item(instances[0])
	var migrated_result := ItemSerializationScript.new(catalog).import_item(
		migrated_sword
	)
	_expect(
		bool(migrated_result.get("ok", false)),
		"migrated catalog item reloads: %s" % [migrated_result.get("errors", [])],
	)
	if bool(migrated_result.get("ok", false)):
		_expect_equal(
			migrated_result.get("legacyView", {}).get("classicItemId"),
			31,
			"versioned round trip retains unresolved legacy Classic identity",
		)
	_expect_equal(
		instances[1].definition_id,
		"classic:scenario-fixture:901",
		"explicit Classic ID wins over a stale display name",
	)
	_expect_equal(
		instances[1].charges,
		9,
		"out-of-range legacy charges are retained without clamping",
	)
	_expect(
		_array_contains_fragment(
			imported.get("diagnostics", []),
			"outside definition range",
		),
		"legacy out-of-range state produces a migration diagnostic",
	)
	_expect(
		not _contains_key_recursive(
			serializer.serialize_item(instances[0]),
			"texture",
		),
		"legacy runtime objects never enter versioned output",
	)


func _test_embedded_custom_item_round_trip() -> void:
	var catalog := ItemCatalogScript.new()
	var serializer := ItemSerializationScript.new(catalog)
	var custom_item := _definition_source(
		"Portable Storm Wand",
		"Misc. Magical Item",
		77,
	)
	custom_item["unidentified_name"] = "Crackling rod"
	custom_item["charges"] = 3
	custom_item["charges_max"] = 6
	custom_item["equipped"] = 1
	custom_item["is_identified"] = 0
	custom_item["classicItemId"] = 1444
	custom_item["imgdata"] = "H4sIAAAAAAACA2NgYGBgAAAABQAB"
	custom_item["imgdatasize"] = 4
	custom_item["_on_field_use_source"] = "\nreturn true\n"
	custom_item["traits"] = [["portable_trait", [2]]]
	custom_item["portable_trait_source"] = "extends RefCounted\n"
	custom_item["customCampaignFlag"] = {"value": [1, 2, 3]}
	custom_item["texture"] = RefCounted.new()
	custom_item["_on_field_use"] = GDScript.new()
	var imported := serializer.import_item(custom_item)
	_expect(
		bool(imported.get("ok", false)),
		"self-contained custom item imports: %s" % [imported.get("errors", [])],
	)
	if not bool(imported.get("ok", false)):
		return
	var instance: ItemInstance = imported.get("instance")
	_expect(
		instance.definition_id.begins_with("embedded:sha256:"),
		"unresolved custom item receives digest identity",
	)
	_expect_equal(instance.charges, 3, "custom current charges remain instance state")
	_expect(instance.equipped, "custom equipment state is preserved")
	_expect(not instance.identified, "custom identification state is preserved")
	var saved := serializer.serialize_item(instance)
	var embedded: Dictionary = saved.get("embeddedDefinition", {})
	_expect(not embedded.is_empty(), "custom item save embeds its definition")
	_expect_equal(
		embedded.get("media"),
		{
			"encoding": "gzip+base64-png",
			"data": "H4sIAAAAAAACA2NgYGBgAAAABQAB",
			"bytes": 4,
		},
		"portable compressed image source is preserved",
	)
	_expect_equal(
		embedded.get("hooks", {}).get("sources", {}).get(
			"_on_field_use_source"
		),
		"\nreturn true\n",
		"custom hook source is preserved",
	)
	_expect_equal(
		embedded.get("hooks", {}).get("sources", {}).get(
			"portable_trait_source"
		),
		"extends RefCounted\n",
		"custom trait source is preserved",
	)
	_expect_equal(
		embedded.get("gameplay", {}).get("extraData", {}).get(
			"legacyDefinitionFields",
			{},
		).get("customCampaignFlag"),
		{"value": [1, 2, 3]},
		"unknown portable custom definition data is retained explicitly",
	)
	_expect(
		not _contains_key_recursive(saved, "_on_field_use"),
		"compiled hook objects are excluded from embedded output",
	)
	_expect(
		not _contains_key_recursive(saved, "texture"),
		"custom runtime textures are excluded from embedded output",
	)

	var restored_catalog := ItemCatalogScript.new()
	var restored_serializer := ItemSerializationScript.new(restored_catalog)
	var restored := restored_serializer.import_item(saved)
	_expect(
		bool(restored.get("ok", false)),
		"embedded custom item restores without an installed catalog: %s"
		% [restored.get("errors", [])],
	)
	if not bool(restored.get("ok", false)):
		return
	var restored_instance: ItemInstance = restored.get("instance")
	_expect_equal(
		restored_instance.instance_id,
		instance.instance_id,
		"embedded item instance identity survives round trip",
	)
	_expect_equal(
		restored_instance.definition_id,
		instance.definition_id,
		"embedded definition identity survives round trip",
	)
	var restored_view: Dictionary = restored.get("legacyView", {})
	_expect_equal(
		restored_view.get("imgdata"),
		custom_item["imgdata"],
		"temporary runtime view rebuilds embedded image source",
	)
	_expect_equal(
		restored_view.get("_on_field_use_source"),
		custom_item["_on_field_use_source"],
		"temporary runtime view rebuilds embedded hook source",
	)


func _test_transactional_rejection() -> void:
	var catalog := _catalog_with_fixture_books()
	var serializer := ItemSerializationScript.new(catalog)
	var definition_count := catalog.definition_count()
	var future_item := {
		"format": "realmz-remake-item-instance",
		"formatVersion": 2,
		"instanceId": "11111111-1111-4111-8111-111111111111",
		"definitionId": "shared:Fixture%20Sword",
		"state": {
			"charges": 0,
			"equipped": false,
			"identified": true,
			"data": {},
		},
	}
	var future_copy := future_item.duplicate(true)
	var future_result := serializer.import_inventory([future_item])
	_expect(
		not bool(future_result.get("ok", true)),
		"unsupported future schema is rejected",
	)
	_expect(
		_array_contains_fragment(
			future_result.get("errors", []),
			"unsupported item format version",
		),
		"future-schema rejection explains the unsupported version",
	)
	_expect_equal(future_item, future_copy, "failed import leaves source data unchanged")
	_expect_equal(
		catalog.definition_count(),
		definition_count,
		"failed import does not mutate the catalog",
	)
	_expect(
		not catalog.has_issued_instance_id(future_item["instanceId"]),
		"failed import does not reserve an instance ID",
	)

	var custom_serializer := ItemSerializationScript.new(ItemCatalogScript.new())
	var custom := _definition_source("Tamper Test", "Test", 1)
	custom["charges"] = 1
	custom["charges_max"] = 1
	var custom_result := custom_serializer.import_item(custom)
	_expect(bool(custom_result.get("ok", false)), "tamper fixture imports")
	if not bool(custom_result.get("ok", false)):
		return
	var saved := custom_serializer.serialize_item(custom_result["instance"])
	saved["embeddedDefinition"]["name"] = "Tampered"
	var reject_catalog := ItemCatalogScript.new()
	var reject_serializer := ItemSerializationScript.new(reject_catalog)
	var tamper_result := reject_serializer.import_inventory([saved])
	_expect(
		not bool(tamper_result.get("ok", true)),
		"embedded payload with a stale digest is rejected",
	)
	_expect(
		_array_contains_fragment(
			tamper_result.get("errors", []),
			"canonical embedded definition payload",
		),
		"digest rejection identifies the canonical payload mismatch",
	)
	_expect_equal(
		reject_catalog.definition_count(),
		0,
		"digest rejection does not register a partial embedded definition",
	)
	_expect(
		not reject_catalog.has_issued_instance_id(saved["instanceId"]),
		"digest rejection does not reserve a partial instance",
	)

	var duplicate := future_copy.duplicate(true)
	duplicate["formatVersion"] = 1
	var duplicate_result := serializer.import_inventory([duplicate, duplicate])
	_expect(
		not bool(duplicate_result.get("ok", true)),
		"duplicate instance identity is rejected transactionally",
	)
	_expect(
		not catalog.has_issued_instance_id(duplicate["instanceId"]),
		"duplicate rejection leaves the instance ID unreserved",
	)

	var valid_instance := catalog.create_instance("shared:Fixture%20Sword")
	var orphan_instance := ItemInstanceScript.new(
		"22222222-2222-4222-8222-222222222222",
		"shared:Missing",
		0,
		false,
		true,
		{},
	)
	var mixed_serialization := serializer.serialize_inventory(
		[orphan_instance, valid_instance]
	)
	_expect(
		not bool(mixed_serialization.get("ok", true)),
		"a later valid item cannot erase an earlier serialization error",
	)
	_expect(
		_array_contains_fragment(
			mixed_serialization.get("errors", []),
			"shared:Missing",
		),
		"mixed-inventory rejection identifies the unresolved definition",
	)


func _catalog_with_fixture_books() -> ItemCatalog:
	var catalog := ItemCatalogScript.new()
	var shared_book := {
		"Fixture Sword": _definition_source(
			"Fixture Sword",
			"Longsword",
			10,
		),
		"Fixture Potion": _definition_source(
			"Fixture Potion",
			"Misc. Item",
			5,
		),
	}
	shared_book["Fixture Sword"]["slots"] = ["Melee Weapon"]
	shared_book["Fixture Sword"]["hands"] = 1
	shared_book["Fixture Sword"]["equippable"] = 1
	shared_book["Fixture Sword"]["weapon_dmg"] = {"Physical": [1, 6]}
	shared_book["Fixture Potion"]["charges"] = 3
	shared_book["Fixture Potion"]["charges_max"] = 3
	shared_book["Fixture Potion"]["unidentified_name"] = "Cloudy potion"
	_expect(
		catalog.load_book(
			shared_book,
			"shared",
			"",
			"fixture/shared/stuff_book.json",
			{"ITEM_Test": true},
		),
		"fixture shared catalog loads: %s" % [catalog.last_errors],
	)
	for key: String in shared_book:
		var definition_id := catalog.resolve_catalog_key("shared", "", key)
		_expect(
			catalog.bind_legacy_template(definition_id, shared_book[key]),
			"fixture shared template binds: %s" % key,
		)
	var campaign_book := {
		"Scenario Wand": _definition_source(
			"Scenario Storm Wand",
			"Misc. Magical Item",
			20,
		),
	}
	campaign_book["Scenario Wand"]["classicItemId"] = 901
	campaign_book["Scenario Wand"]["charges"] = 5
	campaign_book["Scenario Wand"]["charges_max"] = 5
	campaign_book["Scenario Wand"]["slots"] = ["Accessory"]
	campaign_book["Scenario Wand"]["equippable"] = 1
	_expect(
		catalog.load_book(
			campaign_book,
			"campaign",
			"scenario-fixture",
			"fixture/campaign/stuff_book.json",
			{"ITEM_Test": true},
		),
		"fixture campaign catalog loads: %s" % [catalog.last_errors],
	)
	var campaign_id := catalog.resolve_catalog_key(
		"campaign",
		"scenario-fixture",
		"Scenario Wand",
	)
	_expect(
		catalog.bind_legacy_template(campaign_id, campaign_book["Scenario Wand"]),
		"fixture campaign template binds",
	)
	return catalog


func _definition_source(
	item_name: String,
	item_type: String,
	price: int,
) -> Dictionary:
	return {
		"name": item_name,
		"description": "",
		"type": item_type,
		"img_ptr": "ITEM_Test",
		"sound": "",
		"price": price,
		"stats": {},
		"slots": [],
		"weight": 1,
		"charges_weight": 0,
	}


func _contains_key_recursive(value: Variant, target: String) -> bool:
	if value is Dictionary:
		if value.has(target):
			return true
		for child: Variant in value.values():
			if _contains_key_recursive(child, target):
				return true
	elif value is Array:
		for child: Variant in value:
			if _contains_key_recursive(child, target):
				return true
	return false


func _array_contains_fragment(values: Array, fragment: String) -> bool:
	for value: Variant in values:
		if str(value).contains(fragment):
			return true
	return false


func _expect(condition: bool, message: String) -> void:
	_assertions += 1
	if not condition:
		_failures.append(message)


func _expect_equal(actual: Variant, expected: Variant, message: String) -> void:
	_expect(actual == expected, "%s; expected %s, got %s" % [message, expected, actual])


func _finish() -> void:
	if _failures.is_empty():
		print(
			(
				"ITEM_SERIALIZATION PASS: %d assertions; versioned shared, charged, "
				+ "campaign, Classic, embedded, legacy, and rejection paths are verified."
			)
			% _assertions
		)
		quit(0)
		return
	for failure: String in _failures:
		printerr("ITEM_SERIALIZATION FAIL: %s" % failure)
	printerr(
		"ITEM_SERIALIZATION FAIL: %d of %d assertions failed."
		% [_failures.size(), _assertions]
	)
	quit(1)
