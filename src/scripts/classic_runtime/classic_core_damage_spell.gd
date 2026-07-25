class_name ClassicCoreDamageSpell
extends "res://scripts/classic_runtime/classic_spell_override.gd"

const CoreSpellCatalogScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_catalog.gd"
)
const PresentationScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_presentation.gd"
)


func configure_core_damage_spell(spell_id: int, required_spell_class := -1) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic core spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_direct_damage_record(record, required_spell_class):
		push_error("Classic core spell %d is not an immediate damage record" % spell_id)
		return false
	_configure_core_record(inventory, record)
	return true


func _configure_custom_record(record: Dictionary) -> void:
	var source := record.duplicate(true)
	var display_name := str(source.get("displayName", "")).strip_edges()
	if str(source.get("description", "")).strip_edges().is_empty():
		source["description"] = _description(display_name, source)
	source["elements"] = [_element_for_damage_type(absi(int(source.get("damageType", 0))))]
	source["tags"] = _tags_for_damage_type(absi(int(source.get("damageType", 0))))
	source["lineOfSight"] = int(source.get("range1", 0)) >= 0 \
		and int(source.get("range2", 0)) >= 0
	source["projectileTexture"] = PresentationScript.gfx_for_source_id(
		int(source.get("spellLook1", 0))
	)
	source["projectileHit"] = PresentationScript.gfx_for_source_id(
		int(source.get("spellLook2", 0))
	)
	source["sounds"] = PresentationScript.sounds(source)
	match int(source.get("size", 0)):
		8:
			source["nativeAoe"] = "radiant"
		9:
			source["nativeAoe"] = "round"
	configure(source)


func _configure_core_record(inventory: Dictionary, record: Dictionary) -> void:
	var spell_id := int(inventory.get("packedSpellId", 0))

	var caster_class := str(inventory.get("casterClass", ""))
	var spell_level := int(inventory.get("level", 0))
	record["packedSpellId"] = int(inventory.get("packedSpellId", spell_id))
	record["displayName"] = str(inventory.get("displayName", ""))
	record["description"] = _description(record["displayName"], record)
	record["schools"] = [caster_class]
	record["schoolLevels"] = PresentationScript.school_values(caster_class, spell_level)
	record["selectionCosts"] = PresentationScript.school_values(
		caster_class,
		int(PresentationScript.SELECTION_COST_BY_LEVEL.get(spell_level, 0))
	)
	record["elements"] = [_element_for_damage_type(abs(int(record["damageType"])))]
	record["tags"] = _tags_for_damage_type(abs(int(record["damageType"])))
	record["lineOfSight"] = int(record.get("range1", 0)) >= 0 \
		and int(record.get("range2", 0)) >= 0
	record["projectileTexture"] = PresentationScript.gfx_for_source_id(
		int(record.get("spellLook1", 0))
	)
	record["projectileHit"] = PresentationScript.gfx_for_source_id(
		int(record.get("spellLook2", 0))
	)
	record["sounds"] = PresentationScript.sounds(record)
	match int(record.get("size", 0)):
		8:
			record["nativeAoe"] = "radiant"
		9:
			record["nativeAoe"] = "round"
	record["sourceRecord"] = inventory.get("sourceRecord", {}).duplicate(true)
	configure(record)


func _is_direct_damage_record(record: Dictionary, required_spell_class: int) -> bool:
	if int(record.get("special", 0)) != 0 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or not bool(record.get("inCombat", 0)):
		return false
	var spell_class: int = absi(int(record.get("spellClass", 0)))
	if required_spell_class >= 0 and spell_class != required_spell_class:
		return false
	if spell_class == 9 and required_spell_class != 9:
		return false
	if abs(int(record.get("damageType", 0))) not in range(1, 8):
		return false
	for field_name: String in [
		"duration1", "duration2", "powerDuration1", "powerDuration2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return false
	for field_name: String in ["damage1", "damage2", "powerDamage1", "powerDamage2"]:
		if int(record.get(field_name, 0)) != 0:
			return int(record.get("targetType", 0)) in [0, 1, 3, 4, 10]
	return false


func _element_for_damage_type(damage_type: int) -> int:
	match damage_type:
		1:
			return GameGlobal.ELEMENTS.FIRE
		2:
			return GameGlobal.ELEMENTS.ICE
		3:
			return GameGlobal.ELEMENTS.ELECTRIC
		4:
			return GameGlobal.ELEMENTS.CHEMICAL
		5:
			return GameGlobal.ELEMENTS.MENTAL
		7:
			# Classic uses type 7 for its special DRV, not healing damage.
			# Remake has no matching element, so its neutral magical defense is
			# the least lossy damage-side fallback; the DRV remains separate.
			return GameGlobal.ELEMENTS.MAGICAL
		8:
			# Type 8 is Classic's miscellaneous, no-element damage path.
			return GameGlobal.ELEMENTS.MAGICAL
		_:
			return GameGlobal.ELEMENTS.MAGICAL


func _tags_for_damage_type(damage_type: int) -> Array[String]:
	var result: Array[String] = ["Magical"]
	var element_name: String = str({
		1: "Fire",
		2: "Ice",
		3: "Electric",
		4: "Chemical",
		5: "Mental",
		7: "Special",
		8: "Miscellaneous",
	}.get(damage_type, ""))
	if not element_name.is_empty():
		result.append(element_name)
	return result


func _description(display_name: String, record: Dictionary) -> String:
	var fixed_low := int(record.get("damage1", 0))
	var fixed_high := _range_high(fixed_low, int(record.get("damage2", 0)))
	var power_low := int(record.get("powerDamage1", 0))
	var power_high := _range_high(power_low, int(record.get("powerDamage2", 0)))
	var damage_text := "%d-%d" % [fixed_low, fixed_high]
	if power_low != 0 or power_high != 0:
		damage_text = "%d-%d per power" % [power_low, power_high] \
			if fixed_low == 0 and fixed_high == 0 \
			else "%s plus %d-%d per power" % [damage_text, power_low, power_high]
	return "%s: Deals %s %s damage using its Classic Data S record." % [
		display_name,
		damage_text,
		_tag_for_description(abs(int(record.get("damageType", 0)))),
	]


func _tag_for_description(damage_type: int) -> String:
	var labels := {
		1: "fire",
		2: "ice",
		3: "electrical",
		4: "chemical",
		5: "mental",
		6: "magical",
		7: "special",
		8: "miscellaneous",
	}
	return str(labels.get(damage_type, "unknown"))
