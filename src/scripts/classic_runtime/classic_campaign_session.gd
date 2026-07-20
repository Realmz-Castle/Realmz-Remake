class_name ClassicCampaignSession
extends Node

const InstallScript = preload("res://scripts/classic_runtime/classic_campaign_install.gd")
const HostScript = preload("res://scripts/classic_runtime/classic_runtime_host.gd")
const RuntimeScript = preload("res://scripts/classic_runtime/classic_runtime.gd")
const SAVE_SCHEMA_VERSION := 2

var install: Object
var host: Object
var command_adapter: Object


func load_installed_campaign(
	campaigns_directory: String,
	campaign_name: String,
	command_adapter: Object
) -> Dictionary:
	clear()
	self.command_adapter = command_adapter
	install = InstallScript.new()
	if not install.load_from_campaigns_directory(campaigns_directory, campaign_name):
		return {"status": "error", "message": install.last_error}
	host = HostScript.new()
	add_child(host)
	host.configure(self.command_adapter)
	host.use_campaign(install.bundle)
	return {
		"status": "ok",
		"campaignDirectory": install.campaign_directory,
		"campaignId": str(install.bundle.manifest.get("id", "")),
		"host": host,
	}


func activate_start_location(force_reload := false) -> Dictionary:
	if not is_instance_valid(host):
		return {"status": "error", "message": "Classic campaign runtime is not loaded"}
	var result: Variant = host.activate_start_location(force_reload)
	return result if result is Dictionary else {
		"status": "error",
		"message": "Classic campaign start returned an invalid result",
	}


func make_save_payload() -> Dictionary:
	var result := make_save_result()
	return result.get("payload", {}) if str(result.get("status", "")) == "ok" else {}


func validate_save_point() -> Dictionary:
	if not is_instance_valid(host) or host.runtime == null:
		return _error("Classic campaign runtime is not loaded")
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
	var adapter_state := {}
	if command_adapter != null and command_adapter.has_method("classic_save_state"):
		var saved_adapter_state: Variant = command_adapter.call("classic_save_state")
		if saved_adapter_state is Dictionary:
			adapter_state = saved_adapter_state.duplicate(true)
	return {
		"status": "ok",
		"payload": {
			"schemaVersion": SAVE_SCHEMA_VERSION,
			"campaignId": _campaign_id(),
			"runtimeState": runtime_state.call("snapshot"),
			"adapterState": adapter_state,
			"continuationState": continuation_result["snapshot"],
		},
	}


func restore_save_payload(payload: Dictionary) -> Dictionary:
	var validation := validate_save_payload(payload, _campaign_id())
	if str(validation.get("status", "")) != "ok":
		return validation
	if not is_instance_valid(host) or host.runtime == null:
		return _error("Classic campaign runtime is not loaded")
	var runtime_state: Object = host.runtime.runtime_state
	var previous_runtime_state: Dictionary = runtime_state.call("snapshot")
	var previous_continuation_result: Dictionary = host.make_continuation_snapshot()
	if str(previous_continuation_result.get("status", "")) != "ok":
		return previous_continuation_result
	var previous_adapter_state := {}
	if command_adapter != null and command_adapter.has_method("restore_classic_save_state"):
		if not command_adapter.has_method("classic_save_state"):
			return _error("Classic campaign adapter state cannot be recovered safely")
		var saved_adapter_state: Variant = command_adapter.call("classic_save_state")
		if not (saved_adapter_state is Dictionary):
			return _error("Classic campaign adapter returned invalid recovery state")
		previous_adapter_state = saved_adapter_state.duplicate(true)
	runtime_state.call("restore", payload["runtimeState"])
	if command_adapter != null and command_adapter.has_method("restore_classic_save_state"):
		var adapter_result: Variant = command_adapter.call(
			"restore_classic_save_state",
			payload.get("adapterState", {})
		)
		if not (adapter_result is Dictionary):
			_rollback_restore(
				runtime_state,
				previous_runtime_state,
				previous_adapter_state,
				previous_continuation_result["snapshot"]
			)
			return _error("Classic campaign adapter returned an invalid restore result")
		if str(adapter_result.get("status", "")) == "error":
			_rollback_restore(
				runtime_state,
				previous_runtime_state,
				previous_adapter_state,
				previous_continuation_result["snapshot"]
			)
			return adapter_result
	var continuation_state: Dictionary = payload.get("continuationState", {
		"schemaVersion": RuntimeScript.CONTINUATION_SCHEMA_VERSION,
		"state": "idle",
	})
	var continuation_result: Dictionary = host.restore_continuation(continuation_state)
	if str(continuation_result.get("status", "")) != "ok":
		_rollback_restore(
			runtime_state,
			previous_runtime_state,
			previous_adapter_state,
			previous_continuation_result["snapshot"]
		)
	return continuation_result


func _rollback_restore(
	runtime_state: Object,
	previous_runtime_state: Dictionary,
	previous_adapter_state: Dictionary,
	previous_continuation_state: Dictionary
) -> void:
	runtime_state.call("restore", previous_runtime_state)
	if command_adapter != null and command_adapter.has_method("restore_classic_save_state"):
		command_adapter.call("restore_classic_save_state", previous_adapter_state)
	host.restore_continuation(previous_continuation_state)


func has_pending_continuation() -> bool:
	return is_instance_valid(host) and host.has_restored_continuation()


func resume_saved_continuation() -> Dictionary:
	if not is_instance_valid(host):
		return _error("Classic campaign runtime is not loaded")
	return host.resume_restored_continuation()


func restore_legacy_native_location(location: Dictionary) -> Dictionary:
	var result := sync_native_location(location)
	if str(result.get("status", "")) == "ok":
		result["legacy"] = true
	return result


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
		entries.append({
			"record": map_record.duplicate(true),
			"runtimeMediaPath": runtime_path,
		})
	return entries


static func validate_save_payload(payload: Variant, expected_campaign_id := "") -> Dictionary:
	if payload is Dictionary and payload.is_empty():
		return {"status": "legacy"}
	if not (payload is Dictionary):
		return _error("Classic save data is not a dictionary")
	if not payload.has("schemaVersion"):
		return _error("Classic save data has no schema version")
	var version := int(payload.get("schemaVersion", 0))
	if version > SAVE_SCHEMA_VERSION:
		return _error(
			"Classic save schema %d is newer than this build supports (maximum %d)" % [
				version,
				SAVE_SCHEMA_VERSION,
			]
		)
	if version < 1:
		return _error("Classic save schema %d is not supported" % version)
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
	if not (payload.get("adapterState", {}) is Dictionary):
		return _error("Classic save data has invalid adapter state")
	if version >= 2:
		var continuation_value: Variant = payload.get("continuationState")
		var continuation_result: Dictionary = RuntimeScript.validate_continuation_snapshot(
			continuation_value
		)
		if str(continuation_result.get("status", "")) != "ok":
			return continuation_result
		if str(continuation_value.get("state", "")) == "suspended" \
				and not (continuation_value.get("commandContext", {}) is Dictionary):
			return _error("Classic continuation has an invalid command context")
	return {"status": "ok"}


func _campaign_id() -> String:
	if install == null or install.bundle == null:
		return ""
	return str(install.bundle.manifest.get("id", ""))


static func _error(message: String) -> Dictionary:
	return {"status": "error", "message": message}


func clear() -> void:
	if is_instance_valid(host):
		host.queue_free()
	host = null
	install = null
	command_adapter = null
