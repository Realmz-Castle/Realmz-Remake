"""
Author: Francisco de Biaso Neto
email: kikinhobiaso@gmail.com

#######################
### Resource Module ###
#######################

All resources are loaded and accessed through this module.
"""
extends Node
class_name CampaignResources

const NativeEncounterBookScript = preload(
	"res://scripts/native_encounters/native_encounter_book.gd"
)
const ClassicMagicResistanceScript = preload(
	"res://scripts/classic_runtime/classic_magic_resistance.gd"
)
const ItemCatalogScript = preload("res://scripts/items/item_catalog.gd")
const ItemSerializationScript = preload(
	"res://scripts/items/item_serialization.gd"
)
const ItemHookRuntimeScript = preload(
	"res://scripts/items/item_hook_runtime.gd"
)
const ClassicItemIdsScript = preload("res://scripts/item_id_divinity.gd")
const ClassicItemBehaviorsScript = preload(
	"res://scripts/classic_runtime/classic_item_behaviors.gd"
)
const ClassicSharedAssetStoreScript = preload(
	"res://scripts/classic_runtime/classic_shared_asset_store.gd"
)
const LEGACY_ITEM_IDENTITY_STATE_KEY := "legacyDefinitionIdentity"
const SHARED_SPELL_PATH := "res://shared_assets/spells/"
var g_scripts = {}

var images_book : Dictionary = {}
var tiles_book : Dictionary = {}	#contains data about the tiles used in maps
var items_book : Dictionary = {}	# contains models of standard items.
var item_catalog: ItemCatalog = ItemCatalogScript.new()
var item_serialization: ItemSerialization = ItemSerializationScript.new(
	item_catalog
)
var item_hooks: ItemHookRuntime = ItemHookRuntimeScript.new()
var crea_book: Dictionary = {}	# contains dicts defining creatures for combat.
var battles_book : Dictionary = {}	# contains dicts defining battles.
var creascripts_book : Dictionary = {}	#a  dict of  scriptname:creature ai gdscript
var maps_book : Dictionary = {}	#contains maps
var map_info_book : Dictionary = {}	#contains the source metadata for each map
var thingtypes : Dictionary = {"ground" : 0, "ground_level" : 1, "furnitures" : 2, "creatures" : 3, "structures" : 4}
var sounds_book : Dictionary = {}
var spells_book : Dictionary = {}
var musics_book : Dictionary = {}
var musics_types_book : Dictionary = {}
var special_encounters_book : Dictionary = {}
var _shared_spell_cache: Dictionary = {}
var _shared_spell_paths: Array[String] = []
var _materialized_shared_spell_paths: Dictionary = {}
var _shared_spell_cache_complete := false

# Initialize resources #
func _ready():
	load_music_resources(Paths.datafolderpath+'Music/')
	call_deferred("_request_shared_spell_warmup")


func _request_shared_spell_warmup() -> void:
	if not _shared_spell_paths.is_empty():
		return
	for filename: String in Utils.FileHandler.list_files_in_directory(
		SHARED_SPELL_PATH
	):
		if filename.ends_with(".gd"):
			_shared_spell_paths.append(SHARED_SPELL_PATH + filename)
	_shared_spell_paths.sort()
	call_deferred("_materialize_shared_spell_warmup")


func _materialize_shared_spell_warmup() -> void:
	while not _shared_spell_cache_complete and is_inside_tree():
		for spell_path: String in _shared_spell_paths:
			if _materialized_shared_spell_paths.has(spell_path):
				continue
			_cache_shared_spell_script(spell_path, load(spell_path))
			break
		_shared_spell_cache_complete = (
			_materialized_shared_spell_paths.size()
			== _shared_spell_paths.size()
		)
		if not _shared_spell_cache_complete:
			await get_tree().process_frame

func clear_ressources() -> void:
	tiles_book.clear()
	battles_book.clear()
	crea_book.clear()
	maps_book.clear()
	map_info_book.clear()
	items_book.clear()
	item_catalog.clear()
	item_hooks.clear()
	sounds_book.clear()
	musics_book.clear()
	musics_types_book.clear()
	special_encounters_book.clear()
	spells_book.clear()
	creascripts_book.clear()
#	shopsGD = null
	load_music_resources(Paths.datafolderpath+'Music/')

func load_campaign_ressources( campaign : String = "") ->void :
	print("RESOURCES load_campaign_ressources")
	clear_ressources()
	load_tile_resources("res://shared_assets/tiles/")
	var campaign_root := Paths.campaignsfolderpath.path_join(campaign)
	var tilesetspath: String = campaign_root.path_join("Tilesets")
	if FileAccess.file_exists(campaign_root.path_join("campaign.json")):
		_load_classic_campaign_tile_resources(campaign_root)
	elif DirAccess.dir_exists_absolute(tilesetspath):
		load_tile_resources(tilesetspath)
	load_item_resources("res://shared_assets/items/")
	var itemsetpath : String = Paths.campaignsfolderpath + campaign + "/Items/"
	if DirAccess.dir_exists_absolute(itemsetpath) :
		load_item_resources(itemsetpath)

	load_sound_ressources("res://shared_assets/sounds/")
	var soundsspath : String = Paths.campaignsfolderpath + campaign + "/Sounds/"
	if DirAccess.dir_exists_absolute(soundsspath) :
		load_sound_ressources(soundsspath)

#	print(sounds_book)
	load_music_resources(Paths.datafolderpath+'Music/')
	var musicspath = Paths.campaignsfolderpath + campaign + "/Music/"
	if DirAccess.dir_exists_absolute(musicspath) :
		load_music_resources(musicspath)

	print("Resources B4load spells")

	load_spell_resources("res://shared_assets/spells/")
#	print("\n\n", "spell resources : \n", spells_book.keys() ,"\n\n")

	load_creature_ai_resources("res://shared_assets/CreatureScripts/")

	load_bestiary_resources("res://shared_assets/Bestiary/")
	var bestiarypath = Paths.campaignsfolderpath + campaign + "/Bestiary/"
	if DirAccess.dir_exists_absolute(bestiarypath) :
		load_bestiary_resources(bestiarypath)

	var mapspath : String =  Paths.campaignsfolderpath + campaign + "/Maps/"
	print("RESOURCES load_campaign_ressources mapspath : ", mapspath)
	var mapnames : Array = Utils.FileHandler.list_dirs_in_directory(mapspath)
	var classic_start_map := _classic_start_map_name(campaign)
	if not classic_start_map.is_empty():
		ensure_campaign_map_resource(campaign, classic_start_map)
	else:
		for mn in mapnames :
			load_map_ressources(mapspath + mn + '/', mn)
	_restore_deferred_character_inventories()


func _restore_deferred_character_inventories() -> void:
	var restored_characters := {}
	for characters: Array in [
		GameGlobal.profile_characters_list,
		GameGlobal.player_characters,
		GameGlobal.player_allies,
	]:
		for character: Variant in characters:
			if not (character is Object) \
					or restored_characters.has(character.get_instance_id()) \
					or not character.has_method("restore_deferred_item_inventory"):
				continue
			restored_characters[character.get_instance_id()] = true
			var result: Dictionary = character.restore_deferred_item_inventory()
			if not bool(result.get("ok", false)):
				for message: Variant in result.get("errors", []):
					push_error(str(message))


func ensure_campaign_map_resource(campaign: String, map_name: String) -> bool:
	if maps_book.has(map_name):
		return true
	if (
		map_name.is_empty()
		or map_name in [".", ".."]
		or map_name.contains("/")
		or map_name.contains("\\")
		or map_name.contains(":")
	):
		return false
	var map_directory := (
		Paths.campaignsfolderpath
		+ campaign
		+ "/Maps/"
		+ map_name
		+ "/"
	)
	if not DirAccess.dir_exists_absolute(map_directory):
		return false
	for file_name: String in [
		"map_info.json",
		"map_scriptareas.json",
		"map_things.json",
	]:
		if not FileAccess.file_exists(map_directory + file_name):
			return false
	load_map_ressources(map_directory, map_name)
	return maps_book.has(map_name)


func _classic_start_map_name(campaign: String) -> String:
	var manifest_path := (
		Paths.campaignsfolderpath + campaign + "/campaign.json"
	)
	if not FileAccess.file_exists(manifest_path):
		return ""
	var manifest_result := _read_item_json_object(manifest_path)
	if not bool(manifest_result.get("ok", false)):
		return ""
	var manifest: Dictionary = manifest_result["value"]
	var start: Variant = manifest.get("start", {})
	if not (start is Dictionary):
		return ""
	var level_index := int(start.get("levelIndex", -1))
	if level_index < 0:
		return ""
	match str(start.get("levelType", "")):
		"land":
			return "map_%d" % level_index
		"dungeon":
			return "mapd_%d" % level_index
		_:
			return ""

# Load tiles data, added to the tiles_book ressource dictionary #
func load_tile_resources( path : String ) -> void:
	# load the tile data at the "path" location

	#make a list of the folders inside the directory at paths
	var tileset_folder_names : Array = Utils.FileHandler.list_dirs_in_directory(path)
#	print("resources load_tile_resources tileset_folder_names : ", tileset_folder_names)

	for ts_name in tileset_folder_names :
		var tileset_directory := path.path_join(str(ts_name))
		_load_tile_resource_from_paths(
			str(ts_name),
			tileset_directory.path_join("%s.json" % ts_name),
			tileset_directory.path_join("%s.png" % ts_name),
			tileset_directory.path_join("tile_templates.json")
		)
	print("Done loading tiles from : ", path)
	return


func _load_classic_campaign_tile_resources(campaign_root: String) -> bool:
	var manifest_value: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(campaign_root.path_join("campaign.json"))
	)
	if not (manifest_value is Dictionary):
		push_error("Classic campaign manifest is invalid while loading tiles")
		return false
	var store = ClassicSharedAssetStoreScript.new()
	if not store.load_for_campaign(campaign_root, manifest_value):
		push_error(store.last_error)
		return false
	var names: Dictionary = {}
	var local_tilesets := campaign_root.path_join("Tilesets")
	for local_name: String in Utils.FileHandler.list_dirs_in_directory(local_tilesets):
		names[local_name] = true
	for shared_name: String in store.shared_tileset_names():
		names[shared_name] = true
	var sorted_names: Array = names.keys()
	sorted_names.sort()
	for name_value: Variant in sorted_names:
		var tileset_name := str(name_value)
		var logical_root := "Tilesets/%s" % tileset_name
		if not _load_tile_resource_from_paths(
			tileset_name,
			store.resolve("%s/%s.json" % [logical_root, tileset_name]),
			store.resolve("%s/%s.png" % [logical_root, tileset_name]),
			store.resolve("%s/tile_templates.json" % logical_root)
		):
			return false
	return true


func _load_tile_resource_from_paths(
	ts_name: String,
	definition_path: String,
	texture_atlas_path: String,
	templates_path: String
) -> bool:
	print("resource load tiles : ", ts_name)
	for required_path: String in [
		definition_path,
		texture_atlas_path,
		templates_path,
	]:
		if not FileAccess.file_exists(required_path):
			push_error("Tileset '%s' is missing %s" % [ts_name, required_path])
			return false
	var n_ts_json_data: Dictionary = (
		Utils.FileHandler.read_json_dictionary_from_txt(
			Utils.FileHandler.read_txt_from_file(definition_path)
		)
	)
	var templates_dict: Dictionary = (
		Utils.FileHandler.read_json_dictionary_from_txt(
			Utils.FileHandler.read_txt_from_file(templates_path)
		)
	)
	if n_ts_json_data.is_empty() or templates_dict.is_empty():
		push_error("Tileset '%s' has invalid JSON metadata" % ts_name)
		return false
	var texture_atlas: Image
	if texture_atlas_path.begins_with("res://"):
		texture_atlas = load(texture_atlas_path)
	else:
		texture_atlas = Image.new()
		var image_error := texture_atlas.load(texture_atlas_path)
		if image_error != OK:
			push_error(
				"Tileset '%s' atlas could not be decoded: %s"
				% [ts_name, error_string(image_error)]
			)
			return false
	var atlas_width := int(n_ts_json_data["columns"])
	var tileset_name := str(n_ts_json_data["name"])
	var json_tiles_array: Array = n_ts_json_data["tiles"]
	var n_tileset: Array = []
	for id: int in range(int(n_ts_json_data["tilecount"])):
		var t_dict: Dictionary = json_tiles_array[id]
		var x_pos := id % atlas_width
		var y_pos := floori(float(id) / float(atlas_width))
		var rect := Rect2i(
			x_pos * Utils.GRID_SIZE,
			y_pos * Utils.GRID_SIZE,
			Utils.GRID_SIZE,
			Utils.GRID_SIZE
		)
		var image := texture_atlas.get_region(rect)
		var texture := ImageTexture.create_from_image(image)
		var imgbk_key := tileset_name + str(id)
		images_book[imgbk_key] = {"img": image, "tex": texture}
		var n_tile_dict := {"texture": texture}
		var tile_name := str(t_dict["properties"][0]["value"])
		var tile_template_name := str(t_dict["properties"][1]["value"])
		var expansion: Array = []
		if t_dict["properties"].size() > 2:
			expansion = t_dict["properties"][2]["value"]
		var template_dict: Dictionary = templates_dict[tile_template_name]
		for property: Variant in template_dict:
			n_tile_dict[property] = template_dict[property]
		n_tile_dict["name"] = tile_name
		n_tile_dict["tileset_name"] = ts_name
		n_tile_dict["id"] = id
		n_tile_dict["expansion"] = expansion
		n_tileset.append(n_tile_dict)
	tiles_book["%s.json" % ts_name] = n_tileset
	return true

func load_item_resources(
	path: String,
	campaign_id := "",
	preserve_existing_campaign_definitions := false,
) -> bool:
	# load the item data at the "path" location
	print("Resources.load_item_resources("+path+')')
	var load_from_pack : bool = path.contains("shared_assets")
	if not path.begins_with("res://") and load_from_pack :
		path = "res://"+path
	print("   path changed to : "+path)
	var image_book_path := path + "img_pack.json"
	var item_book_path := path + "stuff_book.json"
	var image_book_result := _read_item_json_object(image_book_path)
	if not bool(image_book_result.get("ok", false)):
		push_error(str(image_book_result.get("error", "Item image book is invalid")))
		return false
	var item_book_result := _read_item_json_object(item_book_path)
	if not bool(item_book_result.get("ok", false)):
		push_error(str(item_book_result.get("error", "Item definition book is invalid")))
		return false
	var n_item_img_pack: Dictionary = image_book_result["value"]
	var n_item_stuff_book: Dictionary = item_book_result["value"]
	if load_from_pack:
		n_item_stuff_book = _shared_item_book_with_classic_ids(
			n_item_stuff_book
		)
	n_item_stuff_book = ClassicItemBehaviorsScript.enrich_item_book(
		n_item_stuff_book
	)
	if not _validate_item_image_book(n_item_img_pack, image_book_path):
		return false
	var source_scope := "shared" if load_from_pack else "campaign"
	if source_scope == "campaign" and campaign_id.strip_edges().is_empty():
		campaign_id = _item_campaign_id(path)
	if source_scope == "campaign" and preserve_existing_campaign_definitions:
		n_item_stuff_book = _without_existing_campaign_item_definitions(
			n_item_stuff_book,
			campaign_id,
		)
	var available_image_keys := {}
	for loaded_image_key: Variant in images_book:
		available_image_keys[loaded_image_key] = true
	for local_image_key: Variant in n_item_img_pack:
		available_image_keys[local_image_key] = true
	if not item_catalog.load_book(
		n_item_stuff_book,
		source_scope,
		campaign_id,
		item_book_path,
		available_image_keys,
	):
		_report_item_catalog_errors()
		return false

	var texture_atlas: Image = Image.new()
	var texture_atlas_path: String = path+"textureAtlas.png"
	if load_from_pack :  #loaded from inside
		print("load_item_resources load_from_pack  :  ", texture_atlas_path)
		texture_atlas = load(texture_atlas_path)
	else :	#loaded from campaign data
		print("load_item_resources not load_from_pack  :  ", texture_atlas_path)
		var atlas_error := texture_atlas.load(texture_atlas_path)
		if atlas_error != OK:
			push_error(
				"%s: could not load item texture atlas: %s"
				% [texture_atlas_path, error_string(atlas_error)]
			)
			return false
	if texture_atlas == null or texture_atlas.is_empty():
		push_error("%s: item texture atlas is empty" % texture_atlas_path)
		return false

	var staged_images := {}
	for image_key: String in n_item_img_pack:
		# Get position inside  texture atlas #
		var rect := Rect2(
			int(n_item_img_pack[image_key]["0_ref_x"]) * 34 + 1,
			int(n_item_img_pack[image_key]["0_ref_y"]) * 34 + 1,
			32,
			32,
		)
		# Create a new texture for this thing #
		var image := texture_atlas.get_region(rect)
		# Loads texture from texture atlas #
		var texture := ImageTexture.create_from_image(image)
		staged_images[image_key] = {"img": image, "tex": texture}
	images_book.merge(staged_images, true)

	var staged_item_book := {}
	for item_key: String in n_item_stuff_book:
		var new_item: Dictionary = generate_item_from_json_dict(
			n_item_stuff_book[item_key]
		)
		new_item["KEY"] = item_key
		staged_item_book[item_key] = new_item
		var definition_id := item_catalog.resolve_catalog_key(
			source_scope,
			campaign_id,
			item_key,
		)
		if definition_id.is_empty() \
				or not item_catalog.bind_legacy_template(definition_id, new_item):
			_report_item_catalog_errors()
			return false
		var definition := item_catalog.get_definition(definition_id)
		if definition != null and not _register_item_custom_spell(definition):
			return false
	items_book.merge(staged_item_book, true)
	return true


func _shared_item_book_with_classic_ids(item_book: Dictionary) -> Dictionary:
	return ClassicItemIdsScript.new().enrich_item_book(item_book)


func _without_existing_campaign_item_definitions(
	item_book: Dictionary,
	campaign_id: String,
) -> Dictionary:
	var additions := {}
	for catalog_key_value: Variant in item_book:
		var catalog_key := str(catalog_key_value)
		if not item_book[catalog_key_value] is Dictionary:
			continue
		if not item_catalog.resolve_catalog_key(
			"campaign",
			campaign_id,
			catalog_key,
		).is_empty():
			continue
		var source: Dictionary = item_book[catalog_key_value]
		var classic_ids: Array[int] = []
		if source.has("classicItemId"):
			classic_ids.append(abs(int(source["classicItemId"])))
		var alias_values: Variant = source.get("classicItemIds", [])
		if alias_values is Array:
			for alias_value: Variant in alias_values:
				var alias_id: int = abs(int(alias_value))
				if alias_id != 0 and not classic_ids.has(alias_id):
					classic_ids.append(alias_id)
		var already_resolved := false
		for item_id: int in classic_ids:
			if item_catalog.resolve_classic_item(campaign_id, item_id) \
					.begins_with("classic:%s:" % campaign_id):
				already_resolved = true
				break
		if not already_resolved:
			additions[catalog_key] = source.duplicate(true)
	return additions


func create_item_instance(
	item_identity: String,
	overrides: Dictionary = {},
) -> ItemInstance:
	var definition_id := item_identity
	if item_catalog.get_definition(definition_id) == null:
		definition_id = item_catalog.resolve_active_catalog_key(item_identity)
	var instance := item_catalog.create_instance(definition_id, overrides)
	if instance == null:
		_report_item_catalog_errors()
	return instance


func ensure_shared_item_catalog_loaded() -> bool:
	if item_catalog.get_definition("shared:Dagger") != null:
		return true
	return load_item_resources("res://shared_assets/items/")


func get_item_definition(instance: ItemInstance) -> ItemDefinition:
	if instance == null:
		return null
	return item_catalog.get_definition(instance.definition_id)


func resolve_classic_item_definition(item_id: int) -> ItemDefinition:
	var definition_id := item_catalog.resolve_classic_item(
		item_catalog.active_campaign_id(),
		item_id,
	)
	return item_catalog.get_definition(definition_id) \
		if not definition_id.is_empty() else null


func create_classic_item_instance(
	item_id: int,
	overrides: Dictionary = {},
) -> ItemInstance:
	var definition := resolve_classic_item_definition(item_id)
	if definition == null:
		push_error(
			"Classic item %d does not resolve through definition metadata"
			% abs(item_id)
		)
		return null
	var resolved_overrides := overrides.duplicate(true)
	var state_data: Dictionary = resolved_overrides.get(
		"stateData",
		{},
	).duplicate(true)
	var legacy_identity: Dictionary = state_data.get(
		LEGACY_ITEM_IDENTITY_STATE_KEY,
		{},
	).duplicate(true)
	legacy_identity["classicItemId"] = abs(item_id)
	state_data[LEGACY_ITEM_IDENTITY_STATE_KEY] = legacy_identity
	resolved_overrides["stateData"] = state_data
	return create_item_instance(definition.definition_id, resolved_overrides)


func item_classic_ids(instance: ItemInstance) -> Array[int]:
	var classic_ids: Array[int] = []
	if instance != null:
		var legacy_identity: Variant = instance.state_value(
			LEGACY_ITEM_IDENTITY_STATE_KEY,
			{},
		)
		if legacy_identity is Dictionary:
			if legacy_identity.has("classicItemId"):
				var primary_id: int = abs(int(legacy_identity["classicItemId"]))
				if primary_id != 0:
					classic_ids.append(primary_id)
			var alias_values: Variant = legacy_identity.get("classicItemIds", [])
			if alias_values is Array:
				for alias_value: Variant in alias_values:
					var alias_id: int = abs(int(alias_value))
					if alias_id != 0 and not classic_ids.has(alias_id):
						classic_ids.append(alias_id)
	var definition := get_item_definition(instance)
	if definition != null:
		for definition_id: int in definition.classic_item_ids():
			if not classic_ids.has(definition_id):
				classic_ids.append(definition_id)
	return classic_ids


func item_has_hook(instance: ItemInstance, hook_kind: String) -> bool:
	var definition := get_item_definition(instance)
	return item_hooks.has_hook(definition, hook_kind)


func run_item_hook(
	instance: ItemInstance,
	hook_kind: String,
	arguments: Array,
	runtime_view: Dictionary = {},
) -> Dictionary:
	var definition := get_item_definition(instance)
	if definition == null:
		return {
			"ok": false,
			"handled": false,
			"value": null,
			"errors": [
				"Item instance %s has no definition" % instance.instance_id
			],
		}
	var view := runtime_view
	if view.is_empty():
		view = legacy_item_view_for_adapter(instance)
	var result := item_hooks.invoke(
		definition,
		instance,
		hook_kind,
		arguments,
		view,
	)
	if bool(result.get("handled", false)) \
			and bool(result.get("ok", false)) \
			and not sync_legacy_item_adapter(instance, view):
		return {
			"ok": false,
			"handled": true,
			"value": result.get("value"),
			"errors": item_serialization.last_errors.duplicate(),
		}
	return result


func item_trait_bindings(
	instance: ItemInstance,
	inflicted := false,
) -> Dictionary:
	return item_hooks.trait_bindings(
		get_item_definition(instance),
		inflicted,
	)


func item_spell_use(instance: ItemInstance, use_kind: String) -> Array:
	var definition := get_item_definition(instance)
	return definition.spell_use(use_kind) if definition != null else []


func item_custom_spell_script(instance: ItemInstance) -> GDScript:
	return item_hooks.custom_spell_script(get_item_definition(instance))


func copy_item_instance(
	instance: ItemInstance,
	overrides: Dictionary = {},
) -> ItemInstance:
	var definition := get_item_definition(instance)
	if definition == null:
		return null
	var copied_overrides := {
		"charges": instance.charges,
		"equipped": instance.equipped,
		"identified": instance.identified,
		"stateData": instance.state_data(),
	}
	copied_overrides.merge(overrides, true)
	return create_item_instance(instance.definition_id, copied_overrides)


func item_texture(instance: ItemInstance) -> Texture2D:
	var definition := get_item_definition(instance)
	if definition == null:
		return null
	var image_value: Variant = images_book.get(definition.image_key, {})
	if image_value is Dictionary:
		var texture_value: Variant = image_value.get("tex")
		if texture_value is Texture2D:
			return texture_value
	# Embedded legacy definitions carry their own media. Keep that reconstruction
	# inside the resource/import boundary rather than exposing a dictionary to UI.
	var runtime_view := legacy_item_view_for_adapter(instance)
	var embedded_texture: Variant = runtime_view.get("texture")
	return embedded_texture if embedded_texture is Texture2D else null


func item_trait_display_names(instance: ItemInstance) -> Array[String]:
	var definition := get_item_definition(instance)
	if definition == null:
		return []
	var result: Array[String] = []
	var resolved := item_trait_bindings(instance)
	if not bool(resolved.get("ok", false)):
		return result
	for binding_value: Variant in resolved.get("bindings", []):
		if not (binding_value is Dictionary):
			continue
		var binding: Dictionary = binding_value
		var trait_name := str(binding.get("name", ""))
		var script_value: Variant = binding.get("script")
		var menu_name: Variant = script_value.get("menuname") \
			if script_value is Object else null
		if menu_name != null and not str(menu_name).is_empty():
			result.append(str(menu_name))
			continue
		result.append(trait_name.get_file().trim_suffix(".gd"))
	return result


func import_item_instance(item_value: Variant) -> ItemInstance:
	var imported := item_instance_from_runtime_value(item_value)
	if not bool(imported.get("ok", false)):
		for message: Variant in imported.get("errors", []):
			push_error(str(message))
		return null
	return imported.get("instance")


func generate_item_from_catalog(
	catalog_key: String,
	overrides: Dictionary = {},
) -> Dictionary:
	var item := item_catalog.create_legacy_item_for_catalog_key(catalog_key, overrides)
	if item.is_empty():
		_report_item_catalog_errors()
	return item


func serialize_item_inventory(instances: Array) -> Dictionary:
	return item_serialization.serialize_inventory(instances)


func deserialize_item_inventory(saved_inventory: Array) -> Dictionary:
	return _deserialize_item_inventory(saved_inventory, false)


func deserialize_item_inventory_preserving_unresolved(
	saved_inventory: Array
) -> Dictionary:
	return _deserialize_item_inventory(saved_inventory, true)


func _deserialize_item_inventory(
	saved_inventory: Array,
	defer_unresolved: bool,
) -> Dictionary:
	var imported := item_serialization.import_inventory(
		saved_inventory,
		item_catalog.active_campaign_id(),
		defer_unresolved,
	)
	if not bool(imported.get("ok", false)):
		return imported
	return {
		"ok": true,
		"instances": imported.get("instances", []),
		"deferred": imported.get("deferred", []),
		"diagnostics": imported.get("diagnostics", []),
		"errors": [],
	}


# Old campaign scripts and pre-v1 saves may still submit a dictionary here.
# Stable runtime code should construct and carry ItemInstance values directly.
func serialize_runtime_item_inventory(runtime_inventory: Array) -> Dictionary:
	var domain_values: Array = []
	for index: int in runtime_inventory.size():
		var item_value: Variant = runtime_inventory[index]
		if item_value is ItemInstance:
			domain_values.append(item_value)
			continue
		if not (item_value is Dictionary):
			return {
				"ok": false,
				"errors": [
					"inventory[%d]: runtime item must be an ItemInstance or dictionary"
					% index
				],
			}
		var item: Dictionary = item_value
		var instance_value: Variant = item.get("_item_instance")
		if instance_value is ItemInstance:
			if not item_serialization.sync_instance_from_legacy_view(
				instance_value,
				item,
			):
				return {
					"ok": false,
					"errors": item_serialization.last_errors.duplicate(),
					"diagnostics": item_serialization.last_diagnostics.duplicate(),
				}
			domain_values.append(instance_value)
		else:
			domain_values.append(item)
	var imported := item_serialization.import_inventory(
		domain_values,
		item_catalog.active_campaign_id(),
	)
	if not bool(imported.get("ok", false)):
		return imported
	var instances: Array = imported.get("instances", [])
	var serialized := item_serialization.serialize_inventory(instances)
	if not bool(serialized.get("ok", false)):
		return serialized
	for index: int in runtime_inventory.size():
		var item_value: Variant = runtime_inventory[index]
		if not (item_value is Dictionary):
			continue
		var item: Dictionary = item_value
		var instance: ItemInstance = instances[index]
		_attach_item_instance(item, instance)
	serialized["diagnostics"] = imported.get("diagnostics", [])
	return serialized


func item_instance_from_runtime_value(item_value: Variant) -> Dictionary:
	if item_value is ItemInstance:
		var existing_instance: ItemInstance = item_value
		var existing_view := legacy_item_view_for_adapter(existing_instance)
		if existing_view.is_empty():
			return {
				"ok": false,
				"errors": item_serialization.last_errors.duplicate(),
			}
		return {
			"ok": true,
			"instance": existing_instance,
			"item": existing_view,
			"errors": [],
			"diagnostics": [],
		}
	if not (item_value is Dictionary):
		return {
			"ok": false,
			"errors": ["item: runtime value must be an ItemInstance or dictionary"],
		}
	var runtime_item: Dictionary = item_value
	var attached_value: Variant = runtime_item.get("_item_instance")
	if attached_value is ItemInstance:
		var attached_instance: ItemInstance = attached_value
		if not item_serialization.sync_instance_from_legacy_view(
			attached_instance,
			runtime_item,
		):
			return {
				"ok": false,
				"errors": item_serialization.last_errors.duplicate(),
				"diagnostics": item_serialization.last_diagnostics.duplicate(),
			}
		_attach_item_instance(runtime_item, attached_instance)
		return {
			"ok": true,
			"instance": attached_instance,
			"item": runtime_item,
			"errors": [],
			"diagnostics": item_serialization.last_diagnostics.duplicate(),
		}
	var imported := item_serialization.import_item(
		runtime_item,
		item_catalog.active_campaign_id(),
	)
	if not bool(imported.get("ok", false)):
		return imported
	var instance: ItemInstance = imported.get("instance")
	var view: Dictionary = imported.get("legacyView", {})
	var hydrated_view := runtime_item \
		if runtime_item.has("texture") else _hydrate_runtime_item_view(view)
	_attach_item_instance(hydrated_view, instance)
	return {
		"ok": true,
		"instance": instance,
		"item": hydrated_view,
		"errors": [],
		"diagnostics": imported.get("diagnostics", []),
	}


func legacy_item_view_for_adapter(instance: ItemInstance) -> Dictionary:
	if instance == null:
		return {}
	var view := item_serialization.legacy_view(instance)
	if view.is_empty():
		return {}
	var runtime_item := _hydrate_runtime_item_view(view)
	_attach_item_instance(runtime_item, instance)
	return runtime_item


func sync_legacy_item_adapter(
	instance: ItemInstance,
	runtime_item: Dictionary,
) -> bool:
	return item_serialization.sync_instance_from_legacy_view(
		instance,
		runtime_item,
	)


# Deprecated compatibility spellings retained for old campaign scripts only.
func runtime_item_view(instance: ItemInstance) -> Dictionary:
	return legacy_item_view_for_adapter(instance)


func sync_runtime_item_instance(
	instance: ItemInstance,
	runtime_item: Dictionary,
) -> bool:
	return sync_legacy_item_adapter(instance, runtime_item)


func deserialize_runtime_item_inventory(saved_inventory: Array) -> Dictionary:
	var imported := item_serialization.import_inventory(
		saved_inventory,
		item_catalog.active_campaign_id(),
	)
	if not bool(imported.get("ok", false)):
		return imported
	var instances: Array = imported.get("instances", [])
	var views: Array = imported.get("legacyViews", [])
	var runtime_items: Array[Dictionary] = []
	for index: int in views.size():
		var view: Dictionary = views[index]
		var runtime_item := _hydrate_runtime_item_view(view)
		var instance: ItemInstance = instances[index]
		_attach_item_instance(runtime_item, instance)
		runtime_items.append(runtime_item)
	return {
		"ok": true,
		"items": runtime_items,
		"instances": instances,
		"diagnostics": imported.get("diagnostics", []),
		"errors": [],
	}


func _hydrate_runtime_item_view(view: Dictionary) -> Dictionary:
	var runtime_item := view.duplicate(true)
	if not runtime_item.has("texture"):
		runtime_item = generate_item_from_json_dict(view)
	return runtime_item


func _attach_item_instance(
	runtime_item: Dictionary,
	instance: ItemInstance,
) -> void:
	runtime_item["definitionId"] = instance.definition_id
	runtime_item["instanceId"] = instance.instance_id
	runtime_item["stateData"] = instance.state_data()
	runtime_item["charges"] = instance.charges
	runtime_item["equipped"] = 1 if instance.equipped else 0
	runtime_item["is_identified"] = 1 if instance.identified else 0
	runtime_item["_item_instance"] = instance


func _read_item_json_object(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		return {
			"ok": false,
			"error": "%s: file does not exist" % file_path,
		}
	var parser := JSON.new()
	var parse_error := parser.parse(FileAccess.get_file_as_string(file_path))
	if parse_error != OK:
		return {
			"ok": false,
			"error": "%s:%d: %s" % [
				file_path,
				parser.get_error_line(),
				parser.get_error_message(),
			],
		}
	if not (parser.data is Dictionary):
		return {
			"ok": false,
			"error": "%s: root value must be a JSON object" % file_path,
		}
	return {"ok": true, "value": parser.data}


func _validate_item_image_book(image_book: Dictionary, source_path: String) -> bool:
	for image_key_value: Variant in image_book:
		var image_key := str(image_key_value)
		var image_value: Variant = image_book[image_key_value]
		if not (image_value is Dictionary):
			push_error("%s[%s]: image entry must be an object" % [source_path, image_key])
			return false
		for coordinate_name: String in ["0_ref_x", "0_ref_y"]:
			if not image_value.has(coordinate_name) \
					or not _item_value_is_integer(image_value[coordinate_name]):
				push_error(
					"%s[%s].%s: must be an integer"
					% [source_path, image_key, coordinate_name]
				)
				return false
	return true


func _item_campaign_id(item_directory: String) -> String:
	var campaign_directory := item_directory.trim_suffix("/").get_base_dir()
	var manifest_path := campaign_directory.path_join("campaign.json")
	if FileAccess.file_exists(manifest_path):
		var manifest_result := _read_item_json_object(manifest_path)
		if bool(manifest_result.get("ok", false)):
			var manifest: Dictionary = manifest_result["value"]
			var manifest_id := str(manifest.get("id", "")).strip_edges()
			if not manifest_id.is_empty():
				return manifest_id
	var folder_name := campaign_directory.get_file().strip_edges().to_lower()
	var slug := ""
	var pending_separator := false
	for index: int in folder_name.length():
		var character := folder_name.substr(index, 1)
		if character.to_ascii_buffer()[0] in range(97, 123) \
				or character.to_ascii_buffer()[0] in range(48, 58):
			if pending_separator and not slug.is_empty():
				slug += "-"
			slug += character
			pending_separator = false
		else:
			pending_separator = true
	if slug.is_empty():
		slug = "campaign"
	return "scenario-%s" % slug


func _report_item_catalog_errors() -> void:
	for message: String in item_catalog.last_errors:
		push_error(message)


func _register_item_custom_spell(definition: ItemDefinition) -> bool:
	var sources: Dictionary = definition.hooks().get("sources", {})
	if not sources.has("custom_spell_source"):
		return true
	var script := item_hooks.custom_spell_script(definition)
	if script == null:
		for message: String in item_hooks.last_errors:
			push_error(message)
		return false
	var spell_name := script.get_global_name()
	if spell_name.is_empty():
		var spell_instance: Variant = script.new()
		if spell_instance is Object:
			var instance_name: Variant = spell_instance.get("name")
			if instance_name != null:
				spell_name = str(instance_name)
	if spell_name.is_empty():
		push_error(
			"Item definition %s custom spell has no stable name"
			% definition.definition_id
		)
		return false
	spells_book[spell_name] = {
		"name": spell_name,
		"source": str(sources["custom_spell_source"]),
		"script": script,
		"itemDefinitionId": definition.definition_id,
	}
	return true


static func _item_value_is_integer(value: Variant) -> bool:
	if value is int:
		return true
	if value is float:
		return is_equal_approx(value, float(int(value)))
	return false


func load_bestiary_resources( path : String ) -> void:
	var creatureGD : GDScript = preload("res://Creature/Creature.gd")
	var crea_template = creatureGD.new()

	var n_crea_img_pack : Dictionary = {}
	n_crea_img_pack = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path + "img_pack.json"))
	var texture_atlas_path : String = path+"textureAtlas.png"
	var texture_atlas : Image
	if (texture_atlas_path.begins_with("res://")) :
		texture_atlas = load(texture_atlas_path)
	else :
		texture_atlas = Image.new()
		var _err = texture_atlas.load(texture_atlas_path)

	#load images to images_book
	for i in n_crea_img_pack :
		var size_txt : String = n_crea_img_pack[i]["size"]
		var size : Vector2 = Vector2.ZERO
		match size_txt :
			"32x32" :
				size = Vector2(32,32)
			"32x64" :
				size = Vector2(32,64)
			"64x32" :
				size = Vector2(64,32)
			"64x64" :
				size = Vector2(64,64)
		# Get position inside  texture atlas #
		var rect = Rect2(32*n_crea_img_pack[i]["0_ref_x"], 32*n_crea_img_pack[i]["0_ref_y"], size.x, size.y)
		# Create a new texture for this thing #

#		print(" RESOURCE RECT : ", rect)

		var image = texture_atlas.get_region(rect)
		# Loads texture from texture atlas #
		var texture = ImageTexture.create_from_image(image) #,0
		images_book[i] = {}
		images_book[i]["img"] = image
		images_book[i]["tex"] = texture

	var n_crea_stuff_book : Dictionary = {}
	n_crea_stuff_book = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path +"stuff_book.json"))
	#load creature data
	for crea_name in n_crea_stuff_book :
		var new_crea_data : Dictionary = { "stats" : crea_template.stats.duplicate() , "tools" : {} }
		var ncreastatmods : Dictionary = n_crea_stuff_book[crea_name]["stats"]

		if ncreastatmods.has("traits") :
			n_crea_stuff_book[crea_name]["traits"] = ncreastatmods["traits"]
			ncreastatmods.erase("traits")

		for s in ncreastatmods :
			#printerr("Resources load _bestiary l268 : "+crea_name+"ncreastatmods :\n", ncreastatmods)
			#assert( s!="traits")

			new_crea_data["stats"][s] = ncreastatmods[s]
		if n_crea_stuff_book[crea_name].has("traits") :
			#print("RESOURCELOADER n_crea_stuff_book[crea_name][traits] : "+crea_name+" : ", n_crea_stuff_book[crea_name]["traits"])
			new_crea_data["traits"] = n_crea_stuff_book[crea_name]["traits"]
		new_crea_data["data"] = n_crea_stuff_book[crea_name] ["data"]
		new_crea_data["data"]["image"] = images_book[ new_crea_data["data"]["image"] ]["tex"]
		if n_crea_stuff_book[crea_name].has("classicMonsterId") :
			new_crea_data["classicMonsterId"] = int(
				n_crea_stuff_book[crea_name]["classicMonsterId"]
			)
		if (
			n_crea_stuff_book[crea_name].has("classicMonsterIds")
			and n_crea_stuff_book[crea_name]["classicMonsterIds"] is Array
		) :
			new_crea_data["classicMonsterIds"] = \
				n_crea_stuff_book[crea_name]["classicMonsterIds"].duplicate()
		for classic_field : String in [
			"classicMonsterNameId",
			"classicDeathMacro",
			"classicTurnUndeadEligible",
			"classicHitDice",
			"classicMagicResistance",
			"classicRegenerationPerRound",
			"classicSpellScreenLevel",
			"classicCanSummon",
			"classicRunPercent",
			"classicSurrenderPercent",
			"classicWeaponItemId",
			"classicMissileItemName",
			"classicMissileItemSlot",
			"classicRequiredWeaponKind",
			"classicRequiredWeaponItemId",
			"classicRequiredWeaponName",
			"classicRequiredMagicPlus",
		] :
			if n_crea_stuff_book[crea_name].has(classic_field) :
				new_crea_data[classic_field] = n_crea_stuff_book[crea_name][classic_field]
		for classic_field : String in ["classicSpellSaves", "classicSpellImmunities"] :
			if n_crea_stuff_book[crea_name].has(classic_field) :
				new_crea_data[classic_field] = \
					n_crea_stuff_book[crea_name][classic_field].duplicate()
		for classic_field : String in ["classicRecord", "classicMaterialization"] :
			if n_crea_stuff_book[crea_name].has(classic_field) :
				new_crea_data[classic_field] = \
					n_crea_stuff_book[crea_name][classic_field].duplicate(true)
		new_crea_data["tools"] = n_crea_stuff_book[crea_name]["tools"]
		new_crea_data["ai"] = n_crea_stuff_book[crea_name]["ai"]
		if n_crea_stuff_book[crea_name].has("scripts"):
			new_crea_data["scripts"] = n_crea_stuff_book[crea_name]["scripts"]
		else :
			new_crea_data["scripts"] = {"default" : "test_crea_script.gd"}
		n_crea_stuff_book[crea_name] = new_crea_data
	#add to crea book
	for crea_name in n_crea_stuff_book :
		crea_book[crea_name] = n_crea_stuff_book[crea_name]
	#if n_crea_stuff_book.has("Vodalian") :
		#printerr("Resources load _bestiary l285 : n_crea_stuff_book['Vodalian'] :\n", n_crea_stuff_book["Vodalian"])
		#pass

func generate_item_from_json_dict(json_dict : Dictionary) -> Dictionary :
	# sets  item's sound image etc from its dict data
	# need to load sounds first !
	var canonical_item: Dictionary = items_book.get(
		str(json_dict.get("name", "")), {}
	)
	json_dict = ClassicMagicResistanceScript.normalize_item_data(
		json_dict, canonical_item
	)

#	print("generate_item_from_json_dict, has imgdata ? ",json_dict["name"],' ',json_dict.has("imgdata"))

	var new_item : Dictionary = {}
	if not json_dict.has("imgdata"):
#		print("RESOURCE generate_item_from_json_dict ITEM HAS NO imgdata ! "+json_dict["name"])
		# item comes from a  stuffbook... get the image from imagebook
		# Get img ref #
		var img_ref = json_dict["img_ptr"]
		# find texture in images_book :
		var texture = images_book[img_ref]["tex"]
		# assign texture
		new_item["texture"] = texture
		var image : Image = images_book[img_ref]["img"]

		var imgdata : PackedByteArray = image.save_png_to_buffer()
		var imgdatasize : int = imgdata.size()
		var imgdatacompressed : PackedByteArray = imgdata.compress(FileAccess.COMPRESSION_GZIP)
		# use  imgdatacompressed.decompress(imgdatasize, File.COMPRESSION_GZIP)  to decompress
		# now i need to turn this into a string
		new_item["imgdatasize"] = imgdatasize
#		new_item["name"] = "lol"
		new_item["imgdata"]  = Marshalls.raw_to_base64(imgdatacompressed)
		# use Marshalls.base64_to_raw(new_item["imgdata"]) to recover  the compressed image data
		#</new>
	else :
		if json_dict["imgdatasize"] >0 :
			var texture = Utils.load_texture_as_string(json_dict["imgdata"], json_dict["imgdatasize"])
			new_item["texture"] = texture
			new_item["imgdata"] = json_dict["imgdata"]
			new_item["imgdatasize"] = json_dict["imgdatasize"]

	new_item["name"] = json_dict["name"]
	new_item["type"] = json_dict["type"]
	new_item["sound"] = json_dict["sound"]
	if json_dict.has("classicItemId") :
		new_item["classicItemId"] = int(json_dict["classicItemId"])
	if json_dict.has("classicItemIds") and json_dict["classicItemIds"] is Array :
		new_item["classicItemIds"] = json_dict["classicItemIds"].duplicate()
	if json_dict.has("classicItemCategory") :
		new_item["classicItemCategory"] = int(json_dict["classicItemCategory"])
	if json_dict.has("classicMagicResistance") :
		new_item["classicMagicResistance"] = int(json_dict["classicMagicResistance"])

	if json_dict.has("unique") :
		new_item["unique"] = json_dict["unique"]
	else :
		new_item["is_unique"] = 0

	if json_dict.has("is_magical") :
		new_item["is_magical"] = json_dict["is_magical"]
	else :
		new_item["is_magical"] = 0

	if json_dict.has("unidentified_name") :
		new_item["unidentified_name"] = json_dict["unidentified_name"]
		if not json_dict.has("is_identified") :
			new_item["is_identified"] = 0
	else :
		new_item["unidentified_name"] = json_dict["name"]
		new_item["is_identified"] = 1
	if json_dict.has("is_identified") :
		new_item["is_identified"] = json_dict["is_identified"]

	if json_dict.has("is_magical") :
		new_item["is_magical"] = json_dict["is_magical"]
	else :
		new_item["is_magical"] = 0

	if json_dict.has("hands") :
		new_item["hands"] = json_dict["hands"]
	else :
		new_item["hands"] = 0

	if json_dict.has("unique") :
		new_item["unique"] = json_dict["unique"]
	else :
		new_item["unique"] = 0

	if json_dict.has("description") :
		new_item["description"] = json_dict["description"]
	else :
		new_item["description"] = ''

	if json_dict.has("delete_on_empty") :
		new_item["delete_on_empty"] = json_dict["delete_on_empty"]
	else :
		new_item["delete_on_empty"] = 0

	if json_dict.has("slots") :
		new_item["slots"] = json_dict["slots"]
	else :
		new_item["slots"] = []

	if json_dict.has("equippable") :
		new_item["equippable"] = json_dict["equippable"]
	else :
		new_item["equippable"] = 0
	if json_dict.has("equipped") :
		new_item["equipped"] = json_dict["equipped"]
	else :
		new_item["equipped"] = 0
	if json_dict.has("drops_on_defeat") :
		new_item["drops_on_defeat"] = bool(json_dict["drops_on_defeat"])

	if json_dict.has("only_usable_by_classes") :
		new_item["only_usable_by_classes"] = json_dict["only_usable_by_classes"]
	if json_dict.has("not_usable_by_classes") :
		new_item["not_usable_by_classes"] = json_dict["not_usable_by_classes"]
	if json_dict.has("only_usable_by_races") :
		new_item["only_usable_by_races"] = json_dict["only_usable_by_races"]
	if json_dict.has("not_usable_by_races") :
		new_item["not_usable_by_races"] = json_dict["not_usable_by_races"]

	if json_dict.has("stats") :
		new_item["stats"] = json_dict["stats"].duplicate(true)
	else :
		if new_item.has('equippable') :
			new_item["stats"] = {}

	if json_dict.has("stats_mini") :
		new_item["stats_mini"] = json_dict["stats_mini"]
	else :
		new_item["stats_mini"] = ''

	if json_dict.has("charges") :
		new_item["charges_max"] = json_dict["charges_max"]
		new_item["charges"] = json_dict["charges"]
	else :
		new_item["charges_max"] = 0
		new_item["charges"] = 0



	if json_dict.has("tradeable") :
		new_item["tradeable"] = json_dict["tradeable"]
	else :
		new_item["tradeable"] = 1

	if json_dict.has("weight") :
		new_item["weight"] = json_dict["weight"]
	else :
		new_item["weight"] = 0

	if json_dict.has("price") :
		new_item["price"] = json_dict["price"]
	else :
		new_item["price"] = 0

	if json_dict.has("charges_weight") :
		new_item["charges_weight"] = json_dict["charges_weight"]
	else :
		new_item["charges_weight"] = 0

	if json_dict.has("splittable") :
		new_item["splittable"] = json_dict["splittable"]
	else :
		new_item["splittable"] = 0

	if json_dict.has("ammo_type") :
		new_item["ammo_type"] = json_dict["ammo_type"]
	else :
		new_item["ammo_type"] = 'cantuse'

	if json_dict.has("custom_spell_source") :
		new_item["custom_spell_source"] = json_dict["custom_spell_source"]

	if json_dict.has("weapon_dmg") :
		new_item["weapon_dmg"] = json_dict["weapon_dmg"]
		if json_dict.has("melee_atk_anim_icon") :
			new_item["melee_atk_anim_icon"] = json_dict["melee_atk_anim_icon"]
		else :
			new_item["melee_atk_anim_icon"] = "ATK_HTH"

		if json_dict.has("weapon_tag_bonus_dmg") :
			new_item["weapon_tag_bonus_dmg"] = json_dict["weapon_tag_bonus_dmg"]
	#Load Scripts !
#	print("checking for item scripts  in "+new_item["name"])

	for hook_source_name: String in [
		"_on_equipping_source",
		"on_equipping_source",
		"_on_unequipping_source",
		"on_unequipping_source",
		"_on_field_use_source",
		"_on_combat_use_source",
		"_on_drop_source",
		"_calculate_melee_attack_source",
		"_calculate_melee_accuracy_source",
	]:
		if json_dict.has(hook_source_name):
			new_item[hook_source_name] = json_dict[hook_source_name]

	if json_dict.has("_on_field_use_spell") :
		new_item["_on_field_use_spell"] = json_dict["_on_field_use_spell"]
	if json_dict.has("_on_combat_use_spell") :
		new_item["_on_combat_use_spell"] = json_dict["_on_combat_use_spell"]

	if json_dict.has("extra_data") :
		new_item["extra_data"] = json_dict["extra_data"].duplicate(true)

	# load traits !
	if json_dict.has("traits") :
		new_item["traits"] = json_dict["traits"].duplicate(true)
		for traitarray in json_dict["traits"] :
			var traitname := str(traitarray[0])
			var source_field := "%s_source" % traitname
			if not traitname.ends_with(".gd") and json_dict.has(source_field):
				new_item[source_field] = json_dict[source_field]

	if json_dict.has("melee_inflicted_traits") :
		new_item["melee_inflicted_traits"] = json_dict[
			"melee_inflicted_traits"
		].duplicate(true)
		for traitarray in json_dict["melee_inflicted_traits"] :
			var traitname := str(traitarray[0])
			var source_field := "%s_source" % traitname
			if not traitname.ends_with(".gd") and json_dict.has(source_field):
				new_item[source_field] = json_dict[source_field]
	return new_item


func load_sound_ressources( path : String ) -> void :
	print("Resources.gd load_sound_ressources "+path)
	var filenames : Array = Utils.FileHandler.list_files_in_directory(path)
	var soundnames : Array = []
	for s in filenames :
		if s.ends_with(".ogg") or s.ends_with(".wav") or s.ends_with(".mp3") or s.ends_with(".import"):
			soundnames.append(s)
	print ("sounds in folder : ",soundnames)
	for s in soundnames :
		#print("sound path : ", path+s)
		var loadedsound : AudioStream
		# DOESNT WORK IN  OUTSIDE FOLDERS !
		if path == "res://shared_assets/sounds/" :  #easy to load from inside res:// !
			#print(path+s)
			loadedsound = load(path+s.replace(".import",""))
		else :
			var snd_file : FileAccess = FileAccess.open(path+s, FileAccess.ModeFlags.READ)
#			ogg_file.open(path+s, File.READ)
			var bytes = snd_file.get_buffer(snd_file.get_length())
			if s.ends_with("ogg") :
				loadedsound = AudioStreamOggVorbis.new()
				print("Resources OGG outside sharedassets is glitchy, "+s+" not loaded")
			elif s.ends_with("mp3") :
				loadedsound = AudioStreamMP3.new()
				loadedsound.data = bytes
			elif s.ends_with("wav") :
#				if assert(stream.format == AudioStreamSample.FORMAT_8_BITS) :
				print("Resources WAV outside sharedassets is glitchy, "+s+" not loaded")
#				bytes = convert_wav_pcm8(bytes)
#				loadedsound = AudioStreamWAV.new()
#				loadedsound.data = bytes
			elif s.ends_with("ogg") :
				print("RESOURCE L577 : FIX OGG LOADER WORKS ???")
				loadedsound = AudioStreamOggVorbis.load_from_file(path+s)

			snd_file.close()

		sounds_book[s.replace(".import","")] = loadedsound



func load_music_resources(path : String) :
	#path =  path to  a Music folder that may have subfolders
	print('Resources.gd load_music_resources ',path)
	#Paths.datafolderpath+"Music/"
	var subfoldernames = Utils.FileHandler.list_dirs_in_directory(path)
	#list all subfolders, this is just an array of Strings
	for sf in subfoldernames :
		if not musics_types_book.has(sf) :
			musics_types_book[sf] = {}
		var sfpath = path + sf #+ '/'
		var sfmusicnames = Utils.FileHandler.list_files_in_directory(sfpath)
		#again just an array of Strings
		for sfmn in sfmusicnames :
			var musicdict = {}
			if sfmn.ends_with("ogg") :
				musicdict["type"] = 'ogg'
				var ogg_file = FileAccess.open(sfpath+'/'+sfmn, FileAccess.READ)
				if ogg_file:
					var bytes = ogg_file.get_buffer(ogg_file.get_length())
					var loadedsound = AudioStreamOggVorbis.load_from_buffer(bytes)
					musicdict["sound"] = loadedsound
					ogg_file.close()
					print("Loaded OGG: ", sfmn, " (", bytes.size(), " bytes)")
				else:
					print("ERROR: Could not open OGG file: ", sfpath+'/'+sfmn)
					continue

			elif sfmn.ends_with("mp3") :
				musicdict["type"] = 'mp3'
				var mp3_file = FileAccess.open(sfpath+'/'+sfmn, FileAccess.ModeFlags.READ)
#				mp3_file.open(sfpath+'/'+sfmn, File.READ)
				var bytes = mp3_file.get_buffer(mp3_file.get_length())
				var loadedsound = AudioStreamMP3.new()
				loadedsound.data = bytes
				mp3_file.close()
				musicdict["sound"] = loadedsound
			elif _is_tracker_format(sfmn) :
				musicdict["type"] = 'mod'

			musicdict["path"] = sfpath+'/'+sfmn
				#the modplayer addon uses the path
			musics_types_book[sf][sfmn] = musicdict
			musics_book[sfmn]= musicdict

#			print("music resource loaded : "+sfmn,","+String(musicdict))
#	pass
#	print("MSUIC LOADED")
#	print(musics_book)

func _is_tracker_format(filename: String) -> bool:
	# Check if the file extension matches any OpenMPT supported tracker format
	var tracker_extensions = [
		".mod",   # ProTracker modules
		".s3m",   # Scream Tracker 3 modules
		".xm",    # FastTracker 2 modules
		".it",    # Impulse Tracker modules
		".mtm",   # MultiTracker modules
		".669",   # Composer 669 modules
		".ptm",   # PolyTracker modules
		".psm",   # Protracker Studio modules
		".umx",   # Unreal Music Container
		".med",   # OctaMED modules
		".dbm",   # DigiBooster Pro modules
		".ams",   # Velvet Studio AMS modules
		".dsm",   # DSIK modules
		".far",   # Farandole Composer modules
		".mdl",   # Digitrakker modules
		".okt",   # Oktalyzer modules
		".stm",   # Scream Tracker 2 modules
		".ult",   # UltraTracker modules
		".j2b",   # Jazz Jackrabbit 2 modules
		".mt2",   # MadTracker 2 modules
		".imf",   # Imago Orpheus modules
		".gdm",   # General DigiMusic modules
		".mptm",  # OpenMPT modules
		".plm",   # DisorderTracker 2 modules
		".mo3",   # Compressed modules
		".xpk",   # Various compressed formats
		".pp20",  # PowerPacker compressed
		".mmcmp"  # MO3-style compressed
	]

	var filename_lower = filename.to_lower()
	for ext in tracker_extensions:
		if filename_lower.ends_with(ext):
			return true
	return false

func load_spell_resources(path : String) :
	print("resources.gd load_spell_resources "+path)
	if not DirAccess.dir_exists_absolute(path) :
		return
	if path == SHARED_SPELL_PATH:
		_load_shared_spell_resources()
		return
	for filename : String in Utils.FileHandler.list_files_in_directory(path) :
		if not filename.ends_with(".gd") :
			continue
		var script : GDScript = load(path + filename)
		if script == null :
			printerr("Resources _load_spell_classes failed to load ", path + filename)
			continue
		var instance = script.new()
		if not (instance is Spell) :
			printerr("Resources _load_spell_classes ", filename, " is not a Spell subclass; skipping")
			continue
		if instance.name == "" :
			printerr("Resources _load_spell_classes ", filename, " has empty name; skipping")
			continue
		# Bake the script's source into the dict the same way JSON spells do, so
		# character saves can include the full text and stay self-contained
		# even if the class file later moves or disappears.
		var spell_entry: Dictionary = {
			"name": instance.name,
			"source": instance.generate_json_string(),
			"script": instance,
		}
		var resource_key := _store_spell_resource(spell_entry)
		print("  loaded spell class ", filename, " as '", resource_key, "'")


func _load_shared_spell_resources() -> void:
	if _shared_spell_cache_complete:
		spells_book.merge(_shared_spell_cache, true)
		return
	if _shared_spell_paths.is_empty():
		_request_shared_spell_warmup()
	for spell_path: String in _shared_spell_paths:
		if _materialized_shared_spell_paths.has(spell_path):
			continue
		_cache_shared_spell_script(spell_path, load(spell_path))
	_shared_spell_cache_complete = true
	spells_book.merge(_shared_spell_cache, true)


func _cache_shared_spell_script(spell_path: String, script: GDScript) -> void:
	_materialized_shared_spell_paths[spell_path] = true
	if script == null or not script.can_instantiate():
		printerr("Resources _load_spell_classes failed to load ", spell_path)
		return
	var instance = script.new()
	if not (instance is Spell):
		printerr(
			"Resources _load_spell_classes ",
			spell_path.get_file(),
			" is not a Spell subclass; skipping"
		)
		return
	if instance.name == "":
		printerr(
			"Resources _load_spell_classes ",
			spell_path.get_file(),
			" has empty name; skipping"
		)
		return
	var spell_entry: Dictionary = {
		"name": instance.name,
		"source": instance.generate_json_string(),
		"script": instance,
	}
	_store_spell_resource_in_book(
		spell_entry,
		_shared_spell_cache
	)


func _store_spell_resource(spell_entry: Dictionary) -> String:
	return _store_spell_resource_in_book(spell_entry, spells_book)


func _store_spell_resource_in_book(
	spell_entry: Dictionary,
	destination: Dictionary
) -> String:
	var instance: Variant = spell_entry.get("script")
	var resource_key := str(spell_entry.get("name", ""))
	if destination.has(resource_key):
		var previous: Variant = destination[resource_key]
		var previous_script: Variant = previous.get("script") \
			if previous is Dictionary else null
		var previous_ids: Array[int] = _explicit_classic_spell_ids(previous_script)
		var incoming_ids: Array[int] = _explicit_classic_spell_ids(instance)
		if not previous_ids.is_empty() and not incoming_ids.is_empty() \
				and not _integer_arrays_overlap(previous_ids, incoming_ids):
			destination[_classic_spell_variant_key(resource_key, previous_ids)] = previous
	destination[resource_key] = spell_entry
	return resource_key


func _explicit_classic_spell_ids(spell: Variant) -> Array[int]:
	var ids: Array[int] = []
	if not (spell is Object):
		return ids
	var raw_ids: Variant = spell.get("classic_spell_ids")
	if raw_ids is Array:
		for id_value: Variant in raw_ids:
			var spell_id: int = abs(int(id_value))
			if spell_id > 0 and not ids.has(spell_id):
				ids.append(spell_id)
	ids.sort()
	return ids


func _integer_arrays_overlap(first: Array[int], second: Array[int]) -> bool:
	for value: int in first:
		if value in second:
			return true
	return false


func _classic_spell_variant_key(display_name: String, spell_ids: Array[int]) -> String:
	var id_labels: PackedStringArray = []
	for spell_id: int in spell_ids:
		id_labels.append(str(spell_id))
	return "%s (%s)" % [display_name, ",".join(id_labels)]

# load map data, convert to an array, added to the maps_book ressource dictionary
func load_map_ressources( path : String , _name : String) -> void :
	print("Resources load_map_ressources ", path, _name)
	var newmapdict : Dictionary = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path+"map_things.json"))
	var newmapinfo : Dictionary = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path+"map_info.json"))
	var newmapscriptareas : Dictionary = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path+"map_scriptareas.json"))

	# Scenario v2 map actions are data routed through ScenarioInterpreter. Campaign
	# folders never provide executable map scripts.
	var newmapscripts: GDScript = null

	var sizey : int = newmapdict[ "height"]
	var sizex : int = newmapdict[ "width"]
	var mapname : String = newmapinfo[ "name"]
	var maptype : String = newmapinfo["map_type"]
	var mapmusictype : String = newmapinfo["music_type"]
	var outdoor_riding : bool = newmapinfo["outdoor_riding"]
	var darkness_level : int = newmapinfo["darkness_level"]
	var display_explored_only : bool = bool(newmapinfo["display_explored_only"])

	# get the ids occupied by each tileset used here
	var used_tilesets_array : Array = newmapdict["tilesets"] #{(}"source.json :string = first_id : int}
	var ts_first_id_dict : Dictionary = {}
	for uts in used_tilesets_array :
		ts_first_id_dict[uts["source"]] = uts["firstgid"]
#	print(used_tilesets_array)
	# build the array
	var newmapdata : Array = []
	for _y in range(sizex) :
		var newline : Array = []
		for _x in range(sizey) :
			newline.append([])
		newmapdata.append(newline)

	var explored_tiles : Array = []
	for _y in range(sizey) :
		var newline : Array = []
		for _x in range(sizex) :
			newline.append(0)
		explored_tiles.append(newline)


	# fill the array with the items found in the json
	for layer in newmapdict["layers"] :
		var t_number : int = 0
#		print('layer["chunks"][0]["data"] : \n', layer["chunks"][0]["data"])
		for tn in layer["chunks"][0]["data"] :

			if tn==0 :
				t_number+=1
				continue
#			print(tn)

			var used_tileset_name : String = used_tilesets_array[0]["source"]

			for uts in used_tilesets_array :
				if uts["firstgid"] > tn :
					break
				used_tileset_name = uts["source"]
			var t_id = tn - ts_first_id_dict[used_tileset_name] #id of the tile in its own tileset
			var y : int = floor(float(t_number)/float(sizex))
			var x : int = t_number%sizex
			#print(tn)
			var tile = tiles_book[used_tileset_name][t_id]
			newmapdata[x][y].append(tile)
			#print(sizex, ' sx: ', x, ' ,  sy :', sizey, ' ', y)
#			print("newmapdata" , newmapdata)
#			return
			t_number+=1
	###
#	for t in newmapdict[ "map_units" ] :
#
#		var x = t["x"]
#		var y = t["y"]
##		var z = t["z"]
##		if z == 3 :
#		var light : bool = bool(t["has_light"])
#		var items : Array = Array(t["items"])
#		items.sort_custom(Callable(self,"sort_item_type"))
#		# items should be organized by layer
#		var newtiledata : Dictionary = {"items":items, "light":light}
#
#		newmapdata[x][y].append(newtiledata)
#	var secret_paths : Dictionary = {}
#	var secrets : Dictionary = {}

	#print("RESOURCE load maps : "+mapname+" scriptareas : ", newmapscriptareas)
	#if maps_book.has("map_0") :
		#print("RESOURCE load maps : map_0 scriptareas is :", maps_book["map_0"][1])
	#else :
		#print("RESOURCE load maps : map_0 not loaded yet")
	#print(' , ')
	#pass
	maps_book[mapname] = [newmapdata, newmapscriptareas, newmapscripts, maptype,mapmusictype, outdoor_riding, darkness_level, display_explored_only, explored_tiles]
	map_info_book[mapname] = newmapinfo
	print("Resources done load map resources : ", _name)
	return


func load_special_encounter_resources(campaign : String) :
#	print("RESOURCES load_special_encounter_resources")
	var encounters_folder_path = Paths.campaignsfolderpath+ campaign + "/Special Encounters/"
	var native_encounters_path := encounters_folder_path.path_join("encounters.json")
	if FileAccess.file_exists(native_encounters_path):
		var native_book := NativeEncounterBookScript.new()
		var load_result: Dictionary = native_book.load_file(native_encounters_path)
		if load_result.get("status") != "ok":
			push_error(str(load_result.get("message", "Unable to load native encounter data")))
		else:
			for encounter_id_value: Variant in load_result.get("encounterIds", []):
				var encounter_id := str(encounter_id_value)
				var controller_result: Dictionary = native_book.create_controller(
					encounter_id,
					GameGlobal.native_encounter_state
				)
				if controller_result.get("status") != "ok":
					push_error(str(controller_result.get(
						"message",
						"Unable to create native encounter %s" % encounter_id
					)))
					continue
				special_encounters_book[encounter_id] = controller_result["controller"]
	print("special encounters : ", special_encounters_book.keys())

func sort_item_type(a : String, b : String):
	# comparator for sorting items by  layer as defined in  thing_types.json
	return thingtypes[tiles_book[a]["type"]] < thingtypes[tiles_book[b]["type"]]


func load_creature_ai_resources(path : String) :
	
	var scriptfilenames : Array = Utils.FileHandler.list_files_in_directory(path)
	print("resources.gd load_creature_ai_resources "+path, " scriptfilenames: :",scriptfilenames)
#	var n_creascripts_book = Utils.FileHandler.read_json_dic_from_file(path +"spells_book.json")
#	print("n_spells_book : ", n_spells_book)
	for sn : String in scriptfilenames :
		if sn.ends_with(".gd") or sn.ends_with(".gdc") :
			print(" resources.gd load_creature_ai_resources adding " +path+sn)
			var newcreascript : GDScript = load(path+sn)
			var key : String = sn
			if key.ends_with('.gdc'):
				key = key.trim_suffix('.gdc')
			elif key.ends_with('.gd'):
				key = key.trim_suffix('.gd')
			
			key = key + '.gd'
			print('resources.gd load_creature_ai_resources : key is '+key)
			#print('resources.gd load_creature_ai_resources methods .GD : ',newcreascript.get_script_method_list())
			creascripts_book[key] = newcreascript
		#if sn.ends_with(".gdc") :
			#var sncut : String = sn.trim_suffix('c')
			#print(" resources.gd load_creature_ai_resources adding " +path+sn +' (removed .gdc)')
			#var newcreascript : GDScript = load(path+sncut)
			#print('resources.gd load_creature_ai_resources methods GDC: ',newcreascript.get_script_method_list())
			#creascripts_book[sn] = newcreascript
			#var newcreascript : GDScript
			#if path.begins_with("res://") :
				#newcreascript = load(path+sn)
			#else :
			#var newcreascript = GDScript.new()
			
			#print('resources.gd load_creature_ai_resources methods: ',newcreascript.get_script_method_list())
			#var _err = #newcreascript.load(path+sn)
			#if _err>0 :
				#printerr("RESOURCE.GD load_creature_ai_resources ERROR : "+sn+ ','+str(_err))
			
			



""" Accessible resources """

# Tiles Book :
func get_tiles_book() -> Dictionary:
	return tiles_book

func get_sounds_book() -> Dictionary:
	return sounds_book




# Img Pack
#func get_img_pack() -> Dictionary:
#	return g_img_pack

# Stuff Book
#func get_stuff_book() -> Dictionary:
#	return g_stuff_book

# Map things
#func get_map_things() -> Dictionary:
#	return g_map_things

# Thing types - Layers
#func get_thing_types() -> Array:
#	return g_thing_types
#
## Get texture Atlas #
#func get_texture_atlas() -> Image:
#	return g_texture_atlas
