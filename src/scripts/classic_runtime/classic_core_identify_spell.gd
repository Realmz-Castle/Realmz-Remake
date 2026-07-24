class_name ClassicCoreIdentifySpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"


func configure_core_identify_spell(
	primary_spell_id: int,
	equivalent_spell_ids: Array[int] = []
) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(primary_spell_id)
	if inventory.is_empty():
		push_error("Classic identify spell %d has no Data S inventory record" % primary_spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_identify_record(record):
		push_error("Classic spell %d is not an Identify Objects record" % primary_spell_id)
		return false

	var spell_ids: Array[int] = [primary_spell_id]
	for equivalent_spell_id: int in equivalent_spell_ids:
		var equivalent: Dictionary = CoreSpellCatalogScript.inventory_spell(equivalent_spell_id)
		if equivalent.is_empty() or not _same_identify_behavior(
			record,
			equivalent.get("record", {})
		):
			push_error(
				"Classic spell %d is not source-equivalent to identify spell %d" % [
					equivalent_spell_id,
					primary_spell_id,
				]
			)
			return false
		spell_ids.append(equivalent_spell_id)

	_configure_core_record(inventory, record)
	_apply_school_metadata(spell_ids)
	classic_spell_ids = spell_ids
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	max_plevel = 1
	targettile = TARGET_TILE.CREATURE
	skip_targeting = false
	autotarget_type = AUTOTARGET_TYPE.NONE
	elements = [GameGlobal.ELEMENTS.MAGICAL]
	attributes = ["Magical"]
	tags = ["Magical", "Miscellaneous"]
	description = "Identify Objects: Reveals every item carried by one selected party member."
	return true


func apply_classic_group_effect(_caster, targets: Array, _power: int) -> int:
	return identify_targets(targets)


func get_sp_cost(_power: int, _caster) -> int:
	return absi(_cost)


func special_effect(
	_caster,
	_spell,
	_power: int,
	_main_targeted_tile,
	_effected_tiles,
	effected_creatures,
	_add_terrain
) -> bool:
	identify_targets(effected_creatures if effected_creatures is Array else [])
	return true


func identify_targets(targets: Array) -> int:
	var identified := 0
	for target: Variant in targets:
		if not (target is Object):
			continue
		var stable_inventory: bool = target.has_method("inventory_instances")
		var inventory: Variant = target.inventory_instances() \
			if stable_inventory else _legacy_inventory(target)
		if not (inventory is Array):
			continue
		for item: Variant in inventory:
			if item is ItemInstance:
				item.identified = true
				identified += 1
				continue
			# Old campaign character objects can still reach this Classic spell
			# before their dictionary inventory is imported into a Creature.
			if not stable_inventory and item is Dictionary:
				item["is_identified"] = 1
				item["identified"] = true
				identified += 1
	return identified


func _legacy_inventory(target: Object) -> Variant:
	for property: Dictionary in target.get_property_list():
		if str(property.get("name", "")) == "inventory":
			return target.get("inventory")
	return []


func _apply_school_metadata(spell_ids: Array[int]) -> void:
	var school_names: Array[String] = []
	var levels := {"Sorcerer": 0, "Priest": 0, "Enchanter": 0}
	var costs := levels.duplicate()
	for spell_id: int in spell_ids:
		var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
		var caster_class := str(inventory.get("casterClass", ""))
		var spell_level := int(inventory.get("level", 0))
		if not levels.has(caster_class):
			continue
		school_names.append(caster_class)
		levels[caster_class] = spell_level
		costs[caster_class] = int(
			PresentationScript.SELECTION_COST_BY_LEVEL.get(spell_level, 0)
		)
	schools = school_names
	school_levels = levels
	selection_costs = costs


func _is_identify_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 48 \
			or int(record.get("targetType", -1)) != 1 \
			or int(record.get("cost", 0)) >= 0 \
			or int(record.get("cannot", 0)) != 3 \
			or int(record.get("damageType", 0)) != 8 \
			or int(record.get("spellClass", 0)) != 8 \
			or bool(record.get("inCombat", 0)) \
			or not bool(record.get("inCamp", 0)):
		return false
	for field_name: String in ["damage1", "damage2", "powerDamage1", "powerDamage2"]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return true


func _same_identify_behavior(left: Dictionary, right: Dictionary) -> bool:
	# Special 48's inventory loop never reads duration, and it does not enter
	# either of the later duration-consuming party-condition or target branches.
	for field_name: String in [
		"range1", "range2", "queueIcon", "toHitBonus", "saveBonus",
		"fixedTargetNum", "canRotate", "saveAdjust", "cannot", "resistAdjust",
		"cost", "damage1", "damage2", "powerDamage1", "powerDamage2",
		"spellLook1", "spellLook2", "sound1", "sound2", "targetType", "size",
		"special", "damageType", "spellClass", "inCombat", "inCamp",
	]:
		if int(left.get(field_name, 0)) != int(right.get(field_name, 0)):
			return false
	return _is_identify_record(right)
