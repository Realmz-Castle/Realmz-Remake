class_name ClassicCoreSpellPresentation
extends RefCounted

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


static func school_values(caster_class: String, value: int) -> Dictionary:
	var result := {"Sorcerer": 0, "Priest": 0, "Enchanter": 0}
	if result.has(caster_class):
		result[caster_class] = value
	return result


static func gfx_for_source_id(source_id: int) -> int:
	return source_id - 1 if source_id > 0 else Spell.GFX.NONE


static func sounds(record: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for field_name: String in ["sound1", "sound2"]:
		var sound_id := int(record.get(field_name, -1))
		if SOUND_BY_CLASSIC_ID.has(sound_id):
			result.append(str(SOUND_BY_CLASSIC_ID[sound_id]))
	return result
