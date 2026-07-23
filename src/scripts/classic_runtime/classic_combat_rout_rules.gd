class_name ClassicCombatRoutRules
extends RefCounted

const ROUTED_META := "classic_permanently_routed"
const EDGE_INSET := 1
const INERT_MORALE_MAX := 100
const OUTCOME_NONE := ""
const OUTCOME_RUN := "run"
const OUTCOME_SURRENDER := "surrender"
const OUTCOME_PANIC := "panic"


static func mark_routed(creature: Object) -> void:
	creature.set_meta(ROUTED_META, true)


static func clear_routed(creature: Object) -> void:
	creature.remove_meta(ROUTED_META)


static func is_routed(creature: Variant) -> bool:
	return creature is Object and bool(creature.get_meta(ROUTED_META, false))


static func opening_morale_outcome(
	run_percent: int,
	surrender_percent: int
) -> String:
	# Realmz compares both fields with a percentage that getup.c always
	# calculates as 100. Surrender is checked before running.
	if surrender_percent > INERT_MORALE_MAX:
		return OUTCOME_PANIC if surrender_percent == 101 else OUTCOME_SURRENDER
	if run_percent > INERT_MORALE_MAX:
		return OUTCOME_RUN
	return OUTCOME_NONE


static func apply_opening_morale(
	creature: Variant,
	fleeing_trait: Script
) -> String:
	if not (creature is Object) or is_routed(creature):
		return OUTCOME_NONE
	var outcome := opening_morale_outcome(
		int(creature.get_meta("classic_run_percent", 0)),
		int(creature.get_meta("classic_surrender_percent", 0))
	)
	if outcome == OUTCOME_RUN:
		if not creature.has_method("add_trait") or fleeing_trait == null:
			return OUTCOME_NONE
		creature.add_trait(fleeing_trait, [])
		mark_routed(creature)
	elif outcome == OUTCOME_SURRENDER or outcome == OUTCOME_PANIC:
		creature.set("please_remove_from_combat", true)
	return outcome


static func mark_exit_if_at_edge(creature: Variant, battlefield_size: Vector2i) -> bool:
	if not is_routed(creature):
		return false
	if int(creature.get_meta("classic_can_summon", 0)) in [-1, 255]:
		return false
	if battlefield_size.x < EDGE_INSET * 2 + 1 or battlefield_size.y < EDGE_INSET * 2 + 1:
		return false
	var position_value: Variant = creature.get("position")
	if not (position_value is Vector2 or position_value is Vector2i):
		return false
	var position := Vector2i(position_value)
	# Classic resolves retreat after a move reaches the outer inset of its field.
	var at_edge := position.x <= EDGE_INSET or position.y <= EDGE_INSET \
		or position.x >= battlefield_size.x - EDGE_INSET - 1 \
		or position.y >= battlefield_size.y - EDGE_INSET - 1
	if not at_edge:
		return false
	creature.set("please_remove_from_combat", true)
	return true
