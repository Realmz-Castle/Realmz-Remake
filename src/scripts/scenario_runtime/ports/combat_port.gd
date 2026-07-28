class_name CombatPort
extends DelegatingScenarioPort

const COMMANDS := [
	"start_battle",
	"check_combat_monster",
	"destroy_combat_monsters",
	"deanimate_lower_undead",
	"rout_combat_monsters",
	"spawn_combat_monsters",
	"revive_classic_combatants",
	"alter_classic_combatants",
	"fumble_active_combatant",
	"activate_battle_round_macro",
	"end_classic_battle",
	"set_priest_turning",
	"give_battle_loot",
	"apply_coward_penalty",
]
const OPERATIONS := {
	"start_battle": "_start_classic_battle",
	"check_combat_monster": "_check_combat_monster",
	"destroy_combat_monsters": "_destroy_combat_monsters",
	"deanimate_lower_undead": "_deanimate_lower_undead",
	"rout_combat_monsters": "_rout_combat_monsters",
	"spawn_combat_monsters": "_spawn_combat_monsters",
	"revive_classic_combatants": "_revive_classic_combatants",
	"alter_classic_combatants": "_alter_classic_combatants",
	"fumble_active_combatant": "_fumble_active_combatant",
	"activate_battle_round_macro": "_activate_battle_round_macro",
	"end_classic_battle": "_end_classic_battle",
	"set_priest_turning": "_present_priest_turning",
	"give_battle_loot": "_give_battle_loot",
	"apply_coward_penalty": "_apply_coward_penalty",
}


func port_id() -> String:
	return "core.combat"


func service_operation(command_id: String) -> String:
	return str(OPERATIONS.get(command_id, ""))


func owned_command_ids() -> PackedStringArray:
	return PackedStringArray(COMMANDS)


func execute(command_id: String, request: Dictionary) -> Dictionary:
	if command_id == "activate_battle_round_macro" \
			and not bool(rule_option("combat", "battleMacros", true)):
		return {
			"status": "ok",
			"skipped": true,
			"reason": "gameplay-rules",
		}
	if command_id == "rout_combat_monsters" \
			and not bool(rule_option("combat", "classicMorale", true)):
		return {
			"status": "ok",
			"skipped": true,
			"reason": "gameplay-rules",
		}
	var extension_result := invoke_runtime_binding(
		"monsterAi",
		"monsterAiProviders",
		[
			request.get("monsterDefinitionId", ""),
			request.get("monsterId", ""),
			request.get("monsterNameId", ""),
		],
		request
	)
	if bool(extension_result.get("handled", false)):
		return extension_result
	return await super.execute(command_id, request)
