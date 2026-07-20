class_name ClassicCombatRoutRules
extends RefCounted

const ROUTED_META := "classic_permanently_routed"
const EDGE_INSET := 1


static func mark_routed(creature: Object) -> void:
	creature.set_meta(ROUTED_META, true)


static func is_routed(creature: Variant) -> bool:
	return creature is Object and bool(creature.get_meta(ROUTED_META, false))


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
