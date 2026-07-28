class_name ScenarioMapTimeHandler
extends ClassicOpcodeHandler


func _init() -> void:
	configure(
		"core.map-time",
		PackedInt32Array([
			12, 13, 20, 23, 28, 29, 37, 45, 54, 57, 61, 63, 66, 70, 92, 93,
			94, 95, 96, 97, 101, 103, 104, 106,
		])
	)


func execute_on_runtime(instruction: Dictionary, runtime: Object) -> Dictionary:
	var code := int(instruction.get("code", 0))
	var record_id := int(instruction.get("id", 0))
	match code:
		12:
			return _invoke(runtime, "_execute_tile_mutation", [record_id])
		13:
			return _invoke(runtime, "_execute_trigger_mutation", [record_id])
		20, 45:
			return _invoke(
				runtime,
				"_execute_teleport",
				[record_id, code == 20]
			)
		23:
			return _invoke(
				runtime,
				"_execute_random_rectangle_mutation",
				[record_id, false]
			)
		28:
			return _invoke(runtime, "_yield_result", ["redraw_map", {}])
		29:
			return _invoke(runtime, "_execute_player_map", [record_id])
		37:
			return _invoke(runtime, "_execute_dungeon_move", [record_id])
		54:
			return _invoke(
				runtime,
				"_execute_timed_encounter_mutation",
				[record_id]
			)
		57:
			return _invoke(runtime, "_execute_landlook", [record_id])
		61:
			return _invoke(runtime, "_execute_position_shift", [record_id])
		63:
			return _invoke(runtime, "_execute_time_mutation", [record_id])
		66:
			return _invoke(runtime, "_yield_result", [
				"set_camping_permission",
				{
					"disabled": record_id != 0,
					"soundId": 6001,
				},
			])
		70:
			return _invoke(runtime, "_execute_saved_position", [record_id])
		92:
			return _invoke(
				runtime,
				"_execute_random_rectangle_bounds",
				[record_id]
			)
		93, 94:
			return _invoke(runtime, "_execute_compass", [code == 93])
		95:
			return _invoke(runtime, "_execute_look_direction", [record_id])
		96, 97:
			return _invoke(runtime, "_execute_map_view_mode", [code == 97])
		101:
			if runtime.runtime_state.level_type == "dungeon":
				return _invoke(runtime, "_continue_result")
			_call_void(
				runtime,
				"set_pending_continuation",
				["back-up-party", {"active": true}]
			)
			return _invoke(runtime, "_yield_result", [
				"back_up_party",
				{"levelType": runtime.runtime_state.level_type},
			])
		103:
			return _invoke(
				runtime,
				"_execute_exploration_status",
				[record_id]
			)
		104:
			runtime.runtime_state.random_encounters_enabled = record_id != 0
			return _invoke(runtime, "_continue_result")
		106:
			return _invoke(runtime, "_execute_darkland", [record_id])
	return _unsupported(instruction)
