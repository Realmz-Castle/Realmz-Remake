class_name ScenarioCombatHandler
extends ClassicOpcodeHandler


func _init() -> void:
	configure(
		"core.combat",
		PackedInt32Array([
			2, 48, 82, 83, 100, 119, 120, 121, 122, 123, 124, 125, 126, 127,
		])
	)


func execute_on_runtime(instruction: Dictionary, runtime: Object) -> Dictionary:
	var code := int(instruction.get("code", 0))
	var record_id := int(instruction.get("id", 0))
	match code:
		2:
			return _invoke(runtime, "_execute_battle", [record_id])
		48:
			return _invoke(runtime, "_execute_selective_battle", [record_id])
		82, 83:
			return _invoke(runtime, "_execute_priest_turning", [code == 83])
		100:
			_call_void(
				runtime,
				"set_pending_continuation",
				["forced-battle-end", {"active": true}]
			)
			return _invoke(runtime, "_yield_result", [
				"end_classic_battle",
				{
					"outcome": "won",
					"lootMode": 5,
					"rewardMode": "experience_only",
					"resumeSlot": 8,
				},
			])
		119:
			return _invoke(runtime, "_execute_combat_revival")
		120:
			return _invoke(
				runtime,
				"_execute_combatant_mutation",
				[record_id]
			)
		121:
			return _invoke(
				runtime,
				"_execute_deanimate_lower_undead",
				[record_id]
			)
		122:
			return _invoke(runtime, "_execute_combat_fumble", [record_id])
		123:
			return _invoke(runtime, "_execute_combat_rout", [record_id])
		124:
			return _invoke(
				runtime,
				"_execute_spawn_combat_monsters",
				[record_id]
			)
		125:
			return _invoke(
				runtime,
				"_execute_destroy_combat_monsters",
				[record_id]
			)
		126:
			return _invoke(
				runtime,
				"_execute_battle_round_macro",
				[record_id]
			)
		127:
			return _invoke(
				runtime,
				"_execute_combat_monster_check",
				[record_id]
			)
	return _unsupported(instruction)
