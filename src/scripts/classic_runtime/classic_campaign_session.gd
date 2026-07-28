class_name ClassicCampaignSession
extends Node

signal timed_encounter_dispatched(encounter_id: int, trigger_id: String, result: Dictionary)

const InstallScript = preload("res://scripts/classic_runtime/classic_campaign_install.gd")
const HostScript = preload("res://scripts/classic_runtime/classic_runtime_host.gd")
const RuntimeScript = preload("res://scripts/classic_runtime/classic_runtime.gd")
const TimedEncounterSchedulerScript = preload(
	"res://scripts/classic_runtime/classic_timed_encounter_scheduler.gd"
)
const CharacterRulesScript = preload(
	"res://scripts/classic_runtime/classic_character_rules.gd"
)
const GameplayRuleRegistryScript = preload(
	"res://scripts/scenario_runtime/gameplay_rule_registry.gd"
)
const GameplayRuleSetScript = preload(
	"res://scripts/scenario_runtime/gameplay_rule_set.gd"
)
const SAVE_SCHEMA_VERSION := 3

var install: Object
var host: Object
var command_adapter: Object
var timed_encounter_scheduler := TimedEncounterSchedulerScript.new()
var gameplay_rule_registry: GameplayRuleRegistry
var gameplay_rule_set: GameplayRuleSet
var _timed_dispatch_loop_active := false


func load_installed_campaign(
	campaigns_directory: String,
	campaign_name: String,
	command_adapter: Object,
	prepared_install: Object = null,
	gameplay_rule_selection := {}
) -> Dictionary:
	clear()
	self.command_adapter = command_adapter
	if (
		prepared_install != null
		and str(prepared_install.get("campaign_name")) == campaign_name
		and prepared_install.get("bundle") != null
		and str(prepared_install.get("last_error")).is_empty()
	):
		install = prepared_install
	else:
		install = InstallScript.new()
		if not install.load_from_campaigns_directory(campaigns_directory, campaign_name):
			return {"status": "error", "message": install.last_error}
	var item_load_result := _load_installed_item_definitions()
	if str(item_load_result.get("status", "")) == "error":
		return item_load_result
	var rule_result := _resolve_gameplay_rules(gameplay_rule_selection)
	if str(rule_result.get("status", "")) != "ok":
		return rule_result
	host = HostScript.new()
	add_child(host)
	host.configure(self.command_adapter, gameplay_rule_set)
	host.use_campaign(install.bundle)
	host.playthrough_finished.connect(_on_host_playthrough_finished)
	return {
		"status": "ok",
		"campaignDirectory": install.campaign_directory,
		"campaignId": str(install.bundle.manifest.get("id", "")),
		"host": host,
		"gameplayRules": gameplay_rule_set.snapshot(),
	}


func _resolve_gameplay_rules(selection: Variant) -> Dictionary:
	if not (selection is Dictionary):
		return _error("Gameplay rule selection must be a dictionary")
	gameplay_rule_registry = GameplayRuleRegistryScript.new()
	if not gameplay_rule_registry.load_builtin_catalog():
		return _error(gameplay_rule_registry.last_error)
	var runtime_document: Dictionary = install.bundle.documents.get("runtime", {})
	var preset_id := str(
		selection.get(
			"presetId",
			runtime_document.get("recommendedGameplayProfile", "core.classic")
		)
	)
	var overrides: Variant = selection.get("domains", {})
	if not (overrides is Dictionary):
		return _error("Gameplay rule domain selection must be a dictionary")
	var result := gameplay_rule_registry.resolve(preset_id, overrides)
	if str(result.get("status", "")) != "ok":
		return result
	gameplay_rule_set = result["ruleset"]
	return {"status": "ok"}


func _load_installed_item_definitions() -> Dictionary:
	var main_loop := Engine.get_main_loop()
	if not (main_loop is SceneTree):
		return {"status": "skipped"}
	var resources: Node = main_loop.root.get_node_or_null("Main/Resources")
	if resources == null or not resources.has_method("load_item_resources"):
		return {"status": "skipped"}
	var item_directory: String = install.campaign_directory.path_join("Items") + "/"
	if not FileAccess.file_exists(item_directory.path_join("stuff_book.json")):
		return {"status": "skipped"}
	var campaign_id := str(install.bundle.manifest.get("id", "")).strip_edges()
	if campaign_id.is_empty():
		return _error("Classic campaign manifest has no item catalog identity")
	if not resources.load_item_resources(item_directory, campaign_id, true):
		return _error("Classic campaign item definitions could not be loaded")
	return {"status": "ok"}


func activate_start_location(force_reload := false) -> Dictionary:
	if not is_instance_valid(host):
		return {"status": "error", "message": "Classic campaign runtime is not loaded"}
	var result: Variant = host.activate_start_location(force_reload)
	var normalized: Dictionary = result if result is Dictionary else {
		"status": "error",
		"message": "Classic campaign start returned an invalid result",
	}
	if str(normalized.get("status", "")) != "error":
		_drain_timed_encounter_scans()
	return normalized


func apply_character_rules(party: Array) -> Dictionary:
	if install == null or install.bundle == null:
		return {"status": "error", "message": "Classic campaign runtime is not loaded"}
	return CharacterRulesScript.apply_party(install.bundle, party)


func on_native_time_advanced(
	previous_time: int,
	current_time: int,
	native_location: Dictionary = {}
) -> Dictionary:
	if not is_instance_valid(host) or host.runtime == null:
		return _error("Classic campaign runtime is not loaded")
	if gameplay_rule_set != null and not bool(
		gameplay_rule_set.options("mapTime").get("timedEncounters", true)
	):
		return {
			"status": "ok",
			"queuedDays": 0,
			"dispatched": 0,
			"disabledByGameplayRules": true,
		}
	var defer_dispatch := bool(native_location.get("deferDispatch", false))
	var location := native_location.duplicate(true)
	location.erase("deferDispatch")
	if not location.is_empty():
		var location_result := sync_native_location(location)
		if str(location_result.get("status", "")) == "error":
			return location_result

	var runtime_state: Object = host.runtime.runtime_state
	var queued_days := 0
	if current_time > previous_time:
		for scenario_day: int in timed_encounter_scheduler.crossed_days(
			previous_time,
			current_time
		):
			if runtime_state.enqueue_timed_encounter_day(scenario_day):
				queued_days += 1
	if not defer_dispatch and (
		queued_days > 0 or not runtime_state.pending_timed_encounter_scan().is_empty()
	):
		_drain_timed_encounter_scans()
	return {
		"status": "ok",
		"queuedDays": queued_days,
		"deferred": defer_dispatch,
	}


func _drain_timed_encounter_scans() -> void:
	if _timed_dispatch_loop_active \
			or not is_instance_valid(host) \
			or host.runtime == null \
			or host.active \
			or host.has_restored_continuation():
		return
	_timed_dispatch_loop_active = true
	var runtime_state: Object = host.runtime.runtime_state
	while not runtime_state.pending_timed_encounter_scan().is_empty():
		if host.active or host.has_restored_continuation():
			break
		var pending_scan: Dictionary = runtime_state.pending_timed_encounter_scan()
		var scan_result: Dictionary = timed_encounter_scheduler.scan_day(
			install.bundle,
			runtime_state,
			int(pending_scan.get("day", -1)),
			int(pending_scan.get("nextIndex", 0)),
			Callable(self, "_party_has_timed_item")
		)
		if str(scan_result.get("status", "")) == "error":
			push_error(str(scan_result.get("message", "Classic timed-encounter scan failed")))
			runtime_state.finish_pending_timed_encounter_day()
			continue
		runtime_state.set_pending_timed_encounter_index(
			int(scan_result.get("nextIndex", 0))
		)
		if bool(scan_result.get("complete", false)):
			runtime_state.finish_pending_timed_encounter_day()
			continue

		var dispatch: Dictionary = scan_result.get("dispatch", {})
		var encounter_id := int(dispatch.get("encounterId", -1))
		var trigger_id := str(dispatch.get("triggerId", ""))
		var trigger_result := {}
		if trigger_id.is_empty() or not host.has_trigger(trigger_id):
			trigger_result = _error(
				"Timed encounter %d references missing trigger '%s'" % [
					encounter_id,
					trigger_id,
				]
			)
		else:
			trigger_result = await host.run_trigger(
				trigger_id,
				0,
				{
					"scenarioDay": int(dispatch.get("scenarioDay", -1)),
					"timedEncounterId": encounter_id,
				}
			)
		timed_encounter_dispatched.emit(encounter_id, trigger_id, trigger_result)
		if str(trigger_result.get("status", "")) == "error":
			push_error(str(trigger_result.get(
				"message",
				"Classic timed encounter %d stopped" % encounter_id
			)))
		# Resume after the macro so opcode 54 can alter a later record in this scan.
	_timed_dispatch_loop_active = false


func _party_has_timed_item(item_id: int) -> bool:
	if command_adapter == null or not command_adapter.has_method("classic_party_has_item"):
		return false
	var item_texts: Array = []
	if install != null and install.bundle != null:
		var item_text: Dictionary = install.bundle.get_item_text(item_id)
		if not item_text.is_empty():
			item_texts.append(item_text)
	var result: Variant = command_adapter.call(
		"classic_party_has_item",
		item_id,
		item_texts
	)
	return result is Dictionary \
		and str(result.get("status", "")) != "error" \
		and bool(result.get("possessed", false))


func _on_host_playthrough_finished(_result: Dictionary) -> void:
	if not _timed_dispatch_loop_active:
		call_deferred("_drain_timed_encounter_scans")


func make_save_payload() -> Dictionary:
	var result := make_save_result()
	return result.get("payload", {}) if str(result.get("status", "")) == "ok" else {}


func validate_save_point() -> Dictionary:
	if not is_instance_valid(host) or host.runtime == null:
		return _error("Classic campaign runtime is not loaded")
	if (
		host.active
		and gameplay_rule_set != null
		and not bool(
			gameplay_rule_set.options("persistence").get("continuationSaves", true)
		)
	):
		return _error(
			"The selected gameplay rules require finishing the current scenario action before saving"
		)
	var result: Dictionary = host.make_continuation_snapshot()
	return {"status": "ok"} if str(result.get("status", "")) == "ok" else result


func make_save_result() -> Dictionary:
	if not is_instance_valid(host) or host.runtime == null:
		return _error("Classic campaign runtime is not loaded")
	var runtime_state: Object = host.runtime.runtime_state
	if runtime_state == null or not runtime_state.has_method("snapshot"):
		return _error("Classic campaign runtime state is unavailable")
	var continuation_result: Dictionary = host.make_continuation_snapshot()
	if str(continuation_result.get("status", "")) != "ok":
		return continuation_result
	var port_state: Dictionary = host.snapshot_port_state()
	return {
		"status": "ok",
		"payload": {
			"schemaVersion": SAVE_SCHEMA_VERSION,
			"campaignId": _campaign_id(),
			"runtimeState": runtime_state.call("snapshot"),
			"portState": port_state,
			"continuationState": continuation_result["snapshot"],
			"gameplayRules": gameplay_rule_set.snapshot(),
		},
	}


func restore_save_payload(payload: Dictionary) -> Dictionary:
	var validation := validate_save_payload(payload, _campaign_id())
	if str(validation.get("status", "")) != "ok":
		return validation
	if not is_instance_valid(host) or host.runtime == null:
		return _error("Classic campaign runtime is not loaded")
	var rules_restore := gameplay_rule_registry.restore(payload["gameplayRules"])
	if str(rules_restore.get("status", "")) != "ok":
		return rules_restore
	gameplay_rule_set = rules_restore["ruleset"]
	host.configure(command_adapter, gameplay_rule_set)
	var runtime_state: Object = host.runtime.runtime_state
	var previous_runtime_state: Dictionary = runtime_state.call("snapshot")
	var previous_continuation_result: Dictionary = host.make_continuation_snapshot()
	if str(previous_continuation_result.get("status", "")) != "ok":
		return previous_continuation_result
	var previous_port_state: Dictionary = host.snapshot_port_state()
	runtime_state.call("restore", payload["runtimeState"])
	var port_result: Dictionary = host.restore_port_state(payload.get("portState", {}))
	if str(port_result.get("status", "")) == "error":
		_rollback_restore(
			runtime_state,
			previous_runtime_state,
			previous_port_state,
			previous_continuation_result["snapshot"]
		)
		return port_result
	var continuation_state: Dictionary = payload.get("continuationState", {
		"schemaVersion": RuntimeScript.CONTINUATION_SCHEMA_VERSION,
		"state": "idle",
	})
	var continuation_result: Dictionary = host.restore_continuation(continuation_state)
	if str(continuation_result.get("status", "")) != "ok":
		_rollback_restore(
			runtime_state,
			previous_runtime_state,
			previous_port_state,
			previous_continuation_result["snapshot"]
		)
	return continuation_result


func _rollback_restore(
	runtime_state: Object,
	previous_runtime_state: Dictionary,
	previous_port_state: Dictionary,
	previous_continuation_state: Dictionary
) -> void:
	runtime_state.call("restore", previous_runtime_state)
	host.restore_port_state(previous_port_state)
	host.restore_continuation(previous_continuation_state)


func has_pending_continuation() -> bool:
	return is_instance_valid(host) and host.has_restored_continuation()


func resume_saved_continuation() -> Dictionary:
	if not is_instance_valid(host):
		return _error("Classic campaign runtime is not loaded")
	return host.resume_restored_continuation()


func restore_legacy_native_location(location: Dictionary) -> Dictionary:
	return _error(
		(
			"This save predates scenario runtime v2 and cannot be upgraded; "
			+ "start a new playthrough"
		)
	)


func sync_native_location(location: Dictionary) -> Dictionary:
	if not is_instance_valid(host) or host.runtime == null:
		return _error("Classic campaign runtime is not loaded")
	var map_name := str(location.get("mapName", ""))
	var level_type := ""
	var level_text := ""
	if map_name.begins_with("mapd_"):
		level_type = "dungeon"
		level_text = map_name.trim_prefix("mapd_")
	elif map_name.begins_with("map_"):
		level_type = "land"
		level_text = map_name.trim_prefix("map_")
	if level_type.is_empty() or not level_text.is_valid_int():
		return _error("Older Classic save has an unrecognized map '%s'" % map_name)
	host.runtime.runtime_state.set_location(
		level_type,
		int(level_text),
		int(location.get("x", 0)),
		int(location.get("y", 0))
	)
	return {"status": "ok"}


func acquired_player_map_entries() -> Array:
	if not is_instance_valid(host) or host.runtime == null \
			or install == null or install.bundle == null:
		return []
	var runtime_state: Object = host.runtime.runtime_state
	if runtime_state == null or not runtime_state.has_method("is_map_owned"):
		return []
	var map_ids: Array = install.bundle.player_maps_by_id.keys()
	map_ids.sort()
	var entries: Array = []
	for map_id_value: Variant in map_ids:
		var map_id := int(map_id_value)
		if not runtime_state.call("is_map_owned", map_id):
			continue
		var map_record: Dictionary = install.bundle.get_player_map(map_id)
		if map_record.is_empty():
			continue
		var runtime_path := ""
		if command_adapter != null and command_adapter.has_method("runtime_media_path"):
			runtime_path = str(command_adapter.call("runtime_media_path", map_record, "image/"))
		var current_position := {
			"levelType": str(runtime_state.get("level_type")),
			"levelIndex": int(runtime_state.get("level_index")),
			"x": int(runtime_state.get("x")),
			"y": int(runtime_state.get("y")),
		}
		entries.append({
			"record": map_record.duplicate(true),
			"runtimeMediaPath": runtime_path,
			"nativeMapName": "%s_%d" % [
				"mapd" if bool(map_record.get("isDungeon", false)) else "map",
				int(map_record.get("level", 0)),
			],
			"currentPosition": current_position,
		})
	return entries


static func validate_save_payload(payload: Variant, expected_campaign_id := "") -> Dictionary:
	if payload is Dictionary and payload.is_empty():
		return _error(
			"This save predates scenario runtime v2 and cannot be upgraded; start a new playthrough"
		)
	if not (payload is Dictionary):
		return _error("Classic save data is not a dictionary")
	if not payload.has("schemaVersion"):
		return _error("Classic save data has no schema version")
	var version := int(payload.get("schemaVersion", 0))
	if version != SAVE_SCHEMA_VERSION:
		return _error(
			(
				"Save schema %d is incompatible with scenario runtime v2 schema %d; "
				+ "start a new playthrough"
			) % [
				version,
				SAVE_SCHEMA_VERSION,
			]
		)
	if not expected_campaign_id.is_empty():
		var saved_campaign_id := str(payload.get("campaignId", ""))
		if saved_campaign_id != expected_campaign_id:
			return _error(
				"Classic save belongs to campaign '%s', not '%s'" % [
					saved_campaign_id,
					expected_campaign_id,
				]
			)
	if not (payload.get("runtimeState") is Dictionary):
		return _error("Classic save data has no runtime state")
	if not (payload.get("portState") is Dictionary):
		return _error("Scenario runtime save data has invalid port state")
	var continuation_value: Variant = payload.get("continuationState")
	var continuation_result: Dictionary = RuntimeScript.validate_continuation_snapshot(
		continuation_value
	)
	if str(continuation_result.get("status", "")) != "ok":
		return continuation_result
	if str(continuation_value.get("state", "")) == "suspended" \
			and not (continuation_value.get("commandContext", {}) is Dictionary):
		return _error("Classic continuation has an invalid command context")
	var gameplay_rule_validation := GameplayRuleSetScript.validate_snapshot(
		payload.get("gameplayRules")
	)
	if not bool(gameplay_rule_validation.get("valid", false)):
		return _error(str(gameplay_rule_validation.get(
			"message",
			"Saved gameplay rules are invalid"
		)))
	return {"status": "ok"}


func _campaign_id() -> String:
	if install == null or install.bundle == null:
		return ""
	return str(install.bundle.manifest.get("id", ""))


static func _error(message: String) -> Dictionary:
	return {"status": "error", "message": message}


func clear() -> void:
	_timed_dispatch_loop_active = false
	if is_instance_valid(host):
		host.queue_free()
	host = null
	install = null
	command_adapter = null
	gameplay_rule_registry = null
	gameplay_rule_set = null
