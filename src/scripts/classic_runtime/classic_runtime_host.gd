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
	command_context.clear()
	if not runtime.load_campaign(directory):
		return false
	if command_adapter != null and command_adapter.has_method("configure_classic_bundle"):
		command_adapter.call("configure_classic_bundle", runtime.bundle)
	return true


func has_trigger(trigger_id: String) -> bool:
	return runtime.has_trigger(trigger_id)


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


func activate_start_location() -> Dictionary:
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


func start_trigger(trigger_id: String, start_slot := 0, context := {}) -> bool:
	if command_adapter == null or not command_adapter.has_method("execute_command"):
		_stop_with_error("ClassicRuntimeHost requires an execute_command adapter")
		return false
	if not (context is Dictionary):
		_stop_with_error("ClassicRuntimeHost command context must be a dictionary")
		return false
	command_context.clear()
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
			if str(payload.get("participantMode", "party")) == "selected":
				if not response.has("survivorCount"):
					_stop_with_error("Selective battle adapter response is missing 'survivorCount'", command)
					return
				runtime.finish_selective_battle(int(response["survivorCount"]))
			elif bool(payload.get("outcomeBranch", false)):
				if not response.has("coward"):
					_stop_with_error("Battle adapter response is missing 'coward'", command)
					return
				runtime.finish_battle(bool(response["coward"]))
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
		"activate_battle_round_macro":
			runtime.finish_battle_round_macro()
		"present_random_branch":
			runtime.finish_random_branch_presentation()
		"show_text", "play_sound", "wait_for_click", "show_picture", "redraw_map", \
		"give_treasure", "give_experience", \
		"give_character_condition", \
		"pick_characters", "filter_selected_characters", "select_characters_by_misc", \
		"change_selected_health", "change_party_health", "cast_classic_spell", \
		"give_map", "load_shop", "offer_temple", "enable_banking", "set_map_tile", \
		"set_trigger_percent", "set_view_direction", \
		"set_view_mode", "set_map_darkness", "set_random_encounter_rect", \
		"set_priest_turning", \
		"set_land_look", "give_battle_loot", "alter_party_items", \
		"store_party_equipment", "add_party_ally", \
		"destroy_combat_monsters", "deanimate_lower_undead", "rout_combat_monsters", \
		"spawn_combat_monsters", \
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
