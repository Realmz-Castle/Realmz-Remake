class_name ClassicSpellSaves
extends RefCounted

const SAVE_MODES := ["none", "negate", "half_damage"]
const SAVE_STATS := {
	0: ["MultiplierMental", "ResistanceMental"],
	1: ["MultiplierFire", "ResistanceFire"],
	2: ["MultiplierIce", "ResistanceIce"],
	3: ["MultiplierElect", "ResistanceElect"],
	4: ["MultiplierChemical", "ResistanceChemical"],
	5: ["MultiplierMental", "ResistanceMental"],
	6: ["MultiplierMagic", "ResistanceMagic"],
	7: ["MultiplierHealing", "ResistanceHealing"],
}


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
	if not SAVE_STATS.has(save_index):
		return {"status": "error", "message": "Spell has no Classic save type"}
	if character == null or not character.has_method("get_stat"):
		return {"status": "error", "message": "Classic spell target has no readable stats"}

	var stat_names: Array = SAVE_STATS[save_index]
	var multiplier := float(character.get_stat(stat_names[0]))
	var resistance := float(character.get_stat(stat_names[1]))
	var save_chance := clampf(
		(2.0 * (1.0 - multiplier) + 0.1 * resistance) * 100.0
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
