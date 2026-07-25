class_name ClassicCoreQueuedAreaSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const AreaPatternsScript = preload(
	"res://scripts/classic_runtime/classic_spell_area_patterns.gd"
)
# Source queue icons have direct counterparts in Remake's battlefield atlas.
const TERRAIN_TEXTURE_BY_QUEUE_ICON := {
	5: "Trg",
	6: "Yfr",
	7: "Gcl",
	8: "Bcl",
	9: "ClassicQueue9",
	10: "ClassicQueue10",
	11: "Spn",
	12: "Slm",
	13: "Spr",
	14: "Bal",
	15: "Orb",
	16: "Thn",
}


func configure_core_queued_area_spell(
	spell_id: int,
	required_spell_class := -1
) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic queued spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_queued_area_record(record, required_spell_class):
		push_error("Classic spell %d is not a queued-area damage record" % spell_id)
		return false
	var queue_icon := int(record.get("queueIcon", 0))
	var terrain_texture := str(TERRAIN_TEXTURE_BY_QUEUE_ICON.get(queue_icon, ""))
	if terrain_texture.is_empty():
		push_error(
			"Classic queued spell %d has unmapped queue icon %d" % [spell_id, queue_icon]
		)
		return false
	_configure_core_record(inventory, record)
	terrain_tex = terrain_texture
	terrain_walk_type = 0
	if not tags.has("Terrain"):
		tags.append("Terrain")
	return true


func get_aoe(power: int, _caster) -> Array[Vector2i]:
	var shape := classic_size
	if classic_target_type == 4:
		shape = power
	return AreaPatternsScript.pattern(shape)


func is_classic_queued_spell() -> bool:
	return true


func _is_queued_area_record(record: Dictionary, required_spell_class: int) -> bool:
	if int(record.get("special", 0)) != 0 \
			or int(record.get("queueIcon", 0)) <= 0 \
			or int(record.get("cost", 0)) <= 0 \
			or not bool(record.get("inCombat", 0)):
		return false
	var spell_class: int = absi(int(record.get("spellClass", 0)))
	if required_spell_class >= 0 and spell_class != required_spell_class:
		return false
	if spell_class == 9:
		return false
	if abs(int(record.get("damageType", 0))) not in range(1, 9):
		return false
	var has_damage := false
	for field_name: String in ["damage1", "damage2", "powerDamage1", "powerDamage2"]:
		has_damage = has_damage or int(record.get(field_name, 0)) != 0
	var has_duration := false
	for field_name: String in [
		"duration1", "duration2", "powerDuration1", "powerDuration2",
	]:
		has_duration = has_duration or int(record.get(field_name, 0)) != 0
	return has_damage and has_duration and int(record.get("targetType", 0)) in [0, 3, 4]
