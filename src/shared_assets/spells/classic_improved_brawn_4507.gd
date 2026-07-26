extends "res://scripts/classic_runtime/classic_spell_override.gd"

const CharacterRulesScript = preload(
	"res://scripts/classic_runtime/classic_character_rules.gd"
)
const PresentationScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_presentation.gd"
)


func _init() -> void:
	name = "Improved Brawn"
	classic_spell_class = 8
	classic_target_type = 5
	classic_spell_ids = [4507]
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	var source := {
		"packedSpellId": 4507,
		"displayName": "Improved Brawn",
		"range1": 0,
		"range2": 0,
		"queueIcon": 0,
		"toHitBonus": 0,
		"saveBonus": 0,
		"fixedTargetNum": 0,
		"canRotate": 0,
		"saveAdjust": 0,
		"cannot": 3,
		"resistAdjust": 0,
		"cost": 0,
		"damage1": 0,
		"damage2": 0,
		"powerDamage1": 0,
		"powerDamage2": 0,
		"duration1": 0,
		"duration2": 0,
		"powerDuration1": 0,
		"powerDuration2": 0,
		"spellLook1": 14,
		"spellLook2": 14,
		"sound1": 93,
		"sound2": 83,
		"targetType": 5,
		"size": 7,
		"special": 66,
		"damageType": 8,
		"spellClass": 8,
		"inCombat": 0,
		"inCamp": 1,
		"sourceRecord": {
			"sourceFile": "Data S",
			"recordIndex": 381,
			"byteOffset": 11430,
			"byteLength": 30,
		},
	}
	source["description"] = (
		"Improved Brawn: Preserves Classic's source record, which increments "
		+ "the first learned-spell byte rather than a character attribute."
	)
	source["elements"] = [GameGlobal.ELEMENTS.MAGICAL]
	source["tags"] = ["Magical", "Compatibility"]
	source["lineOfSight"] = false
	source["projectileTexture"] = PresentationScript.gfx_for_source_id(
		int(source["spellLook1"])
	)
	source["projectileHit"] = PresentationScript.gfx_for_source_id(
		int(source["spellLook2"])
	)
	source["sounds"] = PresentationScript.sounds(source)
	configure(source)
	attributes = ["Magical", "Misc"]


func is_generically_executable() -> bool:
	return true


func apply_classic_spell_memory_increment(
	target,
	spell_book: Dictionary,
	spell_id_mapping: Dictionary
) -> Dictionary:
	return CharacterRulesScript.apply_first_spell_memory_increment(
		target,
		spell_book,
		spell_id_mapping
	)


func add_traits_to_creature(_caster, target, _power: int) -> void:
	var resources: Variant = NodeAccess.__Resources()
	if resources == null or not (resources.get("spells_book") is Dictionary):
		push_error("Classic spell-memory mutation requires the loaded spell book.")
		return
	var result := apply_classic_spell_memory_increment(
		target,
		resources.spells_book,
		SpellsIdDivinity.mappings
	)
	if str(result.get("status", "")) == "error":
		push_error(str(result.get("message", "Classic spell-memory mutation failed.")))
