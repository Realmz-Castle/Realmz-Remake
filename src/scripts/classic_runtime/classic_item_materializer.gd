class_name ClassicItemMaterializer
extends RefCounted

const DistributionJsonScript = preload(
	"res://scripts/classic_runtime/classic_distribution_json.gd"
)
const ItemBehaviorsScript = preload(
	"res://scripts/classic_runtime/classic_item_behaviors.gd"
)

const ITEM_BOOK_PATH := "Items/stuff_book.json"
const ITEM_IMAGE_BOOK_PATH := "Items/img_pack.json"
const ITEM_ATLAS_PATH := "Items/textureAtlas.png"
const SHARED_ITEM_BOOK_PATH := "res://shared_assets/items/stuff_book.json"
# These fields affect item behavior but do not yet have verified native equivalents.
# Keeping the record is lossless; treating it as launchable would not be.
const UNSUPPORTED_EFFECT_FIELDS := [
	"cursedItemId",
	"lu",
	"special1",
	"special2",
	"special3",
	"special4",
	"special5",
]
const ELEMENT_BY_CLASSIC_FIELD := {
	"heat": "Fire",
	"cold": "Ice",
	"electric": "Electric",
}
const TARGET_TAG_BY_CLASSIC_FIELD := {
	"vsUndead": "Undead",
	"vsDemonDevil": "Demonic",
	"vsEvil": "Evil Creature",
}
const STANDARD_RACE_NAMES := [
	"Human",
	"Shadow Elf",
	"Elf",
	"Orc",
	"Furfoot",
	"Gnome",
	"Dwarf",
	"Half Elf",
	"Half Orc",
	"Goblin",
	"Hobgoblin",
	"Kobold",
	"Vampire",
	"Lizard Man",
	"Brownie",
	"Pixie",
	"Leprechaun",
	"Demon",
	"Cathoon",
]
# The shared Realmz race table only assigns the Evil descriptor among the
# standard profiles. Scenario-specific profile overrides remain a separate
# character-resource boundary.
const STANDARD_RACE_DESCRIPTORS := [
	0,
	0x0080,
	0,
	0x0080,
	0,
	0,
	0,
	0,
	0,
	0x0080,
	0x0080,
	0x0080,
	0x0080,
	0,
	0,
	0,
	0,
	0x0080,
	0,
]
const STANDARD_CASTE_NAMES := [
	"Fighter",
	"Monk",
	"Crusader",
	"Archer",
	"Rogue",
	"Sorcerer",
	"Priest",
	"Enchanter",
	"Evoker",
	"Cardinal",
	"Cabalist",
	"Berzerker",
	"Bard",
	"Fencer",
	"Marksman",
	"Assassin",
	"Dabbler",
	"Battle Mage",
	"Warlock",
	"Minstrel",
]
const STANDARD_CASTE_CLASSES := [1, 2, 7, 3, 2, 4, 5, 6, 6, 5, 4, 1, 2, 1, 3, 2, 7, 7, 6, 7]
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
var _shared_item_book: Dictionary = {}
var _shared_item_book_loaded := false


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
	var empty := 0
	for record: Dictionary in records:
		var item_id: int = abs(int(record.get("itemId", 0)))
		if item_id == 0:
			continue
		if bundle.is_empty_scenario_item(item_id):
			empty += 1
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
	return {
		"status": "ok",
		"generated": generated,
		"skipped": skipped,
		"empty": empty,
	}


func _native_item(record: Dictionary, item_texts: Array) -> Dictionary:
	var item_id: int = abs(int(record.get("itemId", 0)))
	var item_text := _item_text(item_texts, item_id)
	var identified_name := str(item_text.get("identifiedName", "")).strip_edges()
	var unidentified_name := str(item_text.get("unidentifiedName", "")).strip_edges()
	var missing_item_text := identified_name.is_empty()
	if identified_name.is_empty():
		identified_name = "Classic Item %d" % item_id
	if unidentified_name.is_empty():
		unidentified_name = identified_name
	var classic_type: int = abs(int(record.get("type", 0)))
	var asset_category := _category_for_item(item_id)
	var native_type := _native_item_type(record, classic_type, asset_category)
	var native_fields := _native_item_fields(record, classic_type)
	var unsupported_fields := _unsupported_fields(record, native_fields, native_type)
	var fidelity_fallbacks: Array = native_fields.get("fidelityFallbacks", [])
	if missing_item_text:
		fidelity_fallbacks.append("missingItemText")
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
		"classicItemCategory": _first_classic_item_category(record),
		"classicIconId": int(record.get("iconId", 0)),
		"classicSoundId": int(record.get("sound", 0)),
		"classicRecord": record.duplicate(true),
		"classicMaterialization": {
			"status": materialization_status,
			"unsupportedFields": unsupported_fields,
			"fidelityFallbacks": fidelity_fallbacks,
		},
		"type": native_type.get("value", asset_category),
		"img_ptr": _native_item_icon(
			identified_name,
			str(item_text.get("description", "")),
			asset_category
		),
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
	for field_name: String in native_fields.get("fields", {}):
		native_item[field_name] = native_fields["fields"][field_name]
	return ItemBehaviorsScript.enrich_definition_source(native_item)


func _native_item_icon(
	identified_name: String,
	description: String,
	asset_category: String
) -> String:
	var shared_item := _shared_item(identified_name)
	if not shared_item.is_empty() \
			and str(shared_item.get("description", "")) == description:
		var shared_icon := str(shared_item.get("img_ptr", "")).strip_edges()
		if not shared_icon.is_empty():
			return shared_icon
	return str(ICON_BY_CATEGORY[asset_category])


func _shared_item(item_name: String) -> Dictionary:
	if not _shared_item_book_loaded:
		_shared_item_book_loaded = true
		var value: Variant = JSON.parse_string(
			FileAccess.get_file_as_string(SHARED_ITEM_BOOK_PATH)
		)
		if value is Dictionary:
			_shared_item_book = value
	var item_value: Variant = _shared_item_book.get(item_name, {})
	return item_value if item_value is Dictionary else {}


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


func _native_item_fields(record: Dictionary, classic_type: int) -> Dictionary:
	var fields := {}
	var unsupported_fields: Array[String] = []
	var fidelity_fallbacks: Array[String] = []
	var stats := {}
	var stats_summary: Array[String] = []
	var small_damage := int(record.get("vSmall", 0))
	var large_damage := int(record.get("vLarge", 0))
	var magic_plus := int(record.get("damage", 0))
	if classic_type != 2:
		if small_damage != 0:
			unsupported_fields.append("vSmall")
		if large_damage != 0:
			unsupported_fields.append("vLarge")
		if magic_plus != 0:
			unsupported_fields.append("damage")
		for field_name: String in ELEMENT_BY_CLASSIC_FIELD:
			if int(record.get(field_name, 0)) != 0:
				unsupported_fields.append(field_name)
	else:
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
				if not fidelity_fallbacks.has("elementalWeaponDamageMitigation"):
					# Native resistance replaces Classic's separate save and protection rolls.
					fidelity_fallbacks.append("elementalWeaponDamageMitigation")
		if not damage.is_empty():
			fields["weapon_dmg"] = damage
			fields["melee_atk_anim_icon"] = "ATK_WPN"
			fields["extra_data"] = {
				"classicMagicPlus": magic_plus,
				"classicWeaponDamage": {
					"small": small_damage,
					"large": large_damage,
				},
			}
		if magic_plus < 0:
			unsupported_fields.append("damage")
		elif magic_plus > 0:
			# One Remake accuracy point is five percentage points, matching Classic.
			stats["AccuracyMelee"] = magic_plus
			stats["Bonus_Physical_dmg"] = magic_plus
			stats_summary.append("+%d%% Melee Hit" % (magic_plus * 5))
			stats_summary.append("+%d Physical Damage" % magic_plus)

	var weapon_kind := int(record.get("blunt", 0))
	if weapon_kind != 0:
		if classic_type != 2 or weapon_kind not in [-2, -1]:
			unsupported_fields.append("blunt")
		else:
			var weapon_extra_data: Dictionary = fields.get("extra_data", {})
			weapon_extra_data["classicWeaponKind"] = "blunt" if weapon_kind == -1 else "sharp"
			fields["extra_data"] = weapon_extra_data

	var tag_bonus_damage := {}
	for field_name: String in TARGET_TAG_BY_CLASSIC_FIELD:
		var bonus_damage := int(record.get(field_name, 0))
		if bonus_damage < 0 or (bonus_damage > 0 and classic_type != 2):
			unsupported_fields.append(field_name)
		elif bonus_damage > 0:
			tag_bonus_damage[TARGET_TAG_BY_CLASSIC_FIELD[field_name]] = {
				"Physical": [1, bonus_damage],
			}
	if not tag_bonus_damage.is_empty():
		fields["weapon_tag_bonus_dmg"] = tag_bonus_damage

	var armor_rating := int(record.get("ac", 0))
	if armor_rating < 0 or (armor_rating > 0 and not SLOT_BY_CLASSIC_TYPE.has(classic_type)):
		unsupported_fields.append("ac")
	elif armor_rating > 0:
		stats["EvasionMelee"] = armor_rating
		stats["EvasionRanged"] = armor_rating
		stats_summary.append("+%d Melee Evasion" % armor_rating)
		stats_summary.append("+%d Ranged Evasion" % armor_rating)
		var extra_data: Dictionary = fields.get("extra_data", {})
		extra_data["classicArmorRating"] = armor_rating
		fields["extra_data"] = extra_data
		# Remake's shared items use this direct mapping despite its coarser hit scale.
		fidelity_fallbacks.append("armorRatingUsesNativeEvasionScale")

	var strength_modifier := int(record.get("st", 0))
	if strength_modifier != 0 and not SLOT_BY_CLASSIC_TYPE.has(classic_type):
		unsupported_fields.append("st")
	elif strength_modifier != 0:
		stats["Strength"] = strength_modifier
		var sign_prefix := "+" if strength_modifier > 0 else ""
		stats_summary.append("%s%d Strength" % [sign_prefix, strength_modifier])
		var strength_extra_data: Dictionary = fields.get("extra_data", {})
		strength_extra_data["classicStrengthModifier"] = strength_modifier
		fields["extra_data"] = strength_extra_data

	var spell_point_modifier := int(record.get("spellPoints", 0))
	if spell_point_modifier != 0 and not SLOT_BY_CLASSIC_TYPE.has(classic_type):
		unsupported_fields.append("spellPoints")
	elif spell_point_modifier != 0:
		# Classic changes current and maximum spell points by the same amount.
		stats["maxSP"] = spell_point_modifier
		stats["curSP"] = spell_point_modifier
		var spell_point_sign_prefix := "+" if spell_point_modifier > 0 else ""
		stats_summary.append(
			"%s%d Spell Points" % [spell_point_sign_prefix, spell_point_modifier]
		)
		var spell_point_extra_data: Dictionary = fields.get("extra_data", {})
		spell_point_extra_data["classicSpellPointModifier"] = spell_point_modifier
		fields["extra_data"] = spell_point_extra_data

	var movement_modifier := int(record.get("movement", 0))
	if movement_modifier != 0 and not SLOT_BY_CLASSIC_TYPE.has(classic_type):
		unsupported_fields.append("movement")
	elif movement_modifier != 0:
		stats["MaxMovement"] = movement_modifier
		var movement_sign_prefix := "+" if movement_modifier > 0 else ""
		stats_summary.append(
			"%s%d Movement" % [movement_sign_prefix, movement_modifier]
		)
		var movement_extra_data: Dictionary = fields.get("extra_data", {})
		movement_extra_data["classicMovementModifier"] = movement_modifier
		fields["extra_data"] = movement_extra_data
		# Classic applies the item bonus after encumbrance; Remake weights the final stat.
		fidelity_fallbacks.append("movementUsesNativeEncumbranceScale")

	var magic_resistance_modifier := int(record.get("magicResistance", 0))
	if magic_resistance_modifier != 0 and not SLOT_BY_CLASSIC_TYPE.has(classic_type):
		unsupported_fields.append("magicResistance")
	elif magic_resistance_modifier != 0:
		fields["classicMagicResistance"] = magic_resistance_modifier
		var resistance_sign_prefix := "+" if magic_resistance_modifier > 0 else ""
		stats_summary.append(
			"%s%d%% Classic Magic Resistance" % [
				resistance_sign_prefix,
				magic_resistance_modifier,
			]
		)

	var native_restrictions := _native_restrictions(
		record,
		SLOT_BY_CLASSIC_TYPE.has(classic_type)
	)
	for field_name: String in native_restrictions.get("fields", {}):
		fields[field_name] = native_restrictions["fields"][field_name]
	for field_name: String in native_restrictions.get("unsupportedFields", []):
		if not unsupported_fields.has(field_name):
			unsupported_fields.append(field_name)

	if not stats.is_empty():
		fields["stats"] = stats
	if not stats_summary.is_empty():
		fields["stats_mini"] = ", ".join(stats_summary)
	return {
		"fields": fields,
		"unsupportedFields": unsupported_fields,
		"fidelityFallbacks": fidelity_fallbacks,
	}


func _native_restrictions(record: Dictionary, is_equipment: bool) -> Dictionary:
	var fields := {}
	var unsupported_fields: Array[String] = []
	var race_restrictions := int(record.get("raceRestrictions", 0))
	var race_only := int(record.get("raceClassOnly", 0))
	var specific_race := int(record.get("specificRace", 0))
	var caste_restrictions := int(record.get("casteRestrictions", 0))
	var caste_only := int(record.get("casteClassOnly", 0))
	var specific_caste := int(record.get("specificCaste", 0))
	var restriction_values := {
		"raceRestrictions": race_restrictions,
		"raceClassOnly": race_only,
		"specificRace": specific_race,
		"casteRestrictions": caste_restrictions,
		"casteClassOnly": caste_only,
		"specificCaste": specific_caste,
	}
	if not is_equipment:
		for field_name: String in restriction_values:
			if int(restriction_values[field_name]) != 0:
				unsupported_fields.append(field_name)
		return {"fields": fields, "unsupportedFields": unsupported_fields}

	if _mask_has_bits_after(race_restrictions, 9):
		unsupported_fields.append("raceRestrictions")
	if _mask_has_bits_after(race_only, 9):
		unsupported_fields.append("raceClassOnly")
	if _mask_has_bits_after(caste_restrictions, 7):
		unsupported_fields.append("casteRestrictions")
	if _mask_has_bits_after(caste_only, 7):
		unsupported_fields.append("casteClassOnly")

	var has_race_restriction := (
		race_restrictions != 0 or race_only != 0 or specific_race != 0
	)
	if has_race_restriction:
		if specific_race < 0 or specific_race > STANDARD_RACE_NAMES.size():
			unsupported_fields.append("specificRace")
		else:
			var allowed_races: Array[String] = []
			for race_index: int in range(STANDARD_RACE_NAMES.size()):
				if specific_race > 0 and race_index != specific_race - 1:
					continue
				var descriptors: int = STANDARD_RACE_DESCRIPTORS[race_index]
				if _masks_overlap(descriptors, race_restrictions, 9):
					continue
				if not _mask_contains_all(descriptors, race_only, 9):
					continue
				allowed_races.append(STANDARD_RACE_NAMES[race_index])
			fields["only_usable_by_races"] = allowed_races

	var has_caste_restriction := (
		caste_restrictions != 0 or caste_only != 0 or specific_caste != 0
	)
	if has_caste_restriction:
		if specific_caste < 0 or specific_caste > STANDARD_CASTE_NAMES.size():
			unsupported_fields.append("specificCaste")
		else:
			var allowed_castes: Array[String] = []
			for caste_index: int in range(STANDARD_CASTE_NAMES.size()):
				if specific_caste > 0 and caste_index != specific_caste - 1:
					continue
				var caste_class: int = STANDARD_CASTE_CLASSES[caste_index]
				if _classic_mask_has(caste_restrictions, caste_class - 1):
					continue
				if caste_only != 0 and not _classic_mask_has(caste_only, caste_class - 1):
					continue
				allowed_castes.append(STANDARD_CASTE_NAMES[caste_index])
			fields["only_usable_by_classes"] = allowed_castes
	return {"fields": fields, "unsupportedFields": unsupported_fields}


func _classic_mask_has(mask: int, bit_index: int) -> bool:
	return (mask & (1 << (15 - bit_index))) != 0


func _mask_has_bits_after(mask: int, supported_bits: int) -> bool:
	for bit_index: int in range(supported_bits, 16):
		if _classic_mask_has(mask, bit_index):
			return true
	return false


func _masks_overlap(left: int, right: int, bit_count: int) -> bool:
	for bit_index: int in range(bit_count):
		if _classic_mask_has(left, bit_index) and _classic_mask_has(right, bit_index):
			return true
	return false


func _mask_contains_all(value: int, required: int, bit_count: int) -> bool:
	for bit_index: int in range(bit_count):
		if _classic_mask_has(required, bit_index) and not _classic_mask_has(value, bit_index):
			return false
	return true


func _unsupported_fields(
	record: Dictionary,
	native_fields: Dictionary,
	native_type: Dictionary
) -> Array[String]:
	var fields: Array[String] = []
	for field_name: String in UNSUPPORTED_EFFECT_FIELDS:
		if int(record.get(field_name, 0)) != 0 \
				and not ItemBehaviorsScript.handles_special_field(
					record,
					field_name
				):
			fields.append(field_name)
	for field_name: String in native_fields.get("unsupportedFields", []):
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
	file.store_string(DistributionJsonScript.stringify(value, true))
	file.close()
	return OK


func _fail(message: String) -> Dictionary:
	last_error = message
	return {"status": "error", "message": message}
