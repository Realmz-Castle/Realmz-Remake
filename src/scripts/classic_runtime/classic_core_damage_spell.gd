class_name ClassicCoreDamageSpell
extends "res://scripts/classic_runtime/classic_spell_override.gd"

const CoreSpellCatalogScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_catalog.gd"
)

const SELECTION_COST_BY_LEVEL := {
	1: 1,
	2: 3,
	3: 6,
	4: 10,
	5: 15,
	6: 21,
	7: 28,
}

const SOUND_BY_CLASSIC_ID := {
	0: "spell launch 1.wav",
	1: "spell launch 2.wav",
	2: "spell launch 3.wav",
	3: "spell launch 4.wav",
	4: "spell launch 5.wav",
	5: "spell launch 6.wav",
	6: "spell launch 7.wav",
	7: "spell launch 8.wav",
	9: "spell launch 9.wav",
	10: "hit effect 1.wav",
	11: "hit effect 2.wav",
	12: "hit effect 3.wav",
	13: "hit effect 4.wav",
	15: "lightning.wav",
	18: "bubbles.wav",
	20: "pops.wav",
	21: "boing.wav",
	22: "claps.wav",
	24: "bombom.wav",
	25: "bow.wav",
	26: "dididup.wav",
	29: "bloomp.wav",
	30: "hit bumper.wav",
	31: "resurrect death.wav",
	33: "claw.wav",
	34: "bite.wav",
	35: "clash.wav",
	37: "attack hit.wav",
	39: "club.wav",
	40: "slimed.wav",
	41: "sting.wav",
	42: "big explode.wav",
	44: "bubble dip.wav",
	45: "small explode.wav",
	49: "boink.wav",
	51: "bwee.wav",
	53: "metal armor.wav",
	54: "cloth armor.wav",
	58: "prout.wav",
	59: "teleport.wav",
	61: "dingy ray gun.wav",
	62: "bloop.wav",
	64: "force field.wav",
	65: "slurpy.wav",
	66: "drippity beep.wav",
	67: "underwater laser.wav",
	70: "pinball bumper.wav",
	74: "nuk.wav",
	75: "energy blast.wav",
	77: "swup.wav",
	81: "bwabble.wav",
	83: "identify.wav",
	84: "big splat.wav",
	86: "electric energize.wav",
	90: "door slam.wav",
	91: "spell hit object.wav",
	92: "smack.wav",
	93: "jump.wav",
	94: "chaclunk.wav",
	95: "spell effect heal.wav",
	98: "poinkeroo.wav",
	99: "wind.wav",
}


func configure_core_damage_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic core spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_direct_damage_record(record):
		push_error("Classic core spell %d is not an immediate damage record" % spell_id)
		return false

	var caster_class := str(inventory.get("casterClass", ""))
	var spell_level := int(inventory.get("level", 0))
	record["packedSpellId"] = int(inventory.get("packedSpellId", spell_id))
	record["displayName"] = str(inventory.get("displayName", ""))
	record["description"] = _description(record["displayName"], record)
	record["schools"] = [caster_class]
	record["schoolLevels"] = _school_values(caster_class, spell_level)
	record["selectionCosts"] = _school_values(
		caster_class,
		int(SELECTION_COST_BY_LEVEL.get(spell_level, 0))
	)
	record["elements"] = [_element_for_damage_type(abs(int(record["damageType"])))]
	record["tags"] = _tags_for_damage_type(abs(int(record["damageType"])))
	record["lineOfSight"] = int(record.get("range1", 0)) >= 0 \
		and int(record.get("range2", 0)) >= 0
	record["projectileTexture"] = _gfx_for_source_id(int(record.get("spellLook1", 0)))
	record["projectileHit"] = _gfx_for_source_id(int(record.get("spellLook2", 0)))
	record["sounds"] = _sounds(record)
	match int(record.get("size", 0)):
		8:
			record["nativeAoe"] = "radiant"
		9:
			record["nativeAoe"] = "round"
	record["sourceRecord"] = inventory.get("sourceRecord", {}).duplicate(true)
	configure(record)
	return true


func _is_direct_damage_record(record: Dictionary) -> bool:
	if int(record.get("special", 0)) != 0 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or not bool(record.get("inCombat", 0)):
		return false
	if abs(int(record.get("spellClass", 0))) == 9:
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


func _school_values(caster_class: String, value: int) -> Dictionary:
	var result := {"Sorcerer": 0, "Priest": 0, "Enchanter": 0}
	if result.has(caster_class):
		result[caster_class] = value
	return result


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
			return GameGlobal.ELEMENTS.HEALING
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
		7: "Healing",
	}.get(damage_type, ""))
	if not element_name.is_empty():
		result.append(element_name)
	return result


func _gfx_for_source_id(source_id: int) -> int:
	return source_id - 1 if source_id > 0 else GFX.NONE


func _sounds(record: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for field_name: String in ["sound1", "sound2"]:
		var sound_id := int(record.get(field_name, -1))
		if SOUND_BY_CLASSIC_ID.has(sound_id):
			result.append(str(SOUND_BY_CLASSIC_ID[sound_id]))
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
	}
	return str(labels.get(damage_type, "unknown"))
