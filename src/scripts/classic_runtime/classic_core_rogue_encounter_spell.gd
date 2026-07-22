class_name ClassicCoreRogueEncounterSpell
extends "res://scripts/classic_runtime/classic_spell_override.gd"

const CoreSpellCatalogScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_catalog.gd"
)
const PresentationScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_presentation.gd"
)

const DESCRIPTION_BY_SPECIAL := {
	65: (
		"Destroy Trap: Attempts to disarm a trap. On failure it also attempts "
		+ "to open the lock, which may spring the trap."
	),
	70: "Open Lock: Attempts to open a lock by magical means.",
}


func configure_core_rogue_encounter_spell(spell_id: int, special_code: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic rogue spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_rogue_encounter_record(record, special_code):
		push_error(
			"Classic spell %d is not a special-%d rogue encounter record"
			% [spell_id, special_code]
		)
		return false

	var caster_class := str(inventory.get("casterClass", ""))
	var spell_level := int(inventory.get("level", 0))
	record["packedSpellId"] = spell_id
	record["displayName"] = name
	record["description"] = str(DESCRIPTION_BY_SPECIAL.get(special_code, name))
	record["elements"] = [GameGlobal.ELEMENTS.MAGICAL]
	record["tags"] = ["Magical", "Special", "Encounter"]
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
	classic_spell_response_ids = [spell_id]
	max_plevel = 7
	# The spell menu exposes these only while a complex encounter is waiting for
	# a response. The rogue resolver owns the mutable lock and trap state.
	in_field = false
	in_combat = false
	attributes = ["Magical", "Special"]
	return true


func _is_rogue_encounter_record(record: Dictionary, special_code: int) -> bool:
	if int(record.get("special", 0)) != special_code \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("cannot", 0)) != 3 \
			or absi(int(record.get("damageType", 0))) != 8 \
			or absi(int(record.get("spellClass", 0))) != 8 \
			or bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)) \
			or int(record.get("targetType", -1)) != 11 \
			or int(record.get("size", 0)) != 0:
		return false
	for field_name: String in [
		"damage1", "damage2", "powerDamage1", "powerDamage2",
		"duration1", "duration2", "powerDuration1", "powerDuration2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return true
