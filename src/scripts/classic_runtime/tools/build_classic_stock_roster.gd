extends Node

const CreatureScript = preload("res://Creature/Creature.gd")
const SpellIdentityScript = preload(
	"res://scripts/classic_runtime/classic_spell_identity.gd"
)
const LearnedSpellIdentityScript = preload(
	"res://scripts/classic_runtime/classic_learned_spell_identity.gd"
)
const ROSTER_ROOT := "res://Data/Classic Character Roster"
const MANIFEST_PATH := ROSTER_ROOT + "/manifest.json"

var failures: Array[String] = []


func _ready() -> void:
	call_deferred("_build")


func _build() -> void:
	await get_tree().process_frame
	var resources: CampaignResources = NodeAccess.__Resources()
	if not resources.load_item_resources("res://shared_assets/items/"):
		_fail("Shared item resources could not be loaded.")
	resources.load_spell_resources("res://shared_assets/spells/")
	var manifest_value: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(MANIFEST_PATH)
	)
	if not (manifest_value is Dictionary):
		_fail("The Classic stock-character manifest is invalid.")
		_finish()
		return
	var character_specs: Variant = manifest_value.get("characters", [])
	if not (character_specs is Array):
		_fail("The Classic stock-character manifest has no character list.")
		_finish()
		return
	for spec_value: Variant in character_specs:
		if spec_value is Dictionary:
			_build_character(spec_value, resources)
		else:
			_fail("The Classic stock-character manifest contains a malformed entry.")
	_finish()


func _build_character(
	spec: Dictionary,
	resources: CampaignResources
) -> void:
	var character_name := str(spec.get("name", "")).strip_edges()
	var class_script: GDScript = load(
		"res://Data/Character Classes/Class_%s.gd"
		% str(spec.get("casteName", ""))
	)
	var race_script: GDScript = load(
		"res://Data/Character Races/Race_%s.gd"
		% str(spec.get("raceName", ""))
	)
	var portrait: Texture2D = _load_external_texture(
		"%s/portraits/%d.png" % [
			ROSTER_ROOT,
			int(spec.get("portraitId", 0)),
		]
	)
	var icon: Texture2D = _load_external_texture(
		"%s/combat/%d.png" % [
			ROSTER_ROOT,
			int(spec.get("combatIconId", 0)),
		]
	)
	if class_script == null or race_script == null \
			or portrait == null or icon == null:
		_fail("%s has an unresolved class, race, portrait, or icon." % character_name)
		return
	var data_result := _character_data(spec, resources)
	if str(data_result.get("status", "")) != "ok":
		_fail("%s: %s" % [character_name, data_result.get("message", "")])
		return
	var character := PlayerCharacter.new(
		data_result["data"],
		icon,
		portrait,
		class_script,
		race_script
	)
	var output_directory := (
		ROSTER_ROOT
		.path_join("Characters")
		.path_join(character_name)
	)
	_remove_directory(output_directory)
	var create_error := DirAccess.make_dir_recursive_absolute(output_directory)
	if create_error != OK:
		_fail(
			"%s output directory could not be created: %s"
			% [character_name, error_string(create_error)]
		)
		return
	Utils.FileHandler.save_character(output_directory, character)
	_normalize_saved_text_files(output_directory)
	var source_file := FileAccess.open(
		output_directory.path_join("classic-source.json"),
		FileAccess.WRITE
	)
	if source_file == null:
		_fail("%s source snapshot could not be written." % character_name)
		return
	source_file.store_string(JSON.stringify(spec, "  ", true) + "\n")
	source_file.close()
	print("CLASSIC_STOCK_ROSTER BUILT: %s" % character_name)


func _normalize_saved_text_files(output_directory: String) -> void:
	for file_name: String in ["class.gd", "race.gd", "data.json"]:
		var path := output_directory.path_join(file_name)
		var lines := FileAccess.get_file_as_string(path).split("\n", true)
		for line_index: int in range(lines.size()):
			lines[line_index] = lines[line_index].strip_edges(false, true)
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file == null:
			_fail("Could not normalize generated file %s." % path)
			continue
		file.store_string("\n".join(lines))
		file.close()


func _character_data(
	spec: Dictionary,
	resources: CampaignResources
) -> Dictionary:
	var source_stats: Variant = spec.get("stats", {})
	if not (source_stats is Dictionary):
		return _error("source stats are missing")
	var base_stats: Dictionary = CreatureScript.new().base_stats.duplicate(true)
	base_stats["MaxMovement"] = int(source_stats.get("maximumMovement", 0))
	base_stats["MaxActions"] = (
		1.0
		+ float(source_stats.get("normalHalfAttacks", 0)) / 2.0
	)
	base_stats["MaxSpellsPerRound"] = int(
		source_stats.get("maximumSpellsPerRound", 0)
	)
	base_stats["Strength"] = int(source_stats.get("strength", 0))
	base_stats["Intellect"] = int(source_stats.get("intellect", 0))
	base_stats["Wisdom"] = int(source_stats.get("wisdom", 0))
	base_stats["Dexterity"] = int(source_stats.get("dexterity", 0))
	base_stats["Vitality"] = int(source_stats.get("vitality", 0))
	base_stats["maxHP"] = int(source_stats.get("maximumStamina", 0))
	base_stats["maxSP"] = int(source_stats.get("maximumSpellPoints", 0))
	base_stats["AccuracyMelee"] = (
		float(source_stats.get("toHit", 0)) / 5.0
	)
	base_stats["AccuracyRanged"] = (
		float(source_stats.get("missile", 0)) / 5.0
	)
	base_stats["EvasionMelee"] = (
		float(maxi(0, 2 * (int(source_stats.get("dexterity", 0)) - 14)))
		/ 5.0
	)
	base_stats["EvasionRanged"] = (
		float(source_stats.get("dodge", 0)) / 5.0
	)
	base_stats["Bonus_Physical_dmg"] = int(
		source_stats.get("damageBonus", 0)
	)
	var special_abilities: Array = spec.get("specialAbilities", [])
	for mapping: Array in [
		[4, "Detect_Secret"],
		[5, "Acrobatics"],
		[6, "Detect_Trap"],
		[7, "Disable_Trap"],
		[9, "Force_Lock"],
		[11, "Pick_Lock"],
		[13, "Turn_Undead"],
	]:
		if special_abilities.size() > mapping[0]:
			base_stats[mapping[1]] = special_abilities[mapping[0]]

	var inventory_result := _inventory(
		spec.get("items", []),
		resources,
		str(spec.get("name", "")),
	)
	if str(inventory_result.get("status", "")) != "ok":
		return inventory_result
	var spells_result := _spells(
		spec.get("learnedSpellIds", []),
		resources
	)
	if str(spells_result.get("status", "")) != "ok":
		return spells_result
	var caster_type := int(spec.get("spellcasterType", 0))
	var data := {
		"name": str(spec.get("name", "")),
		"level": int(spec.get("level", 1)),
		"money": spec.get("money", [0, 0, 0]),
		"exp_tnl": int(spec.get("experienceToNextLevel", 0)),
		"curHP": int(source_stats.get("currentStamina", 0)),
		"curSP": int(source_stats.get("currentSpellPoints", 0)),
		"base_stats": base_stats,
		"inventory": inventory_result["inventory"],
		"spells": spells_result["spells"],
		"traits": [],
		"selection_pts": 0,
		"campaign": "Free",
		"classicRaceId": int(spec.get("raceId", 0)),
		"classicCasteId": int(spec.get("casteId", 0)),
		"classicRaceName": str(spec.get("raceName", "")),
		"classicCasteName": str(spec.get("casteName", "")),
		"classicMagicResistance": int(source_stats.get("magicResistance", 0)),
		"classicHandToHand": int(source_stats.get("handToHand", 0)),
		"classicLuck": int(source_stats.get("luck", 0)),
		"classicGender": int(spec.get("gender", 0)),
		"classicAgeYears": int(spec.get("ageDays", 0)) / 365,
		"classicAgeDays": int(spec.get("ageDays", 0)),
		"classicAgeGroup": int(spec.get("ageGroup", 0)),
		"classicAgeMovementAdjustment": 0,
		"classicSavingThrows": spec.get("savingThrows", []),
		"classicConditions": spec.get("conditions", []),
		"classicCanRegenerate": bool(spec.get("canRegenerate", false)),
		"classicCreationResourcesInitialized": true,
		"classicSpecialAbilities": special_abilities,
		"classicSourceCharacter": spec,
	}
	if caster_type > 0:
		data["classicSpellcasterType"] = caster_type
	return {"status": "ok", "data": data}


func _inventory(
	items_value: Variant,
	resources: CampaignResources,
	character_name: String,
) -> Dictionary:
	var inventory: Array = []
	if not (items_value is Array):
		return _error("source inventory is malformed")
	for item_index: int in range(items_value.size()):
		var item_value: Variant = items_value[item_index]
		if not (item_value is Dictionary):
			return _error("source inventory contains a malformed item")
		var item_name := str(item_value.get("name", ""))
		if not resources.items_book.has(item_name):
			return _error("item %s has no native definition" % item_name)
		var item: Dictionary = resources.items_book[item_name].duplicate(true)
		item["instanceId"] = "classic-stock:%s:item:%d" % [
			character_name.uri_encode(),
			item_index,
		]
		item["classicItemId"] = int(item_value.get("id", 0))
		# The manifest and classicSourceCharacter retain the source flag. The
		# bundled roster is starter content, so every carried item is usable
		# immediately without an identification service.
		item["is_identified"] = 1
		item["equipped"] = 2 if bool(
			item_value.get("equipped", false)
		) else 0
		var source_charge := int(item_value.get("charge", -1))
		if source_charge >= 0:
			item["charges"] = source_charge
			item["charges_max"] = maxi(
				source_charge,
				int(item.get("charges_max", 0))
			)
		inventory.append(item)
	return {"status": "ok", "inventory": inventory}


func _spells(
	spell_ids_value: Variant,
	resources: CampaignResources
) -> Dictionary:
	var spell_levels: Array = [[], [], [], [], [], [], []]
	if not (spell_ids_value is Array):
		return _error("learned spell list is malformed")
	for spell_id_value: Variant in spell_ids_value:
		var spell_id := int(spell_id_value)
		var resource_name := SpellIdentityScript.resource_key(
			spell_id,
			SpellsIdDivinity.mappings,
			resources.spells_book
		)
		if resource_name.is_empty():
			return _error(
				"learned spell %d has no exact native resource" % spell_id
			)
		var learned_entry := LearnedSpellIdentityScript.with_explicit_id(
			resources.spells_book[resource_name],
			spell_id,
			resource_name
		)
		var spell_level := int((spell_id % 1000) / 100) - 1
		if spell_level < 0 or spell_level >= spell_levels.size():
			return _error("learned spell %d has an invalid level" % spell_id)
		spell_levels[spell_level].append(learned_entry)
	return {"status": "ok", "spells": spell_levels}


func _load_external_texture(path: String) -> Texture2D:
	var image := Image.new()
	var load_error := image.load(ProjectSettings.globalize_path(path))
	if load_error != OK:
		return null
	return ImageTexture.create_from_image(image)


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


func _fail(message: String) -> void:
	failures.append(message)
	push_error("CLASSIC_STOCK_ROSTER: %s" % message)


func _error(message: String) -> Dictionary:
	return {"status": "error", "message": message}


func _finish() -> void:
	if failures.is_empty():
		print("CLASSIC_STOCK_ROSTER PASS: built all stock characters")
		get_tree().quit(0)
	else:
		print("CLASSIC_STOCK_ROSTER FAIL: %s" % " | ".join(failures))
		get_tree().quit(1)
