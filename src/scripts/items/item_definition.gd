class_name ItemDefinition
extends RefCounted

var _data: Dictionary = {}

var definition_id: String:
	get:
		return str(_data.get("definitionId", ""))

var catalog_key: String:
	get:
		return str(_data.get("catalogKey", ""))

var display_name: String:
	get:
		return str(_data.get("name", ""))

var unidentified_name: String:
	get:
		return str(_data.get("unidentifiedName", ""))

var description: String:
	get:
		return str(_data.get("description", ""))

var item_type: String:
	get:
		return str(_data.get("type", ""))

var display_type: String:
	get:
		var extra_data: Variant = gameplay_value("extraData", {})
		if extra_data is Dictionary:
			return str(extra_data.get("displayType", item_type))
		return item_type

var image_key: String:
	get:
		return str(_data.get("imageKey", ""))

var sound_key: String:
	get:
		return str(_data.get("soundKey", ""))

var hand_count: int:
	get:
		return int(gameplay_value("hands", 0))

var drops_on_defeat: bool:
	get:
		return bool(gameplay_value("dropsOnDefeat", false))

var melee_animation: String:
	get:
		return str(gameplay_value("meleeAnimation", ""))

var source_scope: String:
	get:
		return str(_data.get("source", {}).get("scope", ""))

var campaign_id: String:
	get:
		return str(_data.get("source", {}).get("campaignId", ""))

var default_identified: bool:
	get:
		return bool(_data.get("defaultIdentified", true))

var magical: bool:
	get:
		return int(gameplay_value("magical", 0)) > 0

var unique: bool:
	get:
		return int(gameplay_value("unique", 0)) > 0

var delete_on_empty: bool:
	get:
		return int(gameplay_value("deleteOnEmpty", 0)) > 0

var equippable: bool:
	get:
		return int(gameplay_value("equippable", 0)) > 0

var maximum_charges: int:
	get:
		return int(gameplay_value("maxCharges", 0))

var tradeable: bool:
	get:
		return int(gameplay_value("tradeable", 1)) > 0

var base_weight: int:
	get:
		return int(gameplay_value("baseWeight", 0))

var price: int:
	get:
		return int(gameplay_value("price", 0))

var weight_per_charge: int:
	get:
		return int(gameplay_value("weightPerCharge", 0))

var splittable: bool:
	get:
		return int(gameplay_value("splittable", 0)) > 0

var stats_summary: String:
	get:
		return str(gameplay_value("statsSummary", ""))

var ammo_type: String:
	get:
		return str(gameplay_value("ammoType", "cantuse"))


func _init(normalized_data: Dictionary = {}) -> void:
	_data = normalized_data.duplicate(true)


func to_dictionary() -> Dictionary:
	return _data.duplicate(true)


func source() -> Dictionary:
	return _data.get("source", {}).duplicate(true)


func gameplay() -> Dictionary:
	return _data.get("gameplay", {}).duplicate(true)


func gameplay_value(field_name: String, fallback: Variant = null) -> Variant:
	var value: Variant = _data.get("gameplay", {}).get(field_name, fallback)
	if value is Dictionary or value is Array:
		return value.duplicate(true)
	return value


func hooks() -> Dictionary:
	return _data.get("hooks", {}).duplicate(true)


func classic() -> Dictionary:
	return _data.get("classic", {}).duplicate(true)


func classic_item_ids() -> Array[int]:
	var result: Array[int] = []
	for value: Variant in _data.get("classic", {}).get("itemIds", []):
		result.append(int(value))
	return result


func has_classic_item_id(item_id: int) -> bool:
	return classic_item_ids().has(abs(item_id))


func classic_record() -> Dictionary:
	var value: Variant = classic().get("record", {})
	return value.duplicate(true) if value is Dictionary else {}


func classic_materialization() -> Dictionary:
	var value: Variant = classic().get("materialization", {})
	return value.duplicate(true) if value is Dictionary else {}


func display_name_for(instance: ItemInstance) -> String:
	if instance == null:
		return display_name
	if instance.identified or unidentified_name.is_empty():
		return str(_legacy_mutable_value(instance, "name", display_name))
	return unidentified_name


func description_for(instance: ItemInstance) -> String:
	return str(_legacy_mutable_value(instance, "description", description))


func _legacy_mutable_value(
	instance: ItemInstance,
	field_name: String,
	fallback: Variant,
) -> Variant:
	if instance == null:
		return fallback
	var overrides: Variant = instance.state_value("legacyMutableFields", {})
	if not (overrides is Dictionary):
		return fallback
	return overrides.get(field_name, fallback)


func slots() -> Array:
	return gameplay_value("slots", [])


func stats() -> Dictionary:
	return gameplay_value("stats", {})


func weapon_damage() -> Dictionary:
	return gameplay_value("weaponDamage", {})


func tagged_weapon_damage() -> Dictionary:
	return gameplay_value("taggedWeaponDamage", {})


func only_usable_by_classes() -> Array:
	return gameplay_value("onlyUsableByClasses", [])


func not_usable_by_classes() -> Array:
	return gameplay_value("notUsableByClasses", [])


func only_usable_by_races() -> Array:
	return gameplay_value("onlyUsableByRaces", [])


func not_usable_by_races() -> Array:
	return gameplay_value("notUsableByRaces", [])


func extra_data_value(field_name: String, fallback: Variant = null) -> Variant:
	var extra_data: Variant = gameplay_value("extraData", {})
	if not (extra_data is Dictionary):
		return fallback
	var value: Variant = extra_data.get(field_name, fallback)
	return value.duplicate(true) if value is Dictionary or value is Array else value


func classic_magic_resistance() -> int:
	return int(extra_data_value("classicMagicResistance", 0))


func trait_descriptors() -> Array:
	return hooks().get("traits", []).duplicate(true)


func melee_inflicted_trait_descriptors() -> Array:
	return hooks().get("meleeInflictedTraits", []).duplicate(true)


func spell_use(use_kind: String) -> Array:
	var descriptor_name := "_on_%s_use_spell" % use_kind
	var descriptor: Variant = hooks().get(
		"spellUses",
		{},
	).get(descriptor_name, [])
	return descriptor.duplicate(true) if descriptor is Array else []


func has_use(use_kind: String) -> bool:
	var hook_data := hooks()
	if not spell_use(use_kind).is_empty():
		return true
	var source_name := "_on_%s_use_source" % use_kind
	return hook_data.get("sources", {}).has(source_name)


func total_weight(instance: ItemInstance) -> int:
	var current_charges := instance.charges if instance != null else 0
	return base_weight + weight_per_charge * current_charges
