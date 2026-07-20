class_name BattleRemovalRules
extends RefCounted


static func remove_combatant(combat_state: Variant, combatant: Variant) -> String:
	if not (combat_state is Object) or not combat_state.has_method("remove_cb_from_battle"):
		return ""
	if not (combatant is Object):
		return ""
	var creature: Variant = combatant.get("creature")
	if not (creature is Object or creature is Dictionary):
		return ""
	var defeated_enemies: Variant = combat_state.get("battle_dead_enemies")
	var defeated_party_members: Variant = combat_state.get("battle_dead_party_members")
	var classification := "ally"
	if int(creature.get("curFaction")) != 0:
		classification = "enemy"
		if defeated_enemies is Array and not defeated_enemies.has(creature):
			defeated_enemies.append(creature)
	else:
		var current_hp := int(creature.get_stat("curHP")) \
			if creature is Object and creature.has_method("get_stat") \
			else int(creature.get("curHP"))
		if current_hp <= 0:
			classification = "party"
			if defeated_party_members is Array and not defeated_party_members.has(creature):
				defeated_party_members.append(creature)
	combat_state.remove_cb_from_battle(combatant)
	return classification
