extends RefCounted
class_name ClassicPlayerAutoCombat

const GenericAutoCombatScript = preload(
	"res://shared_assets/CreatureScripts/test_crea_script.gd"
)


static func decide_action(creature: Creature) -> Array:
	if creature.get_apr_left() <= 0:
		return [0, Vector2i.ZERO]
	var enemies: Array = AiFunctions.get_closest_creas_not_of_side(
		creature,
		creature.curFaction
	)
	if enemies.is_empty():
		return [0, Vector2i.ZERO]
	var target: Creature = enemies[0]
	if AiFunctions.get_range_between_creas(creature, target) <= 1:
		return GenericAutoCombatScript._move_toward_target(
			creature,
			target.position
		)

	var spell_decision := _best_safe_spell_decision(creature, target)
	if not spell_decision.is_empty():
		return spell_decision
	return GenericAutoCombatScript._move_toward_target(
		creature,
		target.position
	)


static func best_affordable_damage_power(
	creature: Creature,
	spell: Spell
) -> int:
	var available_spell_points := int(creature.get_stat("curSP"))
	var maximum_power := clampi(int(spell.max_plevel), 1, 7)
	var best_power := 0
	var best_damage := 0
	var best_cost := 0
	for power: int in range(1, maximum_power + 1):
		var cost := int(creature.get_spell_resource_cost(spell, power))
		if cost > available_spell_points:
			continue
		var damage := int(spell.get_max_damage(power, creature))
		if damage > best_damage or (
			damage == best_damage
			and damage > 0
			and (best_power == 0 or cost < best_cost)
		):
			best_power = power
			best_damage = damage
			best_cost = cost
	return best_power


static func _best_safe_spell_decision(
	creature: Creature,
	target: Creature
) -> Array:
	if not creature.can_cast_spells() \
			or creature.get_spellsperround_left() <= 0:
		return []
	var best_decision: Array = []
	var best_damage := 0
	var best_cost := 0
	for learned_spell: Variant in creature.get_all_spells():
		if not (learned_spell is Dictionary):
			continue
		var spell_value: Variant = learned_spell.get("script")
		if not (spell_value is Spell):
			continue
		var spell: Spell = spell_value
		if not spell.in_combat \
				or spell.autotarget_type != Spell.AUTOTARGET_TYPE.NONE:
			continue
		var power := best_affordable_damage_power(creature, spell)
		if power <= 0:
			continue
		var decision := _safe_spell_decision(creature, target, spell, power)
		if decision.is_empty():
			continue
		var damage := int(spell.get_max_damage(power, creature))
		var cost := int(creature.get_spell_resource_cost(spell, power))
		if damage > best_damage or (
			damage == best_damage
			and (best_decision.is_empty() or cost < best_cost)
		):
			best_decision = decision
			best_damage = damage
			best_cost = cost
	return best_decision


static func _safe_spell_decision(
	creature: Creature,
	target: Creature,
	spell: Spell,
	power: int
) -> Array:
	if spell.get_range(power, creature) \
			< AiFunctions.get_range_between_creas(creature, target):
		return []
	var affected_tiles: Array = GameGlobal.map.targetingLayer.get_affected_tiles(
		spell,
		power,
		creature.combat_button,
		target.position,
		[]
	)
	if affected_tiles.is_empty():
		return []
	var affected_buttons: Array = (
		GameGlobal.map.targetingLayer.get_cbs_touching_tiles(affected_tiles)
	)
	var hits_target := false
	for button: Variant in affected_buttons:
		if not is_instance_valid(button):
			continue
		if button.creature == target:
			hits_target = true
		elif button.creature.curFaction == creature.curFaction:
			return []
	if not hits_target:
		return []
	return [
		1,
		spell,
		power,
		target.position,
		spell.get_aoe(power, creature),
		{},
		Vector2i(target.position),
		affected_tiles,
		affected_buttons,
	]
