class_name ClassicSpellAbsorption
extends RefCounted

const SUPPRESS_META := "suppress_spell_reflection"


static func absorb_spell_power(
	target: Object,
	attacker: Object,
	spell: Object,
	power: int
) -> int:
	if target == null or attacker == null or spell == null or power <= 0:
		return 0
	var spell_ids: Variant = spell.get("classic_spell_ids")
	if not (spell_ids is Array) or spell_ids.is_empty() \
			or bool(spell.get_meta(SUPPRESS_META, false)):
		return 0
	if int(target.get("curFaction")) == int(attacker.get("curFaction")):
		return 0
	if not target.has_method("get_stat") or not target.has_method("change_cur_sp"):
		return 0

	var current_sp := int(target.get_stat("curSP"))
	if _is_player_character(target):
		var maximum_sp := int(target.get_stat("maxSP"))
		if maximum_sp <= 0:
			return 0
		var gain := mini(power, maximum_sp - current_sp)
		if gain <= 0:
			return 0
		target.change_cur_sp(gain)
		return gain

	# resolvespell.c requires a monster to have spell points, then lets the
	# absorbed power exceed its starting pool.
	if current_sp <= 0:
		return 0
	var stats: Variant = target.get("stats")
	if stats is Dictionary and stats.has("curSP"):
		stats["curSP"] = current_sp + power
		return power
	target.change_cur_sp(power)
	return int(target.get_stat("curSP")) - current_sp


static func _is_player_character(character: Object) -> bool:
	return character is PlayerCharacter or bool(character.get("is_player_controlled"))
