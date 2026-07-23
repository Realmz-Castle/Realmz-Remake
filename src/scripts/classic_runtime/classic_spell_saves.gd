class_name ClassicSpellSaves
extends RefCounted

const SAVE_MODES := ["none", "negate", "half_damage"]
const META_SAVES_KEY := "classic_spell_saves"
const META_IMMUNITIES_KEY := "classic_spell_immunities"
const META_HIT_DICE_KEY := "classic_hit_dice"
const MONSTER_SAVE_COUNT := 6
const SAVE_STATS := {
	0: ["MultiplierMental", "ResistanceMental"],
	1: ["MultiplierFire", "ResistanceFire"],
	2: ["MultiplierIce", "ResistanceIce"],
	3: ["MultiplierElect", "ResistanceElect"],
	4: ["MultiplierChemical", "ResistanceChemical"],
	5: ["MultiplierMental", "ResistanceMental"],
	6: ["MultiplierMagic", "ResistanceMagic"],
	# Classic's seventh damage type is its special DRV. Native characters do
	# not expose that family, so use their general magical defense as fallback.
	7: ["MultiplierMagic", "ResistanceMagic"],
}


static func monster_saves(values: Variant) -> Array:
	return _integer_array(values, MONSTER_SAVE_COUNT)


static func monster_immunities(values: Variant) -> Array:
	return _integer_array(values, MONSTER_SAVE_COUNT)


static func apply_monster_metadata(
	character: Object,
	saves: Variant,
	immunities: Variant
) -> void:
	if character == null:
		return
	character.set_meta(META_SAVES_KEY, monster_saves(saves))
	character.set_meta(META_IMMUNITIES_KEY, monster_immunities(immunities))


static func supports_save_index(save_index: int) -> bool:
	return SAVE_STATS.has(save_index)


static func save_chance_for(character: Object, save_index: int) -> float:
	var monster_chance: Variant = _monster_save_chance(character, save_index)
	if monster_chance != null:
		return float(monster_chance)
	if character != null \
			and character.has_method("has_classic_saving_throws") \
			and bool(character.call("has_classic_saving_throws")) \
			and character.has_method("get_classic_saving_throw"):
		return clampf(
			float(character.call("get_classic_saving_throw", save_index)),
			0.0,
			100.0
		)
	var stat_names: Array = SAVE_STATS[save_index]
	var multiplier := float(character.get_stat(stat_names[0]))
	var resistance := float(character.get_stat(stat_names[1]))
	# Remake stores elemental defense as damage modifiers rather than Classic DRVs.
	return clampf((2.0 * (1.0 - multiplier) + 0.1 * resistance) * 100.0, 0.0, 100.0)


static func monster_attack_save_chance_for(
	character: Object,
	save_index: int,
	party_charm_bonus := 0
) -> float:
	if character == null or not character.has_meta(META_HIT_DICE_KEY):
		return clampf(
			save_chance_for(character, save_index) + party_charm_bonus,
			0.0,
			100.0
		)

	var saves := monster_saves(character.get_meta(META_SAVES_KEY, []))
	if save_index == 7:
		var total := 0
		for value: Variant in saves:
			total += int(value)
		return clampf(float(int(float(total) / float(MONSTER_SAVE_COUNT))), 0.0, 100.0)
	if save_index < 0 or save_index > MONSTER_SAVE_COUNT:
		return 0.0

	var immunities := monster_immunities(
		character.get_meta(META_IMMUNITIES_KEY, [])
	)
	if save_index < MONSTER_SAVE_COUNT and int(immunities[save_index]) != 0:
		return 100.0
	# savevs grants Undead monsters automatic Charm, Chemical, and Mental saves.
	if save_index in [0, 4, 5] and _has_tag(character, "Undead"):
		return 100.0
	# Monster save bytes cover types 1-6; Charm has no ordinary monster save byte.
	if save_index == 0:
		return 0.0
	return clampf(float(saves[save_index - 1]), 0.0, 100.0)


static func target_resolution(
	character: Object,
	spell: Object,
	power: int,
	roll: int,
	extra_adjustment := 0,
	forced := false
) -> Dictionary:
	var save_index := int(spell.get("classic_spell_save_index"))
	var save_mode := str(spell.get("classic_spell_save_mode"))
	if not SAVE_MODES.has(save_mode):
		return {"status": "error", "message": "Spell has invalid Classic save metadata"}
	if save_mode == "none":
		return {
			"saveIndex": save_index,
			"saveMode": save_mode,
			"roll": roll,
			"saveChance": 0.0,
			"saved": false,
			"forced": forced,
			"effectScale": 1.0,
		}
	if not supports_save_index(save_index):
		return {"status": "error", "message": "Spell has no Classic save type"}
	if character == null or not character.has_method("get_stat"):
		return {"status": "error", "message": "Classic spell target has no readable stats"}

	var save_chance := clampf(
		save_chance_for(character, save_index)
			+ int(spell.get("classic_save_bonus"))
			+ power * (
				int(spell.get("classic_save_adjust")) + int(extra_adjustment)
			),
		0.0,
		100.0
	)
	var saved := not forced and roll <= save_chance
	var effect_scale := 1.0
	if saved:
		effect_scale = 0.5 if save_mode == "half_damage" else 0.0
	return {
		"saveIndex": save_index,
		"saveMode": save_mode,
		"roll": roll,
		"saveChance": save_chance,
		"saved": saved,
		"forced": forced,
		"effectScale": effect_scale,
	}


static func _monster_save_chance(character: Object, save_index: int) -> Variant:
	if character == null or not character.has_meta(META_SAVES_KEY):
		return null
	# Data MD keeps Charm and Mental as separate families even though Remake
	# represents both with its native Mental defense.
	var saves := monster_saves(character.get_meta(META_SAVES_KEY))
	if save_index >= 0 and save_index < MONSTER_SAVE_COUNT:
		var immunities := monster_immunities(
			character.get_meta(META_IMMUNITIES_KEY, [])
		)
		if int(immunities[save_index]) != 0:
			return 100.0
		return clampf(float(saves[save_index]), 0.0, 100.0)
	if save_index == 7:
		# Classic's special save truncates the average of all six monster saves.
		var total := 0
		for value: Variant in saves:
			total += int(value)
		return clampf(float(int(float(total) / float(MONSTER_SAVE_COUNT))), 0.0, 100.0)
	return null


static func _has_tag(character: Object, tag: String) -> bool:
	for property: Dictionary in character.get_property_list():
		if str(property.get("name", "")) != "tags":
			continue
		var tags: Variant = character.get("tags")
		return tags is Array and tag in tags
	return false


static func _integer_array(values: Variant, expected_size: int) -> Array:
	var result: Array = []
	for index: int in expected_size:
		result.append(int(values[index]) if values is Array and index < values.size() else 0)
	return result
