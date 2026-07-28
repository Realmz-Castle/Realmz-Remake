class_name PresentationPort
extends DelegatingScenarioPort

const COMMANDS := [
	"show_text",
	"show_scrolling_text",
	"choice",
	"start_encounter",
	"play_sound",
	"wait_for_click",
	"show_picture",
	"present_random_branch",
]
const OPERATIONS := {
	"show_text": "_show_text",
	"show_scrolling_text": "_show_scrolling_text",
	"choice": "_show_yes_no_choice",
	"start_encounter": "_show_encounter",
	"play_sound": "_play_sound_command",
	"wait_for_click": "_wait_for_click",
	"show_picture": "_show_classic_picture",
	"present_random_branch": "_present_random_branch",
}


func port_id() -> String:
	return "core.presentation"


func service_operation(command_id: String) -> String:
	return str(OPERATIONS.get(command_id, ""))


func owned_command_ids() -> PackedStringArray:
	return PackedStringArray(COMMANDS)


func execute(command_id: String, request: Dictionary) -> Dictionary:
	if command_id == "wait_for_click" \
			and not bool(
				rule_option("presentation", "waitForAuthoredClicks", true)
			):
		return {
			"status": "ok",
			"acknowledged": true,
			"skipped": true,
			"reason": "gameplay-rules",
		}
	if command_id == "start_encounter":
		var encounter_id := str(request.get("encounterId", ""))
		var extension_result := invoke_runtime_binding(
			"encounters",
			"encounterResolvers",
			[
				"%s:%s" % [request.get("encounterKind", ""), encounter_id],
				encounter_id,
			],
			request
		)
		if bool(extension_result.get("handled", false)):
			return extension_result
	return await super.execute(command_id, request)
