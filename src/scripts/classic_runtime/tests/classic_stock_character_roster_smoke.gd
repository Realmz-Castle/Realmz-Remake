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
		FileAccess.get_file_as_string(sentinel_path),
		"keep me",
		"an existing same-name character is not overwritten"
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
