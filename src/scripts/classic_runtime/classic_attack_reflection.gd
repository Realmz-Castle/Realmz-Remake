class_name ClassicAttackReflection
extends RefCounted


static func should_reflect(defender: Object, attacker: Object, roll: int) -> bool:
	if defender == null or attacker == null:
		return false
	if not is_instance_valid(defender.get("combat_button")) \
			or not is_instance_valid(attacker.get("combat_button")):
		return false
	return roll >= 1 and roll < 34
