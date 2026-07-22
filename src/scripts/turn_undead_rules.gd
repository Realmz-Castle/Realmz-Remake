class_name TurnUndeadRules
extends RefCounted

# Classic spends two half-action units; Remake represents that as one action.
const ACTION_COST := 1
const TURNABLE_TAGS := ["Undead", "Nether Spawn"]


static func can_attempt(caster: Object, combatants: Array, battle_data: Dictionary) -> bool:
	if caster == null or not bool(battle_data.get("classicPriestTurningEnabled", true)):
		return false
	if int(caster.get("curFaction")) != 0 or bool(caster.get("has_turned_undead")):
		return false
	if not caster.has_method("get_stat") or int(caster.get_stat("Turn_Undead")) <= 0:
		return false
	if not caster.has_method("get_apr_left") or int(caster.get_apr_left()) < ACTION_COST:
		return false
	for combatant: Variant in combatants:
		var target := _combatant_creature(combatant)
		if target != null and is_eligible_target(caster, target):
			return true
	return false


static func perform_attempt(
	caster: Object,
	combatants: Array,
	battle_data: Dictionary,
	rolls: Array = []
) -> Dictionary:
	if not can_attempt(caster, combatants, battle_data):
		return {
			"status": "unavailable",
			"attempted": 0,
			"destroyed": 0,
			"turned": 0,
			"resisted": 0,
			"bonusExperience": 0,
			"outcomes": [],
		}

	caster.set("has_turned_undead", true)
	caster.set("used_apr", int(caster.get("used_apr")) + ACTION_COST)
	var outcomes: Array = []
	var destroyed := 0
	var turned := 0
	var resisted := 0
	var bonus_experience := 0
	var roll_index := 0
	for combatant: Variant in combatants:
		var target := _combatant_creature(combatant)
		if target == null or not is_eligible_target(caster, target):
			continue
		var roll := clampi(
			int(rolls[roll_index]) if roll_index < rolls.size() else randi_range(1, 100),
			1,
			100
		)
		roll_index += 1
		var resolution := resolve_target(
			caster,
			target,
			int(caster.get_stat("Turn_Undead")),
			roll,
			true
		)
		var outcome := str(resolution.get("outcome", "resisted"))
		var hit_dice := int(resolution.get("hitDice", 0))
		var experience := turning_experience(outcome, hit_dice)
		if outcome == "destroyed":
			destroyed += 1
		elif outcome == "turned":
			turned += 1
		else:
			resisted += 1
		bonus_experience += experience
		outcomes.append({
			"combatant": combatant,
			"creature": target,
			"outcome": outcome,
			"roll": roll,
			"difficulty": resolution.get("difficulty", 0),
			"bonusExperience": experience,
		})
	return {
		"status": "ok",
		"attempted": outcomes.size(),
		"destroyed": destroyed,
		"turned": turned,
		"resisted": resisted,
		"bonusExperience": bonus_experience,
		"outcomes": outcomes,
	}


static func resolve_target(
	caster: Object,
	target: Object,
	turning_strength: int,
	roll: int,
	include_magic_resistance := true
) -> Dictionary:
	if not is_eligible_target(caster, target):
		return {"status": "ineligible", "outcome": "ineligible"}
	var hit_dice := target_hit_dice(target)
	# A roll above the source threshold succeeds. Margins below 30 destroy;
	# larger margins turn the target to the caster's side.
	var difficulty := maxi(25, 100 - turning_strength + 5 * hit_dice)
	if include_magic_resistance:
		difficulty += _target_magic_resistance(target)
	var margin := clampi(roll, 1, 100) - difficulty
	var outcome := "resisted"
	if margin > 0 and margin < 30:
		outcome = "destroyed"
	elif margin >= 30:
		outcome = "turned"
	apply_target_outcome(caster, target, outcome)
	return {
		"status": "ok",
		"outcome": outcome,
		"roll": clampi(roll, 1, 100),
		"difficulty": difficulty,
		"margin": margin,
		"hitDice": hit_dice,
	}


static func apply_target_outcome(caster: Object, target: Object, outcome: String) -> bool:
	match outcome:
		"destroyed":
			var current_hp := int(target.get_stat("curHP"))
			target.change_cur_hp(-current_hp)
			return true
		"turned":
			target.set("curFaction", int(caster.get("curFaction")))
			return true
	return false


static func turning_experience(outcome: String, hit_dice: int) -> int:
	if outcome == "destroyed":
		return 25 * maxi(0, hit_dice)
	if outcome == "turned":
		return 50 * maxi(0, hit_dice)
	return 0


static func is_eligible_target(caster: Object, target: Object) -> bool:
	if caster == null or target == null:
		return false
	if int(target.get("curFaction")) == int(caster.get("curFaction")):
		return false
	if not target.has_method("get_stat") or int(target.get_stat("curHP")) <= 0:
		return false
	if target.has_meta("classic_turn_undead_eligible"):
		return bool(target.get_meta("classic_turn_undead_eligible")) \
			and int(target.get_meta("classic_can_summon", 0)) != 255
	var tags: Variant = target.get("tags")
	if not (tags is Array):
		return false
	for tag: String in TURNABLE_TAGS:
		if tags.has(tag):
			return true
	return false


static func target_hit_dice(target: Object) -> int:
	if target.has_meta("classic_hit_dice"):
		return maxi(0, int(target.get_meta("classic_hit_dice")))
	return maxi(0, int(target.get("level")))


static func _target_magic_resistance(target: Object) -> int:
	if target.has_meta("classic_magic_resistance"):
		return int(target.get_meta("classic_magic_resistance"))
	return int(target.get_stat("ResistanceMagic"))


static func _combatant_creature(combatant: Variant) -> Object:
	if not (combatant is Object):
		return null
	var creature: Variant = combatant.get("creature")
	return creature if creature is Object else null
