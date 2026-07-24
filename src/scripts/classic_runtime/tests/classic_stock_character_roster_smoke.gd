extends Node

const Roster = preload(
	"res://scripts/classic_runtime/classic_stock_character_roster.gd"
)
const ROSTER_ROOT := "res://Data/Classic Character Roster"
const REQUIRED_FILES := [
	"data.json",
	"class.gd",
	"race.gd",
	"icon.png",
	"portrait.png",
	"classic-source.json",
]

var failures: Array[String] = []
var temporary_root := ""


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	await get_tree().process_frame
	var resources: CampaignResources = NodeAccess.__Resources()
	_expect(
		resources.load_item_resources("res://shared_assets/items/"),
		"shared item resources load"
	)
	resources.load_spell_resources("res://shared_assets/spells/")

	var manifest_value: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(
			ROSTER_ROOT.path_join("manifest.json")
		)
	)
	if not (manifest_value is Dictionary):
		_fail("the stock-character manifest parses")
		_finish()
		return
	var specs_value: Variant = manifest_value.get("characters", [])
	if not (specs_value is Array):
		_fail("the stock-character manifest contains a character list")
		_finish()
		return
	var specs: Array = specs_value
	_expect_equal(specs.size(), 7, "the manifest owns all seven stock characters")
	var tristan_spec := _spec_by_name(specs, "Tristan")
	_expect(not tristan_spec.is_empty(), "the manifest includes Tristan")

	temporary_root = "user://classic-stock-roster-smoke-%d" % Time.get_ticks_usec()
	var collision_profile := temporary_root.path_join("collision/Characters")
	var collision_directory := collision_profile.path_join("Tristan")
	_expect_equal(
		DirAccess.make_dir_recursive_absolute(collision_directory),
		OK,
		"the collision fixture directory is created"
	)
	var sentinel_path := collision_directory.path_join("user-character.txt")
	var sentinel := FileAccess.open(sentinel_path, FileAccess.WRITE)
	if sentinel == null:
		_fail("the collision fixture sentinel is created")
	else:
		sentinel.store_string("keep me")
		sentinel.close()
	var collision_result := Roster.ensure_roster(
		ROSTER_ROOT,
		collision_profile
	)
	_expect_equal(
		collision_result.get("status"),
		"ok",
		"the roster installs around an existing same-name character"
	)
	_expect_equal(
		collision_result.get("created", []).size(),
		6,
		"only the six non-colliding characters are installed"
	)
	_expect_equal(
		collision_result.get("existing", []),
		["Tristan"],
		"the existing Tristan directory is reported"
	)
	_expect_equal(
		collision_result.get("repaired", []),
		[],
		"an unrelated same-name character is not treated as stock content"
	)
	_expect_equal(
		FileAccess.get_file_as_string(sentinel_path),
		"keep me",
		"an existing same-name character is not overwritten"
	)

	var legacy_profile := temporary_root.path_join("legacy/Characters")
	var legacy_directory := legacy_profile.path_join("Tristan")
	_expect_equal(
		DirAccess.make_dir_recursive_absolute(legacy_directory),
		OK,
		"the legacy-stock repair fixture directory is created",
	)
	_expect(
		_write_legacy_stock_fixture(
			legacy_directory.path_join("data.json"),
			tristan_spec,
		),
		"the legacy-stock repair fixture is written",
	)
	var legacy_result := Roster.ensure_roster(ROSTER_ROOT, legacy_profile)
	_expect_equal(
		legacy_result.get("repaired", []),
		["Tristan"],
		"an unchanged legacy stock inventory is safely identified",
	)
	var legacy_data: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(legacy_directory.path_join("data.json"))
	)
	_expect(
		legacy_data is Dictionary and _saved_inventory_is_identified(
			legacy_data
		),
		"the legacy stock inventory is fully identified",
	)

	var repair_profile := temporary_root.path_join("repair/Characters")
	var repair_directory := repair_profile.path_join("Tristan")
	_expect_equal(
		DirAccess.make_dir_recursive_absolute(repair_directory),
		OK,
		"the existing-stock repair fixture directory is created"
	)
	for file_name: String in REQUIRED_FILES:
		_expect_equal(
			DirAccess.copy_absolute(
				(
					ROSTER_ROOT
					.path_join("Characters/Tristan")
					.path_join(file_name)
				),
				repair_directory.path_join(file_name),
			),
			OK,
			"the existing-stock repair fixture copies %s" % file_name,
		)
	_expect(
		_mark_first_saved_item_unidentified(
			repair_directory.path_join("data.json")
		),
		"the existing-stock repair fixture simulates an older unidentified item",
	)
	_expect(
		_append_unidentified_fixture_loot(
			repair_directory.path_join("data.json")
		),
		"the existing-stock repair fixture includes later unidentified loot",
	)
	var repair_result := Roster.ensure_roster(ROSTER_ROOT, repair_profile)
	_expect_equal(
		repair_result.get("status"),
		"ok",
		"the roster safely checks an existing stock character"
	)
	_expect_equal(
		repair_result.get("repaired", []),
		["Tristan"],
		"the roster identifies legacy stock inventory on an existing profile"
	)
	var repaired_data: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(repair_directory.path_join("data.json"))
	)
	_expect(
		repaired_data is Dictionary and _saved_stock_inventory_is_identified(
			repaired_data,
			"Tristan",
		),
		"the existing stock character's starter items are all identified",
	)
	_expect_equal(
		_saved_unidentified_count(repaired_data),
		1,
		"the stock repair does not identify loot acquired later",
	)

	var clean_profile := temporary_root.path_join("clean/Characters")
	var first_result := Roster.ensure_roster(ROSTER_ROOT, clean_profile)
	_expect_equal(
		first_result.get("status"),
		"ok",
		"the roster installs into a clean profile"
	)
	_expect_equal(
		first_result.get("created", []).size(),
		7,
		"all seven stock characters install into a clean profile"
	)
	_expect_equal(
		first_result.get("repaired", []),
		[],
		"current stock templates require no identification repair"
	)
	var second_result := Roster.ensure_roster(ROSTER_ROOT, clean_profile)
	_expect_equal(
		second_result.get("created", []).size(),
		0,
		"a repeated install creates no duplicate characters"
	)
	_expect_equal(
		second_result.get("existing", []).size(),
		7,
		"a repeated install recognizes all seven existing characters"
	)
	_expect_equal(
		second_result.get("repaired", []).size(),
		0,
		"a repeated install leaves already-identified stock inventory unchanged"
	)

	for spec_value: Variant in specs:
		if spec_value is Dictionary:
			_verify_character(spec_value, clean_profile)
		else:
			_fail("every manifest character entry is a dictionary")
	_finish()


func _verify_character(spec: Dictionary, clean_profile: String) -> void:
	var character_name := str(spec.get("name", ""))
	var template_directory := (
		ROSTER_ROOT.path_join("Characters").path_join(character_name)
	)
	var installed_directory := clean_profile.path_join(character_name)
	for file_name: String in REQUIRED_FILES:
		_expect(
			FileAccess.file_exists(installed_directory.path_join(file_name)),
			"%s installs %s" % [character_name, file_name]
		)
		if file_name != "data.json":
			_expect_equal(
				FileAccess.get_sha256(installed_directory.path_join(file_name)),
				FileAccess.get_sha256(template_directory.path_join(file_name)),
				"%s installs an exact copy of %s" % [character_name, file_name]
			)

	var source_record_path := (
		ROSTER_ROOT
		.path_join("source-records")
		.path_join(str(spec.get("sourceFile", "")) + ".realmz-character")
	)
	_expect_equal(
		_file_length(source_record_path),
		872,
		"%s retains its exact 872-byte Classic record" % character_name
	)
	_expect_equal(
		FileAccess.get_sha256(source_record_path),
		str(spec.get("sourceSha256", "")),
		"%s source record matches the manifest SHA-256" % character_name
	)

	var data_value: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(
			installed_directory.path_join("data.json")
		)
	)
	if not (data_value is Dictionary):
		_fail("%s has a readable Remake character save" % character_name)
		return
	var data: Dictionary = data_value
	_expect_equal(
		int(data.get("exp_tnl", -1)),
		int(spec.get("experienceToNextLevel", -2)),
		"%s preserves experience remaining to next level" % character_name
	)
	_expect_equal(
		data.get("classicSourceCharacter", {}).get("sourceSha256", ""),
		spec.get("sourceSha256", ""),
		"%s embeds its parsed Classic source snapshot" % character_name
	)
	_expect_equal(
		_source_unidentified_count(
			data.get("classicSourceCharacter", {}).get("items", [])
		),
		_source_unidentified_count(spec.get("items", [])),
		"%s preserves source identification flags as provenance" % character_name,
	)
	_expect(
		_saved_inventory_is_identified(data),
		"%s installs with every carried item identified" % character_name,
	)

	var character: PlayerCharacter = Utils.FileHandler.load_character(
		installed_directory
	)
	if character == null:
		_fail("%s loads through the normal profile character loader" % character_name)
		return
	_expect_equal(character.name, character_name, "%s retains its name" % character_name)
	_expect_equal(
		character.level,
		int(spec.get("level", 0)),
		"%s retains its level" % character_name
	)
	_expect_equal(
		character.exp_tnl,
		int(spec.get("experienceToNextLevel", 0)),
		"%s loads its experience progression" % character_name
	)
	_expect_equal(
		character.classic_race_id,
		int(spec.get("raceId", 0)),
		"%s retains its Classic race ID" % character_name
	)
	_expect_equal(
		character.classic_caste_id,
		int(spec.get("casteId", 0)),
		"%s retains its Classic caste ID" % character_name
	)
	_expect_equal(
		character.classic_saving_throws,
		_int_array(spec.get("savingThrows", [])),
		"%s retains all Classic saving throws" % character_name
	)
	_expect_equal(
		character.classic_conditions,
		_int_array(spec.get("conditions", [])),
		"%s retains all Classic conditions" % character_name
	)
	_expect_equal(
		_inventory_ids(character.inventory),
		_item_ids(spec.get("items", [])),
		"%s resolves inventory by Classic item ID" % character_name
	)
	_expect(
		_runtime_inventory_is_identified(character.inventory),
		"%s loads every carried item as identified" % character_name,
	)
	_expect_equal(
		_spell_ids(character.spells),
		_int_array(spec.get("learnedSpellIds", [])),
		"%s resolves learned spells by Classic spell ID" % character_name
	)
	_expect_image_pixels(
		character.portrait,
		ROSTER_ROOT.path_join(
			"portraits/%d.png" % int(spec.get("portraitId", 0))
		),
		"%s portrait pixels match Classic resource %d"
		% [character_name, int(spec.get("portraitId", 0))]
	)
	_expect_image_pixels(
		character.icon,
		ROSTER_ROOT.path_join(
			"combat/%d.png" % int(spec.get("combatIconId", 0))
		),
		"%s combat pixels match Classic resource %d"
		% [character_name, int(spec.get("combatIconId", 0))]
	)

	var roundtrip_directory := (
		temporary_root.path_join("roundtrip").path_join(character_name)
	)
	DirAccess.make_dir_recursive_absolute(roundtrip_directory)
	Utils.FileHandler.save_character(roundtrip_directory, character)
	var reloaded: PlayerCharacter = Utils.FileHandler.load_character(
		roundtrip_directory
	)
	_expect_equal(
		reloaded.exp_tnl,
		int(spec.get("experienceToNextLevel", 0)),
		"%s preserves progression through a normal save round trip"
		% character_name
	)
	_expect_equal(
		reloaded.classic_source_character.get("sourceSha256", ""),
		spec.get("sourceSha256", ""),
		"%s preserves source provenance through a normal save round trip"
		% character_name
	)
	_expect(
		_runtime_inventory_is_identified(reloaded.inventory),
		"%s preserves item identification through a normal save round trip"
		% character_name,
	)


func _expect_image_pixels(
	texture: Texture2D,
	source_path: String,
	description: String
) -> void:
	var source_image := Image.new()
	var load_error := source_image.load(
		ProjectSettings.globalize_path(source_path)
	)
	if texture == null or load_error != OK:
		_fail(description)
		return
	_expect_equal(
		_pixel_hash(texture.get_image()),
		_pixel_hash(source_image),
		description
	)


func _file_length(path: String) -> int:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return -1
	var length := file.get_length()
	file.close()
	return length


func _pixel_hash(image: Image) -> String:
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(image.get_data())
	return hashing.finish().hex_encode()


func _inventory_ids(inventory: Array[ItemInstance]) -> Array[int]:
	var ids: Array[int] = []
	var resources: CampaignResources = NodeAccess.__Resources()
	for item: ItemInstance in inventory:
		var classic_ids: Array[int] = resources.item_classic_ids(item)
		ids.append(classic_ids[0] if not classic_ids.is_empty() else 0)
	return ids


func _saved_inventory_is_identified(data: Dictionary) -> bool:
	var inventory_value: Variant = data.get("inventory", [])
	if not (inventory_value is Array):
		return false
	for item_value: Variant in inventory_value:
		if not (item_value is Dictionary):
			return false
		var state_value: Variant = item_value.get("state")
		if state_value is Dictionary:
			if not bool(state_value.get("identified", false)):
				return false
		elif int(
			item_value.get(
				"is_identified",
				item_value.get("identified", 0),
			)
		) != 1:
			return false
	return true


func _write_legacy_stock_fixture(path: String, spec: Dictionary) -> bool:
	var source_items_value: Variant = spec.get("items", [])
	if not (source_items_value is Array):
		return false
	var inventory: Array = []
	for source_item_value: Variant in source_items_value:
		if not (source_item_value is Dictionary):
			return false
		inventory.append({
			"classicItemId": int(source_item_value.get("id", 0)),
			"is_identified": 0,
		})
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({
		"classicSourceCharacter": {
			"sourceSha256": str(spec.get("sourceSha256", "")),
		},
		"inventory": inventory,
	}, "\t"))
	file.close()
	return true


func _mark_first_saved_item_unidentified(path: String) -> bool:
	var data_value: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(path)
	)
	if not (data_value is Dictionary):
		return false
	var inventory_value: Variant = data_value.get("inventory", [])
	if not (inventory_value is Array) or inventory_value.is_empty():
		return false
	var item_value: Variant = inventory_value[0]
	if not (item_value is Dictionary):
		return false
	var state_value: Variant = item_value.get("state")
	if not (state_value is Dictionary):
		return false
	state_value["identified"] = false
	item_value["state"] = state_value
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data_value, "\t"))
	file.close()
	return true


func _append_unidentified_fixture_loot(path: String) -> bool:
	var data_value: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(path)
	)
	if not (data_value is Dictionary):
		return false
	var inventory_value: Variant = data_value.get("inventory", [])
	if not (inventory_value is Array) or inventory_value.is_empty():
		return false
	var loot_value: Variant = inventory_value[0].duplicate(true)
	if not (loot_value is Dictionary):
		return false
	loot_value["instanceId"] = "fixture-acquired-loot"
	var state_value: Variant = loot_value.get("state")
	if not (state_value is Dictionary):
		return false
	state_value["identified"] = false
	loot_value["state"] = state_value
	inventory_value.append(loot_value)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data_value, "\t"))
	file.close()
	return true


func _saved_stock_inventory_is_identified(
	data: Dictionary,
	character_name: String,
) -> bool:
	var inventory_value: Variant = data.get("inventory", [])
	if not (inventory_value is Array):
		return false
	var stock_prefix := "classic-stock:%s:item:" % character_name.uri_encode()
	for item_value: Variant in inventory_value:
		if not (item_value is Dictionary):
			return false
		if not str(item_value.get("instanceId", "")).begins_with(stock_prefix):
			continue
		var state_value: Variant = item_value.get("state")
		if not (state_value is Dictionary) \
				or not bool(state_value.get("identified", false)):
			return false
	return true


func _saved_unidentified_count(data: Dictionary) -> int:
	var count := 0
	var inventory_value: Variant = data.get("inventory", [])
	if inventory_value is Array:
		for item_value: Variant in inventory_value:
			if not (item_value is Dictionary):
				continue
			var state_value: Variant = item_value.get("state")
			if state_value is Dictionary \
					and not bool(state_value.get("identified", false)):
				count += 1
	return count


func _spec_by_name(specs: Array, character_name: String) -> Dictionary:
	for spec_value: Variant in specs:
		if spec_value is Dictionary \
				and str(spec_value.get("name", "")) == character_name:
			return spec_value
	return {}


func _runtime_inventory_is_identified(
	inventory: Array[ItemInstance]
) -> bool:
	for item: ItemInstance in inventory:
		if not item.identified:
			return false
	return true


func _source_unidentified_count(items_value: Variant) -> int:
	var count := 0
	if items_value is Array:
		for item_value: Variant in items_value:
			if item_value is Dictionary \
					and not bool(item_value.get("identified", false)):
				count += 1
	return count


func _item_ids(items_value: Variant) -> Array[int]:
	var ids: Array[int] = []
	if items_value is Array:
		for item_value: Variant in items_value:
			if item_value is Dictionary:
				ids.append(int(item_value.get("id", 0)))
	return ids


func _spell_ids(spell_levels: Array) -> Array[int]:
	var ids: Array[int] = []
	for level_value: Variant in spell_levels:
		if level_value is Array:
			for spell_value: Variant in level_value:
				if spell_value is Dictionary:
					ids.append(int(spell_value.get("classicSpellId", 0)))
	return ids


func _int_array(values: Variant) -> Array[int]:
	var result: Array[int] = []
	if values is Array:
		for value: Variant in values:
			result.append(int(value))
	return result


func _expect(value: bool, description: String) -> void:
	if value:
		print("PASS: %s" % description)
		return
	_fail(description)


func _expect_equal(
	actual: Variant,
	expected: Variant,
	description: String
) -> void:
	if actual == expected:
		print("PASS: %s" % description)
		return
	_fail("%s (expected %s, got %s)" % [description, expected, actual])


func _fail(message: String) -> void:
	failures.append(message)
	push_error("CLASSIC_STOCK_CHARACTER_ROSTER: %s" % message)


func _remove_directory(path: String) -> void:
	var directory := DirAccess.open(path)
	if directory == null:
		return
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if entry not in [".", ".."]:
			var entry_path := path.path_join(entry)
			if directory.current_is_dir():
				_remove_directory(entry_path)
			else:
				DirAccess.remove_absolute(entry_path)
		entry = directory.get_next()
	directory.list_dir_end()
	DirAccess.remove_absolute(path)


func _finish() -> void:
	if not temporary_root.is_empty():
		_remove_directory(temporary_root)
	if failures.is_empty():
		print(
			"CLASSIC_STOCK_CHARACTER_ROSTER PASS: "
			+ "seven exact records load, seed safely, and round-trip"
		)
		get_tree().quit(0)
		return
	printerr(
		"CLASSIC_STOCK_CHARACTER_ROSTER FAIL: %s"
		% " | ".join(failures)
	)
	get_tree().quit(1)
