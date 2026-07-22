class_name ClassicCoreEncounterResponseSpell
extends "res://scripts/classic_runtime/classic_spell_override.gd"

const CoreSpellCatalogScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_catalog.gd"
)
const PresentationScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_presentation.gd"
)

const DESCRIPTION_BY_ID := {
	1107: "Leap: Allows the party to leap over tall objects.",
	1112: "Superfly: Allows the party to perform fantastic acrobatic acts.",
	1201: "Dig Hole: Allows the party to dig a hole by magical means.",
	1305: "Fantastic Wings: Gives the party magical wings for a short time.",
	1609: "Shape Earth: Moves large amounts of earth.",
	2504: "Hands to Clay: Allows the caster to shape stone as if it were clay.",
	2609: "Teleport Party: Teleports the party when a special encounter permits it.",
	2611: "Watergate: Forms a navigable air bubble around the party underwater.",
	3111: "Splinters: Shatters a limited amount of wood into splinters.",
	3112: "Voiceover: Throws the caster's voice to create a diversion.",
	3306: "Hands to Clay: Allows the caster to shape stone as if it were clay.",
	3410: "Speak Language: Allows the caster to converse and read across languages.",
	3711: "Teleport Party: Teleports the party when a special encounter permits it.",
}


func configure_core_encounter_response_spell(
	primary_spell_id: int,
	equivalent_spell_ids: Array[int] = [],
	expose_school: bool = true
) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(primary_spell_id)
	if inventory.is_empty():
		push_error("Classic encounter spell %d has no Data S inventory record" % primary_spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_encounter_response_record(record):
		push_error("Classic spell %d is not an encounter-response record" % primary_spell_id)
		return false

	var spell_ids: Array[int] = [primary_spell_id]
	for equivalent_spell_id: int in equivalent_spell_ids:
		var equivalent: Dictionary = CoreSpellCatalogScript.inventory_spell(equivalent_spell_id)
		if equivalent.is_empty() or equivalent.get("record", {}) != record:
			push_error(
				"Classic spell %d is not source-equivalent to encounter spell %d" % [
					equivalent_spell_id,
					primary_spell_id,
				]
			)
			return false
		spell_ids.append(equivalent_spell_id)

	record["packedSpellId"] = primary_spell_id
	record["displayName"] = name
	record["description"] = str(DESCRIPTION_BY_ID.get(primary_spell_id, name))
	record["elements"] = [GameGlobal.ELEMENTS.MAGICAL]
	record["tags"] = ["Magical"]
	record["lineOfSight"] = false
	record["projectileTexture"] = PresentationScript.gfx_for_source_id(
		int(record.get("spellLook1", 0))
	)
	record["projectileHit"] = PresentationScript.gfx_for_source_id(
		int(record.get("spellLook2", 0))
	)
	record["sounds"] = PresentationScript.sounds(record)
	record["sourceRecord"] = inventory.get("sourceRecord", {}).duplicate(true)
	if expose_school:
		_apply_school_metadata(record, spell_ids)
	else:
		record["schools"] = []
		record["schoolLevels"] = {}
		record["selectionCosts"] = {}
	configure(record)
	classic_spell_ids = spell_ids
	classic_spell_response_ids = spell_ids.duplicate()
	max_plevel = 1
	# Classic only permits these records while an encounter is requesting a
	# spell response. Their effect is the scenario-authored result block.
	in_field = false
	in_combat = false
	attributes = ["Magical", "Special"]
	return true


func _apply_school_metadata(record: Dictionary, spell_ids: Array[int]) -> void:
	var schools: Array[String] = []
	var levels := {"Sorcerer": 0, "Priest": 0, "Enchanter": 0}
	var costs := levels.duplicate()
	for spell_id: int in spell_ids:
		var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
		var caster_class := str(inventory.get("casterClass", ""))
		var spell_level := int(inventory.get("level", 0))
		if not levels.has(caster_class):
			continue
		if not schools.has(caster_class):
			schools.append(caster_class)
		levels[caster_class] = spell_level
		costs[caster_class] = int(
			PresentationScript.SELECTION_COST_BY_LEVEL.get(spell_level, 0)
		)
	record["schools"] = schools
	record["schoolLevels"] = levels
	record["selectionCosts"] = costs


func _is_encounter_response_record(record: Dictionary) -> bool:
	if int(record.get("special", 0)) != 0 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) >= 0 \
			or bool(record.get("inCombat", 0)):
		return false
	for field_name: String in ["damage1", "damage2", "powerDamage1", "powerDamage2"]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return true
