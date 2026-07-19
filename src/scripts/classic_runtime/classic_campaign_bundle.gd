class_name ClassicCampaignBundle
extends RefCounted

const FORMAT := "realmz-remake-classic-campaign"
const FORMAT_VERSION := 1
const REQUIRED_DOCUMENTS := [
	"scenario",
	"maps",
	"scripts",
	"encounters",
	"content",
	"rules",
	"assets",
	"evidence",
]

var root_directory := ""
var manifest: Dictionary = {}
var documents: Dictionary = {}
var last_error := ""

var triggers_by_id: Dictionary = {}
var extra_action_points_by_id: Dictionary = {}
var triggers_by_coordinate: Dictionary = {}
var extra_codes_by_id: Dictionary = {}
var messages_by_id: Dictionary = {}
var battles_by_id: Dictionary = {}
var treasures_by_id: Dictionary = {}
var shops_by_id: Dictionary = {}
var item_texts_by_id: Dictionary = {}
var simple_encounters_by_id: Dictionary = {}
var complex_encounters_by_id: Dictionary = {}
var thief_encounters_by_id: Dictionary = {}
var maps_by_id: Dictionary = {}
var player_maps_by_id: Dictionary = {}
var random_levels_by_id: Dictionary = {}
var dispatcher_noop_keys: Dictionary = {}


func load_from_directory(directory: String) -> bool:
	_reset()
	root_directory = directory.trim_suffix("/").trim_suffix("\\")
	var manifest_value: Variant = _read_json(root_directory.path_join("campaign.json"))
	if not (manifest_value is Dictionary):
		return _fail("campaign.json must contain a JSON object")
	manifest = manifest_value
	if str(manifest.get("format", "")) != FORMAT:
		return _fail("Unsupported classic campaign format: %s" % manifest.get("format", "<missing>"))
	if int(manifest.get("formatVersion", 0)) != FORMAT_VERSION:
		return _fail(
			"Unsupported classic campaign format version: %s" % manifest.get("formatVersion", "<missing>")
		)

	var file_map: Variant = manifest.get("files", {})
	if not (file_map is Dictionary):
		return _fail("campaign.json files must be a JSON object")
	for document_name: String in REQUIRED_DOCUMENTS:
		if not file_map.has(document_name):
			return _fail("campaign.json is missing the '%s' document path" % document_name)
		var document_value: Variant = _read_json(
			root_directory.path_join(str(file_map[document_name]))
		)
		if not (document_value is Dictionary):
			return _fail("The '%s' classic document must contain a JSON object" % document_name)
		documents[document_name] = document_value

	_build_indexes()
	return true


func get_trigger(trigger_id: String) -> Dictionary:
	return triggers_by_id.get(trigger_id, {})


func get_extra_action_point(record_id: int) -> Dictionary:
	return extra_action_points_by_id.get(record_id, {})


func get_triggers_at(level_type: String, level_index: int, x: int, y: int) -> Array:
	return triggers_by_coordinate.get(_coordinate_key(level_type, level_index, x, y), []).duplicate()


func get_extra_code(record_id: int) -> Dictionary:
	return extra_codes_by_id.get(record_id, {})


func get_message(message_id: int) -> Dictionary:
	return messages_by_id.get(abs(message_id), {})


func get_battle(battle_id: int) -> Dictionary:
	return battles_by_id.get(abs(battle_id), {})


func get_treasure(treasure_id: int) -> Dictionary:
	return treasures_by_id.get(treasure_id, {})


func get_shop(shop_id: int) -> Dictionary:
	return shops_by_id.get(abs(shop_id), {})


func get_item_text(item_id: int) -> Dictionary:
	return item_texts_by_id.get(abs(item_id), {})


func get_encounter(encounter_kind: String, encounter_id: int) -> Dictionary:
	match encounter_kind:
		"simple":
			return simple_encounters_by_id.get(encounter_id, {})
		"complex":
			return complex_encounters_by_id.get(encounter_id, {})
		_:
			return {}


func get_thief_encounter(encounter_id: int) -> Dictionary:
	return thief_encounters_by_id.get(encounter_id, {})


func get_map(map_id: String) -> Dictionary:
	return maps_by_id.get(map_id, {})


func get_player_map(map_id: int) -> Dictionary:
	return player_maps_by_id.get(abs(map_id), {})


func get_random_level(level_type: String, level_index: int) -> Dictionary:
	return random_levels_by_id.get("%s:%d:randlevel" % [level_type, level_index], {})


func get_random_rectangle(level_type: String, level_index: int, rect_index: int) -> Dictionary:
	var random_level := get_random_level(level_type, level_index)
	var rectangles: Variant = random_level.get("rects", [])
	if not (rectangles is Array):
		return {}
	for rectangle: Variant in rectangles:
		if rectangle is Dictionary and int(rectangle.get("rectIndex", -1)) == rect_index:
			return rectangle
	return {}


func get_start() -> Dictionary:
	var start: Variant = manifest.get("start", {})
	return start if start is Dictionary else {}


func is_dispatcher_noop(trigger: Dictionary, action: Dictionary) -> bool:
	return dispatcher_noop_keys.has(_dispatcher_noop_key(
		str(trigger.get("source", "")),
		int(trigger.get("recordIndex", -1)),
		int(action.get("slot", -1)),
		int(action.get("rawCode", 0))
	))


func _reset() -> void:
	root_directory = ""
	manifest.clear()
	documents.clear()
	last_error = ""
	triggers_by_id.clear()
	extra_action_points_by_id.clear()
	triggers_by_coordinate.clear()
	extra_codes_by_id.clear()
	messages_by_id.clear()
	battles_by_id.clear()
	treasures_by_id.clear()
	shops_by_id.clear()
	item_texts_by_id.clear()
	simple_encounters_by_id.clear()
	complex_encounters_by_id.clear()
	thief_encounters_by_id.clear()
	maps_by_id.clear()
	player_maps_by_id.clear()
	random_levels_by_id.clear()
	dispatcher_noop_keys.clear()


func _build_indexes() -> void:
	var script_document: Dictionary = documents["scripts"]
	for trigger: Variant in _array_value(script_document, "triggers"):
		if not (trigger is Dictionary):
			continue
		var trigger_id := str(trigger.get("id", ""))
		if not trigger_id.is_empty():
			triggers_by_id[trigger_id] = trigger
		if str(trigger.get("source", "")) == "Data ED3":
			extra_action_points_by_id[int(trigger.get("recordIndex", -1))] = trigger
		if not bool(trigger.get("active", false)):
			continue
		var coordinate: Variant = trigger.get("coordinate")
		if not (coordinate is Dictionary):
			continue
		var level_type := str(trigger.get("levelType", ""))
		var level_index := int(trigger.get("levelIndex", -1))
		var key := _coordinate_key(
			level_type,
			level_index,
			int(coordinate.get("x", -1)),
			int(coordinate.get("y", -1))
		)
		if not triggers_by_coordinate.has(key):
			triggers_by_coordinate[key] = []
		triggers_by_coordinate[key].append(trigger)

	for row: Variant in _array_value(script_document, "extraCodes"):
		if row is Dictionary:
			extra_codes_by_id[int(row.get("id", -1))] = row
	for message: Variant in _array_value(script_document, "messages"):
		if message is Dictionary:
			messages_by_id[int(message.get("id", -1))] = message
	for random_level: Variant in _array_value(script_document, "randomLevels"):
		if not (random_level is Dictionary):
			continue
		var random_level_id := str(random_level.get("id", ""))
		if not random_level_id.is_empty():
			random_levels_by_id[random_level_id] = random_level

	var encounter_document: Dictionary = documents["encounters"]
	for battle: Variant in _array_value(encounter_document, "battles"):
		if battle is Dictionary:
			battles_by_id[int(battle.get("id", -1))] = battle
	for treasure: Variant in _array_value(encounter_document, "treasures"):
		if treasure is Dictionary:
			treasures_by_id[int(treasure.get("id", -1))] = treasure
	for shop: Variant in _array_value(encounter_document, "shops"):
		if shop is Dictionary:
			shops_by_id[int(shop.get("id", -1))] = shop

	var content_document: Dictionary = documents["content"]
	for item_text: Variant in _array_value(content_document, "itemTexts"):
		if item_text is Dictionary:
			item_texts_by_id[int(item_text.get("itemId", -1))] = item_text
	for encounter: Variant in _array_value(encounter_document, "simpleEncounters"):
		if encounter is Dictionary:
			simple_encounters_by_id[int(encounter.get("id", -1))] = encounter
	for encounter: Variant in _array_value(encounter_document, "complexEncounters"):
		if encounter is Dictionary:
			complex_encounters_by_id[int(encounter.get("id", -1))] = encounter
	for encounter: Variant in _array_value(encounter_document, "thiefEncounters"):
		if encounter is Dictionary:
			thief_encounters_by_id[int(encounter.get("id", -1))] = encounter

	var map_document: Dictionary = documents["maps"]
	for map: Variant in _array_value(map_document, "maps"):
		if map is Dictionary:
			maps_by_id[str(map.get("id", ""))] = map
	for map_record: Variant in _array_value(map_document, "mapRecords"):
		if map_record is Dictionary:
			player_maps_by_id[int(map_record.get("id", -1))] = map_record

	var evidence_document: Dictionary = documents["evidence"]
	var semantic_decoding: Variant = evidence_document.get("semanticDecoding", {})
	if semantic_decoding is Dictionary:
		for row: Variant in _array_value(semantic_decoding, "dispatcherNoops"):
			if row is Dictionary:
				dispatcher_noop_keys[_dispatcher_noop_key(
					str(row.get("source", "")),
					int(row.get("recordIndex", -1)),
					int(row.get("slot", -1)),
					int(row.get("rawCode", 0))
				)] = true


func _read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		last_error = "Missing classic campaign file: %s" % path
		return null
	var parser := JSON.new()
	var parse_error := parser.parse(FileAccess.get_file_as_string(path))
	if parse_error != OK:
		last_error = "Invalid JSON in %s at line %d: %s" % [
			path,
			parser.get_error_line(),
			parser.get_error_message(),
		]
		return null
	return parser.data


func _array_value(document: Dictionary, key: String) -> Array:
	var value: Variant = document.get(key, [])
	return value if value is Array else []


func _coordinate_key(level_type: String, level_index: int, x: int, y: int) -> String:
	return "%s:%d:%d:%d" % [level_type, level_index, x, y]


func _dispatcher_noop_key(source: String, record_index: int, slot: int, raw_code: int) -> String:
	return "%s:%d:%d:%d" % [source, record_index, slot, raw_code]


func _fail(message: String) -> bool:
	if last_error.is_empty():
		last_error = message
	return false
