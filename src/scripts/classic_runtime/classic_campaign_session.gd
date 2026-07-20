class_name ClassicCampaignSession
extends Node

const InstallScript = preload("res://scripts/classic_runtime/classic_campaign_install.gd")
const HostScript = preload("res://scripts/classic_runtime/classic_runtime_host.gd")
const SAVE_SCHEMA_VERSION := 1

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
	if not is_instance_valid(host) or host.runtime == null:
		return {}
	var runtime_state: Object = host.runtime.runtime_state
	if runtime_state == null or not runtime_state.has_method("snapshot"):
		return {}
	var adapter_state := {}
	if command_adapter != null and command_adapter.has_method("classic_save_state"):
		var saved_adapter_state: Variant = command_adapter.call("classic_save_state")
		if saved_adapter_state is Dictionary:
			adapter_state = saved_adapter_state.duplicate(true)
	return {
		"schemaVersion": SAVE_SCHEMA_VERSION,
		"campaignId": _campaign_id(),
		"runtimeState": runtime_state.call("snapshot"),
		"adapterState": adapter_state,
	}


func restore_save_payload(payload: Dictionary) -> Dictionary:
	var validation := validate_save_payload(payload, _campaign_id())
	if str(validation.get("status", "")) != "ok":
		return validation
	if not is_instance_valid(host) or host.runtime == null:
		return _error("Classic campaign runtime is not loaded")
	var runtime_state: Object = host.runtime.runtime_state
	runtime_state.call("restore", payload["runtimeState"])
	if command_adapter != null and command_adapter.has_method("restore_classic_save_state"):
		var adapter_result: Variant = command_adapter.call(
			"restore_classic_save_state",
			payload.get("adapterState", {})
		)
		if adapter_result is Dictionary and str(adapter_result.get("status", "")) == "error":
			return adapter_result
	return {"status": "ok"}


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
	if version != SAVE_SCHEMA_VERSION:
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
