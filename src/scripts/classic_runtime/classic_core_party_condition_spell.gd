class_name ClassicCorePartyConditionSpell
extends "res://scripts/classic_runtime/classic_spell_override.gd"

const CoreSpellCatalogScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_catalog.gd"
)
const PresentationScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_presentation.gd"
)
const PartyConditionScript = preload(
	"res://scripts/classic_runtime/classic_party_condition.gd"
)
# Keep this resource parseable in standalone tests where autoloads are unavailable.
const MAGICAL_ELEMENT := 9


func configure_core_party_condition_spell(
	primary_spell_id: int,
	equivalent_spell_ids: Array[int] = []
) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(primary_spell_id)
	if inventory.is_empty():
		push_error("Classic party spell %d has no Data S inventory record" % primary_spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_party_condition_record(record):
		push_error("Classic spell %d is not a party-condition record" % primary_spell_id)
		return false

	var spell_ids: Array[int] = [primary_spell_id]
	for equivalent_spell_id: int in equivalent_spell_ids:
		var equivalent: Dictionary = CoreSpellCatalogScript.inventory_spell(equivalent_spell_id)
		if equivalent.is_empty() or not _same_party_condition_behavior(
			record,
			equivalent.get("record", {})
		):
			push_error(
				"Classic spell %d is not source-equivalent to party spell %d" % [
					equivalent_spell_id,
					primary_spell_id,
				]
			)
			return false
		spell_ids.append(equivalent_spell_id)

	record["packedSpellId"] = primary_spell_id
	record["displayName"] = name
	record["description"] = description
	record["elements"] = [MAGICAL_ELEMENT]
	record["tags"] = ["Magical", "Party Effect"]
	record["lineOfSight"] = false
	record["projectileTexture"] = PresentationScript.gfx_for_source_id(
		int(record.get("spellLook1", 0))
	)
	record["projectileHit"] = PresentationScript.gfx_for_source_id(
		int(record.get("spellLook2", 0))
	)
	record["sounds"] = PresentationScript.sounds(record)
	record["sourceRecord"] = inventory.get("sourceRecord", {}).duplicate(true)
	_apply_school_metadata(record, spell_ids)
	configure(record)
	classic_spell_ids = spell_ids
	return true


func apply_classic_duration(duration: int) -> int:
	var tree := Engine.get_main_loop() as SceneTree
	var game_global: Node = tree.root.get_node_or_null("GameGlobal") if tree != null else null
	if game_global == null or not game_global.has_method("apply_classic_party_condition"):
		push_error("Classic party-condition state is unavailable")
		return 0
	return int(game_global.call("apply_classic_party_condition", classic_special, duration))


func get_targets(_power: int, _caster) -> int:
	return 0


func get_target_number(_power: int, _caster) -> int:
	return 0


func special_effect(
	_caster,
	_spell,
	power: int,
	_main_targeted_tile,
	_effected_tiles,
	_effected_creatures,
	_add_terrain
) -> bool:
	apply_classic_duration(get_duration_roll(power, null))
	var tree := Engine.get_main_loop() as SceneTree
	var ui: Node = tree.root.get_node_or_null("UI") if tree != null else null
	var hud: Variant = ui.get("ow_hud") if ui != null else null
	if hud is Object and hud.has_method("updateGlobalEffectsDisplay"):
		hud.call("updateGlobalEffectsDisplay")
	return true


func _apply_school_metadata(record: Dictionary, spell_ids: Array[int]) -> void:
	var school_names: Array[String] = []
	var levels := {"Sorcerer": 0, "Priest": 0, "Enchanter": 0}
	var costs := levels.duplicate()
	for spell_id: int in spell_ids:
		var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
		var caster_class := str(inventory.get("casterClass", ""))
		var spell_level := int(inventory.get("level", 0))
		if not levels.has(caster_class):
			continue
		if not school_names.has(caster_class):
			school_names.append(caster_class)
		levels[caster_class] = spell_level
		costs[caster_class] = int(
			PresentationScript.SELECTION_COST_BY_LEVEL.get(spell_level, 0)
		)
	record["schools"] = school_names
	record["schoolLevels"] = levels
	record["selectionCosts"] = costs


func _is_party_condition_record(record: Dictionary) -> bool:
	if int(record.get("targetType", -1)) != 7 \
			or not PartyConditionScript.EFFECT_BY_INDEX.has(abs(int(record.get("special", 0)))) \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or not bool(record.get("inCamp", 0)):
		return false
	for field_name: String in ["damage1", "damage2", "powerDamage1", "powerDamage2"]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return true


func _same_party_condition_behavior(left: Dictionary, right: Dictionary) -> bool:
	for field_name: String in [
		"range1", "range2", "fixedTargetNum", "canRotate", "cost",
		"damage1", "damage2", "powerDamage1", "powerDamage2",
		"duration1", "duration2", "powerDuration1", "powerDuration2",
		"targetType", "size", "special", "damageType", "spellClass", "inCombat",
	]:
		if int(left.get(field_name, 0)) != int(right.get(field_name, 0)):
			return false
	return bool(left.get("inCamp", 0)) == bool(right.get("inCamp", 0))
