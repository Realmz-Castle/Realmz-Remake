class_name ClassicCoreSilenceSpell
extends "res://scripts/classic_runtime/classic_core_timed_condition_spell.gd"

const AreaPatternsScript = preload(
	"res://scripts/classic_runtime/classic_spell_area_patterns.gd"
)
const SilencedTrait = preload("res://shared_assets/traits/t_silenced.gd")


func configure_core_silence_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic Silence %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_silence_record(record):
		push_error("Classic spell %d is not a queued Silence record" % spell_id)
		return false
	_temporary_condition_trait = SilencedTrait
	_conflicting_condition_traits = ["p_silenced.gd"]
	_configure_core_record(inventory, record)
	terrain_tex = "Bal"
	terrain_walk_type = 0
	elements.clear()
	attributes = ["Magical"]
	tags = ["Magical", "Terrain", "Spellcasting Block"]
	description = (
		"%s: Prevents spellcasting for one round per selected power "
		+ "while the field persists."
	) % name
	return true


func get_aoe(_power: int, _caster) -> Array[Vector2i]:
	return AreaPatternsScript.pattern(classic_size)


func is_classic_queued_spell() -> bool:
	return true


# Every creature in the field makes its own resistance and save checks.
func uses_classic_group_effect() -> bool:
	return false


func _is_silence_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 40 \
			or int(record.get("queueIcon", 0)) != 14 \
			or int(record.get("cost", 0)) <= 0 \
			or absi(int(record.get("damageType", 0))) != 7 \
			or absi(int(record.get("spellClass", 0))) != 7 \
			or int(record.get("cannot", 0)) not in [0, 1] \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)) \
			or int(record.get("targetType", -1)) != 3 \
			or int(record.get("size", 0)) != 9:
		return false
	for field_name: String in ["damage1", "damage2", "powerDamage1", "powerDamage2"]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return int(record.get("duration1", 0)) == 0 \
		and int(record.get("duration2", 0)) == 0 \
		and int(record.get("powerDuration1", 0)) == 1 \
		and int(record.get("powerDuration2", 0)) == 1
