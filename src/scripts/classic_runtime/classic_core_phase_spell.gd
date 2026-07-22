class_name ClassicCorePhaseSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const CombatPhaseScript = preload(
	"res://scripts/classic_runtime/classic_combat_phase.gd"
)

var _ends_turn := false


func configure_core_phase_spell(
	primary_spell_id: int,
	equivalent_spell_ids: Array[int],
	ends_turn: bool
) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(primary_spell_id)
	if inventory.is_empty():
		push_error("Classic phase spell %d has no Data S inventory record" % primary_spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_phase_record(record):
		push_error("Classic spell %d is not a special-56 phase record" % primary_spell_id)
		return false

	var spell_ids: Array[int] = [primary_spell_id]
	for equivalent_spell_id: int in equivalent_spell_ids:
		var equivalent: Dictionary = CoreSpellCatalogScript.inventory_spell(equivalent_spell_id)
		if equivalent.is_empty() or not _same_phase_behavior(
			record,
			equivalent.get("record", {})
		):
			push_error(
				"Classic spell %d is not source-equivalent to phase spell %d" % [
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
	attributes = ["Magical", "Miscellaneous"]
	tags = ["Magical", "Teleportation"]
	targettile = TARGET_TILE.NOWALL
	skip_targeting = false
	autotarget_type = AUTOTARGET_TYPE.NONE
	_ends_turn = ends_turn
	description = _phase_description()
	return true


func special_effect(
	caster,
	_spell,
	_power: int,
	main_targeted_tile,
	_effected_tiles,
	_effected_creatures,
	_add_terrain
) -> bool:
	var destination := Vector2i(main_targeted_tile)
	CombatPhaseScript.relocate(
		caster,
		destination,
		_ends_turn,
		CombatPhaseScript.destination_is_blocked(caster, destination)
	)
	return true


func phase_to(caster: Object, destination: Vector2i, destination_blocked := false) -> Dictionary:
	return CombatPhaseScript.relocate(caster, destination, _ends_turn, destination_blocked)


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


func _is_phase_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 56 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("cannot", 0)) != 3 \
			or int(record.get("targetType", -1)) != 8 \
			or int(record.get("damageType", 0)) != 8 \
			or int(record.get("spellClass", 0)) != 8 \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)):
		return false
	for field_name: String in [
		"damage1", "damage2", "powerDamage1", "powerDamage2",
		"duration1", "duration2", "powerDuration1", "powerDuration2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return true


func _same_phase_behavior(left: Dictionary, right: Dictionary) -> bool:
	for field_name: String in left:
		if int(left.get(field_name, 0)) != int(right.get(field_name, 0)):
			return false
	return _is_phase_record(right)


func _phase_description() -> String:
	var result := "%s: Teleports the caster to an unobstructed battlefield tile" % name
	if _ends_turn:
		return result + " and ends the caster's turn."
	return result + " without consuming the caster's remaining physical actions."
