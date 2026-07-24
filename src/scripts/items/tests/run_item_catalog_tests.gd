extends SceneTree

const ItemCatalogScript = preload("res://scripts/items/item_catalog.gd")

const SHARED_ITEM_BOOK := "res://shared_assets/items/stuff_book.json"
const SHARED_IMAGE_BOOK := "res://shared_assets/items/img_pack.json"
const COB_ITEM_BOOK := \
	"res://Campaigns/City of Bywater/Items/stuff_book.json"
const COB_IMAGE_BOOK := \
	"res://Campaigns/City of Bywater/Items/img_pack.json"
const COB_CAMPAIGN_ID := "scenario-city-of-bywater"
const OTHERWORLD_ITEM_BOOK := "res://Campaigns/OtherWorld/Items/stuff_book.json"
const OTHERWORLD_IMAGE_BOOK := "res://Campaigns/OtherWorld/Items/img_pack.json"
const OTHERWORLD_CAMPAIGN_ID := "scenario-otherworld"

var _assertions := 0
var _failures: Array[String] = []


func _init() -> void:
	_test_checked_catalogs()
	_test_override_precedence_and_legacy_factory()
	_test_validation_and_transactionality()
	_finish()


func _test_checked_catalogs() -> void:
	var catalog := ItemCatalogScript.new()
	var shared_book := _read_object(SHARED_ITEM_BOOK)
	var shared_images := _read_object(SHARED_IMAGE_BOOK)
	_expect(
		catalog.load_book(
			shared_book,
			"shared",
			"",
			SHARED_ITEM_BOOK,
			shared_images,
		),
		"shared item book passes validated loading: %s" % str(catalog.last_errors),
	)
	_expect_equal(catalog.definition_count(), 525, "all shared definitions load")
	_expect_equal(
		catalog.resolve_catalog_key("shared", "", "Dagger"),
		"shared:Dagger",
		"shared catalog key resolves stable identity",
	)
	var dagger = catalog.get_definition("shared:Dagger")
	_expect(dagger != null, "shared Dagger definition resolves")
	if dagger != null:
		_expect_equal(dagger.display_name, "Dagger", "Dagger display name is preserved")
		_expect_equal(dagger.item_type, "Dagger", "Dagger item type is preserved")
		_expect_equal(dagger.image_key, "ITEM_Dagger", "Dagger image reference is preserved")
		_expect_equal(dagger.sound_key, "metal hit.wav", "Dagger sound is preserved")
		_expect_equal(
			dagger.gameplay_value("baseWeight"),
			5,
			"Dagger weight is normalized",
		)
		_expect_equal(
			dagger.display_type,
			"Dagger",
			"items without a display override use their mechanical type",
		)
		_expect_equal(
			dagger.gameplay_value("weaponDamage"),
			{"Physical": [1.0, 4.0]},
			"Dagger damage data is preserved",
		)
		var gameplay_copy: Dictionary = dagger.gameplay()
		gameplay_copy["baseWeight"] = 999
		_expect_equal(
			dagger.gameplay_value("baseWeight"),
			5,
			"definition gameplay data is immutable through copies",
		)

	var battleaxe = catalog.get_definition("shared:Battleaxe")
	_expect(battleaxe != null, "shared Battleaxe definition resolves")
	if battleaxe != null:
		_expect_equal(
			battleaxe.item_type,
			"Arming Sword",
			"Battleaxe retains its existing equipment-permission category",
		)
		_expect_equal(
			battleaxe.display_type,
			"Battleaxe",
			"Battleaxe exposes its player-facing weapon type",
		)

	var supply_expectations := {
		"Torch": {
			"description": "A stout stick covered in pitch.",
			"image": "ITEM_Torch",
			"weight": 0,
			"price": 3,
			"charges": 6,
		},
		"Parchment": {
			"description": (
				"Paper of superior quality needed for the etchings of magical words."
			),
			"image": "ITEM_Parchment",
			"weight": 0,
			"price": 100,
			"charges": 3,
		},
		"Iron Rations": {
			"description": (
				"What they lack in taste they more than make up for in nutrition."
			),
			"image": "ITEM_Iron_Rations",
			"weight": 0,
			"price": 5,
			"charges": 36,
		},
		"Rope": {
			"description": "A strong coil make of Hemp and Flax.",
			"image": "ITEM_Rope",
			"weight": 100,
			"price": 10,
			"charges": 0,
		},
		"Mirror": {
			"description": "A highly polished plate of pure silver.",
			"image": "ITEM_Mirror",
			"weight": 15,
			"price": 20,
			"charges": 0,
		},
		"Iron Spikes": {
			"description": (
				"Heavy Iron spikes capable of being driven into the hardest of stone."
			),
			"image": "ITEM_Iron Spikes",
			"weight": 0,
			"price": 15,
			"charges": 3,
		},
		"Flask of Oil": {
			"description": (
				"In combination with flame this becomes a poor mans fireball."
			),
			"image": "ITEM_Flask_of_Oil",
			"weight": 0,
			"price": 25,
			"charges": 5,
		},
	}
	for catalog_key: String in supply_expectations:
		var supply = catalog.get_definition(
			catalog.resolve_catalog_key("shared", "", catalog_key)
		)
		var expected: Dictionary = supply_expectations[catalog_key]
		_expect(supply != null, "shared %s definition resolves" % catalog_key)
		if supply == null:
			continue
		_expect_equal(
			supply.description,
			expected["description"],
			"%s preserves its source-backed description" % catalog_key,
		)
		_expect_equal(
			supply.image_key,
			expected["image"],
			"%s uses its matching inventory icon" % catalog_key,
		)
		_expect(not supply.magical, "%s is not marked magical" % catalog_key)
		_expect_equal(
			supply.stats_summary,
			"",
			"%s has no placeholder stats text" % catalog_key,
		)
		_expect_equal(
			supply.base_weight,
			expected["weight"],
			"%s preserves its source-backed base weight" % catalog_key,
		)
		_expect_equal(
			supply.price,
			expected["price"],
			"%s preserves its source-backed price" % catalog_key,
		)
		_expect_equal(
			supply.maximum_charges,
			expected["charges"],
			"%s preserves its source-backed charge capacity" % catalog_key,
		)

	var resistance_stone = catalog.get_definition(
		"shared:Aqua%20Luck%20Stone%20%2B3"
	)
	_expect(resistance_stone != null, "shared Classic resistance item resolves")
	if resistance_stone != null:
		_expect_equal(
			resistance_stone.gameplay_value("extraData").get(
				"classicMagicResistance"
			),
			3,
			"legacy Classic resistance stat is normalized into compatibility data",
		)
		_expect(
			not resistance_stone.gameplay_value("stats").has(
				"ClassicMagicResistance"
			),
			"normalized native stats do not duplicate Classic resistance",
		)
		_expect_equal(
			resistance_stone.gameplay_value("stats"),
			{"EvasionMelee": 3.0, "EvasionRanged": 3.0},
			"native item statistics survive compatibility normalization",
		)
		_expect_equal(
			resistance_stone.gameplay_value("slots"),
			["IonStone"],
			"equipment slot descriptors are preserved",
		)

	var trait_dagger = catalog.get_definition(
		"shared:Dagger%20of%20Anti%20Magic%20%2B1"
	)
	_expect(trait_dagger != null, "shared trait-bearing item resolves")
	if trait_dagger != null:
		_expect_equal(
			trait_dagger.hooks().get("traits"),
			[["p_spell_lvl_prot.gd", 2.0]],
			"trait resource and initialization descriptors are preserved",
		)

	var scripted_armor = catalog.get_definition(
		"shared:The%20Chastised%20Warrior%20-5"
	)
	_expect(scripted_armor != null, "shared scripted armor definition resolves")
	if scripted_armor != null:
		var armor_sources: Dictionary = scripted_armor.hooks().get("sources", {})
		_expect(
			str(armor_sources.get("_on_equipping_source", "")).contains(
				"This foul prison"
			),
			"legacy equipping source spelling maps to the canonical hook",
		)
		_expect_equal(
			armor_sources.get("_on_unequipping_source"),
			"\nreturn false\n",
			"legacy unequipping hook source is preserved",
		)

	var scroll_id := "shared:Heal%20Small%20Wounds"
	var scroll = catalog.get_definition(scroll_id)
	_expect(scroll != null, "percent-encoded shared identity resolves")
	if scroll != null:
		_expect_equal(
			scroll.gameplay_value("initialCharges"),
			1,
			"definition preserves authored initial charges",
		)
		_expect_equal(
			scroll.gameplay_value("maxCharges"),
			6,
			"definition preserves maximum charges",
		)
		_expect_equal(
			scroll.hooks().get("spellUses", {}).get("_on_combat_use_spell"),
			["Heal Small Wounds (2105)", 1.0],
			"definition preserves scripted spell-use descriptor",
		)
		_expect(not scroll.default_identified, "authored unidentified name controls default")

	var first = catalog.create_instance(scroll_id)
	var second = catalog.create_instance(scroll_id)
	_expect(first != null and second != null, "factory creates shared item instances")
	if first != null and second != null:
		_expect(first.instance_id != second.instance_id, "instances receive independent IDs")
		_expect(_is_uuid(first.instance_id), "factory instance ID is UUID-shaped")
		_expect_equal(first.definition_id, scroll_id, "instance retains definition identity")
		first.charges = 0
		_expect(
			first.set_state_value("nested", {"value": [1, 2]}),
			"instance accepts JSON-compatible extension state",
		)
		var copied_state: Dictionary = first.state_data()
		copied_state["nested"]["value"][0] = 99
		_expect_equal(second.charges, 1, "mutating one instance does not affect another")
		_expect_equal(
			first.state_value("nested"),
			{"value": [1, 2]},
			"instance state access returns independent copies",
		)
		_expect(
			not first.set_state_value("runtime", RefCounted.new()),
			"instance rejects runtime objects in portable state",
		)
		_expect(
			not first.state_data().has("runtime"),
			"rejected instance state leaves prior state unchanged",
		)

	_expect(
		catalog.load_book(
			shared_book,
			"shared",
			"",
			SHARED_ITEM_BOOK,
			shared_images,
		),
		"reloading the same source replaces definitions safely",
	)
	_expect_equal(catalog.definition_count(), 525, "same-source reload does not duplicate")

	var cob_book := _read_object(COB_ITEM_BOOK)
	var cob_images := _read_object(COB_IMAGE_BOOK)
	var available_cob_images := shared_images.duplicate()
	available_cob_images.merge(cob_images, true)
	_expect(
		catalog.load_book(
			cob_book,
			"campaign",
			COB_CAMPAIGN_ID,
			COB_ITEM_BOOK,
			available_cob_images,
		),
		"City of Bywater item book passes validated loading: %s"
		% str(catalog.last_errors),
	)
	_expect_equal(catalog.definition_count(), 531, "campaign definitions extend shared catalog")
	var personal_items_id := "classic:%s:807" % COB_CAMPAIGN_ID
	_expect_equal(
		catalog.resolve_catalog_key(
			"campaign",
			COB_CAMPAIGN_ID,
			"Personal Items",
		),
		personal_items_id,
		"campaign catalog key retains stable Classic identity",
	)
	_expect_equal(
		catalog.resolve_classic_item(COB_CAMPAIGN_ID, -807),
		personal_items_id,
		"signed Classic lookup resolves campaign definition",
	)
	var personal_items = catalog.get_definition(personal_items_id)
	_expect(personal_items != null, "City of Bywater Classic definition resolves")
	if personal_items != null:
		_expect_equal(
			personal_items.classic_item_ids(),
			[807],
			"Classic numeric identity is preserved",
		)
		_expect_equal(
			personal_items.gameplay_value("price"),
			-1,
			"campaign-local authored price is preserved",
		)

	var otherworld_book := _read_object(OTHERWORLD_ITEM_BOOK)
	var otherworld_images := _read_object(OTHERWORLD_IMAGE_BOOK)
	var available_otherworld_images := shared_images.duplicate()
	available_otherworld_images.merge(otherworld_images, true)
	_expect(
		catalog.load_book(
			otherworld_book,
			"campaign",
			OTHERWORLD_CAMPAIGN_ID,
			OTHERWORLD_ITEM_BOOK,
			available_otherworld_images,
		),
		"OtherWorld's minimal campaign item definition loads: %s"
		% str(catalog.last_errors),
	)
	_expect_equal(
		catalog.definition_count(),
		532,
		"all checked shared and campaign definitions load",
	)
	var otherworld_id := "campaign:scenario-otherworld:Bywater%20Dagger"
	var otherworld_dagger = catalog.get_definition(otherworld_id)
	_expect(otherworld_dagger != null, "minimal campaign definition receives stable identity")
	if otherworld_dagger != null:
		_expect_equal(
			otherworld_dagger.gameplay_value("baseWeight"),
			0,
			"minimal campaign definition receives documented defaults",
		)
		_expect_equal(
			otherworld_dagger.gameplay_value("slots"),
			[],
			"minimal campaign definition receives independent collection defaults",
		)


func _test_override_precedence_and_legacy_factory() -> void:
	var catalog := ItemCatalogScript.new()
	var image_keys := {"ITEM_Test": {}}
	var shared_book := {
		"Override Item": _definition_source("Shared Override", 10),
	}
	var campaign_book := {
		"Override Item": _definition_source("Campaign Override", 25),
	}
	campaign_book["Override Item"]["custom_spell_source"] = \
		"extends RefCounted\nvar name := \"Catalog Spell\"\n"
	_expect(
		catalog.load_book(
			shared_book,
			"shared",
			"",
			"fixture/shared/stuff_book.json",
			image_keys,
		),
		"synthetic shared definition loads",
	)
	_expect(
		catalog.load_book(
			campaign_book,
			"campaign",
			"scenario-override",
			"fixture/campaign/stuff_book.json",
			image_keys,
		),
		"synthetic campaign override loads",
	)
	var shared_id := "shared:Override%20Item"
	var campaign_id := "campaign:scenario-override:Override%20Item"
	_expect_equal(
		catalog.resolve_catalog_key("shared", "", "Override Item"),
		shared_id,
		"shared definition remains directly addressable",
	)
	_expect_equal(
		catalog.resolve_active_catalog_key("Override Item"),
		campaign_id,
		"campaign definition wins active legacy precedence",
	)
	_expect_equal(
		catalog.get_definition(campaign_id).gameplay_value("price"),
		25,
		"active campaign definition carries campaign data",
	)
	_expect_equal(
		catalog.get_definition(campaign_id).hooks().get(
			"sources", {}
		).get("custom_spell_source"),
		campaign_book["Override Item"]["custom_spell_source"],
		"campaign custom spell source survives catalog normalization",
	)

	var legacy_template := {
		"name": "Campaign Override",
		"price": 25,
		"charges": 99,
		"equipped": 0,
		"is_identified": 1,
		"stats": {"Strength": 1},
	}
	_expect(
		catalog.bind_legacy_template(campaign_id, legacy_template),
		"temporary legacy template binds to stable identity",
	)
	var first := catalog.create_legacy_item_for_catalog_key("Override Item")
	var second := catalog.create_legacy_item_for_catalog_key("Override Item")
	_expect(not first.is_empty() and not second.is_empty(), "legacy adapter creates items")
	_expect_equal(first.get("charges"), 0, "legacy adapter applies instance default state")
	first["charges"] = 7
	first["stats"]["Strength"] = 4
	_expect_equal(second.get("charges"), 0, "legacy item charges are independent")
	_expect_equal(
		second.get("stats"),
		{"Strength": 1},
		"legacy nested definition data is independently copied",
	)
	_expect_equal(
		legacy_template.get("charges"),
		99,
		"legacy adapter does not mutate the bound caller template",
	)


func _test_validation_and_transactionality() -> void:
	var catalog := ItemCatalogScript.new()
	var image_keys := {"ITEM_Test": {}}
	_expect(
		catalog.load_book(
			{"Valid": _definition_source("Valid", 1)},
			"shared",
			"",
			"fixture/valid.json",
			image_keys,
		),
		"validation fixture baseline loads",
	)
	var initial_ids := catalog.definition_ids()

	var missing_type := _definition_source("Missing Type", 1)
	missing_type.erase("type")
	_expect(
		not catalog.load_book(
			{"Broken": missing_type},
			"campaign",
			"scenario-broken",
			"fixture/missing-type.json",
			image_keys,
		),
		"missing required type is rejected",
	)
	_expect(
		_errors_contain(catalog.last_errors, "fixture/missing-type.json[Broken].type"),
		"missing-field error includes source, key, and field",
	)
	_expect_equal(
		catalog.definition_ids(),
		initial_ids,
		"failed definition load leaves catalog unchanged",
	)

	var missing_image := _definition_source("Missing Image", 1)
	missing_image["img_ptr"] = "ITEM_Missing"
	_expect(
		not catalog.load_book(
			{"Missing Image": missing_image},
			"campaign",
			"scenario-broken",
			"fixture/missing-image.json",
			image_keys,
		),
		"missing image key is rejected",
	)
	_expect(
		_errors_contain(catalog.last_errors, "references missing image key ITEM_Missing"),
		"missing image diagnostic names the unresolved key",
	)

	var incomplete_charges := _definition_source("Incomplete Charges", 1)
	incomplete_charges["charges"] = 1
	_expect(
		not catalog.load_book(
			{"Incomplete Charges": incomplete_charges},
			"campaign",
			"scenario-broken",
			"fixture/incomplete-charges.json",
			image_keys,
		),
		"unpaired charge fields are rejected",
	)
	_expect(
		_errors_contain(catalog.last_errors, "authored together"),
		"charge-pair diagnostic is actionable",
	)

	var duplicate_classic := {
		"First": _definition_source("First", 1),
		"Second": _definition_source("Second", 2),
	}
	duplicate_classic["First"]["classicItemId"] = 901
	duplicate_classic["Second"]["classicItemId"] = -901
	_expect(
		not catalog.load_book(
			duplicate_classic,
			"campaign",
			"scenario-broken",
			"fixture/duplicate-classic.json",
			image_keys,
		),
		"duplicate normalized Classic IDs are rejected",
	)
	_expect(
		_errors_contain(
			catalog.last_errors,
			"duplicates classic:scenario-broken:901",
		),
		"Classic collision diagnostic names the duplicate stable identity",
	)

	var bad_alias := _definition_source("Bad Alias", 1)
	bad_alias["classicItemIds"] = [4, "five"]
	_expect(
		not catalog.load_book(
			{"Bad Alias": bad_alias},
			"campaign",
			"scenario-broken",
			"fixture/bad-alias.json",
			image_keys,
		),
		"non-integer Classic aliases are rejected",
	)
	_expect(
		_errors_contain(catalog.last_errors, "classicItemIds[1]"),
		"Classic alias diagnostic identifies its array index",
	)

	var conflicting_hook := _definition_source("Conflicting Hook", 1)
	conflicting_hook["_on_equipping_source"] = "\nreturn true\n"
	conflicting_hook["on_equipping_source"] = "\nreturn false\n"
	_expect(
		not catalog.load_book(
			{"Conflicting Hook": conflicting_hook},
			"campaign",
			"scenario-broken",
			"fixture/conflicting-hook.json",
			image_keys,
		),
		"conflicting legacy and canonical hook spellings are rejected",
	)
	_expect(
		_errors_contain(catalog.last_errors, "conflicts with _on_equipping_source"),
		"hook conflict diagnostic identifies the canonical source",
	)

	var unknown_hook := _definition_source("Unknown Hook", 1)
	unknown_hook["_on_equiping_source"] = "\nreturn true\n"
	_expect(
		not catalog.load_book(
			{"Unknown Hook": unknown_hook},
			"campaign",
			"scenario-broken",
			"fixture/unknown-hook.json",
			image_keys,
		),
		"unknown hook source spellings are rejected",
	)
	_expect(
		_errors_contain(catalog.last_errors, "_on_equiping_source"),
		"unknown-hook diagnostic identifies the malformed field",
	)

	var valid_definition_id := catalog.resolve_active_catalog_key("Valid")
	_expect(
		catalog.create_instance(valid_definition_id, {"charges": "many"}) == null,
		"malformed instance state is rejected",
	)
	_expect(
		_errors_contain(catalog.last_errors, ".charges: must be an integer"),
		"instance validation identifies the malformed field",
	)
	_expect(
		catalog.create_instance(valid_definition_id, {"unknown": true}) == null,
		"unknown instance override is rejected",
	)
	_expect(
		_errors_contain(catalog.last_errors, "overrides.unknown"),
		"unknown instance override diagnostic identifies the field",
	)


func _definition_source(name: String, price: int) -> Dictionary:
	return {
		"name": name,
		"unidentified_name": name,
		"description": "",
		"type": "Test",
		"img_ptr": "ITEM_Test",
		"sound": "",
		"price": price,
		"stats": {},
		"slots": [],
	}


func _read_object(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	_expect(value is Dictionary, "%s parses as a JSON object" % path)
	return value if value is Dictionary else {}


func _errors_contain(errors: Array[String], fragment: String) -> bool:
	for message: String in errors:
		if message.contains(fragment):
			return true
	return false


func _is_uuid(value: String) -> bool:
	if value.length() != 36:
		return false
	for separator_index: int in [8, 13, 18, 23]:
		if value.substr(separator_index, 1) != "-":
			return false
	return value.replace("-", "").is_valid_hex_number(false)


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
				"ITEM_CATALOG PASS: %d assertions; definitions, overrides, Classic IDs, "
				+ "instance isolation, legacy adaptation, and validation are verified."
			)
			% _assertions
		)
		quit(0)
		return
	for failure: String in _failures:
		printerr("ITEM_CATALOG FAIL: %s" % failure)
	printerr(
		"ITEM_CATALOG FAIL: %d of %d assertions failed."
		% [_failures.size(), _assertions]
	)
	quit(1)
