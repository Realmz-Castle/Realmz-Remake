extends RefCounted


const NativeEncounterRuntimeScript = preload("res://scripts/native_encounters/native_encounter_runtime.gd")
const NATIVE_ENCOUNTER_CONTROLLER_PATH := (
	"res://scripts/native_encounters/native_encounter_controller.gd"
)

var _document: Dictionary = {}


func load_file(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _error("Unable to open native encounter data at %s" % path)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return _error("Native encounter data at %s is not a JSON object" % path)
	var validation: Dictionary = NativeEncounterRuntimeScript.new().validate_document(parsed)
	if validation.get("status") != "ok":
		validation["path"] = path
		return validation
	_document = parsed.duplicate(true)
	return {
		"status": "ok",
		"encounterIds": get_encounter_ids(),
	}


func get_encounter_ids() -> Array:
	if _document.is_empty():
		return []
	var encounter_ids: Array = _document["encounters"].keys()
	encounter_ids.sort()
	return encounter_ids


func create_controller(encounter_id: String, campaign_state: Dictionary) -> Dictionary:
	if _document.is_empty():
		return _error("Native encounter data has not been loaded")
	var runtime := NativeEncounterRuntimeScript.new()
	var configured: Dictionary = runtime.configure(_document, encounter_id, campaign_state)
	if configured.get("status") != "ok":
		return configured
	var controller_script: GDScript = load(NATIVE_ENCOUNTER_CONTROLLER_PATH)
	if controller_script == null:
		return _error("Unable to load the native encounter controller")
	var controller: RefCounted = controller_script.new()
	controller.configure(runtime)
	return {
		"status": "ok",
		"controller": controller,
	}


func _error(message: String) -> Dictionary:
	return {
		"status": "error",
		"message": message,
	}
