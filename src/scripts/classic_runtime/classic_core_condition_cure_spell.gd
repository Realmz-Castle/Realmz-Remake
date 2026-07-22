class_name ClassicCoreConditionCureSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const ConditionCureScript = preload(
	"res://scripts/classic_runtime/classic_condition_cure.gd"
)

const CONDITION_NAMES := {
	9: "poison",
	26: "petrification",
	27: "blindness",
	28: "disease",
}

var classic_condition_index := -1


func configure_core_condition_cure(spell_id: int, condition_index: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic condition cure %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_condition_cure_record(record, condition_index):
		push_error("Classic spell %d is not a condition cure record" % spell_id)
		return false
	classic_condition_index = condition_index
	_configure_core_record(inventory, record)
	elements.clear()
	attributes = ["Magical", "Special"]
	tags = ["Magical", "Restoration"]
	description = "%s: Removes %s from the selected target%s." % [
		name,
		str(CONDITION_NAMES.get(condition_index, "the condition")),
		"s" if classic_target_type == 0 else "",
	]
	# Classic's camp UI chooses party portraits independently of combat range.
	# That matters for the zero-range Enchanter Flesh record.
	skip_targeting = false
	autotarget_type = AUTOTARGET_TYPE.NONE
	targettile = TARGET_TILE.CREATURE
	return true


func apply_classic_scaled_effect(
	_caster,
	target,
	_power: int,
	effect_scale: float
) -> int:
	if effect_scale <= 0.0 or not (target is Object):
		return 0
	return ConditionCureScript.clear_condition(target, classic_condition_index)


func _is_condition_cure_record(record: Dictionary, condition_index: int) -> bool:
	# resolvespell.c encodes these cures as condition index + 101.
	if absi(int(record.get("special", 0))) != condition_index + 101 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cannot", 0)) not in [3, 4] \
			or int(record.get("targetType", 0)) not in [0, 1] \
			or not bool(record.get("inCamp", 0)):
		return false
	for field_name: String in [
		"damage1", "damage2", "powerDamage1", "powerDamage2",
		"duration1", "duration2", "powerDuration1", "powerDuration2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return true
