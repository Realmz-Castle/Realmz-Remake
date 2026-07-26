class_name ClassicStockAttributeSpell
extends "res://scripts/classic_runtime/classic_spell_override.gd"

const CharacterRulesScript = preload(
	"res://scripts/classic_runtime/classic_character_rules.gd"
)
const PresentationScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_presentation.gd"
)


func configure_stock_attribute_spell(record: Dictionary) -> bool:
	if not _is_stock_attribute_record(record):
		push_error(
			"Classic stock spell %d is not a supported attribute improvement"
			% int(record.get("packedSpellId", 0))
		)
		return false
	var source := record.duplicate(true)
	var attribute_name := str({
		2: "Intellect",
		3: "Wisdom",
		6: "Luck",
	}.get(int(source.get("size", 0)), "attribute"))
	source["description"] = (
		"%s: Permanently raises %s by one, to Classic's limit of 25."
		% [str(source.get("displayName", "")), attribute_name]
	)
	source["elements"] = [GameGlobal.ELEMENTS.MAGICAL]
	source["tags"] = ["Magical", "Enhancement"]
	source["lineOfSight"] = false
	source["projectileTexture"] = PresentationScript.gfx_for_source_id(
		int(source.get("spellLook1", 0))
	)
	source["projectileHit"] = PresentationScript.gfx_for_source_id(
		int(source.get("spellLook2", 0))
	)
	source["sounds"] = PresentationScript.sounds(source)
	configure(source)
	attributes = ["Magical", "Misc"]
	return true


func is_generically_executable() -> bool:
	return true


func apply_classic_attribute_improvement(target) -> Dictionary:
	return CharacterRulesScript.apply_attribute_improvement(
		target,
		classic_size
	)


func add_traits_to_creature(_caster, target, _power: int) -> void:
	apply_classic_attribute_improvement(target)


func _is_stock_attribute_record(record: Dictionary) -> bool:
	var spell_id := int(record.get("packedSpellId", 0))
	var expected_size := int({
		4502: 2,
		4503: 3,
		4506: 6,
	}.get(spell_id, 0))
	if expected_size == 0 \
			or int(record.get("size", 0)) != expected_size \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) != 0 \
			or int(record.get("fixedTargetNum", 0)) != 0 \
			or int(record.get("cannot", 0)) != 3 \
			or absi(int(record.get("special", 0))) != 66 \
			or absi(int(record.get("damageType", 0))) != 8 \
			or absi(int(record.get("spellClass", 0))) != 8 \
			or int(record.get("targetType", -1)) != 5 \
			or bool(record.get("inCombat", 0)) \
			or not bool(record.get("inCamp", 0)):
		return false
	for field_name: String in [
		"range1", "range2", "damage1", "damage2",
		"powerDamage1", "powerDamage2", "duration1", "duration2",
		"powerDuration1", "powerDuration2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return true
