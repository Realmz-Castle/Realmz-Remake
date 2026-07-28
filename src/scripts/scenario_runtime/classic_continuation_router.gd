class_name ClassicContinuationRouter
extends RefCounted

const ROUTES := {
	"choice": "_resume_choice",
	"encounter": "_resume_encounter",
	"battle": "_resume_battle",
	"selective-battle": "_resume_selective_battle",
	"forced-battle-end": "_resume_forced_battle_end",
	"item-check": "_resume_item_check",
	"wealth-payment": "_resume_wealth_payment",
	"party-condition-check": "_resume_party_condition_check",
	"character-ability-check": "_resume_character_ability_check",
	"misc-branch": "_resume_misc_branch",
	"ally-check": "_resume_ally_check",
	"combat-monster-check": "_resume_combat_monster_check",
	"combat-revival": "_resume_combat_revival",
	"battle-round-macro": "_resume_battle_round_macro",
	"random-branch": "_resume_random_branch",
	"time-mutation": "_resume_time_mutation",
	"exploration-status": "_resume_exploration_status",
	"teleport": "_resume_teleport",
	"dungeon-move": "_resume_dungeon_move",
	"back-up-party": "_resume_back_up_party",
}

var _executor: Object


func configure(executor: Object) -> void:
	_executor = executor


func resume(pending: ScenarioPendingCommand, response: Dictionary) -> Dictionary:
	if _executor == null:
		return _error("Classic continuation executor is unavailable")
	if response.has("forcedResumeSlot"):
		return _executor.resume_forced_battle_at_slot(
			int(response["forcedResumeSlot"])
		)
	var continuation_id := str(
		pending.continuation.get("_continuationId", "")
	)
	var route_method := str(ROUTES.get(continuation_id, "_continue"))
	if not has_method(route_method):
		return _error(
			"Classic continuation route '%s' is unavailable" % continuation_id
		)
	return call(route_method, pending, response)


func _resume_choice(
	_pending: ScenarioPendingCommand,
	response: Dictionary
) -> Dictionary:
	if not response.has("accepted"):
		return _error("Choice response is missing 'accepted'")
	return _executor.resume_choice(bool(response["accepted"]))


func _resume_encounter(
	_pending: ScenarioPendingCommand,
	response: Dictionary
) -> Dictionary:
	if not response.has("outcome"):
		return _error("Encounter response is missing 'outcome'")
	return _executor.resume_encounter(int(response["outcome"]), response)


func _resume_battle(
	_pending: ScenarioPendingCommand,
	response: Dictionary
) -> Dictionary:
	if not response.has("coward"):
		return _error("Battle response is missing 'coward'")
	return _executor.resume_battle(bool(response["coward"]))


func _resume_selective_battle(
	_pending: ScenarioPendingCommand,
	response: Dictionary
) -> Dictionary:
	if not response.has("survivorCount"):
		return _error("Selective battle response is missing 'survivorCount'")
	return _executor.resume_selective_battle(int(response["survivorCount"]))


func _resume_forced_battle_end(
	_pending: ScenarioPendingCommand,
	_response: Dictionary
) -> Dictionary:
	return _executor.resume_forced_battle_end()


func _resume_item_check(
	_pending: ScenarioPendingCommand,
	response: Dictionary
) -> Dictionary:
	if not response.has("possessed"):
		return _error("Item-check response is missing 'possessed'")
	return _executor.resume_item_check(bool(response["possessed"]))


func _resume_wealth_payment(
	_pending: ScenarioPendingCommand,
	response: Dictionary
) -> Dictionary:
	if not response.has("paid"):
		return _error("Wealth-payment response is missing 'paid'")
	return _executor.resume_wealth_payment(bool(response["paid"]))


func _resume_party_condition_check(
	_pending: ScenarioPendingCommand,
	response: Dictionary
) -> Dictionary:
	if not response.has("active"):
		return _error("Party-condition response is missing 'active'")
	return _executor.resume_party_condition_check(bool(response["active"]))


func _resume_character_ability_check(
	_pending: ScenarioPendingCommand,
	response: Dictionary
) -> Dictionary:
	if not response.has("passed"):
		return _error("Character-ability response is missing 'passed'")
	return _executor.resume_character_ability_check(bool(response["passed"]))


func _resume_misc_branch(
	_pending: ScenarioPendingCommand,
	response: Dictionary
) -> Dictionary:
	if not response.has("matched"):
		return _error("Party identity response is missing 'matched'")
	return _executor.resume_misc_branch(bool(response["matched"]))


func _resume_ally_check(
	_pending: ScenarioPendingCommand,
	response: Dictionary
) -> Dictionary:
	if not response.has("present"):
		return _error("Ally-check response is missing 'present'")
	return _executor.resume_ally_check(bool(response["present"]))


func _resume_combat_monster_check(
	_pending: ScenarioPendingCommand,
	response: Dictionary
) -> Dictionary:
	if not response.has("present"):
		return _error("Combat-monster response is missing 'present'")
	return _executor.resume_combat_monster_check(bool(response["present"]))


func _resume_combat_revival(
	_pending: ScenarioPendingCommand,
	response: Dictionary
) -> Dictionary:
	return _executor.resume_combat_revival(
		int(response.get("partyRevived", 0)) > 0
	)


func _resume_battle_round_macro(
	_pending: ScenarioPendingCommand,
	_response: Dictionary
) -> Dictionary:
	return _executor.resume_battle_round_macro()


func _resume_random_branch(
	_pending: ScenarioPendingCommand,
	_response: Dictionary
) -> Dictionary:
	return _executor.resume_random_branch()


func _resume_dungeon_move(
	_pending: ScenarioPendingCommand,
	_response: Dictionary
) -> Dictionary:
	return _executor.run_until_yield()


func _resume_back_up_party(
	_pending: ScenarioPendingCommand,
	_response: Dictionary
) -> Dictionary:
	return _executor.resume_back_up_party()


func _resume_time_mutation(
	_pending: ScenarioPendingCommand,
	response: Dictionary
) -> Dictionary:
	return _executor.resume_time_mutation(response)


func _resume_exploration_status(
	_pending: ScenarioPendingCommand,
	response: Dictionary
) -> Dictionary:
	return _executor.resume_exploration_status(response)


func _resume_teleport(
	_pending: ScenarioPendingCommand,
	_response: Dictionary
) -> Dictionary:
	return _executor.resume_teleport()


func _continue(
	_pending: ScenarioPendingCommand,
	_response: Dictionary
) -> Dictionary:
	return _executor.run_until_yield()


func _error(message: String) -> Dictionary:
	return {"status": "error", "message": message}
