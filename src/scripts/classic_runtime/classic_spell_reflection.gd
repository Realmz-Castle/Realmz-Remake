class_name ClassicSpellReflection
extends RefCounted

const SUPPRESS_META := "suppress_spell_reflection"
const REDIRECT_QUEUED_META := "spell_reflection_redirect_queued"


# Spell resources are reused across actions, so per-cast state is bracketed and
# removed as soon as the current resolution finishes.
static func begin_resolution(spell: Object, suppress_reflection: bool) -> void:
	if spell == null:
		return
	spell.remove_meta(REDIRECT_QUEUED_META)
	spell.set_meta(SUPPRESS_META, suppress_reflection)


static func end_resolution(spell: Object) -> void:
	if spell == null:
		return
	spell.remove_meta(SUPPRESS_META)
	spell.remove_meta(REDIRECT_QUEUED_META)


static func is_classic_spell(spell: Object) -> bool:
	if spell == null:
		return false
	var spell_ids: Variant = spell.get("classic_spell_ids")
	return spell_ids is Array and not spell_ids.is_empty()


static func should_reflect(spell: Object, roll: int) -> bool:
	if spell == null or bool(spell.get_meta(SUPPRESS_META, false)):
		return false
	var attributes: Variant = spell.get("attributes")
	if not (attributes is Array) or not attributes.has("Magical"):
		return false
	if is_classic_spell(spell):
		# spelltargets.c bypasses reflection for missile-class and automatic
		# all-friendly, all-enemy, and everyone targeting.
		if int(spell.get("classic_spell_class")) == 9 \
				or int(spell.get("classic_target_type")) in [9, 10, 12]:
			return false
	return roll >= 1 and roll < 34


static func resolve_target(
	defender: Object,
	attacker: Object,
	spell: Object,
	power: int,
	roll: int
) -> Array:
	if not should_reflect(spell, roll):
		return [true, []]
	if defender == null or attacker == null:
		return [true, []]
	var defender_button: Variant = defender.get("combat_button")
	var attacker_button: Variant = attacker.get("combat_button")
	if not is_instance_valid(defender_button) or not is_instance_valid(attacker_button):
		return [true, []]

	var actions: Array = []
	if not bool(spell.get_meta(REDIRECT_QUEUED_META, false)):
		spell.set_meta(REDIRECT_QUEUED_META, true)
		var target_position := Vector2i(attacker.get("position"))
		actions.append({
			"type": "Spell",
			"caster": defender_button,
			"spell": spell,
			"s_plvl": power,
			"used_item": {"charges_max": 100, "charges": 100},
			"add_terrain": true,
			"override_aoe": [Vector2i.ZERO],
			"from_terrain": false,
			"Effected Tiles": [target_position],
			"Effected Creas": [attacker_button],
			"Targeted Tiles": [target_position],
			"Main Targeted Tile": target_position,
			"suppress_spell_reflection": true,
		})
	# Every successful reflector avoids the original spell, while the caster is
	# added to Classic's boolean target set only once per resolution.
	return [false, actions]
