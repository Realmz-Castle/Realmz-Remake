class_name CharacterPort
extends DelegatingScenarioPort

const COMMANDS := [
	"alter_party_fatigue",
	"check_party_condition",
	"check_party_ally",
	"add_party_ally",
	"remove_party_ally",
	"give_experience",
	"remove_experience",
	"give_character_condition",
	"pick_characters",
	"filter_selected_characters",
	"check_character_ability",
	"level_up_selected_characters",
	"alter_selected_characters",
	"select_characters_by_misc",
	"select_characters_by_identity",
	"check_party_misc",
	"change_selected_health",
	"change_party_health",
	"cast_classic_spell",
]
const OPERATIONS := {
	"alter_party_fatigue": "_alter_party_fatigue",
	"check_party_condition": "_check_party_condition",
	"check_party_ally": "_check_party_ally",
	"add_party_ally": "_add_classic_ally",
	"remove_party_ally": "_remove_classic_allies",
	"give_experience": "_give_experience",
	"remove_experience": "_remove_experience",
	"give_character_condition": "_give_character_condition",
	"pick_characters": "_pick_characters",
	"filter_selected_characters": "_filter_selected_characters",
	"check_character_ability": "_check_character_ability",
	"level_up_selected_characters": "_level_up_selected_characters",
	"alter_selected_characters": "_alter_selected_characters",
	"select_characters_by_misc": "_select_characters_by_misc",
	"select_characters_by_identity": "_select_characters_by_identity",
	"check_party_misc": "_check_party_misc",
	"change_selected_health": "_change_selected_health",
	"change_party_health": "_change_party_health",
	"cast_classic_spell": "_cast_classic_spell",
}


func port_id() -> String:
	return "core.character"


func service_operation(command_id: String) -> String:
	return str(OPERATIONS.get(command_id, ""))


func owned_command_ids() -> PackedStringArray:
	return PackedStringArray(COMMANDS)


func execute(command_id: String, request: Dictionary) -> Dictionary:
	if not bool(rule_option("character", "classicConditions", true)):
		if command_id == "give_character_condition":
			return {
				"status": "ok",
				"skipped": true,
				"reason": "gameplay-rules",
			}
		if command_id == "check_party_condition":
			return {
				"status": "ok",
				"active": false,
				"reason": "gameplay-rules",
			}
	if command_id == "cast_classic_spell":
		var extension_result := invoke_runtime_binding(
			"spells",
			"spells",
			[
				request.get("spellId", ""),
				request.get("authoredSpellId", ""),
				request.get("spellName", ""),
			],
			request
		)
		if bool(extension_result.get("handled", false)):
			return extension_result
	return await super.execute(command_id, request)
