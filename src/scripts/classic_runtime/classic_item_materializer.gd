class_name ClassicItemMaterializer
extends RefCounted

const ITEM_BOOK_PATH := "Items/stuff_book.json"
const ITEM_IMAGE_BOOK_PATH := "Items/img_pack.json"
const ITEM_ATLAS_PATH := "Items/textureAtlas.png"
# These fields affect item behavior but do not yet have verified native equivalents.
# Keeping the record is lossless; treating it as launchable would not be.
const UNSUPPORTED_EFFECT_FIELDS := [
	"ac",
	"blunt",
	"casteClassOnly",
	"casteRestrictions",
	"cursedItemId",
	"damage",
	"lu",
	"magicResistance",
	"movement",
	"raceClassOnly",
	"raceRestrictions",
	"special1",
	"special2",
	"special3",
	"special4",
	"special5",
	"specificCaste",
	"specificRace",
	"spellPoints",
	"st",
	"vsDemonDevil",
	"vsEvil",
	"vsUndead",
]
const ELEMENT_BY_CLASSIC_FIELD := {
	"heat": "Fire",
	"cold": "Ice",
	"electric": "Electric",
}
const NATIVE_TYPE_BY_CLASSIC_ITEM_CATEGORY := {
	0: "Mace",
	1: "Hammer",
	2: "Warhammer/Maul",
	3: "Dagger",
	4: "Shortsword",
	5: "Arming Sword",
	6: "Longsword",
	7: "Longsword",
	8: "Staff",
	9: "Spear",
	10: "Pole Axe",
	11: "Eastern Weapon",
	12: "Bow",
	13: "Crossbow",
	14: "Dart",
	15: "Throwing Bottle",
	16: "Throwing Dagger",
	17: "Whip",
	18: "Quiver",
	19: "Belt",
	20: "Necklace",
	21: "Hat",
	22: "Soft Helmet",
	23: "Light Helmet",
	24: "Great Helm",
	25: "Small Shield",
	26: "Medium Shield",
	27: "Large Shield",
	28: "Bracers",
	29: "Cloth Gloves",
	30: "Leather Gloves",
	31: "Metal Gloves",
	32: "Cloak/Cape",
	33: "Robe",
	34: "Gambeson",
	35: "Leather Armor",
	36: "Chainmail Armor",
	37: "Splint Armor",
	38: "Plate Armor",
	39: "Soft Boots",
	40: "Hard Boots",
	41: "Throwing Hammer",
	42: "Eastern Weapon",
	43: "Misc. Melee Weapon",
	44: "Misc. Melee Weapon",
	45: "Misc. Melee Weapon",
	46: "Misc Ranged Weapon",
	48: "Scroll Case",
	50: "Ring",
	54: "Ion Stone",
}
const SLOT_BY_CLASSIC_TYPE := {
	0: "Ring",
	2: "Melee Weapon",
	3: "Shield",
	4: "Body",
	5: "Hands",
	6: "Cloak",
	7: "Head",
	8: "IonStone",
	9: "Feet",
	10: "Ammunition",
	11: "Belt",
	12: "Neck",
	13: "ScrollCase",
	15: "Ranged Weapon",
	16: "Broach",
	17: "Mask",
	18: "Loop",
	19: "Loop",
}
const ICON_BY_CATEGORY := {
	"Weapons": "ITEM_Dagger",
	"Armor": "ITEM_Leather_Armor",
	"Limbs": "ITEM_Ring_of_Defense_3",
	"Magic": "ITEM_Parchment",
	"Supplies": "ITEM_Rope",
}
const SOUND_BY_CATEGORY := {
	"Weapons": "metal hit.wav",
	"Armor": "metal armor.wav",
	"Limbs": "cloth armor.wav",
	"Magic": "prout.wav",
	"Supplies": "cloth armor.wav",
}

var last_error := ""


func materialize(bundle: Object, campaign_directory: String) -> Dictionary:
	last_error = ""
	if bundle == null:
		return _fail("Classic campaign bundle is unavailable")
	var root := campaign_directory.strip_edges().replace("\\", "/").trim_suffix("/")
	if root.is_empty() or not DirAccess.dir_exists_absolute(root):
		return _fail("Classic campaign directory is unavailable")
	var content: Variant = bundle.documents.get("content", {})
	if not (content is Dictionary):
		return _fail("Classic content document is unavailable")
	var scenario_items: Variant = content.get("scenarioItems", [])
	if not (scenario_items is Array):
		return _fail("Classic scenario item collection is malformed")
	if scenario_items.is_empty():
		return {"status": "ok", "generated": 0, "skipped": 0}

	var item_book_path := root.path_join(ITEM_BOOK_PATH)
	var item_book := _read_item_book(item_book_path)
	if not last_error.is_empty():
		return {"status": "error", "message": last_error}
	var item_texts: Array = content.get("itemTexts", []) if content.get("itemTexts", []) is Array else []
	var records: Array[Dictionary] = []
	for item_value: Variant in scenario_items:
		if not (item_value is Dictionary):
			return _fail("Classic scenario item collection contains a malformed record")
		records.append(item_value)
	records.sort_custom(
		func(left: Dictionary, right: Dictionary) -> bool:
			return abs(int(left.get("itemId", 0))) < abs(int(right.get("itemId", 0)))
	)

	var generated := 0
	var skipped := 0
	for record: Dictionary in records:
		var item_id: int = abs(int(record.get("itemId", 0)))
		if item_id == 0:
			continue
		if _book_has_item_id(item_book, item_id):
			skipped += 1
			continue
		item_book[_item_key(item_book, item_id)] = _native_item(record, item_texts)
		generated += 1

	var items_directory := item_book_path.get_base_dir()
	var make_error := DirAccess.make_dir_recursive_absolute(items_directory)
	if make_error != OK:
		return _fail("Could not create native item directory: %s" % error_string(make_error))
	var write_error := OK
	if generated > 0 or not FileAccess.file_exists(item_book_path):
		write_error = _write_json(item_book_path, item_book)
		if write_error != OK:
			return _fail("Could not write native item book: %s" % error_string(write_error))
	# CampaignResources requires a complete local item pack even though generated
	# definitions currently reuse textures from the shared item pack.
	var image_book_path := root.path_join(ITEM_IMAGE_BOOK_PATH)
	if not FileAccess.file_exists(image_book_path):
		write_error = _write_json(image_book_path, {})
		if write_error != OK:
			return _fail("Could not write native item image book: %s" % error_string(write_error))
	var atlas_path := root.path_join(ITEM_ATLAS_PATH)
	if not FileAccess.file_exists(atlas_path):
		var atlas := Image.create(1, 1, false, Image.FORMAT_RGBA8)
		atlas.fill(Color(0, 0, 0, 0))
		write_error = atlas.save_png(atlas_path)
		if write_error != OK:
			return _fail("Could not write native item atlas: %s" % error_string(write_error))
	return {"status": "ok", "generated": generated, "skipped": skipped}


func _native_item(record: Dictionary, item_texts: Array) -> Dictionary:
	var item_id: int = abs(int(record.get("itemId", 0)))
	var item_text := _item_text(item_texts, item_id)
	var identified_name := str(item_text.get("identifiedName", "")).strip_edges()
	var unidentified_name := str(item_text.get("unidentifiedName", "")).strip_edges()
	if identified_name.is_empty():
		identified_name = "Classic Item %d" % item_id
	if unidentified_name.is_empty():
		unidentified_name = identified_name
	var classic_type: int = abs(int(record.get("type", 0)))
	var asset_category := _category_for_item(item_id)
	var native_type := _native_item_type(record, classic_type, asset_category)
	var native_weapon := _native_weapon(record, classic_type)
	var unsupported_fields := _unsupported_fields(record, native_weapon, native_type)
	var fidelity_fallbacks: Array = native_weapon.get("fidelityFallbacks", [])
	var materialization_status := "complete"
	if not unsupported_fields.is_empty():
		materialization_status = "blocked"
	elif not fidelity_fallbacks.is_empty():
		materialization_status = "fallback"
	var charge := int(record.get("charge", 0))
	var slots: Array[String] = []
	if SLOT_BY_CLASSIC_TYPE.has(classic_type):
		slots.append(str(SLOT_BY_CLASSIC_TYPE[classic_type]))
	var native_item := {
		"name": identified_name,
		"unidentified_name": unidentified_name,
		"description": str(item_text.get("description", "")),
		"classicItemId": item_id,
		"classicRecordId": int(record.get("id", -1)),
		"classicItemType": int(record.get("type", 0)),
		"classicIconId": int(record.get("iconId", 0)),
		"classicSoundId": int(record.get("sound", 0)),
		"classicRecord": record.duplicate(true),
		"classicMaterialization": {
			"status": materialization_status,
			"unsupportedFields": unsupported_fields,
			"fidelityFallbacks": fidelity_fallbacks,
		},
		"type": native_type.get("value", asset_category),
		"img_ptr": str(ICON_BY_CATEGORY[asset_category]),
		"sound": str(SOUND_BY_CATEGORY[asset_category]),
		"is_magical": int(record.get("magical", 0)),
		"is_identified": 1 if classic_type == 24 else 0,
		"weight": int(record.get("weight", 0)),
		"price": abs(int(record.get("cost", 0))),
		"charges": max(charge, 0),
		"charges_max": max(charge, 0),
		"charges_weight": int(record.get("weightPerCharge", 0)),
		"delete_on_empty": int(record.get("dropOnEmpty", 0)),
		"hands": int(record.get("hands", 0)),
		"slots": slots,
		"equippable": 1 if SLOT_BY_CLASSIC_TYPE.has(classic_type) else 0,
		"equipped": 0,
		"stats": {},
		"stats_mini": "",
		"unique": 1 if int(record.get("cost", 0)) < 0 else 0,
		"tradeable": 1,
		"splittable": 0,
	}
	for field_name: String in native_weapon.get("fields", {}):
		native_item[field_name] = native_weapon["fields"][field_name]
	return native_item


func _item_text(item_texts: Array, item_id: int) -> Dictionary:
	for text_value: Variant in item_texts:
		if text_value is Dictionary and abs(int(text_value.get("itemId", 0))) == item_id:
			return text_value
	return {}


func _category_for_item(item_id: int) -> String:
	if item_id < 200:
		return "Weapons"
	if item_id < 400:
		return "Armor"
	if item_id < 600:
		return "Limbs"
	if item_id < 800:
		return "Magic"
	return "Supplies"


func _native_item_type(
	record: Dictionary,
	classic_type: int,
	fallback_type: String
) -> Dictionary:
	var unsupported_fields: Array[String] = []
	if not SLOT_BY_CLASSIC_TYPE.has(classic_type):
		return {"value": fallback_type, "unsupportedFields": unsupported_fields}
	# Classic uses item type for the slot and the first category for use permission.
	var category_index := _first_classic_item_category(record)
	if category_index < 0:
		unsupported_fields.append("itemCategory.missing")
	elif NATIVE_TYPE_BY_CLASSIC_ITEM_CATEGORY.has(category_index):
		return {
			"value": NATIVE_TYPE_BY_CLASSIC_ITEM_CATEGORY[category_index],
			"unsupportedFields": unsupported_fields,
		}
	else:
		unsupported_fields.append("itemCategory[%d]" % category_index)
	return {"value": fallback_type, "unsupportedFields": unsupported_fields}


func _first_classic_item_category(record: Dictionary) -> int:
	# Classic scans the packed categories from zero and uses the first set bit.
	for category_index: int in range(58):
		var field_name := "itemCat0" if category_index < 32 else "itemCat1"
		var storage_bit := 31 - category_index % 32
		if (int(record.get(field_name, 0)) & (1 << storage_bit)) != 0:
			return category_index
	return -1


func _native_weapon(record: Dictionary, classic_type: int) -> Dictionary:
	var fields := {}
	var unsupported_fields: Array[String] = []
	var fidelity_fallbacks: Array[String] = []
	var small_damage := int(record.get("vSmall", 0))
	var large_damage := int(record.get("vLarge", 0))
	if classic_type != 2:
		if small_damage != 0:
			unsupported_fields.append("vSmall")
		if large_damage != 0:
			unsupported_fields.append("vLarge")
		for field_name: String in ELEMENT_BY_CLASSIC_FIELD:
			if int(record.get(field_name, 0)) != 0:
				unsupported_fields.append(field_name)
		return {
			"fields": fields,
			"unsupportedFields": unsupported_fields,
			"fidelityFallbacks": fidelity_fallbacks,
		}

	if small_damage < 1:
		unsupported_fields.append("vSmall")
	if large_damage < 1 or large_damage != small_damage:
		unsupported_fields.append("vLarge")
	var damage := {}
	if small_damage > 0:
		damage["Physical"] = [1, small_damage]
	for field_name: String in ELEMENT_BY_CLASSIC_FIELD:
		var element_damage := int(record.get(field_name, 0))
		if element_damage < 0:
			unsupported_fields.append(field_name)
		elif element_damage > 0:
			damage[ELEMENT_BY_CLASSIC_FIELD[field_name]] = [1, element_damage]
			if fidelity_fallbacks.is_empty():
				# Native resistance replaces Classic's separate save and protection rolls.
				fidelity_fallbacks.append("elementalWeaponDamageMitigation")
	if not damage.is_empty():
		fields = {
			"weapon_dmg": damage,
			"melee_atk_anim_icon": "ATK_WPN",
			"extra_data": {
				"classicWeaponDamage": {
					"small": small_damage,
					"large": large_damage,
				},
			},
		}
	return {
		"fields": fields,
		"unsupportedFields": unsupported_fields,
		"fidelityFallbacks": fidelity_fallbacks,
	}


func _unsupported_fields(
	record: Dictionary,
	native_weapon: Dictionary,
	native_type: Dictionary
) -> Array[String]:
	var fields: Array[String] = []
	for field_name: String in UNSUPPORTED_EFFECT_FIELDS:
		if int(record.get(field_name, 0)) != 0:
			fields.append(field_name)
	for field_name: String in native_weapon.get("unsupportedFields", []):
		if not fields.has(field_name):
			fields.append(field_name)
	for field_name: String in native_type.get("unsupportedFields", []):
		if not fields.has(field_name):
			fields.append(field_name)
	return fields


func _read_item_book(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (value is Dictionary):
		last_error = "Existing native item book is not a JSON object"
		return {}
	return value


func _book_has_item_id(item_book: Dictionary, item_id: int) -> bool:
	for item_value: Variant in item_book.values():
		if not (item_value is Dictionary):
			continue
		if abs(int(item_value.get("classicItemId", 0))) == item_id:
			return true
		var ids: Variant = item_value.get("classicItemIds", [])
		if ids is Array:
			for id_value: Variant in ids:
				if abs(int(id_value)) == item_id:
					return true
	return false


func _item_key(item_book: Dictionary, item_id: int) -> String:
	var base := "Classic Item %d" % item_id
	var candidate := base
	var suffix := 2
	while item_book.has(candidate):
		candidate = "%s (%d)" % [base, suffix]
		suffix += 1
	return candidate


func _write_json(path: String, value: Variant) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(value, "  ", true) + "\n")
	file.close()
	return OK


func _fail(message: String) -> Dictionary:
	last_error = message
	return {"status": "error", "message": message}
