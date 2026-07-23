class_name ClassicCoreTangleWeedSpell
extends "res://scripts/classic_runtime/classic_core_slow_spell.gd"

const TangledTrait = preload("res://shared_assets/traits/t_classic_tangled.gd")


func configure_core_tangle_weed_spell() -> bool:
	var spell_id := 2412
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic Tangle Weed has no Data S inventory record")
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_tangle_weed_record(record):
		push_error("Classic spell 2412 is not the queued Tangle Weed record")
		return false

	_temporary_condition_trait = TangledTrait
	_conflicting_condition_traits = ["p_classic_tangled.gd"]
	_configure_core_record(inventory, record)
	# Data S stores -3 in the unsigned special byte as 253. The intended
	# condition is confirmed by the spell description and spelllist.c's Tangle
	# branch; keep the raw byte in source_record and expose the resolved code.
	classic_special = 3
	elements.clear()
	attributes = ["Magical", "Special"]
	tags = ["Magical", "Special", "Terrain", "Tangled"]
	terrain_tex = "Web"
	terrain_walk_type = 0
	description = (
		"Tangle Weed: Entangles creatures in a persistent area, reducing "
		+ "movement, physical accuracy, and physical evasion for %s."
	) % _duration_description()
	return true


func _is_tangle_weed_record(record: Dictionary) -> bool:
	if int(record.get("special", 0)) != 253 \
			or int(record.get("queueIcon", 0)) != 4 \
			or int(record.get("cost", 0)) != 30 \
			or int(record.get("cannot", 0)) != 3 \
			or absi(int(record.get("damageType", 0))) != 7 \
			or absi(int(record.get("spellClass", 0))) != 7 \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)) \
			or int(record.get("targetType", -1)) != 3 \
			or int(record.get("size", 0)) != 14:
		return false
	for field_name: String in ["damage1", "damage2", "powerDamage1", "powerDamage2"]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return int(record.get("duration1", 0)) == 0 \
		and int(record.get("duration2", 0)) == 0 \
		and int(record.get("powerDuration1", 0)) == 1 \
		and int(record.get("powerDuration2", 0)) == 2
