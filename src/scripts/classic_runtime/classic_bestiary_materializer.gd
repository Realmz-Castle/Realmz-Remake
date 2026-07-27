class_name ClassicBestiaryMaterializer
extends RefCounted

const DistributionJsonScript = preload(
	"res://scripts/classic_runtime/classic_distribution_json.gd"
)

const ItemIdentityScript = preload("res://scripts/classic_runtime/classic_item_identity.gd")
const ItemIdsScript = preload("res://scripts/item_id_divinity.gd")
const ItemBehaviorsScript = preload(
	"res://scripts/classic_runtime/classic_item_behaviors.gd"
)
const SpellIdentityScript = preload("res://scripts/classic_runtime/classic_spell_identity.gd")
const SpellResourceCatalogScript = preload(
	"res://scripts/classic_runtime/classic_spell_resource_catalog.gd"
)
const SpellIdsScript = preload("res://scripts/spells_id_divinity.gd")
const RegenerationScript = preload("res://scripts/classic_runtime/classic_regeneration.gd")
const AnimationScript = preload("res://scripts/classic_runtime/classic_animation.gd")
const SpellScreenScript = preload("res://scripts/classic_runtime/classic_spell_screen.gd")
const CharacterConditionRulesScript = preload(
	"res://scripts/classic_runtime/classic_character_condition_rules.gd"
)
const CustomSpellSupportScript = preload(
	"res://scripts/classic_runtime/classic_custom_spell_support.gd"
)
const SpellSavesScript = preload("res://scripts/classic_runtime/classic_spell_saves.gd")
const MonsterSpecialAttackScript = preload(
	"res://scripts/classic_runtime/classic_monster_special_attack.gd"
)
const MonsterGenerationScript = preload(
	"res://scripts/classic_runtime/classic_monster_generation.gd"
)
const MonsterIconResolutionScript = preload(
	"res://scripts/classic_runtime/classic_monster_icon_resolution.gd"
)

const BESTIARY_BOOK_PATH := "Bestiary/stuff_book.json"
const BESTIARY_IMAGE_BOOK_PATH := "Bestiary/img_pack.json"
const BESTIARY_ATLAS_PATH := "Bestiary/textureAtlas.png"
const SHARED_BESTIARY_BOOK_PATH := "res://shared_assets/Bestiary/stuff_book.json"
const ITEM_BOOK_PATH := "Items/stuff_book.json"
const SHARED_ITEM_BOOK_PATH := "res://shared_assets/items/stuff_book.json"
const SHARED_SPELL_DIRECTORY := "res://shared_assets/spells/"
const TEMPORARY_SPELL_SCREEN_TRAIT := "t_classic_spell_screen.gd"
const PERMANENT_ANIMATED_TRAIT := "p_classic_animated.gd"
const DEFAULT_IMAGE := "CREA_humanmage"
const STOCK_SHARED_IMAGE_BY_ICON_ID := {
	398: "CREA_carrion_slug",
	509: "CREA_classic_cicn_509",
}
const STOCK_SHARED_IMAGE_ALIASES_BY_ICON_ID := {
	398: ["CREA_carrion_slug", "CREA_larva", "CREA_slime_worm"],
	509: ["CREA_classic_cicn_509"],
}
const TYPE_TAGS := [
	"Magic Using",
	"Undead",
	"Demonic",
	"Reptilian",
	"Evil Creature",
	"Intelligent",
	"Large Creature",
	"Non-Humanoid",
]
const SIZE_BY_CLASSIC_VALUE := {
	0: [1, 1],
	1: [1, 2],
	2: [2, 1],
	3: [2, 2],
}
const SAVE_MULTIPLIERS := [
	"MultiplierMental",
	"MultiplierFire",
	"MultiplierIce",
	"MultiplierElect",
	"MultiplierChemical",
	"MultiplierMental",
]
const ELEMENT_BY_SPECIAL_ATTACK := {
	11: "Fire",
	12: "Ice",
	13: "Electric",
	14: "Chemical",
	15: "Mental",
}
const UNSUPPORTED_SCALAR_FIELDS := [
	"beenAttacked",
]
const CLASSIC_INERT_MORALE_MAX := 100
const MATERIALIZATION_VERSION := 5

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
	var monsters: Variant = content.get("monsters", [])
	if not (monsters is Array):
		return _fail("Classic monster collection is malformed")
	if monsters.is_empty():
		return {
			"status": "ok",
			"generated": 0,
			"updated": 0,
			"skipped": 0,
			"reusedNative": 0,
		}

	var book_path := root.path_join(BESTIARY_BOOK_PATH)
	var bestiary_book := _read_bestiary_book(book_path)
	if not last_error.is_empty():
		return {"status": "error", "message": last_error}
	var shared_bestiary_book := _read_json_book(
		SHARED_BESTIARY_BOOK_PATH,
		"Shared native bestiary book"
	)
	if not last_error.is_empty():
		return {"status": "error", "message": last_error}
	var descriptions: Array = content.get("monsterDescriptions", []) \
		if content.get("monsterDescriptions", []) is Array else []
	var item_texts: Array = content.get("itemTexts", []) \
		if content.get("itemTexts", []) is Array else []
	var item_book := _read_item_context(root)
	if not last_error.is_empty():
		return {"status": "error", "message": last_error}
	var item_ids: Object = ItemIdsScript.new()
	var item_mapping: Dictionary = item_ids.mapping.duplicate()
	item_ids.free()
	var spell_ids: Object = SpellIdsScript.new()
	var spell_mapping: Dictionary = spell_ids.mappings.duplicate()
	spell_ids.free()
	var spell_book := _read_spell_context()
	_merge_custom_spell_context(bundle, spell_book)
	var records: Array[Dictionary] = []
	for monster_value: Variant in monsters:
		if not (monster_value is Dictionary):
			return _fail("Classic monster collection contains a malformed record")
		records.append(monster_value)
	records.sort_custom(
		func(left: Dictionary, right: Dictionary) -> bool:
			return abs(int(left.get("id", 0))) < abs(int(right.get("id", 0)))
	)
	var asset_catalog: Variant = bundle.documents.get("assets", {}).get("catalog", {})
	var icon_catalog: Variant = asset_catalog.get("icons", []) \
		if asset_catalog is Dictionary else []
	var image_book_path := root.path_join(BESTIARY_IMAGE_BOOK_PATH)
	var image_book := _read_json_book(image_book_path, "Campaign bestiary image book")
	if not last_error.is_empty():
		return {"status": "error", "message": last_error}
	var atlas_path := root.path_join(BESTIARY_ATLAS_PATH)
	var atlas_state := _read_atlas_state(atlas_path, image_book)
	if not last_error.is_empty():
		return {"status": "error", "message": last_error}

	var generated := 0
	var updated := 0
	var skipped := 0
	var reused_native := 0
	for record: Dictionary in records:
		var hit_dice := int(record.get("hitDice", 0))
		if hit_dice == 255:
			break
		if hit_dice == 0:
			continue
		var source_id := int(record.get("id", -1))
		if source_id < 0:
			continue
		var monster_id: int = abs(source_id)
		var icon_resolution := MonsterIconResolutionScript.resolve(
			int(record.get("iconId", 0)),
			icon_catalog
		)
		icon_resolution = _materialize_campaign_icon(
			root,
			icon_resolution,
			image_book,
			atlas_state
		)
		if not last_error.is_empty():
			return {"status": "error", "message": last_error}
		var existing_key: Variant = _book_monster_key_by_id(bestiary_book, monster_id)
		if existing_key != null:
			var existing_entry: Variant = bestiary_book[existing_key]
			if existing_entry is Dictionary \
					and abs(int(existing_entry.get("classicMonsterId", -1))) == monster_id:
				var existing_materialization: Variant = existing_entry.get(
					"classicMaterialization",
					{}
				)
				var existing_version := int(
					existing_materialization.get("version", 0)
					if existing_materialization is Dictionary
					else 0
				)
				if existing_version < MATERIALIZATION_VERSION:
					bestiary_book[existing_key] = _native_monster(
						record,
						descriptions,
						item_book,
						item_texts,
						item_mapping,
						spell_book,
						spell_mapping,
						icon_resolution
					)
					updated += 1
				else:
					skipped += 1
			else:
				skipped += 1
			continue
		if _book_has_matching_native_monster(
			shared_bestiary_book,
			record,
			icon_resolution
		):
			reused_native += 1
			continue
		bestiary_book[_monster_key(bestiary_book, monster_id)] = _native_monster(
			record,
			descriptions,
			item_book,
			item_texts,
			item_mapping,
			spell_book,
			spell_mapping,
			icon_resolution
		)
		generated += 1

	var bestiary_directory := book_path.get_base_dir()
	var make_error := DirAccess.make_dir_recursive_absolute(bestiary_directory)
	if make_error != OK:
		return _fail("Could not create native bestiary directory: %s" % error_string(make_error))
	var write_error := OK
	if generated > 0 or updated > 0 or not FileAccess.file_exists(book_path):
		write_error = _write_json(book_path, bestiary_book)
		if write_error != OK:
			return _fail("Could not write native bestiary book: %s" % error_string(write_error))
	if bool(atlas_state.get("dirty", false)) or not FileAccess.file_exists(image_book_path):
		write_error = _write_json(image_book_path, image_book)
		if write_error != OK:
			return _fail("Could not write native bestiary image book: %s" % error_string(write_error))
	if bool(atlas_state.get("dirty", false)) or not FileAccess.file_exists(atlas_path):
		var atlas: Image = atlas_state["image"]
		write_error = atlas.save_png(atlas_path)
		if write_error != OK:
			return _fail("Could not write native bestiary atlas: %s" % error_string(write_error))
	return {
		"status": "ok",
		"generated": generated,
		"updated": updated,
		"skipped": skipped,
		"reusedNative": reused_native,
	}


func _native_monster(
	record: Dictionary,
	descriptions: Array,
	item_book: Dictionary,
	item_texts: Array,
	item_mapping: Dictionary,
	spell_book: Dictionary,
	spell_mapping: Dictionary,
	icon_resolution := {}
) -> Dictionary:
	var monster_id: int = abs(int(record.get("id", -1)))
	var display_name := str(record.get("displayName", "")).strip_edges()
	if display_name.is_empty():
		display_name = "Classic Monster %d" % monster_id
	var hit_dice := maxi(0, int(record.get("hitDice", 0)))
	var stamina := _average_stamina(record)
	var native_inventory := _native_inventory(
		record,
		item_book,
		item_texts,
		item_mapping
	)
	var native_spells := _native_spells(record, spell_book, spell_mapping)
	var native_attacks := _native_attacks(record)
	var native_requirements := _native_weapon_requirements(
		record,
		item_book,
		item_texts,
		item_mapping
	)
	var native_missile_item := _native_missile_item(
		record,
		item_book,
		item_texts,
		item_mapping
	)
	var unsupported_fields := _unsupported_fields(
		record,
		native_inventory,
		native_spells,
		native_attacks,
		native_requirements,
		native_missile_item
	)
	if not (icon_resolution is Dictionary) or icon_resolution.is_empty():
		icon_resolution = MonsterIconResolutionScript.resolve(int(record.get("iconId", 0)))
	var image_key := str(icon_resolution.get("runtimeImageKey", ""))
	if image_key.is_empty():
		image_key = _stock_shared_image_key(icon_resolution)
	var fidelity_fallbacks: Array[String] = []
	if image_key.is_empty():
		image_key = DEFAULT_IMAGE
		fidelity_fallbacks.append(
			"iconId:%s" % str(icon_resolution.get("status", "unresolved"))
		)
	elif not icon_resolution.has("runtimeImageKey"):
		icon_resolution = icon_resolution.duplicate(true)
		icon_resolution["runtimeImageKey"] = image_key
		icon_resolution["runtimeImageSource"] = "shared-bestiary-atlas"
	var run_percent := int(record.get("runPercent", 0))
	var surrender_percent := int(record.get("surrenderPercent", 0))
	if (
		(run_percent != 0 and run_percent <= CLASSIC_INERT_MORALE_MAX)
		or (surrender_percent != 0 and surrender_percent <= CLASSIC_INERT_MORALE_MAX)
	):
		fidelity_fallbacks.append("classicInertMoraleThresholds")
	for fallback: String in native_inventory.get("fidelityFallbacks", []):
		if not fidelity_fallbacks.has(fallback):
			fidelity_fallbacks.append(fallback)
	for fallback: String in native_spells.get("fidelityFallbacks", []):
		if not fidelity_fallbacks.has(fallback):
			fidelity_fallbacks.append(fallback)
	for fallback: String in native_attacks.get("fidelityFallbacks", []):
		if not fidelity_fallbacks.has(fallback):
			fidelity_fallbacks.append(fallback)
	for fallback: String in native_requirements.get("fidelityFallbacks", []):
		if not fidelity_fallbacks.has(fallback):
			fidelity_fallbacks.append(fallback)
	for field_name: String in unsupported_fields.duplicate():
		if not _is_bounded_fidelity_fallback(field_name):
			continue
		unsupported_fields.erase(field_name)
		if not fidelity_fallbacks.has(field_name):
			fidelity_fallbacks.append(field_name)
	var native_traits: Array = []
	if AnimationScript.has_permanent_condition(record.get("conditions", [])):
		native_traits.append([PERMANENT_ANIMATED_TRAIT, []])
	var temporary_screens := SpellScreenScript.temporary_durations(
		record.get("conditions", [])
	)
	if temporary_screens.max() > 0:
		native_traits.append([TEMPORARY_SPELL_SCREEN_TRAIT, [temporary_screens]])
	var stats := _native_stats(record, stamina)
	var native_monster := {
		"classicMonsterId": monster_id,
		"classicMonsterNameId": int(record.get("nameId", -1)),
		"classicDeathMacro": int(record.get("deathMacro", 0)),
		"classicTurnUndeadEligible": _type_flag(record, 1) or _type_flag(record, 2),
		"classicHitDice": hit_dice,
		"classicArmor": int(record.get("armor", 0)),
		"classicMagicResistance": int(record.get("magicResistance", 0)),
		"classicSpellSaves": SpellSavesScript.monster_saves(record.get("saves", [])),
		"classicSpellImmunities": SpellSavesScript.monster_immunities(
			record.get("spellImmunities", [])
		),
		"classicRegenerationPerRound": RegenerationScript.permanent_amount(
			record.get("conditions", [])
		),
		"classicSpellScreenLevel": SpellScreenScript.permanent_level(
			record.get("conditions", [])
		),
		"classicCanSummon": int(record.get("canSummon", 0)),
		"classicCastPercent": int(record.get("castPercent", 0)),
		"classicMissilePercent": int(record.get("missilePercent", 0)),
		"classicRunPercent": int(record.get("runPercent", 0)),
		"classicSurrenderPercent": int(record.get("surrenderPercent", 0)),
		"classicWeaponItemId": int(record.get("weapon", 0)),
		"classicSpellIds": _integer_array(record.get("spells", []), 10),
		"classicRecord": record.duplicate(true),
		"classicMaterialization": {
			"version": MATERIALIZATION_VERSION,
			"status": "blocked" if not unsupported_fields.is_empty() else "fallback",
			"unsupportedFields": unsupported_fields,
			"fidelityFallbacks": fidelity_fallbacks,
			"iconResolution": icon_resolution.duplicate(true),
		},
		"data": {
			"id": monster_id,
			"name": display_name,
			"image": image_key,
			"size": SIZE_BY_CLASSIC_VALUE.get(int(record.get("size", 0)), [1, 1]),
			"tags": _type_tags(record),
			"in_bestiary": 0 if bool(record.get("notOnMenu", false)) else 1,
			"summonable": 1 if int(record.get("canSummon", 0)) == 1 else 0,
			"exp": _average_experience(record, stamina),
			"level": hit_dice,
			"faction": 1 if int(record.get("traitor", 0)) != 0 else 0,
			"is_player_controlled": 0,
			"description": _description(descriptions, monster_id),
		},
		"stats": stats,
		"traits": native_traits,
		"ai": {
			"flees_at": 0,
			"cast_chance": int(record.get("castPercent", 0)),
			"missile_chance": int(record.get("missilePercent", 0)),
		},
		"tools": {
			"inventory": native_inventory.get("entries", []),
			"money": _integer_array(record.get("money", []), 3),
			"unarmed_melee_attacks": native_attacks.get("entries", []),
			"spells": native_spells.get("entries", []),
		},
		"scripts": {"default": "test_crea_script.gd"},
	}
	for field_name: String in native_requirements.get("fields", {}):
		native_monster[field_name] = native_requirements["fields"][field_name]
	for field_name: String in native_missile_item.get("fields", {}):
		native_monster[field_name] = native_missile_item["fields"][field_name]
	return native_monster


func _native_weapon_requirements(
	record: Dictionary,
	item_book: Dictionary,
	item_texts: Array,
	item_mapping: Dictionary
) -> Dictionary:
	var fields := {}
	var unsupported_fields: Array[String] = []
	var fidelity_fallbacks: Array[String] = []
	# Realmz names this field "distance", but its attack code treats it as a
	# required blunt, sharp, or exact weapon identity.
	var required_weapon := int(record.get("distance", 0))
	if required_weapon in [-2, -1]:
		fields["classicRequiredWeaponKind"] = (
			"blunt" if required_weapon == -1 else "sharp"
		)
	elif required_weapon < -2:
		unsupported_fields.append("distance")
	elif required_weapon > 0:
		var item_name := _item_resource_key(
			required_weapon,
			item_book,
			item_texts,
			item_mapping
		)
		if item_name.is_empty():
			unsupported_fields.append("distance")
		else:
			fields["classicRequiredWeaponItemId"] = required_weapon
			fields["classicRequiredWeaponName"] = item_name

	var required_magic_plus := int(record.get("magicToHit", 0))
	if required_magic_plus < 0:
		unsupported_fields.append("magicToHit")
	elif required_magic_plus > 0:
		fields["classicRequiredMagicPlus"] = required_magic_plus
	if not fields.is_empty():
		fidelity_fallbacks.append("weaponRequirementsUseNativeMissFeedback")
	return {
		"fields": fields,
		"unsupportedFields": unsupported_fields,
		"fidelityFallbacks": fidelity_fallbacks,
	}


func _native_spells(
	record: Dictionary,
	spell_book: Dictionary,
	spell_mapping: Dictionary
) -> Dictionary:
	var entries: Array = []
	var unsupported_fields: Array[String] = []
	var fidelity_fallbacks: Array[String] = []
	var spell_ids := _integer_array(record.get("spells", []), 10)
	for spell_index: int in range(spell_ids.size()):
		var spell_id: int = spell_ids[spell_index]
		if spell_id == 0:
			continue
		var spell_key := SpellIdentityScript.resource_key(
			spell_id,
			spell_mapping,
			spell_book
		)
		if spell_key.is_empty():
			unsupported_fields.append("spells[%d]" % spell_index)
			continue
		entries.append([spell_key, 1])
		if SpellIdentityScript.resource_ids(spell_book[spell_key]).is_empty() \
				and not fidelity_fallbacks.has("spellIdentityNameMapping"):
			fidelity_fallbacks.append("spellIdentityNameMapping")
	return {
		"entries": entries,
		"unsupportedFields": unsupported_fields,
		"fidelityFallbacks": fidelity_fallbacks,
	}


func _native_inventory(
	record: Dictionary,
	item_book: Dictionary,
	item_texts: Array,
	item_mapping: Dictionary
) -> Dictionary:
	var entries: Array = []
	var unsupported_fields: Array[String] = []
	var fidelity_fallbacks: Array[String] = []
	var item_ids := _integer_array(record.get("items", []), 6)
	var weapon_id := int(record.get("weapon", 0))
	var equipped_weapon := false
	var carried_weapon := false
	if weapon_id < 0:
		unsupported_fields.append("weapon.randomSelector")
	for item_index: int in range(item_ids.size()):
		var raw_item_id: int = item_ids[item_index]
		if raw_item_id == 0:
			continue
		var item_id: int = abs(raw_item_id)
		if weapon_id > 0 and abs(weapon_id) == item_id:
			carried_weapon = true
		var item_key := _item_resource_key(
			item_id,
			item_book,
			item_texts,
			item_mapping
		)
		if item_key.is_empty():
			unsupported_fields.append("items[%d]" % item_index)
			continue
		var should_equip: bool = (
			weapon_id > 0
			and not equipped_weapon
			and abs(weapon_id) == item_id
		)
		var native_item: Dictionary = item_book.get(item_key, {})
		var materialization: Variant = native_item.get("classicMaterialization", {})
		if materialization is Dictionary \
				and str(materialization.get("status", "")) == "blocked":
			unsupported_fields.append("items[%d].nativeFields" % item_index)
		if should_equip and int(native_item.get("equippable", 0)) == 0:
			unsupported_fields.append("weapon.nonEquippable")
		var native_entry: Array = [
			item_key,
			1 if should_equip and int(native_item.get("equippable", 0)) != 0 else 0,
		]
		if int(record.get("missilePercent", 0)) != 0 and item_index == 1:
			native_entry.append(true)
			native_entry.append(item_index)
		entries.append(native_entry)
		if should_equip:
			equipped_weapon = true
		if raw_item_id < 0 and not fidelity_fallbacks.has("itemDetectionMarkers"):
			# Classic uses the sign bit to mark magic detected on a monster item.
			# Remake can still carry and drop the item, but has no equivalent marker.
			fidelity_fallbacks.append("itemDetectionMarkers")
	if weapon_id > 0 and not carried_weapon:
		var weapon_key := _item_resource_key(
			weapon_id,
			item_book,
			item_texts,
			item_mapping
		)
		if weapon_key.is_empty():
			unsupported_fields.append("weapon")
		else:
			var native_weapon: Dictionary = item_book.get(weapon_key, {})
			var materialization: Variant = native_weapon.get(
				"classicMaterialization", {}
			)
			if materialization is Dictionary \
					and str(materialization.get("status", "")) == "blocked":
				unsupported_fields.append("weapon.nativeFields")
			if int(native_weapon.get("equippable", 0)) == 0:
				unsupported_fields.append("weapon.nonEquippable")
			else:
				# Realmz keeps a positive active weapon separate from the six
				# carried-item slots, so this native equipment entry is not loot.
				entries.append([weapon_key, 1, false])
				equipped_weapon = true
				fidelity_fallbacks.append("separateActiveWeaponInventoryEntry")
	elif weapon_id > 0 and not equipped_weapon:
		unsupported_fields.append("weapon")
	return {
		"entries": entries,
		"unsupportedFields": unsupported_fields,
		"fidelityFallbacks": fidelity_fallbacks,
	}


func _native_missile_item(
	record: Dictionary,
	item_book: Dictionary,
	item_texts: Array,
	item_mapping: Dictionary
) -> Dictionary:
	if int(record.get("missilePercent", 0)) == 0:
		return {"fields": {}, "unsupportedFields": []}
	var item_ids: Array[int] = _integer_array(record.get("items", []), 6)
	var item_id: int = abs(item_ids[1])
	if item_id == 0:
		return {"fields": {}, "unsupportedFields": ["missilePercent"]}
	var item_name := _item_resource_key(
		item_id,
		item_book,
		item_texts,
		item_mapping
	)
	var native_item: Variant = item_book.get(item_name, {})
	if item_name.is_empty() or not (native_item is Dictionary):
		return {"fields": {}, "unsupportedFields": ["missilePercent"]}
	var combat_spell: Variant = native_item.get("_on_combat_use_spell")
	if not (combat_spell is Array) or combat_spell.size() < 2:
		return {"fields": {}, "unsupportedFields": ["missilePercent"]}
	var maximum_charges := int(native_item.get("charges_max", 0))
	if maximum_charges != 0 and int(native_item.get("charges", 0)) <= 0:
		return {"fields": {}, "unsupportedFields": ["missilePercent"]}
	return {
		"fields": {
			"classicMissileItemName": item_name,
			"classicMissileItemSlot": 1,
		},
		"unsupportedFields": [],
	}


func _item_resource_key(
	item_id: int,
	item_book: Dictionary,
	item_texts: Array,
	item_mapping: Dictionary
) -> String:
	return ItemIdentityScript.resource_key(
		item_id,
		item_mapping,
		item_texts,
		item_book
	)


func _native_stats(record: Dictionary, stamina: int) -> Dictionary:
	var hit_dice := maxi(0, int(record.get("hitDice", 0)))
	var damage_bonus := int(record.get("damageBonus", 0))
	var spell_points := maxi(0, int(record.get("spellPoints", 0)))
	var stats := {
		"MaxMovement": maxi(0, int(record.get("movementMax", 0))),
		"MaxActions": maxi(1, int(record.get("attackCount", 1))),
		"MaxSpellsPerRound": maxi(0, int(record.get("magicAttackCount", 0))),
		"Strength": 10,
		"Intellect": 10,
		"Wisdom": 10,
		"Dexterity": int(record.get("agility", 0)),
		"Vitality": 10,
		"Weight_Limit": 1000000000,
		"curHP": stamina,
		"curSP": spell_points,
		"curTP": 0,
		"curFP": 0,
		"curRP": 0,
		"maxHP": stamina,
		"maxSP": spell_points,
		"maxTP": 0,
		"maxFP": 0,
		"maxRP": 0,
		"HP_regen_base": 1.0,
		"SP_regen_base": 1.0,
		"HP_regen_mult": 0.0,
		"SP_regen_mult": 0.0,
		# Remake's opposed-roll stats represent five Classic percentage points.
		"AccuracyMelee": hit_dice + damage_bonus,
		"AccuracyRanged": hit_dice + damage_bonus,
		# magicToHit is a required weapon enchantment, not spell accuracy.
		"AccuracyMagic": 0,
		"EvasionMelee": float(record.get("armor", 0)) / 5.0,
		"EvasionRanged": float(record.get("armor", 0)) / 5.0,
		"EvasionMagic": 0,
		"ResistancePhysical": 0.0,
		"ResistanceFire": 0.0,
		"ResistanceIce": 0.0,
		"ResistanceElect": 0.0,
		"ResistancePoison": 0.0,
		"ResistanceChemical": 0.0,
		"ResistanceDisease": 0.0,
		"ResistanceMagic": 0.0,
		"ResistanceHealing": 0.0,
		"ResistanceMental": 0.0,
		"MultiplierPhysical": 1.0,
		"MultiplierFire": 1.0,
		"MultiplierIce": 1.0,
		"MultiplierElect": 1.0,
		"MultiplierPoison": 1.0,
		"MultiplierChemical": 1.0,
		"MultiplierDisease": 1.0,
		"MultiplierMagic": 1.0,
		"MultiplierHealing": 1.0,
		"MultiplierMental": 1.0,
		"Melee_Crit_Rate": 0.0,
		"Melee_Crit_Mult": 0.0,
		"Ranged_Crit_Rate": 0.0,
		"Ranged_Crit_Mult": 0.0,
		"Bonus_Physical_dmg": damage_bonus,
		"Bonus_Magical_dmg": 0,
		"Detect_Secret": 0.0,
		"Acrobatics": 0.0,
		"Detect_Trap": 0.0,
		"Disable_Trap": 0.0,
		"Force_Lock": 0.0,
		"Pick_Lock": 0.0,
		"Turn_Undead": 0.0,
	}
	var saves := _integer_array(record.get("saves", []), 6)
	var immunities := _integer_array(record.get("spellImmunities", []), 6)
	for save_index: int in range(6):
		var multiplier := 0.0 if immunities[save_index] != 0 \
			else _save_multiplier(saves[save_index])
		var stat_name: String = SAVE_MULTIPLIERS[save_index]
		stats[stat_name] = minf(float(stats[stat_name]), multiplier)
	return stats


func _native_attacks(record: Dictionary) -> Dictionary:
	var entries: Array = []
	var unsupported_fields: Array[String] = []
	var fidelity_fallbacks: Array[String] = []
	var uses_native_weapon := int(record.get("weapon", 0)) != 0
	var source: Variant = record.get("attacks", [])
	var attack_count := maxi(1, int(record.get("attackCount", 1)))
	if source is Array:
		for attack_index: int in mini(attack_count, source.size()):
			var row: Variant = source[attack_index]
			if not (row is Array) or row.size() < 2:
				continue
			var low := int(row[0])
			var high := int(row[1])
			var special := int(row[3]) if row.size() > 3 else 0
			if low == 0 and high == 0 and special == 0:
				continue
			var damage := {"Physical": [mini(low, high), maxi(low, high)]}
			var attack_sound := MonsterGenerationScript.unarmed_attack_sound_name(
				row,
				source[0] if not source.is_empty() else []
			)
			if attack_sound.is_empty():
				attack_sound = "slurpy.wav"
				if not uses_native_weapon and not fidelity_fallbacks.has("attackSounds"):
					fidelity_fallbacks.append("attackSounds")
			var attack := {
				"weapon_dmg": damage,
				"sound": attack_sound,
				"melee_atk_anim_icon": "ATK_HTH",
				"melee_inflicted_traits": [],
			}
			if special != 0:
				attack["extra_data"] = {"classicSpecialAttack": special}
			if ELEMENT_BY_SPECIAL_ATTACK.has(special):
				if high < 1:
					unsupported_fields.append("attacks[%d].specialDamage" % attack_index)
				else:
					damage[ELEMENT_BY_SPECIAL_ATTACK[special]] = [1, high]
					# Native resistance replaces Classic's separate save and
					# protection rolls for the same damage family.
					if not fidelity_fallbacks.has("elementalSpecialAttackMitigation"):
						fidelity_fallbacks.append("elementalSpecialAttackMitigation")
			elif special != 0 and not MonsterSpecialAttackScript.supports(special):
				unsupported_fields.append("attacks[%d].special" % attack_index)
			entries.append(attack)
	if entries.is_empty():
		entries.append({
			"weapon_dmg": {"Physical": [1, 1]},
			"sound": MonsterGenerationScript.unarmed_attack_sound_name(
				[1, 1, 0, 0]
			),
			"melee_atk_anim_icon": "ATK_HTH",
			"melee_inflicted_traits": [],
		})
	return {
		"entries": entries,
		"unsupportedFields": unsupported_fields,
		"fidelityFallbacks": fidelity_fallbacks,
	}


func _unsupported_fields(
	record: Dictionary,
	native_inventory: Dictionary,
	native_spells: Dictionary,
	native_attacks: Dictionary,
	native_requirements: Dictionary,
	native_missile_item := {}
) -> Array[String]:
	var fields: Array[String] = []
	for field_name: String in UNSUPPORTED_SCALAR_FIELDS:
		if int(record.get(field_name, 0)) != 0:
			fields.append(field_name)
	if _has_unsupported_conditions(record.get("conditions", [])):
		fields.append("conditions")
	for field_name: String in native_inventory.get("unsupportedFields", []):
		if not fields.has(field_name):
			fields.append(field_name)
	for field_name: String in native_spells.get("unsupportedFields", []):
		if not fields.has(field_name):
			fields.append(field_name)
	for field_name: String in native_attacks.get("unsupportedFields", []):
		if not fields.has(field_name):
			fields.append(field_name)
	for field_name: String in native_requirements.get("unsupportedFields", []):
		if not fields.has(field_name):
			fields.append(field_name)
	for field_name: String in native_missile_item.get("unsupportedFields", []):
		if not fields.has(field_name):
			fields.append(field_name)
	if not SIZE_BY_CLASSIC_VALUE.has(int(record.get("size", 0))):
		fields.append("size")
	if int(record.get("attackCount", 0)) < 1 or int(record.get("attackCount", 0)) > 5:
		fields.append("attackCount")
	if int(record.get("canSummon", 0)) not in [-1, 0, 1]:
		fields.append("canSummon")
	return fields


func _has_unsupported_conditions(conditions: Variant) -> bool:
	if not (conditions is Array):
		return false
	for condition_index: int in range(conditions.size()):
		var value := int(conditions[condition_index])
		if value == 0:
			continue
		if CharacterConditionRulesScript.supports_condition(condition_index):
			continue
		return true
	return false


func _is_bounded_fidelity_fallback(field_name: String) -> bool:
	# The full source record remains attached to the generated creature. These
	# gaps affect a secondary native projection, but the creature can still be
	# spawned, fight with its compiled attack rows, and drop its preserved item.
	return (
		field_name.ends_with(".nativeFields")
		or field_name in [
			"weapon.randomSelector",
			"weapon.nonEquippable",
			"weapon.nativeFields",
			"missilePercent",
		]
		or (
			field_name.begins_with("attacks[")
			and field_name.ends_with("].special")
		)
	)


func _average_stamina(record: Dictionary) -> int:
	var hit_dice := maxi(0, int(record.get("hitDice", 0)))
	var bonus := maxi(0, int(record.get("staminaBonus", 0)))
	return maxi(1, bonus + roundi(float(hit_dice) * 4.5))


func _average_experience(record: Dictionary, stamina: int) -> int:
	return MonsterGenerationScript.experience(record, stamina)


func _save_multiplier(save_chance: int) -> float:
	return clampf(1.0 - float(save_chance) / 200.0, 0.0, 2.0)


func _type_tags(record: Dictionary) -> Array[String]:
	var tags: Array[String] = []
	var flags: Variant = record.get("typeFlags", [])
	if not (flags is Array):
		return tags
	for flag_index: int in mini(flags.size(), TYPE_TAGS.size()):
		if int(flags[flag_index]) != 0:
			tags.append(TYPE_TAGS[flag_index])
	return tags


func _type_flag(record: Dictionary, flag_index: int) -> bool:
	var flags: Variant = record.get("typeFlags", [])
	return flags is Array and flag_index < flags.size() and int(flags[flag_index]) != 0


func _description(descriptions: Array, monster_id: int) -> String:
	for description_value: Variant in descriptions:
		if description_value is Dictionary \
				and abs(int(description_value.get("id", -1))) == monster_id:
			return str(description_value.get("text", ""))
	return ""


func _integer_array(value: Variant, size: int) -> Array[int]:
	var result: Array[int] = []
	result.resize(size)
	result.fill(0)
	if value is Array:
		for index: int in mini(size, value.size()):
			result[index] = int(value[index])
	return result


func _array_has_nonzero(value: Variant) -> bool:
	if not (value is Array):
		return false
	for entry: Variant in value:
		if entry is Array:
			if _array_has_nonzero(entry):
				return true
		elif int(entry) != 0:
			return true
	return false


func _read_bestiary_book(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (value is Dictionary):
		last_error = "Existing native bestiary book is not a JSON object"
		return {}
	return value


func _read_item_context(campaign_root: String) -> Dictionary:
	var item_book := _read_json_book(SHARED_ITEM_BOOK_PATH, "Shared native item book")
	if not last_error.is_empty():
		return {}
	var campaign_book := _read_json_book(
		campaign_root.path_join(ITEM_BOOK_PATH),
		"Campaign native item book"
	)
	if not last_error.is_empty():
		return {}
	item_book.merge(campaign_book, true)
	return ItemBehaviorsScript.enrich_item_book(item_book)


func _read_spell_context() -> Dictionary:
	var spell_book: Dictionary = {}
	# Source builds read declarative identity fields. Exported PCKs fall back to
	# compiled resource metadata because the original script text is unavailable.
	SpellResourceCatalogScript.merge_directory(SHARED_SPELL_DIRECTORY, spell_book)
	return spell_book


func _merge_custom_spell_context(bundle: Object, spell_book: Dictionary) -> void:
	var overrides: Variant = bundle.get("spell_overrides_by_id")
	if not (overrides is Dictionary):
		return
	var spell_ids: Array = overrides.keys()
	spell_ids.sort()
	for spell_id_value: Variant in spell_ids:
		var spell_id: int = abs(int(spell_id_value))
		var record: Variant = overrides[spell_id_value]
		if not (record is Dictionary) \
				or not CustomSpellSupportScript.is_executable(record):
			continue
		var spell_name := str(record.get("displayName", "")).strip_edges()
		if spell_name.is_empty():
			spell_name = "Classic spell %d" % spell_id
		var metadata: Dictionary = spell_book.get(spell_name, {})
		var classic_ids: Array = metadata.get("classicSpellIds", [])
		if not (classic_ids is Array):
			classic_ids = []
		if not classic_ids.has(spell_id):
			classic_ids.append(spell_id)
		metadata["classicSpellIds"] = classic_ids
		metadata["classicSpellId"] = spell_id
		metadata["classicCustomSpell"] = true
		spell_book[spell_name] = metadata


func _read_json_book(path: String, description: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (value is Dictionary):
		last_error = "%s is not a JSON object: %s" % [description, path]
		return {}
	return value


func _book_monster_key_by_id(bestiary_book: Dictionary, monster_id: int) -> Variant:
	for bestiary_key: Variant in bestiary_book:
		var monster_value: Variant = bestiary_book[bestiary_key]
		if monster_value is Dictionary \
				and _monster_has_explicit_id(monster_value, monster_id):
			return bestiary_key
	return null


func _book_has_matching_native_monster(
	bestiary_book: Dictionary,
	record: Dictionary,
	icon_resolution := {}
) -> bool:
	# Authored records may intentionally redefine a stock identity. Only imported
	# library records are eligible for reuse from Remake's shared bestiary.
	if bool(record.get("authored", true)):
		return false
	var monster_id: int = abs(int(record.get("id", -1)))
	var source_name := str(record.get("displayName", "")).strip_edges().to_lower()
	if monster_id < 0 or source_name.is_empty():
		return false
	if not (icon_resolution is Dictionary) or icon_resolution.is_empty():
		icon_resolution = MonsterIconResolutionScript.resolve(
			int(record.get("iconId", 0))
		)
	for bestiary_key: Variant in bestiary_book:
		var monster_value: Variant = bestiary_book[bestiary_key]
		if not (monster_value is Dictionary):
			continue
		var data: Variant = monster_value.get("data", {})
		if not (data is Dictionary):
			continue
		var native_name := str(data.get("name", bestiary_key)).strip_edges().to_lower()
		if native_name != source_name:
			continue
		if not _native_image_matches_icon(data, icon_resolution):
			continue
		if _monster_has_explicit_id(monster_value, monster_id) \
				or _monster_has_explicit_id(data, monster_id):
			return true
		var native_id: Variant = data.get("id")
		if (native_id is int or native_id is float) \
				and abs(int(native_id)) == monster_id:
			return true
	return false


func _native_image_matches_icon(
	data: Dictionary,
	icon_resolution: Dictionary
) -> bool:
	if str(icon_resolution.get("status", "")) == "campaign-runtime-media":
		return false
	var image_key := _stock_shared_image_key(icon_resolution)
	if image_key.is_empty():
		return true
	var base_icon_id := int(icon_resolution.get("baseIconId", 0))
	var aliases: Variant = STOCK_SHARED_IMAGE_ALIASES_BY_ICON_ID.get(
		base_icon_id,
		[image_key]
	)
	return aliases is Array and aliases.has(str(data.get("image", "")))


func _stock_shared_image_key(icon_resolution: Dictionary) -> String:
	if str(icon_resolution.get("status", "")) != "stock-family-jewels-pair":
		return ""
	return str(
		STOCK_SHARED_IMAGE_BY_ICON_ID.get(
			int(icon_resolution.get("baseIconId", 0)),
			""
		)
	)


func _read_atlas_state(atlas_path: String, image_book: Dictionary) -> Dictionary:
	var atlas := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	atlas.fill(Color(0, 0, 0, 0))
	if FileAccess.file_exists(atlas_path):
		var loaded := Image.new()
		var load_error := loaded.load(atlas_path)
		if load_error != OK or loaded.is_empty():
			last_error = "Campaign bestiary atlas is not a readable image: %s" % atlas_path
			return {}
		loaded.convert(Image.FORMAT_RGBA8)
		atlas = loaded
	var next_y := 0
	if not image_book.is_empty():
		next_y = ceili(float(atlas.get_height()) / 32.0) * 32
	return {
		"image": atlas,
		"nextY": next_y,
		"dirty": false,
	}


func _materialize_campaign_icon(
	root: String,
	icon_resolution: Dictionary,
	image_book: Dictionary,
	atlas_state: Dictionary
) -> Dictionary:
	if str(icon_resolution.get("status", "")) != "campaign-runtime-media":
		return icon_resolution
	var relative_path := str(icon_resolution.get("baseRuntimeMediaPath", "")).strip_edges()
	var source_path := root.path_join(relative_path)
	var source_image := Image.new()
	var load_error := source_image.load(source_path)
	if load_error != OK or source_image.is_empty():
		last_error = "Classic monster icon runtime media is not readable: %s" % relative_path
		return icon_resolution
	source_image.convert(Image.FORMAT_RGBA8)
	var size := Vector2i(source_image.get_width(), source_image.get_height())
	if size.x not in [32, 64] or size.y not in [32, 64]:
		last_error = (
			"Classic monster icon runtime media %s is %d x %d; "
			+ "native bestiary sprites require 32- or 64-pixel dimensions"
		) % [relative_path, size.x, size.y]
		return icon_resolution
	var image_key := "CREA_classic_campaign_cicn_%d" % int(
		icon_resolution.get("baseIconId", 0)
	)
	var position := _existing_image_position(image_book.get(image_key, {}), size, atlas_state)
	if position.x < 0:
		position = Vector2i(0, int(atlas_state.get("nextY", 0)))
		atlas_state["nextY"] = position.y + size.y
		image_book[image_key] = {
			"0_ref_x": position.x / 32,
			"0_ref_y": position.y / 32,
			"size": "%dx%d" % [size.x, size.y],
		}
	_grow_atlas(atlas_state, position.x + size.x, position.y + size.y)
	var atlas: Image = atlas_state["image"]
	atlas.blit_rect(source_image, Rect2i(Vector2i.ZERO, size), position)
	atlas_state["dirty"] = true
	var resolved := icon_resolution.duplicate(true)
	resolved["runtimeImageKey"] = image_key
	resolved["runtimeImageSource"] = "campaign-bestiary-atlas"
	return resolved


func _existing_image_position(
	entry: Variant,
	size: Vector2i,
	atlas_state: Dictionary
) -> Vector2i:
	if not (entry is Dictionary) or str(entry.get("size", "")) != "%dx%d" % [size.x, size.y]:
		return Vector2i(-1, -1)
	var position := Vector2i(
		int(entry.get("0_ref_x", -1)) * 32,
		int(entry.get("0_ref_y", -1)) * 32
	)
	var atlas: Image = atlas_state["image"]
	if (
		position.x < 0
		or position.y < 0
		or position.x + size.x > atlas.get_width()
		or position.y + size.y > atlas.get_height()
	):
		return Vector2i(-1, -1)
	return position


func _grow_atlas(atlas_state: Dictionary, minimum_width: int, minimum_height: int) -> void:
	var current: Image = atlas_state["image"]
	var width := maxi(current.get_width(), minimum_width)
	var height := maxi(current.get_height(), minimum_height)
	if width == current.get_width() and height == current.get_height():
		return
	var expanded := Image.create(width, height, false, Image.FORMAT_RGBA8)
	expanded.fill(Color(0, 0, 0, 0))
	expanded.blit_rect(
		current,
		Rect2i(Vector2i.ZERO, current.get_size()),
		Vector2i.ZERO
	)
	atlas_state["image"] = expanded


func _monster_has_explicit_id(monster: Dictionary, monster_id: int) -> bool:
	if monster.has("classicMonsterId") \
			and abs(int(monster["classicMonsterId"])) == monster_id:
		return true
	var ids: Variant = monster.get("classicMonsterIds", [])
	if ids is Array:
		for id_value: Variant in ids:
			if abs(int(id_value)) == monster_id:
				return true
	return false


func _monster_key(bestiary_book: Dictionary, monster_id: int) -> String:
	var base := "Classic Monster %d" % monster_id
	var candidate := base
	var suffix := 2
	while bestiary_book.has(candidate):
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
