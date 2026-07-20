class_name ClassicCampaignSession
extends Node

const InstallScript = preload("res://scripts/classic_runtime/classic_campaign_install.gd")
const HostScript = preload("res://scripts/classic_runtime/classic_runtime_host.gd")

var install: Object
var host: Object


func load_installed_campaign(
	campaigns_directory: String,
	campaign_name: String,
	command_adapter: Object
) -> Dictionary:
	clear()
	install = InstallScript.new()
	if not install.load_from_campaigns_directory(campaigns_directory, campaign_name):
		return {"status": "error", "message": install.last_error}
	host = HostScript.new()
	add_child(host)
	host.configure(command_adapter)
	host.use_campaign(install.bundle)
	return {
		"status": "ok",
		"campaignDirectory": install.campaign_directory,
		"campaignId": str(install.bundle.manifest.get("id", "")),
		"host": host,
	}


func activate_start_location() -> Dictionary:
	if not is_instance_valid(host):
		return {"status": "error", "message": "Classic campaign runtime is not loaded"}
	var result: Variant = host.activate_start_location()
	return result if result is Dictionary else {
		"status": "error",
		"message": "Classic campaign start returned an invalid result",
	}


func clear() -> void:
	if is_instance_valid(host):
		host.queue_free()
	host = null
	install = null
