class_name ClassicCampaignBundle
extends RefCounted

const FORMAT := "realmz-remake-classic-campaign"
const FORMAT_VERSION := 1
const CAMPAIGN_KIND := "classic-compiled"
const COMPATIBILITY_PROFILE := "realmz-7.1"
const DOCUMENT_SCHEMA_VERSION := 1
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
var monsters_by_id: Dictionary = {}
var simple_encounters_by_id: Dictionary = {}
var complex_encounters_by_id: Dictionary = {}
var thief_encounters_by_id: Dictionary = {}
var timed_encounters_by_id: Dictionary = {}
var maps_by_id: Dictionary = {}
var player_maps_by_id: Dictionary = {}
var random_levels_by_id: Dictionary = {}
var pictures_by_id: Dictionary = {}
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
	var format_version: Variant = manifest.get("formatVersion")
	if not _is_integer(format_version) or int(format_version) != FORMAT_VERSION:
		return _fail(
			"Unsupported classic campaign format version: %s" % manifest.get("formatVersion", "<missing>")
		)
	if not _validate_manifest_contract():
		return false

	var file_map: Variant = manifest.get("files", {})
	for document_name: String in REQUIRED_DOCUMENTS:
		var document_value: Variant = _read_json(
			root_directory.path_join(str(file_map[document_name]))
		)
		if not (document_value is Dictionary):
			return _fail("The '%s' classic document must contain a JSON object" % document_name)
		documents[document_name] = document_value

	if not _validate_document_contract():
		return false
	_build_indexes()
	return true


func _validate_manifest_contract() -> bool:
	if str(manifest.get("campaignKind", "")) != CAMPAIGN_KIND:
		return _fail("campaign.json campaignKind must be '%s'" % CAMPAIGN_KIND)
	if str(manifest.get("compatibilityProfile", "")) != COMPATIBILITY_PROFILE:
		return _fail(
			"Unsupported classic compatibility profile: %s" % \
			manifest.get("compatibilityProfile", "<missing>")
		)
	for field_name: String in ["id", "name"]:
		var identity_value: Variant = manifest.get(field_name)
		if not (identity_value is String) or identity_value.strip_edges().is_empty():
			return _fail("campaign.json is missing the '%s' identity field" % field_name)

	var start: Variant = manifest.get("start", {})
	if not (start is Dictionary):
		return _fail("campaign.json start must be a JSON object")
	if str(start.get("levelType", "")) not in ["land", "dungeon"]:
		return _fail("campaign.json start.levelType must be 'land' or 'dungeon'")
	for field_name: String in ["levelIndex", "x", "y"]:
		if not _is_nonnegative_integer(start.get(field_name)):
			return _fail("campaign.json start.%s must be a non-negative integer" % field_name)

	var file_map: Variant = manifest.get("files", {})
	if not (file_map is Dictionary):
		return _fail("campaign.json files must be a JSON object")
	var seen_paths: Dictionary = {}
	for document_name: String in REQUIRED_DOCUMENTS:
		if not file_map.has(document_name):
			return _fail("campaign.json is missing the '%s' document path" % document_name)
		var path_value: Variant = file_map[document_name]
		if not (path_value is String):
			return _fail("campaign.json files.%s must be a string" % document_name)
		var document_path: String = path_value
		if not _is_safe_document_path(document_path):
			return _fail(
				"campaign.json files.%s must be a campaign-relative JSON path" % document_name
			)
		var normalized_path := document_path.replace("\\", "/")
		var path_key := normalized_path.to_lower()
		if seen_paths.has(path_key):
			return _fail(
				"campaign.json files.%s duplicates the path used by '%s'" % [
					document_name,
					seen_paths[path_key],
				]
			)
		seen_paths[path_key] = document_name
	return true


func _validate_document_contract() -> bool:
	for document_name: String in REQUIRED_DOCUMENTS:
		var document: Variant = documents.get(document_name, {})
		if not (document is Dictionary):
			return _fail("The '%s' classic document must contain a JSON object" % document_name)
		var schema_version: Variant = document.get("schemaVersion")
		if not _is_integer(schema_version) or int(schema_version) != DOCUMENT_SCHEMA_VERSION:
			return _fail(
				"%s.schemaVersion must be %d, got %s" % [
					document_name,
					DOCUMENT_SCHEMA_VERSION,
					document.get("schemaVersion", "<missing>"),
				]
			)

	if not _validate_scenario_identity():
		return false
	for specification: Array in [
		["scripts", "triggers", "id", true],
		["scripts", "extraCodes", "id", false],
		["scripts", "messages", "id", false],
		["scripts", "randomLevels", "id", true],
		["encounters", "battles", "id", false],
		["encounters", "treasures", "id", false],
		["encounters", "shops", "id", false],
		["encounters", "simpleEncounters", "id", false],
		["encounters", "complexEncounters", "id", false],
		["encounters", "thiefEncounters", "id", false],
		["encounters", "timedEncounters", "id", false],
		["content", "monsters", "id", false],
		["content", "scenarioItems", "id", false],
		["content", "itemTexts", "itemId", false],
		["rules", "spellOverrides", "id", false],
		["rules", "raceOverrides", "id", false],
		["rules", "casteOverrides", "id", false],
		["maps", "maps", "id", true],
		["assets", "managedAssets", "id", true],
	]:
		if not _validate_record_collection(
			str(specification[0]),
			str(specification[1]),
			str(specification[2]),
			bool(specification[3])
		):
			return false
	if not _validate_trigger_actions():
		return false
	for collection_name: String in ["simpleEncounters", "complexEncounters"]:
		if not _validate_encounter_actions(collection_name):
			return false
	if documents["maps"].has("mapRecords") and not _validate_record_collection(
		"maps", "mapRecords", "id", false
	):
		return false

	var catalog: Variant = documents["assets"].get("catalog", {})
	if not (catalog is Dictionary):
		return _fail("assets.catalog must be a JSON object")
	for specification: Array in [
		["tilesets", "id", true],
		["pictures", "resourceId", false],
		["icons", "resourceId", false],
		["sounds", "resourceId", false],
	]:
		if not _validate_nested_record_collection(
			"assets.catalog",
			catalog,
			str(specification[0]),
			str(specification[1]),
			bool(specification[2])
		):
			return false
	if not _validate_payload_paths_in_collection("assets", documents["assets"], "managedAssets"):
		return false
	for collection_name: String in ["tilesets", "pictures", "icons", "sounds"]:
		if not _validate_payload_paths_in_collection("assets.catalog", catalog, collection_name):
			return false

	var semantic_decoding: Variant = documents["evidence"].get("semanticDecoding", {})
	if semantic_decoding is Dictionary and semantic_decoding.has("dispatcherNoops"):
		if not _validate_dispatcher_noops(semantic_decoding):
			return false
	return true


func _validate_scenario_identity() -> bool:
	var identity: Variant = documents["scenario"].get("identity", {})
	if not (identity is Dictionary):
		return _fail("scenario.identity must be a JSON object")
	for field_name: String in ["id", "name"]:
		var identity_value: Variant = identity.get(field_name)
		if not (identity_value is String) or identity_value.strip_edges().is_empty():
			return _fail("scenario.identity.%s must not be empty" % field_name)
		if identity_value.strip_edges() != str(manifest[field_name]).strip_edges():
			return _fail(
				"scenario.identity.%s must match campaign.json %s" % [field_name, field_name]
			)
	return true


func _validate_trigger_actions() -> bool:
	var triggers: Variant = documents["scripts"].get("triggers", [])
	if not (triggers is Array):
		return false
	for trigger_index: int in range(triggers.size()):
		var trigger: Dictionary = triggers[trigger_index]
		var trigger_context := "scripts.triggers[%d]" % trigger_index
		if str(trigger.get("source", "")).strip_edges().is_empty():
			return _fail("%s is missing source record context" % trigger_context)
		if not _is_nonnegative_integer(trigger.get("recordIndex")):
			return _fail("%s.recordIndex must be a non-negative integer" % trigger_context)
		if not _validate_action_array(trigger.get("actions"), trigger_context, 7, true):
			return false
	return true


func _validate_encounter_actions(collection_name: String) -> bool:
	var encounters: Variant = documents["encounters"].get(collection_name, [])
	if not (encounters is Array):
		return false
	for encounter_index: int in range(encounters.size()):
		var encounter: Dictionary = encounters[encounter_index]
		var encounter_context := "encounters.%s[%d]" % [collection_name, encounter_index]
		if not _validate_action_array(encounter.get("actions"), encounter_context, 31, false):
			return false
	return true


func _validate_action_array(
	actions_value: Variant,
	record_context: String,
	max_slot: int,
	require_normalized_code: bool
) -> bool:
	if not (actions_value is Array):
		return _fail("%s.actions must be a JSON array" % record_context)
	var actions: Array = actions_value
	var seen_slots: Dictionary = {}
	for action_index: int in range(actions.size()):
		var action: Variant = actions[action_index]
		var action_context := "%s.actions[%d]" % [record_context, action_index]
		if not (action is Dictionary):
			return _fail("%s must be a JSON object" % action_context)
		if not _is_nonnegative_integer(action.get("slot")):
			return _fail("%s.slot must be a non-negative integer" % action_context)
		var slot := int(action["slot"])
		if slot > max_slot:
			return _fail("%s.slot must be between 0 and %d" % [action_context, max_slot])
		if seen_slots.has(slot):
			return _fail("%s duplicates action slot %d" % [action_context, slot])
		seen_slots[slot] = action_index
		for field_name: String in ["rawCode", "id"]:
			if not _is_integer(action.get(field_name)):
				return _fail("%s.%s must be an integer" % [action_context, field_name])
		if require_normalized_code and not _is_integer(action.get("code")):
			return _fail("%s.code must be an integer" % action_context)
	return true


func _validate_record_collection(
	document_name: String,
	collection_name: String,
	identity_field: String,
	string_identity: bool
) -> bool:
	return _validate_nested_record_collection(
		document_name,
		documents[document_name],
		collection_name,
		identity_field,
		string_identity
	)


func _validate_nested_record_collection(
	context: String,
	container: Dictionary,
	collection_name: String,
	identity_field: String,
	string_identity: bool
) -> bool:
	if not container.has(collection_name):
		return true
	var collection: Variant = container.get(collection_name)
	if not (collection is Array):
		return _fail("%s.%s must be a JSON array" % [context, collection_name])
	var seen_identities: Dictionary = {}
	for index: int in range(collection.size()):
		var record: Variant = collection[index]
		var record_context := "%s.%s[%d]" % [context, collection_name, index]
		if not (record is Dictionary):
			return _fail("%s must be a JSON object" % record_context)
		var identity: Variant = record.get(identity_field)
		if string_identity:
			if not (identity is String) or identity.strip_edges().is_empty():
				return _fail("%s is missing stable field '%s'" % [record_context, identity_field])
		else:
			if not _is_nonnegative_integer(identity):
				return _fail(
					"%s.%s must be a non-negative integer" % [record_context, identity_field]
				)
		var identity_key := str(identity)
		if seen_identities.has(identity_key):
			return _fail(
				"%s duplicates %s '%s' from index %d" % [
					record_context,
					identity_field,
					identity_key,
					seen_identities[identity_key],
				]
			)
		seen_identities[identity_key] = index
	return true


func _validate_dispatcher_noops(semantic_decoding: Dictionary) -> bool:
	var rows: Variant = semantic_decoding.get("dispatcherNoops")
	if not (rows is Array):
		return _fail("evidence.semanticDecoding.dispatcherNoops must be a JSON array")
	for index: int in range(rows.size()):
		var row: Variant = rows[index]
		var context := "evidence.semanticDecoding.dispatcherNoops[%d]" % index
		if not (row is Dictionary):
			return _fail("%s must be a JSON object" % context)
		if str(row.get("source", "")).strip_edges().is_empty():
			return _fail("%s is missing source record context" % context)
		for field_name: String in ["recordIndex", "slot"]:
			if not _is_nonnegative_integer(row.get(field_name)):
				return _fail("%s.%s must be a non-negative integer" % [context, field_name])
		if not _is_integer(row.get("rawCode")):
			return _fail("%s.rawCode must be an integer" % context)
	return true


func _validate_payload_paths_in_collection(
	context: String,
	container: Dictionary,
	collection_name: String
) -> bool:
	if not container.has(collection_name):
		return true
	var records: Array = container[collection_name]
	for index: int in range(records.size()):
		var record: Dictionary = records[index]
		if not record.has("payloadPath"):
			continue
		var path_value: Variant = record["payloadPath"]
		if not (path_value is String) or not _is_safe_campaign_path(path_value):
			return _fail(
				"%s.%s[%d].payloadPath must be a campaign-relative path" % [
					context,
					collection_name,
					index,
				]
			)
	return true


func _is_safe_document_path(path: String) -> bool:
	return _is_safe_campaign_path(path) and path.get_extension().to_lower() == "json"


func _is_safe_campaign_path(path: String) -> bool:
	var normalized := path.strip_edges().replace("\\", "/")
	if (
		normalized.is_empty()
		or normalized.ends_with("/")
		or normalized.is_absolute_path()
		or normalized.contains(":")
	):
		return false
	for component: String in normalized.split("/", false):
		if component in [".", ".."]:
			return false
	return true


func _is_nonnegative_integer(value: Variant) -> bool:
	return _is_integer(value) and int(value) >= 0


func _is_integer(value: Variant) -> bool:
	return (value is int or value is float) and is_equal_approx(float(value), float(int(value)))


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


func get_monster(monster_id: int) -> Dictionary:
	return monsters_by_id.get(abs(monster_id), {})


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


func get_timed_encounter(encounter_id: int) -> Dictionary:
	return timed_encounters_by_id.get(encounter_id, {})


func get_map(map_id: String) -> Dictionary:
	return maps_by_id.get(map_id, {})


func get_player_map(map_id: int) -> Dictionary:
	return player_maps_by_id.get(abs(map_id), {})


func get_random_level(level_type: String, level_index: int) -> Dictionary:
	return random_levels_by_id.get("%s:%d:randlevel" % [level_type, level_index], {})


func get_picture(picture_id: int) -> Dictionary:
	return pictures_by_id.get(abs(picture_id), {})


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
	monsters_by_id.clear()
	simple_encounters_by_id.clear()
	complex_encounters_by_id.clear()
	thief_encounters_by_id.clear()
	timed_encounters_by_id.clear()
	maps_by_id.clear()
	player_maps_by_id.clear()
	random_levels_by_id.clear()
	pictures_by_id.clear()
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
	for monster: Variant in _array_value(content_document, "monsters"):
		if monster is Dictionary:
			monsters_by_id[int(monster.get("id", -1))] = monster
	for encounter: Variant in _array_value(encounter_document, "simpleEncounters"):
		if encounter is Dictionary:
			simple_encounters_by_id[int(encounter.get("id", -1))] = encounter
	for encounter: Variant in _array_value(encounter_document, "complexEncounters"):
		if encounter is Dictionary:
			complex_encounters_by_id[int(encounter.get("id", -1))] = encounter
	for encounter: Variant in _array_value(encounter_document, "thiefEncounters"):
		if encounter is Dictionary:
			thief_encounters_by_id[int(encounter.get("id", -1))] = encounter
	for encounter: Variant in _array_value(encounter_document, "timedEncounters"):
		if encounter is Dictionary:
			timed_encounters_by_id[int(encounter.get("id", -1))] = encounter

	var map_document: Dictionary = documents["maps"]
	for map: Variant in _array_value(map_document, "maps"):
		if map is Dictionary:
			maps_by_id[str(map.get("id", ""))] = map
	for map_record: Variant in _array_value(map_document, "mapRecords"):
		if map_record is Dictionary:
			player_maps_by_id[int(map_record.get("id", -1))] = map_record

	var asset_document: Dictionary = documents["assets"]
	var asset_catalog: Variant = asset_document.get("catalog", {})
	if asset_catalog is Dictionary:
		for picture: Variant in _array_value(asset_catalog, "pictures"):
			if picture is Dictionary:
				pictures_by_id[int(picture.get("resourceId", -1))] = picture

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
