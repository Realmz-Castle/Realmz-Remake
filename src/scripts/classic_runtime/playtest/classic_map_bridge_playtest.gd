extends Node

const HostScript = preload("res://scripts/classic_runtime/classic_runtime_host.gd")
const AdapterScript = preload(
	"res://scripts/scenario_runtime/godot/scenario_godot_services.gd"
)
const AcceptanceAssets = preload(
	"res://scripts/classic_runtime/classic_acceptance_assets.gd"
)
const RogueClass = preload("res://Data/Character Classes/Class_Assassin.gd")
const HumanRace = preload("res://Data/Character Races/Race_Human.gd")

@export_dir var campaign_directory := \
	"res://scripts/classic_runtime/tests/fixtures/cob_vertical_slice"
@export var native_campaign := "City of Bywater"
@export var land_to_dungeon_trigger := "Data DD:0:83"
@export var dungeon_to_land_trigger := "Data DDD:0:1"

var host: ClassicRuntimeHost
var automated_smoke := false
var smoke_failures: Array[String] = []


func _ready() -> void:
	call_deferred("_start_playtest")


func _start_playtest() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--smoke":
			automated_smoke = true
		else:
			campaign_directory = argument
	if automated_smoke:
		get_window().size = Vector2i(1100, 619)

	var resources: CampaignResources = NodeAccess.__Resources()
	GameGlobal.set_current_campaign(native_campaign)
	resources.load_campaign_ressources(native_campaign)
	_create_playtest_party()
	UI.show_only(UI.ow_hud)
	NodeAccess.__Map().show()

	host = HostScript.new()
	add_child(host)
	host.configure(AdapterScript.new())
	if not host.load_campaign(campaign_directory):
		_fail("load_bundle", host.runtime.bundle.last_error)
		_finish_smoke()
		return

	var start_result := host.activate_start_location()
	_verify_stage(
		"01_land_map",
		str(start_result.get("status", "")) != "error"
			and GameGlobal.currentmap_name == "map_0"
			and _native_map_is_visible("map_0", "Outdoor"),
		"Classic land:0 is displayed through Remake's map_0 resource"
	)
	await _wait_for_view()
	var land_pixels := _capture_map_pixels()

	if not automated_smoke:
		await _wait_frames(90)
	var enter_result: Dictionary = await host.run_trigger(land_to_dungeon_trigger)
	await _wait_for_view()
	var dungeon_pixels := _capture_map_pixels()
	_verify_stage(
		"02_dungeon_map",
		str(enter_result.get("status", "")) != "error"
			and GameGlobal.currentmap_name == "mapd_0"
			and host.runtime.runtime_state.level_type == "dungeon"
			and host.runtime.runtime_state.heading == 2
			and host.runtime.runtime_state.multi_view
			and _native_map_is_visible("mapd_0", "Indoor"),
		"Data DD:0:83 moves the party to visible native dungeon mapd_0"
	)
	_verify_stage(
		"03_visible_transition",
		not land_pixels.is_empty()
			and not dungeon_pixels.is_empty()
			and land_pixels != dungeon_pixels,
		"the rendered land and dungeon map regions differ"
	)

	if not automated_smoke:
		await _wait_frames(120)
	var exit_result: Dictionary = await host.run_trigger(dungeon_to_land_trigger)
	await _wait_for_view()
	var returned_land_pixels := _capture_map_pixels()
	_verify_stage(
		"04_land_return",
		str(exit_result.get("status", "")) != "error"
			and GameGlobal.currentmap_name == "map_0"
			and host.runtime.runtime_state.level_type == "land"
			and _native_map_is_visible("map_0", "Outdoor"),
		"Data DDD:0:1 returns the party to visible native map_0"
	)
	if not automated_smoke:
		await _wait_frames(90)
	var landlook_result: Dictionary = await host.command_router.route(
		"set_land_look",
		{
			"levelType": "land",
			"levelIndex": 0,
			"landlook": 10,
			"dark": false,
		}
	)
	await _wait_for_view()
	var snow_pixels := _capture_map_pixels()
	_verify_stage(
		"05_landlook",
		str(landlook_result.get("status", "")) not in ["error", "skipped"]
			and str(landlook_result.get("nativeTileset", "")) == "landlook-10"
			and _native_map_uses_tileset("landlook-10")
			and not returned_land_pixels.is_empty()
			and returned_land_pixels != snow_pixels,
		"Classic landlook 10 redraws map_0 with Realmz PICT 310"
	)

	if automated_smoke:
		_finish_smoke()
	else:
		UI.ow_hud.textRect.show()
		UI.ow_hud.textRect.set_text(
			"Classic land/dungeon map bridge playtest complete.\n"
			+ "The party entered mapd_0, returned to map_0, and changed its native landlook."
		)


func _create_playtest_party() -> void:
	var character: PlayerCharacter = GameGlobal.playerCharacterGD.new(
		{
			"name": "Map Test Rogue",
			"level": 1,
			"exp_tnl": 10000,
		},
		AcceptanceAssets.player_icon(),
		AcceptanceAssets.classic_portrait_257(),
		RogueClass,
		HumanRace
	)
	GameGlobal.player_characters.clear()
	GameGlobal.player_characters.append(character)
	UI.ow_hud.selected_character = character


func _native_map_is_visible(map_name: String, map_type: String) -> bool:
	var resources: CampaignResources = NodeAccess.__Resources()
	var map: Node = NodeAccess.__Map()
	if not resources.maps_book.has(map_name) or map == null:
		return false
	var map_entry: Array = resources.maps_book[map_name]
	if map_entry.is_empty() or map.mapdata != map_entry[0] or map.maptype != map_type:
		return false
	for column: Array in map.mapdata:
		for cell: Array in column:
			for tile: Dictionary in cell:
				if tile.get("texture") is Texture2D:
					return true
	return false


func _native_map_uses_tileset(tileset_name: String) -> bool:
	for column: Array in NodeAccess.__Map().mapdata:
		for cell: Array in column:
			for tile: Dictionary in cell:
				if str(tile.get("tileset_name", "")) == tileset_name:
					return true
	return false


func _capture_map_pixels() -> PackedByteArray:
	var image := _capture_map_image()
	if image == null or image.is_empty():
		return PackedByteArray()
	return image.save_png_to_buffer()


func _capture_map_image() -> Image:
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		return Image.new()
	var map_size := Vector2i(mini(832, image.get_width()), mini(448, image.get_height()))
	if map_size.x <= 0 or map_size.y <= 0:
		return Image.new()
	return image.get_region(Rect2i(Vector2i.ZERO, map_size))


func _wait_for_view() -> void:
	await _wait_frames(6 if automated_smoke else 12)
	await RenderingServer.frame_post_draw


func _wait_frames(frame_count: int) -> void:
	for _frame: int in frame_count:
		await get_tree().process_frame


func _verify_stage(stage_name: String, passed: bool, detail: String) -> void:
	if passed:
		print("CLASSIC_MAP_STAGE PASS: %s - %s" % [stage_name, detail])
		return
	_fail(stage_name, detail)


func _fail(stage_name: String, detail: String) -> void:
	smoke_failures.append(stage_name)
	push_error("CLASSIC_MAP_STAGE FAIL: %s - %s" % [stage_name, detail])


func _finish_smoke() -> void:
	get_tree().quit(0 if smoke_failures.is_empty() else 1)
