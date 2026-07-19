extends SceneTree

const BundleScript = preload("res://scripts/classic_runtime/classic_campaign_bundle.gd")


func _init() -> void:
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() != 1:
		printerr(
			"Usage: godot --headless --path <remake-src> --script " + \
			"res://scripts/classic_runtime/tests/validate_classic_bundle.gd -- <bundle-directory>"
		)
		quit(2)
		return

	var bundle = BundleScript.new()
	if not bundle.load_from_directory(arguments[0]):
		printerr("Classic bundle validation failed: %s" % bundle.last_error)
		quit(1)
		return

	print(
		"Classic bundle valid: %s (%s); %d maps, %d triggers, %d encounters" % [
			bundle.manifest["name"],
			bundle.manifest["id"],
			bundle.maps_by_id.size(),
			bundle.triggers_by_id.size(),
			bundle.simple_encounters_by_id.size() + bundle.complex_encounters_by_id.size(),
		]
	)
	quit(0)
