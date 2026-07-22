class_name ClassicCoreFatigueSpell
extends "res://scripts/classic_runtime/classic_spell_override.gd"

const CoreSpellCatalogScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_catalog.gd"
)
const PresentationScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_presentation.gd"
)
const MAGICAL_ELEMENT := 9
const SLEEPWALK_SPECIAL := 68
const SLEEPWALK_FATIGUE := 1.0


func configure_core_fatigue_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic fatigue spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_sleepwalk_record(record):
		push_error("Classic spell %d is not the special-68 fatigue record" % spell_id)
		return false

	var caster_class := str(inventory.get("casterClass", ""))
	var spell_level := int(inventory.get("level", 0))
	record["packedSpellId"] = spell_id
	record["displayName"] = name
	record["description"] = (
		"Sleepwalk: Reduces the party-wide fatigue meter to Classic value 1."
	)
	record["elements"] = [MAGICAL_ELEMENT]
	record["tags"] = ["Magical", "Restoration", "Party Effect"]
	record["lineOfSight"] = false
	record["projectileTexture"] = PresentationScript.gfx_for_source_id(
		int(record.get("spellLook1", 0))
	)
	record["projectileHit"] = PresentationScript.gfx_for_source_id(
		int(record.get("spellLook2", 0))
	)
	record["sounds"] = PresentationScript.sounds(record)
	record["sourceRecord"] = inventory.get("sourceRecord", {}).duplicate(true)
	record["schools"] = [caster_class]
	record["schoolLevels"] = PresentationScript.school_values(caster_class, spell_level)
	record["selectionCosts"] = PresentationScript.school_values(
		caster_class,
		int(PresentationScript.SELECTION_COST_BY_LEVEL.get(spell_level, 0))
	)
	configure(record)
	classic_spell_ids = [spell_id]
	max_plevel = 7
	skip_targeting = true
	autotarget_type = AUTOTARGET_TYPE.SELF
	targettile = TARGET_TILE.ANY
	attributes = ["Magical", "Special"]
	return true


func apply_to_game_global(game_global: Object) -> bool:
	if game_global == null or not game_global.has_method("set_party_fatigue"):
		push_error("Sleepwalk requires the party fatigue service")
		return false
	game_global.call("set_party_fatigue", SLEEPWALK_FATIGUE)
	return true


func get_targets(_power: int, _caster) -> int:
	return 0


func get_target_number(_power: int, _caster) -> int:
	return 0


func special_effect(
	_caster,
	_spell,
	_power: int,
	_main_targeted_tile,
	_effected_tiles,
	_effected_creatures,
	_add_terrain
) -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	var game_global: Node = tree.root.get_node_or_null("GameGlobal") if tree != null else null
	return apply_to_game_global(game_global)


func _is_sleepwalk_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != SLEEPWALK_SPECIAL \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("cannot", 0)) != 3 \
			or absi(int(record.get("damageType", 0))) != 8 \
			or absi(int(record.get("spellClass", 0))) != 8 \
			or int(record.get("targetType", -1)) != 11 \
			or bool(record.get("inCombat", 0)) \
			or not bool(record.get("inCamp", 0)):
		return false
	for field_name: String in [
		"damage1", "damage2", "powerDamage1", "powerDamage2",
		"duration1", "duration2", "powerDuration1", "powerDuration2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return true
