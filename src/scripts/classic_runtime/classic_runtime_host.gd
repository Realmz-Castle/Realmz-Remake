class_name ClassicRuntimeHost
extends Node

signal command_started(command: String, payload: Dictionary)
signal command_finished(command: String, response: Dictionary)
signal playthrough_completed(result: Dictionary)
signal playthrough_stopped(result: Dictionary)
signal playthrough_finished(result: Dictionary)

var runtime: ClassicRuntime
var command_adapter: Object
var active := false
var command_context: Dictionary = {}
var nested_trigger_active := false
var restored_continuation_pending := false


func _init() -> void:
	runtime = ClassicRuntime.new()
	add_child(runtime)
	runtime.command_requested.connect(_on_command_requested)
	runtime.trigger_completed.connect(_on_trigger_completed)
	runtime.runtime_stopped.connect(_on_runtime_stopped)


func configure(adapter: Object) -> void:
	command_adapter = adapter


func load_campaign(directory: String) -> bool:
	active = false
	nested_trigger_active = false
	restored_continuation_pending = false
	command_context.clear()
	if not runtime.load_campaign(directory):
		return false
	_configure_adapter()
	return true


func use_campaign(campaign_bundle: ClassicCampaignBundle) -> void:
	active = false
	nested_trigger_active = false
	restored_continuation_pending = false
	command_context.clear()
	var loaded_state := ClassicRuntimeState.new()
	loaded_state.configure_from_bundle(campaign_bundle)
	runtime.use_shared_campaign(campaign_bundle, loaded_state)
	_configure_adapter()


func _configure_adapter() -> void:
	if command_adapter != null and command_adapter.has_method("configure_classic_bundle"):
		command_adapter.call("configure_classic_bundle", runtime.bundle)


func has_trigger(trigger_id: String) -> bool:
	return runtime.has_trigger(trigger_id)


func random_encounters_enabled() -> bool:
	return runtime.runtime_state.random_encounters_enabled


func allies_suspended() -> bool:
	return runtime.runtime_state.allies_suspended


func spellcasting_blocked(player_character: bool) -> bool:
	return (
		runtime.runtime_state.player_spellcasting_blocked
		if player_character
		else runtime.runtime_state.monster_spellcasting_blocked
	)


func run_trigger(trigger_id: String, start_slot := 0, context := {}) -> Dictionary:
	if active:
		return {
			"status": "error",
			"message": "A Classic action point is already active",
		}
	if not start_trigger(trigger_id, start_slot, context):
		return runtime.last_result
	if not active:
		return runtime.last_result
	var result: Dictionary = await playthrough_finished
	return result


func run_nested_trigger(trigger_id: String, start_slot := 0, context := {}) -> Dictionary:
	if not active:
		return await run_trigger(trigger_id, start_slot, context)
	if nested_trigger_active:
		return {
			"status": "error",
			"message": "A nested Classic action point is already active",
		}
	nested_trigger_active = true
	# A map action point can remain suspended in start_battle while combat macros run.
	# Share its campaign state without replacing that interpreter's execution stack.
	var nested_host := ClassicRuntimeHost.new()
	add_child(nested_host)
	nested_host.configure(command_adapter)
	nested_host.runtime.use_shared_campaign(runtime.bundle, runtime.runtime_state)
	var result: Dictionary = await nested_host.run_trigger(trigger_id, start_slot, context)
	nested_host.queue_free()
	nested_trigger_active = false
	return result


func run_battle_round_macro(
	battle_data: Dictionary,
	combat_round: int,
	context := {}
) -> Dictionary:
	var raw_macro := int(battle_data.get("battleMacro", 0))
	if combat_round <= 1 or raw_macro >= 0:
		return {"handled": false}
	var trigger_id := "Data ED3:macro:%d" % abs(raw_macro)
	if not has_trigger(trigger_id):
		return {
			"handled": true,
			"triggerId": trigger_id,
			"result": {
				"status": "error",
				"message": "Classic battle macro trigger '%s' is missing" % trigger_id,
			},
		}
	var execution_context: Dictionary = context.duplicate(true) if context is Dictionary else {}
	execution_context["combatRound"] = combat_round
	execution_context["battleMacro"] = raw_macro
	execution_context["queuedMacro"] = false
	return {
		"handled": true,
		"triggerId": trigger_id,
		"result": await run_nested_trigger(trigger_id, 0, execution_context),
	}


func run_queued_combat_macro(entry: Dictionary, combat_context := {}) -> Dictionary:
	var trigger_id := str(entry.get("triggerId", ""))
	if trigger_id.is_empty() or not has_trigger(trigger_id):
		return {
			"handled": true,
			"triggerId": trigger_id,
			"result": {
				"status": "error",
				"message": "Classic queued combat macro trigger '%s' is missing" % trigger_id,
			},
		}
	var execution_context: Dictionary = combat_context.duplicate(true) \
		if combat_context is Dictionary else {}
	var queued_context: Variant = entry.get("context", {})
	if queued_context is Dictionary:
		for context_key: Variant in queued_context:
			execution_context[context_key] = queued_context[context_key]
	execution_context["queuedMacro"] = true
	return {
		"handled": true,
		"triggerId": trigger_id,
		"result": await run_nested_trigger(trigger_id, 0, execution_context),
	}


func activate_start_location(force_reload := false) -> Dictionary:
	if command_adapter == null or not command_adapter.has_method("activate_classic_start"):
		return {
			"status": "error",
			"message": "ClassicRuntimeHost requires a start-location adapter",
		}
	var replay_result := reapply_map_state()
	if str(replay_result.get("status", "")) == "error":
		return replay_result
	var state := runtime.runtime_state
	var response: Variant = command_adapter.call("activate_classic_start", {
		"levelType": state.level_type,
		"levelIndex": state.level_index,
		"x": state.x,
		"y": state.y,
		"heading": state.heading,
		"multiView": state.multi_view,
		"viewType": state.view_type,
		"compassEnabled": state.compass_enabled,
		"recheckDestination": true,
		"forceReload": force_reload,
	})
	if response is Dictionary:
		response["persistentMapState"] = replay_result
		return response
	return {}


func reapply_map_state() -> Dictionary:
	if command_adapter == null or not command_adapter.has_method("reapply_classic_map_state"):
		return {
			"status": "error",
			"message": "ClassicRuntimeHost requires a persistent map-state adapter",
		}
	var response: Variant = command_adapter.call(
		"reapply_classic_map_state",
		runtime.runtime_state
	)
	return response if response is Dictionary else {
		"status": "error",
		"message": "Classic map-state adapter returned an invalid response",
	}


func resolve_dungeon_movement(from_position: Vector2i, to_position: Vector2i) -> Dictionary:
	if command_adapter == null \
			or not command_adapter.has_method("resolve_classic_dungeon_movement"):
		return {"handled": false}
	var response: Variant = command_adapter.call(
		"resolve_classic_dungeon_movement",
		runtime.runtime_state,
		from_position,
		to_position
	)
	return response if response is Dictionary else {
		"status": "error",
		"handled": true,
		"allowed": false,
		"message": "Classic dungeon movement adapter returned an invalid response",
	}


func resolve_map_movement(from_position: Vector2i, to_position: Vector2i) -> Dictionary:
	if command_adapter == null \
			or not command_adapter.has_method("resolve_classic_map_movement"):
		return {"handled": false}
	var response: Variant = command_adapter.call(
		"resolve_classic_map_movement",
		runtime.runtime_state,
		from_position,
		to_position
	)
	return response if response is Dictionary else {
		"status": "error",
		"handled": true,
		"allowed": false,
		"message": "Classic map movement adapter returned an invalid response",
	}


func discover_map_secrets(position: Vector2i) -> Dictionary:
	if command_adapter == null \
			or not command_adapter.has_method("discover_classic_map_secrets"):
		return {"handled": false}
	var response: Variant = command_adapter.call(
		"discover_classic_map_secrets",
		runtime.runtime_state,
		position
	)
	return response if response is Dictionary else {
		"status": "error",
		"handled": true,
		"message": "Classic secret-discovery adapter returned an invalid response",
	}


func play_map_sound(sound_id: int) -> Dictionary:
	if command_adapter == null or not command_adapter.has_method("play_classic_map_sound"):
		return {"handled": false}
	var response: Variant = command_adapter.call("play_classic_map_sound", sound_id)
	if not (response is Dictionary):
		return {
			"status": "error",
			"handled": true,
			"message": "Classic map-sound adapter returned an invalid response",
		}
	var result: Dictionary = response.duplicate()
	result["handled"] = true
	return result


func start_trigger(trigger_id: String, start_slot := 0, context := {}) -> bool:
	if command_adapter == null or not command_adapter.has_method("execute_command"):
		_stop_with_error("ClassicRuntimeHost requires an execute_command adapter")
		return false
	if not (context is Dictionary):
		_stop_with_error("ClassicRuntimeHost command context must be a dictionary")
		return false
	command_context.clear()
	restored_continuation_pending = false
	if command_adapter.has_method("get_classic_execution_context"):
		var adapter_context: Variant = command_adapter.call("get_classic_execution_context")
		if adapter_context is Dictionary:
			command_context = adapter_context.duplicate(true)
	for context_key: Variant in context:
		command_context[context_key] = context[context_key]
	active = true
	if not runtime.activate_trigger(trigger_id, start_slot, command_context):
		active = false
		return false
	return true


func make_continuation_snapshot() -> Dictionary:
	if nested_trigger_active:
		return _continuation_error(
			"Finish the current Classic combat macro before saving"
		)
	if not active:
		return runtime.make_continuation_snapshot()
	var command := str(runtime.last_result.get("command", ""))
	if command_adapter != null \
			and command_adapter.has_method("classic_continuation_save_policy"):
		var policy: Variant = command_adapter.call(
			"classic_continuation_save_policy",
			command
		)
		if policy is Dictionary and str(policy.get("status", "")) == "error":
			return policy
	var runtime_result := runtime.make_continuation_snapshot()
	if str(runtime_result.get("status", "")) != "ok":
		return runtime_result
	var snapshot: Dictionary = runtime_result["snapshot"]
	snapshot["commandContext"] = command_context.duplicate(true)
	return {"status": "ok", "snapshot": snapshot}


func restore_continuation(snapshot: Variant) -> Dictionary:
	active = false
	nested_trigger_active = false
	restored_continuation_pending = false
	command_context.clear()
	var runtime_result := runtime.restore_continuation(snapshot)
	if str(runtime_result.get("status", "")) != "ok":
		return runtime_result
	if str(snapshot.get("state", "")) != "suspended":
		return {"status": "ok"}
	var context_value: Variant = snapshot.get("commandContext", {})
	if not (context_value is Dictionary):
		return _continuation_error("Classic continuation has an invalid command context")
	command_context = context_value.duplicate(true)
	restored_continuation_pending = true
	return {"status": "ok"}


func has_restored_continuation() -> bool:
	return restored_continuation_pending


func resume_restored_continuation() -> Dictionary:
	if not restored_continuation_pending:
		return {"status": "ok", "handled": false}
	if command_adapter == null or not command_adapter.has_method("execute_command"):
		return _continuation_error("ClassicRuntimeHost requires an execute_command adapter")
	restored_continuation_pending = false
	active = true
	var replay_result := runtime.replay_continuation()
	if str(replay_result.get("status", "")) == "error":
		active = false
		command_context.clear()
		return replay_result
	return {"status": "ok", "handled": true}


func _on_command_requested(command: String, payload: Dictionary) -> void:
	if not active:
		return
	var command_payload := payload.duplicate(true)
	for context_key: Variant in command_context:
		if not command_payload.has(context_key):
			command_payload[context_key] = command_context[context_key]
	command_started.emit(command, command_payload)
	var response_value: Variant = await command_adapter.execute_command(command, command_payload)
	if not active:
		return
	var response: Dictionary = response_value if response_value is Dictionary else {}
	command_finished.emit(command, response)
	if str(response.get("status", "")) == "error":
		_stop_with_error(str(response.get("message", "Classic command adapter failed")), command)
		return
	_resume_after_command(command, command_payload, response)


func _resume_after_command(command: String, payload: Dictionary, response: Dictionary) -> void:
	match command:
		"choice":
			if not response.has("accepted"):
				_stop_with_error("Choice adapter response is missing 'accepted'", command)
				return
			runtime.answer_choice(bool(response["accepted"]))
		"start_encounter":
			if not response.has("outcome"):
				_stop_with_error("Encounter adapter response is missing 'outcome'", command)
				return
			runtime.finish_encounter(int(response["outcome"]), response)
		"start_battle":
			if response.has("forcedResumeSlot"):
				runtime.finish_forced_battle_at_slot(int(response["forcedResumeSlot"]))
			elif bool(payload.get("outcomeBranch", false)):
				if not response.has("coward"):
					_stop_with_error("Battle adapter response is missing 'coward'", command)
					return
				runtime.finish_battle(bool(response["coward"]))
			elif str(payload.get("participantMode", "party")) == "selected":
				if not response.has("survivorCount"):
					_stop_with_error("Selective battle adapter response is missing 'survivorCount'", command)
					return
				runtime.finish_selective_battle(int(response["survivorCount"]))
			else:
				runtime.continue_after_command()
		"end_classic_battle":
			runtime.finish_forced_battle_end()
		"check_party_item":
			if not response.has("possessed"):
				_stop_with_error("Item-check adapter response is missing 'possessed'", command)
				return
			runtime.finish_item_check(bool(response["possessed"]))
		"take_party_wealth":
			if not response.has("paid"):
				_stop_with_error("Wealth-payment adapter response is missing 'paid'", command)
				return
			runtime.finish_wealth_payment(bool(response["paid"]))
		"check_party_condition":
			if not response.has("active"):
				_stop_with_error("Party-condition adapter response is missing 'active'", command)
				return
			runtime.finish_party_condition_check(bool(response["active"]))
		"check_character_ability":
			if not response.has("passed"):
				_stop_with_error(
					"Character-ability adapter response is missing 'passed'",
					command
				)
				return
			runtime.finish_character_ability_check(bool(response["passed"]))
		"check_party_misc":
			if not response.has("matched"):
				_stop_with_error("Party identity adapter response is missing 'matched'", command)
				return
			runtime.finish_misc_branch(bool(response["matched"]))
		"check_party_ally":
			if not response.has("present"):
				_stop_with_error("Ally-check adapter response is missing 'present'", command)
				return
			runtime.finish_ally_check(bool(response["present"]))
		"check_combat_monster":
			if not response.has("present"):
				_stop_with_error("Combat-monster adapter response is missing 'present'", command)
				return
			runtime.finish_combat_monster_check(bool(response["present"]))
		"revive_classic_combatants":
			runtime.finish_combat_revival(
				int(response.get("partyRevived", 0)) > 0
			)
		"activate_battle_round_macro":
			runtime.finish_battle_round_macro()
		"present_random_branch":
			runtime.finish_random_branch_presentation()
		"back_up_party":
			runtime.finish_back_up_party()
		"alter_game_time":
			runtime.finish_time_mutation(response)
		"update_exploration_status":
			runtime.finish_exploration_status(response)
		"show_text", "show_scrolling_text", "play_sound", "wait_for_click", \
		"show_picture", "redraw_map", \
		"give_treasure", "give_experience", \
		"alter_party_fatigue", "drop_party_items", \
		"level_up_selected_characters", "alter_selected_characters", \
		"give_character_condition", \
		"pick_characters", "filter_selected_characters", \
		"select_characters_by_misc", "select_characters_by_identity", \
		"change_selected_health", "change_party_health", "cast_classic_spell", \
		"give_map", "load_shop", "offer_temple", "enable_banking", "set_map_tile", \
		"set_trigger_percent", "set_view_direction", \
		"set_view_mode", "set_map_darkness", "set_random_encounter_rect", \
		"shift_party_position", "set_camping_permission", \
		"set_priest_turning", \
		"set_land_look", "give_battle_loot", "alter_party_items", \
		"store_party_equipment", "add_party_ally", "remove_party_ally", \
		"destroy_combat_monsters", "deanimate_lower_undead", "rout_combat_monsters", \
		"spawn_combat_monsters", \
		"alter_classic_combatants", \
		"fumble_active_combatant", \
		"apply_coward_penalty", "eliminate_encounter_option":
			runtime.continue_after_command()
		"teleport":
			if bool(payload.get("dungeonMove", false)):
				runtime.continue_after_command()
			else:
				runtime.finish_teleport()
		_:
			_stop_with_error("No ClassicRuntimeHost continuation rule for '%s'" % command, command)


func _on_trigger_completed(result: Dictionary) -> void:
	if not active:
		return
	active = false
	command_context.clear()
	playthrough_completed.emit(result)
	playthrough_finished.emit(result)


func _on_runtime_stopped(result: Dictionary) -> void:
	if not active:
		return
	active = false
	command_context.clear()
	playthrough_stopped.emit(result)
	playthrough_finished.emit(result)


func _stop_with_error(message: String, command := "") -> void:
	active = false
	command_context.clear()
	var result := {
		"status": "error",
		"message": message,
	}
	if not command.is_empty():
		result["command"] = command
	playthrough_stopped.emit(result)
	playthrough_finished.emit(result)


static func _continuation_error(message: String) -> Dictionary:
	return {"status": "error", "message": message}
