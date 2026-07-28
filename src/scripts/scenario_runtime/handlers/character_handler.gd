class_name ScenarioCharacterHandler
extends ClassicOpcodeHandler


func _init() -> void:
	configure(
		"core.character",
		PackedInt32Array([
			11, 14, 15, 16, 17, 18, 30, 31, 40, 43, 50, 52, 53, 68, 69, 81,
			87, 88, 89, 90, 102, 105, 108,
		])
	)


func execute_on_runtime(instruction: Dictionary, runtime: Object) -> Dictionary:
	var code := int(instruction.get("code", 0))
	var record_id := int(instruction.get("id", 0))
	match code:
		11:
			return _invoke(
				runtime,
				"_yield_result",
				["give_experience", {"experience": record_id}]
			)
		14:
			return _invoke(
				runtime,
				"_execute_character_pick",
				[record_id, false]
			)
		15:
			return _invoke(
				runtime,
				"_execute_selected_health_effect",
				[record_id]
			)
		16:
			return _invoke(runtime, "_execute_party_health_effect", [record_id])
		17, 18:
			return _invoke(
				runtime,
				"_execute_spell_effect",
				[record_id, code == 18]
			)
		30:
			return _invoke(
				runtime,
				"_execute_character_check_selection",
				[record_id]
			)
		31:
			return _invoke(
				runtime,
				"_execute_character_ability_branch",
				[record_id, bool(runtime.gosub_active)]
			)
		40:
			return _invoke(
				runtime,
				"_execute_party_condition_branch",
				[record_id, bool(runtime.gosub_active)]
			)
		43:
			return _invoke(runtime, "_execute_give_condition", [record_id])
		50:
			return _invoke(
				runtime,
				"_execute_identity_character_selection",
				[record_id]
			)
		52:
			return _invoke(
				runtime,
				"_execute_misc_character_selection",
				[record_id]
			)
		53:
			return _invoke(
				runtime,
				"_execute_caste_character_selection",
				[record_id]
			)
		68:
			return _invoke(runtime, "_execute_fatigue_mutation", [record_id])
		69:
			return _invoke(runtime, "_execute_spellcasting_flags", [record_id])
		81:
			return _invoke(
				runtime,
				"_execute_character_condition_branch",
				[record_id, bool(runtime.gosub_active)]
			)
		87:
			return _invoke(
				runtime,
				"_execute_ally_branch",
				[record_id, bool(runtime.gosub_active)]
			)
		88:
			return _invoke(runtime, "_execute_remove_ally", [record_id])
		89:
			return _invoke(runtime, "_execute_add_ally", [record_id])
		90:
			return _invoke(runtime, "_execute_experience_loss", [record_id])
		102:
			return _invoke(runtime, "_yield_result", [
				"level_up_selected_characters",
				{"experience": 1},
			])
		105:
			runtime.runtime_state.allies_suspended = record_id != 0
			return _invoke(runtime, "_continue_result")
		108:
			return _invoke(
				runtime,
				"_execute_selected_character_mutation",
				[record_id]
			)
	return _unsupported(instruction)
