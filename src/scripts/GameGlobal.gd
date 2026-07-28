"""
# Authors: Samuel Rebrearu , Francisco De Biaso Neto
# email: kikinhobiaso@gmail.com

##################
### GameGlobal ###
##################

This module is responsible for wrapper the game logic.
"""
extends Node

const UDLR : Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
const SHOP_RULES_PATH := "res://scripts/shop_rules.gd"
const BATTLE_REWARD_RULES_PATH := "res://scripts/battle_reward_rules.gd"
const MUSIC_SETTINGS_PATH := "res://scripts/audio/music_settings.gd"
const CLASSIC_CAMPAIGN_INSTALL_PATH := (
	"res://scripts/classic_runtime/classic_campaign_install.gd"
)
const CLASSIC_CAMPAIGN_ADMISSION_PATH := (
	"res://scripts/classic_runtime/classic_campaign_admission.gd"
)
const CLASSIC_CAMPAIGN_SESSION_PATH := (
	"res://scripts/classic_runtime/classic_campaign_session.gd"
)
const SCENARIO_GODOT_SERVICES_PATH := (
	"res://scripts/scenario_runtime/godot/scenario_godot_services.gd"
)
const CLASSIC_MONSTER_WEAPON_RULES_PATH := (
	"res://scripts/classic_runtime/classic_monster_weapon_rules.gd"
)
const CLASSIC_CHARACTER_RULES_PATH := (
	"res://scripts/classic_runtime/classic_character_rules.gd"
)
const CLASSIC_PROTECTION_FROM_FOE_PATH := (
	"res://scripts/classic_runtime/classic_protection_from_foe.gd"
)
const CLASSIC_ANIMATION_PATH := "res://scripts/classic_runtime/classic_animation.gd"
const CLASSIC_LIGHT_PATH := "res://scripts/classic_runtime/classic_light.gd"
const CLASSIC_PARTY_CONDITION_PATH := (
	"res://scripts/classic_runtime/classic_party_condition.gd"
)
const CLASSIC_REST_PATH := "res://scripts/classic_runtime/classic_rest.gd"
const CLASSIC_RANDOM_RECTANGLE_PATH := (
	"res://scripts/classic_runtime/classic_random_rectangle.gd"
)
const CLASSIC_MONSTER_GENERATION_PATH := (
	"res://scripts/classic_runtime/classic_monster_generation.gd"
)
const PLAYER_CHARACTER_PATH := "res://Creature/PlayerCharacter.gd"
const COMBAT_CREATURE_PATH := "res://Creature/Creature.gd"
const SPELL_ANIMATION_PATH := "res://scenes/Map/SpellAnimation/SpellAnimation.tscn"
const GAME_SCREEN_PATH := "res://scenes/UI/HUD/OWHUDControl.tscn"
const CLASSIC_DETECT_SECRET_ABILITY_INDEX := 4
const BATTLE_REWARD_NORMAL := "normal"
const BATTLE_REWARD_EXPERIENCE_ONLY := "experience_only"
const DEFAULT_GAME_SPEED_PERCENT := 100.0
const MIN_GAME_SPEED_PERCENT := 25.0
const MAX_GAME_SPEED_PERCENT := 400.0
const GAME_SPEED_STEP_PERCENT := 25.0
const GAME_SPEED_BASE_DELAY_SECONDS := 0.2

var cmp_resources: CampaignResources

var map : Map
var current_map_script_name : String = ''
var classic_runtime_host: Object
var classic_campaign_session: Object
var classic_campaign_install_cache: Dictionary = {}

var _lazy_resources: Dictionary = {}

var ShopRules: GDScript:
	get:
		return _lazy_resource(SHOP_RULES_PATH) as GDScript
var BattleRewardRulesScript: GDScript:
	get:
		return _lazy_resource(BATTLE_REWARD_RULES_PATH) as GDScript
var MusicSettingsScript: GDScript:
	get:
		return _lazy_resource(MUSIC_SETTINGS_PATH) as GDScript
var ClassicCampaignInstallScript: GDScript:
	get:
		return _lazy_resource(CLASSIC_CAMPAIGN_INSTALL_PATH) as GDScript
var ClassicCampaignAdmissionScript: GDScript:
	get:
		return _lazy_resource(CLASSIC_CAMPAIGN_ADMISSION_PATH) as GDScript
var ClassicCampaignSessionScript: GDScript:
	get:
		return _lazy_resource(CLASSIC_CAMPAIGN_SESSION_PATH) as GDScript
var ScenarioGodotServicesScript: GDScript:
	get:
		return _lazy_resource(SCENARIO_GODOT_SERVICES_PATH) as GDScript
var ClassicMonsterWeaponRulesScript: GDScript:
	get:
		return _lazy_resource(CLASSIC_MONSTER_WEAPON_RULES_PATH) as GDScript
var ClassicCharacterRulesScript: GDScript:
	get:
		return _lazy_resource(CLASSIC_CHARACTER_RULES_PATH) as GDScript
var ClassicProtectionFromFoeScript: GDScript:
	get:
		return _lazy_resource(CLASSIC_PROTECTION_FROM_FOE_PATH) as GDScript
var ClassicAnimationScript: GDScript:
	get:
		return _lazy_resource(CLASSIC_ANIMATION_PATH) as GDScript
var ClassicLightScript: GDScript:
	get:
		return _lazy_resource(CLASSIC_LIGHT_PATH) as GDScript
var ClassicPartyConditionScript: GDScript:
	get:
		return _lazy_resource(CLASSIC_PARTY_CONDITION_PATH) as GDScript
var ClassicRestScript: GDScript:
	get:
		return _lazy_resource(CLASSIC_REST_PATH) as GDScript
var ClassicRandomRectangleScript: GDScript:
	get:
		return _lazy_resource(CLASSIC_RANDOM_RECTANGLE_PATH) as GDScript
var ClassicMonsterGenerationScript: GDScript:
	get:
		return _lazy_resource(CLASSIC_MONSTER_GENERATION_PATH) as GDScript
var playerCharacterGD: GDScript:
	get:
		return _lazy_resource(PLAYER_CHARACTER_PATH) as GDScript
var combatCreatureGD: GDScript:
	get:
		return _lazy_resource(COMBAT_CREATURE_PATH) as GDScript
var spellAnimationTSCN: PackedScene:
	get:
		return _lazy_resource(SPELL_ANIMATION_PATH) as PackedScene
var gameScreenTSCN: PackedScene:
	get:
		return _lazy_resource(GAME_SCREEN_PATH) as PackedScene


#var gamescreenInstance

var fatigue :float = 0 #(max=128)
var max_fatigue : float = 86400.0
var time_scale : float = 10.0

enum eGameStates {unchecked,startGame,inGame,saveGame,endGame}
enum eCombatStates {unchecked,startCombat,inCombat,inCombatTargeting,combatAnim,endCombatFail,endCombatSuccess,combatShortPause}
var dontlognext_execute_spell : bool = false

var honest_mode : bool = false
var currentcampaign : String = ''
var currentcampaign_onload_script: Variant = null
var new_gameplay_rule_selection: Dictionary = {}
var campaign_global_script = null
var currentprofile : String = 'Default Profile'
var profile_characters_list : Array = []
var cur_save_name : String = "Game not Saved !"
var cur_save_descrition : String = ''

var currentmap_name : String = 'Default Map'
var last_exploration_map_name : String = 'Default Map'
var pos_when_battle_started : Vector2 = Vector2.ZERO

var currentShop : String = ''
var currentTemple : Array = [] # [ [spellname, price] ]
var prev_simple_enc_name : String = ''  #not saved, only for use inside that simple encounter
var currentSpecialEncounterName : String = "default.gd"
var native_encounter_state : Dictionary = {}

var can_show_ability_list : bool = true

var last_picked_characters : Array = [] #set by ScriptHelperFuncs, not owh_hud.request_pick

var global_effects : Dictionary = {
	"WaterBreath" : {"Duration" : 0},
	"FeatherFall" : {"Duration" : 0},
	"Awareness" : {"Duration" : 0},
	"Scrying" : {"Duration" : 0},
	"Shielded" : {"Duration" : 0},
	"Sentry" : {"Duration" : 0},
	"CharmProt" : {"Duration" : 0}
}
## To 2x scale or not to 2x scale that is the question
var hd_mode : bool = ScreenUtils.get_hd_mode_default()

#settings
var gamespeed : float = GAME_SPEED_BASE_DELAY_SECONDS
var game_speed_percent : float = DEFAULT_GAME_SPEED_PERCENT
var enforce_unique_items : bool = true
var map_debug_overlays_enabled : bool = true

var setting_play_spell_resolution_on_every_aoe_tile : bool = false

var time : int = -1  #the time (date) in-game. -1 = invalid
var player_characters : Array = []
var player_allies : Array = []  #NPCs and summons

var light_time : int = 0
var light_power : int = 0
# Classic combines light strength and remaining duration in one condition counter.
var classic_light_condition : int = 0
var classic_party_conditions: Dictionary = {}
var camping : bool = false
var classic_camping_disabled : bool = false
var money_pool : Array = [0,0,0] # coins gems jewels
var money_banked : Array = [0,0,0] # coins gems jewels

var must_cancel_movement : bool = false

var is_sailing_boat : bool = false
var boat_sailed_image_name : String = ''
var allow_next_battle_loot : bool = true

var shops_dict : Dictionary = {}
var allow_character_swap_anywhere : bool = false
var stuff_done : Dictionary = {}
var minimaps : Array = []
var map_boats_dict : Dictionary = {}

signal battle_end


func _lazy_resource(path: String) -> Resource:
	var cached: Resource = _lazy_resources.get(path)
	if cached == null:
		cached = load(path)
		_lazy_resources[path] = cached
	return cached


func _ready():
	call_deferred("_bind_map")


func _bind_map() -> void:
	var resources := NodeAccess.__Resources()
	if resources is CampaignResources:
		cmp_resources = resources
	var map_node := NodeAccess.__Map()
	if map_node is Map:
		map = map_node

# UI start ------------------- #

# Hide all UI elements #
func hideAllUI():
	NodeAccess.Get.__UI().__hide()

func show_menu(menu : CanvasItem) :
	UI.show_only(menu)

#func setupDefaultUI():
	#UI.ow_hud.initialize()

func create_new_profile(newprofilename : String , new_honest_mode : bool) -> bool :
	var profilesfolderpath = Paths.profilesfolderpath


	# http://docs.godotengine.org/en/latest/classes/class_lineedit.html#class-lineedit
#	var dir = Directory.new()
#	var dir = DirAccess.open(path)
#
	var dir_exists : bool = DirAccess.dir_exists_absolute(profilesfolderpath+"/" + newprofilename)
	print("dir exists ? ",  dir_exists )
	if not dir_exists :
		DirAccess.make_dir_recursive_absolute(profilesfolderpath+"/" + newprofilename)
		DirAccess.make_dir_recursive_absolute(profilesfolderpath+"/" + newprofilename + "/Characters/")
		DirAccess.make_dir_recursive_absolute(profilesfolderpath+"/" + newprofilename + "/Saves/")

		var path = Paths.profilesfolderpath+newprofilename
		print("new char path : ", path)
		DirAccess.make_dir_recursive_absolute(path)
		var _settingscfgFile : FileAccess = FileAccess.open( path+'/profile_settings.cfg' , FileAccess.ModeFlags.WRITE)

		_settingscfgFile = null
		Utils.FileHandler.set_cfg_setting(path+'/profile_settings.cfg', "SET_IN_STONE", "honest_mode", int(new_honest_mode))
		Utils.FileHandler.set_cfg_setting(path+'/profile_settings.cfg', "VOLUME", "volume_sound", 50)
		Utils.FileHandler.set_cfg_setting(path+'/profile_settings.cfg', "VOLUME", "volume_music", 50)
		print("created profile folder for "+newprofilename+" at " +profilesfolderpath + newprofilename)

		return true

	else:
		return false

func set_current_profile(profilename : String) -> void :
	print("GameGlobal set_current_profile : "+profilename)
	currentprofile = profilename
	Paths.currentProfileFolderName = profilename
	#save this profile as the current one to the game wide cfg
	Utils.FileHandler.set_cfg_setting(Paths.settingspath,"SETTINGS","current_profile", profilename)
	#load the settings from this profile
	var path = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/profile_settings.cfg'
	#get_cfg_setting(path, section, key, default) :
	var musicvolume : float = Utils.FileHandler.get_cfg_setting(path, "VOLUME", "volume_music", 50)
	MusicStreamPlayer.volume_db = MusicSettingsScript.volume_db_from_setting(musicvolume)
	var sfxvolume : float = Utils.FileHandler.get_cfg_setting(path, "VOLUME", "volume_sound", 50)
	SfxPlayer.volume_db = MusicSettingsScript.volume_db_from_setting(sfxvolume)
	honest_mode = bool(Utils.FileHandler.get_cfg_setting(path, "SET_IN_STONE", "honest_mode", 0))
	for type in MusicStreamPlayer.oneofeachtype.keys() :
		var favofthistype : String = Utils.FileHandler.get_cfg_setting(
			path,
			"MUSIC",
			type,
			MusicSettingsScript.default_music_choice(type)
		)
		MusicStreamPlayer.set_type_music_choice(type,favofthistype)


	GameGlobal.load_profile_characters()


func load_profile_characters() :
	profile_characters_list.clear()
	var resources: CampaignResources = NodeAccess.__Resources()
	if resources != null and not resources.ensure_shared_item_catalog_loaded():
		push_error("Shared item definitions could not be loaded before profile characters.")
	#load all the characters
	var characterfoldernameslist = Utils.FileHandler.list_dirs_in_directory(Paths.profilesfolderpath+"/"+Paths.currentProfileFolderName+"/Characters/")
	for c in characterfoldernameslist :
		load_character_to_profile(c)

#		var path = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/Characters/'+c
#		print("charpick rect charpath : ",path)
#		var newchar = Utils.FileHandler.load_character(path)
#		print("loaded char ", newchar.name)
#		profile_characters_list.append(newchar)
#		charactersdict[newchar.name] = newchar


func load_character_to_profile(c : String) :
	var path = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/Characters/'+c
	print("GameGlobal load_character_to_profile : ",path)
	var newchar = Utils.FileHandler.load_character(path)
#	print("loaded char ", newchar.name)
	profile_characters_list.append(newchar)

func set_hd_mode(new_hd_mode: bool) -> void:
	hd_mode = new_hd_mode
	#DisplayServer.window_set_position(Vector2i(0,64))
	#if new_hd_mode :
		#DisplayServer.window_set_size(Vector2i(DisplayServer.window_get_size()/2))
		#var winpos : Vector2i = DisplayServer.window_get_position()
		##DisplayServer.window_set_position(Vector2i(0,64))
	#else :
		#DisplayServer.window_set_size(Vector2i(DisplayServer.window_get_size()*2))
	#if new_hd_mode :
		#DisplayServer.window_set_max_size( Vector2i(DisplayServer.screen_get_size() *0.2) )
	#else :
		#DisplayServer.window_set_max_size( DisplayServer.screen_get_size() )

func save_hd_mode(new_hd_mode: bool) -> void:
	Utils.FileHandler.set_cfg_setting(Paths.settingspath,"SETTINGS","hd_mode", new_hd_mode)

func set_game_speed_percent(value: float) -> void:
	game_speed_percent = clampf(
		snappedf(value, GAME_SPEED_STEP_PERCENT),
		MIN_GAME_SPEED_PERCENT,
		MAX_GAME_SPEED_PERCENT
	)
	gamespeed = (
		GAME_SPEED_BASE_DELAY_SECONDS
		* DEFAULT_GAME_SPEED_PERCENT
		/ game_speed_percent
	)

func save_game_speed_percent(value: float) -> void:
	Utils.FileHandler.set_cfg_setting(
		Paths.settingspath,
		"SETTINGS",
		"game_speed_percent",
		clampf(
			snappedf(value, GAME_SPEED_STEP_PERCENT),
			MIN_GAME_SPEED_PERCENT,
			MAX_GAME_SPEED_PERCENT
		)
	)

func set_map_debug_overlays_enabled(enabled: bool) -> void:
	map_debug_overlays_enabled = enabled
	var active_map: Map = map
	if not is_instance_valid(active_map):
		active_map = get_node_or_null("/root/Main/Map") as Map
	if is_instance_valid(active_map):
		active_map.set_debug_overlays_enabled(enabled)

func save_map_debug_overlays_enabled(enabled: bool) -> void:
	Utils.FileHandler.set_cfg_setting(
		Paths.settingspath,
		"SETTINGS",
		"show_map_debug_overlays",
		enabled
	)

func init_globals_before_game_start(data_dict : Dictionary) :
	# used in  load_game() and new_campain_panel  _on_StartButton_pressed
	map.owcharacter.visible = true
	map.owcharacter.set_tile_position(data_dict["position"])
	fatigue = data_dict["fatigue"]
	UI.ow_hud.update_fatigue_bar()
	time = data_dict["time"]
	money_pool = data_dict["money_pool"]
	money_banked = data_dict["money_banked"]
	light_time = data_dict["light_time"]
	light_power = data_dict["light_power"]
	classic_light_condition = int(data_dict.get("classic_light_condition", 0))
	if classic_light_condition > 0:
		_sync_classic_light_state()
	camping = bool(data_dict["camping"])
	classic_camping_disabled = bool(data_dict.get("classic_camping_disabled", false))
	cur_save_name = data_dict["save_name"]
	cur_save_descrition = data_dict["save_descr"]
	allow_character_swap(bool(data_dict["allow_char_swap"]))
	currentShop = data_dict["curr_shop"]
	currentTemple = data_dict["curr_temple"]
	stuff_done = data_dict["stuff_done"]
	restore_native_encounter_state(data_dict.get("native_encounters", {}))
	map_boats_dict = data_dict["map_boats_dict"]
	is_sailing_boat = bool(data_dict["is_sailing_boat"])
	boat_sailed_image_name = data_dict["boat_image"]

	set_current_campaign(
		data_dict["campaign"],
		null,
		data_dict.get("gameplay_rule_selection", {})
	)
	currentmap_name = data_dict["currentmap_name"]
	shops_dict = data_dict["shops_dict"]

	global_effects = data_dict["GlobalEffects"]
	_restore_classic_party_conditions(data_dict.get("classic_party_conditions", {}))

	minimaps = data_dict["minimaps"]
	if UI.ow_hud != null and UI.ow_hud.has_method("update_classic_camping_permission"):
		UI.ow_hud.update_classic_camping_permission()

	allow_next_battle_loot = true
	prev_simple_enc_name = ''


func native_encounter_save_payload() -> Dictionary:
	return native_encounter_state.duplicate(true)


func restore_native_encounter_state(saved_state: Variant) -> void:
	# Keep the dictionary identity stable for loaded encounter controllers.
	native_encounter_state.clear()
	if saved_state is Dictionary:
		native_encounter_state.merge(saved_state, true)


func set_party_fatigue(value: float) -> float:
	var upper_limit: float = (
		ClassicRestScript.MAX_FATIGUE
		if is_classic_runtime_active()
		else max_fatigue * 2.0
	)
	fatigue = clampf(value, 0.0, upper_limit)
	var hud: Variant = UI.get("ow_hud") if UI != null else null
	if hud is Object and hud.has_method("update_fatigue_bar"):
		hud.call("update_fatigue_bar")
	return fatigue


func fatigue_limit() -> float:
	return (
		ClassicRestScript.MAX_FATIGUE
		if is_classic_runtime_active()
		else max_fatigue
	)


func pass_time(seconds : int, fatiguemultiplier : float = 1.0) :
	var previous_time := time
	time += seconds *time_scale
	var classic_field_time: bool = (
		is_classic_runtime_active()
		and not StateMachine.is_combat_state()
	)
	if classic_field_time:
		set_party_fatigue(ClassicRestScript.fatigue_after_time(
			fatigue,
			previous_time,
			time
		))
	else:
		set_party_fatigue(fatigue + fatiguemultiplier * seconds * 0.25 * time_scale)

	if campaign_global_script.has_on_time_pass and ( not StateMachine.is_combat_state() ):
		campaign_global_script._on_time_pass(seconds)

	if not StateMachine.is_combat_state() :   #check timed   encounters
		if stuff_done.has("Timed_Encounters") :
			#var campaign_script_methods_dicts : Array = campaign_global_script.get_script_method_list()
			for t_enc_name : String in stuff_done["Timed_Encounters"] :

				var t_enc_dict = stuff_done["Timed_Encounters"][t_enc_name]

				if t_enc_name == "Time_Enc_1" :
					print(time,' , ', t_enc_dict["before"], ',',t_enc_dict["after"])

				#t_encs["Time_Enc_1"] = { "called_func" = "Time_Enc_1", "after" : 3*86400 , "before" : -1, "chance_prct" : 100,"increment" : 0, "req_map" : "", "req_rect" : [] , "req_quest" : "quest_0"}
				if not (t_enc_dict["req_map"].is_empty() or t_enc_dict["req_map"]==currentmap_name) :
					continue
				if not (time>=t_enc_dict["after"] and (time<=t_enc_dict["before"] or t_enc_dict["before"]<0)) :
					#if t_enc_name == "Time_Enc_1" :
						#print("time check failed")
					continue
				if (not t_enc_dict["req_quest"].is_empty() or stuff_done.has(t_enc_dict["req_quest"].is_empty())) :
					#if t_enc_name == "Time_Enc_1" :
						#print("quest check failed")
					continue
				if t_enc_dict["chance_prct"] <= randi()%100 :
					continue
				var x : int = map.owcharacter.tile_position_x
				var y : int = map.owcharacter.tile_position_y
				print('t_enc_dict["req_rect"]', t_enc_dict["req_rect"])
				if not t_enc_dict["req_rect"].is_empty() :
					var l = t_enc_dict["req_rect"][0][0]
					var u = t_enc_dict["req_rect"][0][1]
					var r = t_enc_dict["req_rect"][1][0]
					var d = t_enc_dict["req_rect"][1][1]
					if not (x>l and x<r and y>u and y<d) :
						continue
				#ok that should be enough checks  let s execute that global script function
				var func_name : String = t_enc_dict["called_func"]
				#var found : bool = false
				#for meth_d in campaign_script_methods_dicts :
					#var meth_name : String = meth_d["name"]
					#if meth_name == func_name :
						#found = true
						#break
				#if found :
				campaign_global_script.call (func_name)
				#else :
					#printerr("GameGlobal ERROR pass_time : Campaign Global function "+ func_name+" NOT FOUND")
	_advance_classic_timed_encounters(
		previous_time,
		time,
		StateMachine.is_combat_state()
	)
	for character in player_characters :
		if classic_field_time and character.has_method("_on_classic_time_pass"):
			character._on_classic_time_pass(seconds)
		else:
			character._on_time_pass(seconds)
		if character.has_method("advance_classic_age_between_times"):
			character.advance_classic_age_between_times(previous_time, time)
	for character in player_allies :
		if classic_field_time and character.has_method("_on_classic_time_pass"):
			character._on_classic_time_pass(seconds)
		else:
			character._on_time_pass(seconds)
		if character.has_method("advance_classic_age_between_times"):
			character.advance_classic_age_between_times(previous_time, time)
	if classic_field_time:
		ClassicRestScript.apply_party_recovery(
			player_characters,
			player_allies,
			previous_time,
			time,
			Callable(self, "_consume_classic_rest_ration")
		)

	for effect in global_effects.keys() :
		global_effects[effect]["Duration"] = max(0, global_effects[effect]["Duration"] - seconds)
	_advance_classic_party_conditions(previous_time, time)

	if classic_light_condition > 0:
		classic_light_condition = ClassicLightScript.advance_time(
			classic_light_condition,
			previous_time,
			time
		)
		_sync_classic_light_state()
	else:
		light_time = clamp(light_time-seconds,0,31536000)
		if light_time == 0 :
			light_power = 0
#	player_characters[0].stats["curHP"] = seconds
	UI.ow_hud.updateTimeDisplay()
	UI.ow_hud.updateGlobalEffectsDisplay()
	UI.ow_hud.updateCharPanelDisplay()


func _advance_classic_timed_encounters(
	previous_time: int,
	current_time: int,
	defer_dispatch: bool
) -> void:
	if not is_instance_valid(classic_campaign_session) \
			or not classic_campaign_session.has_method("on_native_time_advanced"):
		return
	var native_location := {"deferDispatch": defer_dispatch}
	if not defer_dispatch and map != null and map.owcharacter != null:
		native_location.merge({
			"mapName": currentmap_name,
			"x": int(map.owcharacter.tile_position_x),
			"y": int(map.owcharacter.tile_position_y),
		})
	var result: Variant = classic_campaign_session.call(
		"on_native_time_advanced",
		previous_time,
		current_time,
		native_location
	)
	if result is Dictionary and str(result.get("status", "")) == "error":
		push_error(str(result.get(
			"message",
			"Classic timed encounters could not be evaluated"
		)))


func add_light_effect(p : int, t : int) :
	light_power = max(light_power, p)
	light_time = (light_power*light_time+p*t)/light_power


func add_classic_light_effect(power: int) -> void:
	classic_light_condition = ClassicLightScript.apply_power(classic_light_condition, power)
	_sync_classic_light_state()
	var current_map := NodeAccess.__Map()
	if is_instance_valid(current_map):
		current_map.queue_redraw()


func apply_classic_party_condition(condition_index: int, duration: int) -> int:
	if condition_index == 0:
		add_classic_light_effect(duration)
		return classic_light_condition
	if not ClassicPartyConditionScript.supports_condition(condition_index):
		push_error("Classic party condition %d has no Remake state mapping" % condition_index)
		return 0
	var key := str(condition_index)
	var current := int(classic_party_conditions.get(key, 0))
	var result: int = ClassicPartyConditionScript.apply(current, duration)
	classic_party_conditions[key] = result
	_sync_classic_party_condition(condition_index)
	return result


func set_classic_party_condition(condition_index: int, value: int) -> int:
	if condition_index == 0:
		classic_light_condition = value
		_sync_classic_light_state()
		return classic_light_condition
	if not ClassicPartyConditionScript.supports_condition(condition_index):
		push_error("Classic party condition %d has no Remake state mapping" % condition_index)
		return 0
	classic_party_conditions[str(condition_index)] = value
	_sync_classic_party_condition(condition_index)
	return value


func set_classic_search_enabled(enabled: bool) -> void:
	set_classic_party_condition(5, -1 if enabled else 0)


func classic_timeclick_pass_time_units(timeclicks: int, base_scale: int) -> int:
	return ClassicRestScript.pass_time_units(timeclicks, base_scale, time_scale)


func classic_base_scale_for_tile_stack(tile_stack: Array) -> int:
	for tile_value: Variant in tile_stack:
		if not (tile_value is Dictionary):
			continue
		var tile: Dictionary = tile_value
		if tile.has("classicBaseScale"):
			return int(tile["classicBaseScale"])
		if tile.has("classicDungeonField"):
			return 1
	return 1 if currentmap_name.begins_with("mapd_") else 0


func classic_movement_pass_time_units(timeclicks: int, tile_stack: Array) -> int:
	var source_timeclicks := timeclicks
	for tile_value: Variant in tile_stack:
		if tile_value is Dictionary and tile_value.has("classicDungeonField"):
			# Classic threed.c charges one timeclick for every successful dungeon step.
			# Normalize older installed maps whose generated native tile used time 5.
			source_timeclicks = 1
			break
	return classic_timeclick_pass_time_units(
		source_timeclicks,
		classic_base_scale_for_tile_stack(tile_stack)
	)


func apply_classic_search_time_cost() -> bool:
	if not is_classic_party_condition_active(5):
		return false
	# checkforsecret.c advances source time by four ticks on every search pass.
	pass_time(classic_timeclick_pass_time_units(4, _current_classic_base_scale()))
	return true


func _current_classic_base_scale() -> int:
	if map != null and map.owcharacter != null:
		var x := int(map.owcharacter.tile_position_x)
		var y := int(map.owcharacter.tile_position_y)
		if (
			x >= 0
			and x < map.mapdata.size()
			and map.mapdata[x] is Array
			and y >= 0
			and y < map.mapdata[x].size()
			and map.mapdata[x][y] is Array
		):
			return classic_base_scale_for_tile_stack(map.mapdata[x][y])
	return 1 if currentmap_name.begins_with("mapd_") else 0


func is_classic_runtime_active() -> bool:
	return is_instance_valid(classic_campaign_session)


func is_classic_party_condition_active(condition_index: int) -> bool:
	if condition_index == 0:
		return ClassicPartyConditionScript.is_active(classic_light_condition)
	if not ClassicPartyConditionScript.supports_condition(condition_index):
		return false
	return ClassicPartyConditionScript.is_active(
		int(classic_party_conditions.get(str(condition_index), 0))
	)


func reduce_classic_party_conditions(reduction_calls: int = 1) -> void:
	for key: Variant in classic_party_conditions.keys():
		var condition_index := int(key)
		classic_party_conditions[str(condition_index)] = ClassicPartyConditionScript.reduce(
			int(classic_party_conditions[key]),
			reduction_calls
		)
		_sync_classic_party_condition(condition_index)


func _advance_classic_party_conditions(previous_time: int, current_time: int) -> void:
	for key: Variant in classic_party_conditions.keys():
		var condition_index := int(key)
		classic_party_conditions[str(condition_index)] = ClassicPartyConditionScript.advance_time(
			int(classic_party_conditions[key]),
			previous_time,
			current_time
		)
		_sync_classic_party_condition(condition_index)


func _restore_classic_party_conditions(value: Variant) -> void:
	classic_party_conditions.clear()
	if not (value is Dictionary):
		return
	for key: Variant in value:
		var condition_index := int(key)
		if condition_index == 0 \
				or not ClassicPartyConditionScript.supports_condition(
					condition_index
				):
			continue
		classic_party_conditions[str(condition_index)] = int(value[key])
		_sync_classic_party_condition(condition_index)


func _sync_classic_party_condition(condition_index: int) -> void:
	var effect_name := str(ClassicPartyConditionScript.EFFECT_BY_INDEX.get(
		condition_index,
		""
	))
	if effect_name.is_empty():
		return
	if not global_effects.has(effect_name) or not (global_effects[effect_name] is Dictionary):
		global_effects[effect_name] = {"Duration": 0}
	var condition := int(classic_party_conditions.get(str(condition_index), 0))
	global_effects[effect_name]["Duration"] = ClassicPartyConditionScript.remaining_seconds(
		condition,
		time
	)


func reduce_classic_light_condition() -> void:
	if classic_light_condition <= 0:
		return
	classic_light_condition = ClassicLightScript.reduce(classic_light_condition)
	_sync_classic_light_state()


func _sync_classic_light_state() -> void:
	light_power = ClassicLightScript.light_power(classic_light_condition)
	light_time = ClassicLightScript.remaining_seconds(classic_light_condition, time)

func get_shop(shopname : String) :
	return shops_dict[shopname]


func current_shop_accepts_item(item: Variant) -> bool:
	return ShopRules.accepts_item(currentShop, shops_dict, item)

func shop_purchase_balances(character_gold: int, pooled_gold: int, cost: int) -> Array[int]:
	return ShopRules.balances_after_purchase(character_gold, pooled_gold, cost)


func refresh_OW_HUD() :
	UI.ow_hud.update_fatigue_bar()
	UI.ow_hud.updateCharPanelDisplay()
	UI.ow_hud.updateTimeDisplay()
	UI.ow_hud.updateGlobalEffectsDisplay()

	var invrect = UI.ow_hud.inventoryRect
	if invrect.visible :
#		invrect.when_Items_Button_pressed()
		invrect.fill_inventory_Vbox(invrect.inventoryBoxRight, UI.ow_hud.selected_character)
		if invrect.traderect.visible :
			invrect.fill_inventory_Vbox(invrect.inventoryBoxLeft, invrect.selectedTradeCharacter)


func register_classic_runtime_host(host: Object) -> void:
	classic_runtime_host = host


func clear_classic_runtime_host(host: Object = null) -> void:
	if host == null or classic_runtime_host == host:
		classic_runtime_host = null


func classic_monster_generation_context(mode: String) -> Dictionary:
	return ClassicMonsterGenerationScript.context_from_game_global(mode, self)


func classic_random_encounters_enabled() -> bool:
	return (
		not is_instance_valid(classic_runtime_host)
		or not classic_runtime_host.has_method("random_encounters_enabled")
		or bool(classic_runtime_host.call("random_encounters_enabled"))
	)


func classic_allies_suspended() -> bool:
	return (
		is_instance_valid(classic_runtime_host)
		and classic_runtime_host.has_method("allies_suspended")
		and bool(classic_runtime_host.call("allies_suspended"))
	)


func classic_spellcasting_blocked_for(character: Object) -> bool:
	if (
		not is_instance_valid(classic_runtime_host)
		or not classic_runtime_host.has_method("spellcasting_blocked")
	):
		return false
	var is_player_character := player_characters.has(character) \
		or character is PlayerCharacter
	return bool(classic_runtime_host.call(
		"spellcasting_blocked",
		is_player_character
	))


func resolve_classic_dungeon_movement(
	from_position: Vector2i,
	to_position: Vector2i
) -> Dictionary:
	if (
		not is_instance_valid(classic_runtime_host)
		or not classic_runtime_host.has_method("resolve_dungeon_movement")
	):
		return {"handled": false}
	var result: Variant = classic_runtime_host.call(
		"resolve_dungeon_movement",
		from_position,
		to_position
	)
	return result if result is Dictionary else {
		"status": "error",
		"handled": true,
		"allowed": false,
		"message": "Registered Classic runtime host returned an invalid movement response",
	}


func resolve_classic_map_movement(
	from_position: Vector2i,
	to_position: Vector2i
) -> Dictionary:
	if (
		not is_instance_valid(classic_runtime_host)
		or not classic_runtime_host.has_method("resolve_map_movement")
	):
		return {"handled": false}
	var result: Variant = classic_runtime_host.call(
		"resolve_map_movement",
		from_position,
		to_position
	)
	return result if result is Dictionary else {
		"status": "error",
		"handled": true,
		"allowed": false,
		"message": "Registered Classic runtime host returned an invalid movement response",
	}


func reveal_classic_dungeon_overhead(position: Vector2i) -> Dictionary:
	if (
		not is_instance_valid(classic_runtime_host)
		or not classic_runtime_host.has_method("reveal_dungeon_overhead")
	):
		return {"handled": false}
	var result: Variant = classic_runtime_host.call("reveal_dungeon_overhead", position)
	return result if result is Dictionary else {
		"status": "error",
		"handled": true,
		"message": "Registered Classic runtime host returned an invalid dungeon reveal response",
	}


func discover_classic_map_secrets(position: Vector2i) -> Dictionary:
	if (
		not is_instance_valid(classic_runtime_host)
		or not classic_runtime_host.has_method("discover_map_secrets")
	):
		return {"handled": false}
	var result: Variant = classic_runtime_host.call("discover_map_secrets", position)
	return result if result is Dictionary else {
		"status": "error",
		"handled": true,
		"message": "Registered Classic runtime host returned an invalid secret-discovery response",
	}


func play_classic_map_sound(sound_id: int) -> Dictionary:
	if sound_id == 0:
		return {"handled": false}
	if (
		not is_instance_valid(classic_runtime_host)
		or not classic_runtime_host.has_method("play_map_sound")
	):
		return {"handled": false}
	var result: Variant = classic_runtime_host.call("play_map_sound", sound_id)
	return result if result is Dictionary else {
		"status": "error",
		"handled": true,
		"message": "Registered Classic runtime host returned an invalid sound response",
	}


func stop_classic_campaign_runtime() -> void:
	classic_runtime_host = null
	if is_instance_valid(classic_campaign_session):
		classic_campaign_session.call("clear")
		classic_campaign_session.queue_free()
	classic_campaign_session = null


func classic_campaign_save_payload() -> Dictionary:
	var result := classic_campaign_save_result()
	return result.get("payload", {}) if str(result.get("status", "")) == "ok" else {}


func classic_campaign_save_result() -> Dictionary:
	if not is_classic_campaign(currentcampaign):
		return {"status": "ok", "handled": false, "payload": {}}
	if StateMachine.is_combat_state():
		return {
			"status": "error",
			"message": "Finish the current battle before saving",
		}
	if (
		not is_instance_valid(classic_campaign_session)
		or not classic_campaign_session.has_method("make_save_result")
	):
		return {"status": "error", "message": "Classic campaign state is unavailable"}
	var save_point_result: Variant = classic_campaign_session.call("validate_save_point")
	if save_point_result is Dictionary \
			and str(save_point_result.get("status", "")) == "error":
		return save_point_result
	if map != null and map.owcharacter != null:
		var sync_result: Variant = classic_campaign_session.call("sync_native_location", {
			"mapName": currentmap_name,
			"x": int(map.owcharacter.tile_position_x),
			"y": int(map.owcharacter.tile_position_y),
		})
		if sync_result is Dictionary and str(sync_result.get("status", "")) == "error":
			return {
				"status": "error",
				"message": str(sync_result.get(
					"message",
					"Classic save location could not be recorded"
				)),
			}
	var save_result: Variant = classic_campaign_session.call("make_save_result")
	return save_result if save_result is Dictionary else {
		"status": "error",
		"message": "Classic campaign state could not be serialized",
	}


func validate_classic_campaign_save(campaign_name: String, payload: Variant) -> Dictionary:
	if not is_classic_campaign(campaign_name):
		return {"status": "ok", "handled": false}
	var envelope_validation: Dictionary = ClassicCampaignSessionScript.validate_save_payload(
		payload
	)
	if str(envelope_validation.get("status", "")) != "ok":
		return envelope_validation
	var install = get_classic_campaign_install(campaign_name)
	if install == null or not str(install.last_error).is_empty():
		return {
			"status": "error",
			"message": (
				"Classic campaign is unavailable"
				if install == null
				else str(install.last_error)
			),
		}
	var campaign_validation: Dictionary = ClassicCampaignSessionScript.validate_save_payload(
		payload,
		str(install.bundle.manifest.get("id", ""))
	)
	if str(campaign_validation.get("status", "")) != "ok":
		return campaign_validation
	return ScenarioGodotServicesScript.validate_classic_save_state(
		payload.get("portState", {}).get("core.inventory", {})
	)


func start_current_classic_campaign(
	saved_payload: Dictionary = {},
	legacy_location: Dictionary = {}
) -> Dictionary:
	if not is_classic_campaign(currentcampaign):
		return {"handled": false}
	stop_classic_campaign_runtime()
	var session = ClassicCampaignSessionScript.new()
	add_child(session)
	var load_result: Dictionary = session.load_installed_campaign(
		Paths.campaignsfolderpath,
		currentcampaign,
		ScenarioGodotServicesScript.new(),
		get_classic_campaign_install(currentcampaign),
		new_gameplay_rule_selection
	)
	if str(load_result.get("status", "")) == "error":
		session.queue_free()
		return {
			"handled": true,
			"status": "error",
			"message": str(load_result.get("message", "Classic campaign could not be loaded")),
		}
	classic_campaign_session = session
	register_classic_runtime_host(session.host)
	var restore_result := {"status": "ok"}
	if not saved_payload.is_empty():
		restore_result = session.restore_save_payload(saved_payload)
	elif not legacy_location.is_empty():
		restore_result = {
			"status": "error",
			"message": (
				"This save predates scenario runtime v2 and cannot be upgraded; "
				+ "start a new playthrough"
			),
		}
	if str(restore_result.get("status", "")) == "error":
		stop_classic_campaign_runtime()
		return {
			"handled": true,
			"status": "error",
			"message": str(restore_result.get("message", "Classic save could not be restored")),
		}
	var character_rules_result: Dictionary = session.apply_character_rules(player_characters)
	if str(character_rules_result.get("status", "")) == "error":
		stop_classic_campaign_runtime()
		return {
			"handled": true,
			"status": "error",
			"message": str(character_rules_result.get(
				"message",
				"Classic character rules could not be applied"
			)),
		}
	var restored := not saved_payload.is_empty() or not legacy_location.is_empty()
	var start_result: Dictionary = session.activate_start_location(restored)
	start_result["handled"] = true
	start_result["restored"] = restored
	if str(start_result.get("status", "")) == "error":
		stop_classic_campaign_runtime()
	return start_result


func resume_current_classic_continuation() -> Dictionary:
	if not is_instance_valid(classic_campaign_session) \
			or not classic_campaign_session.has_method("resume_saved_continuation"):
		return {"status": "ok", "handled": false}
	var result: Variant = classic_campaign_session.call("resume_saved_continuation")
	if result is Dictionary and str(result.get("status", "")) == "error":
		push_error(str(result.get("message", "Classic continuation could not resume")))
	return result if result is Dictionary else {
		"status": "error",
		"message": "Classic continuation returned an invalid result",
	}


func dispatch_classic_map_script(script_name: String, context := {}) -> Dictionary:
	if (
		not is_instance_valid(classic_runtime_host)
		or not classic_runtime_host.has_method("has_trigger")
		or not classic_runtime_host.call("has_trigger", script_name)
	):
		return {"handled": false}
	if not classic_runtime_host.has_method("run_trigger"):
		return {
			"handled": true,
			"result": {
				"status": "error",
				"message": "Registered Classic runtime host cannot run triggers",
			},
		}
	var result: Variant = await classic_runtime_host.call(
		"run_trigger",
		script_name,
		0,
		context
	)
	return {
		"handled": true,
		"result": result if result is Dictionary else {},
	}

func show_loot_menu(
	items: Array,
	money: Array,
	experience: int,
	classic_battle_reward := false
) :
	await UI.ow_hud.show_loot_menu(
		items,
		money,
		experience,
		classic_battle_reward
	)



func set_current_campaign(
	campname: String,
	selection_rules: Variant = null,
	gameplay_rule_selection: Variant = {}
) :
	if not is_classic_campaign(campname):
		push_error(
			"Campaign '%s' does not use the scenario v2 contract and cannot be started" % campname
		)
		currentcampaign = ""
		currentcampaign_onload_script = null
		new_gameplay_rule_selection = {}
		return
	if currentcampaign != campname:
		stop_classic_campaign_runtime()
	currentcampaign = campname
	currentcampaign_onload_script = (
		selection_rules
		if selection_rules != null
		else get_campaign_selection_rules(currentcampaign)
	)
	new_gameplay_rule_selection = (
		gameplay_rule_selection.duplicate(true)
		if gameplay_rule_selection is Dictionary
		else {}
	)


func is_classic_campaign(campaign_name: String) -> bool:
	return ClassicCampaignInstallScript.has_manifest(
		Paths.campaignsfolderpath,
		campaign_name
	)


func get_campaign_selection_rules(campaign_name: String) -> Variant:
	if is_classic_campaign(campaign_name):
		var install = get_classic_campaign_install(campaign_name)
		return install.selection_rules()
	return {
		"classic": false,
		"valid": false,
		"title": campaign_name,
		"readinessState": "Unsupported",
		"readinessSummary": (
			"Legacy native campaign scripts are no longer executable. "
			+ "Export this campaign as a realmz-remake-scenario v2 package."
		),
	}


func get_campaign_selection_preview(campaign_name: String) -> Variant:
	if is_classic_campaign(campaign_name):
		return ClassicCampaignInstallScript.preview_from_campaigns_directory(
			Paths.campaignsfolderpath,
			campaign_name
		)
	return get_campaign_selection_rules(campaign_name)


func get_classic_campaign_install(campaign_name: String) -> Object:
	if not is_classic_campaign(campaign_name):
		return null
	var cached: Variant = classic_campaign_install_cache.get(campaign_name)
	var expected_directory := (
		Paths.campaignsfolderpath
		.strip_edges()
		.replace("\\", "/")
		.trim_suffix("/")
		.path_join(campaign_name)
	)
	if (
		cached is Object
		and str(cached.get("campaign_directory")) == expected_directory
	):
		return cached
	var install = ClassicCampaignInstallScript.new()
	install.load_from_campaigns_directory(Paths.campaignsfolderpath, campaign_name)
	classic_campaign_install_cache[campaign_name] = install
	return install


func clear_classic_campaign_install_cache(campaign_name := "") -> void:
	if campaign_name.is_empty():
		classic_campaign_install_cache.clear()
	else:
		classic_campaign_install_cache.erase(campaign_name)


func get_campaign_description(campaign_name : String) -> String:
	var campaign_onload_script: Variant = get_campaign_selection_rules(campaign_name)
	if campaign_onload_script==null :
		print("NO currentcampaign_onload_script loaded !!!")
		return "NO currentcampaign_onload_script loaded !!!"
	if campaign_onload_script is Dictionary:
		return str(campaign_onload_script.get("description", ""))
	return campaign_onload_script.description

func get_campaign_restrictions_description(campaign_name : String, campaign_onload_script) -> String:
	if campaign_onload_script==null :
		print("campaign_onload_script loaded !!!")
		return "Pick a campaign first !"
	if campaign_onload_script is Dictionary:
		return str(campaign_onload_script.get("restrictionsDescription", ""))
	return campaign_onload_script.restrictions_description

func can_character_enter_campaign(chara, campaign_name : String,campaign_onload_script ) -> bool :
	return bool(
		get_character_campaign_admission(
			chara,
			campaign_name,
			campaign_onload_script
		).get("allowed", false)
	)


func get_character_campaign_admission(
	chara,
	campaign_name: String,
	campaign_onload_script
) -> Dictionary:
	if campaign_onload_script==null :
		print("NO campaign_onload_script loaded !!!")
		return {
			"allowed": false,
			"reason": "Pick a campaign first.",
			"code": "missing-campaign",
		}
	var honesty : bool = true
	honesty = campaign_name == chara.cur_campaign or chara.cur_campaign=="Free"
	honesty = honesty or (not honest_mode)
	if not honesty:
		return {
			"allowed": false,
			"reason": "%s is already assigned to %s." % [chara.name, chara.cur_campaign],
			"code": "campaign-assignment",
		}
	if campaign_onload_script is Dictionary:
		return ClassicCampaignAdmissionScript.character_admission(
			chara,
			campaign_onload_script
		)
	if campaign_onload_script.can_character_enter(chara):
		return {"allowed": true, "reason": "", "code": "allowed"}
	return {
		"allowed": false,
		"reason": "%s does not meet this campaign's character restrictions." % chara.name,
		"code": "native-campaign-restriction",
	}

func get_campaign_max_party_size(campaign_onselect) -> int :
	if campaign_onselect==null :
		print("NO currentcampaign_onload_script loaded !!!")
		return 0
	if campaign_onselect is Dictionary:
		return int(campaign_onselect.get("charactersLimit", 0))
	return campaign_onselect.characters_limit


func validate_campaign_party(
	party: Array,
	campaign_name: String,
	campaign_onselect
) -> Dictionary:
	if campaign_onselect == null:
		return {
			"allowed": false,
			"reason": "Pick a campaign first.",
			"code": "missing-campaign",
		}
	if campaign_onselect is Dictionary:
		for character in party:
			var character_result := get_character_campaign_admission(
				character,
				campaign_name,
				campaign_onselect
			)
			if not bool(character_result.get("allowed", false)):
				return character_result
		return ClassicCampaignAdmissionScript.party_admission(party, campaign_onselect)
	if party.is_empty():
		return {
			"allowed": false,
			"reason": "Select at least one character.",
			"code": "empty-party",
		}
	var characters_limit := get_campaign_max_party_size(campaign_onselect)
	if characters_limit > 0 and party.size() > characters_limit:
		return {
			"allowed": false,
			"reason": "This campaign allows at most %d characters." % characters_limit,
			"code": "party-size",
		}
	return {"allowed": true, "reason": "", "code": "allowed"}


func allow_character_swap(yes : bool) :
	# enables the party swap button until you move
	UI.ow_hud.set_party_swap_enabled(yes)

func allow_money_change(yes : bool) :
	# enables the party swap button until you move
	UI.ow_hud.set_money_change_enabled(yes)

func allow_banking(yes : bool) :
	UI.ow_hud.set_banking_availlable(yes)

func allow_temple(yes : bool) :
	UI.ow_hud.set_temple_availlable(yes)

func allow_honest_storage(yes : bool) :
	UI.ow_hud.set_allow_honest_storage(honest_mode and yes)

func change_map(mapname : String, x : int, y : int) :
	print("GameGlobal change_map : "+mapname+" ; "+ str(Vector2(x,y)))
	if mapname == 'temporary_zoomed_map':
		map.generate_zoomed_map(currentmap_name)
	else :
		if (
			not cmp_resources.maps_book.has(mapname)
			and not cmp_resources.ensure_campaign_map_resource(
				currentcampaign,
				mapname
			)
		):
			push_error("Campaign map resource is unavailable: %s" % mapname)
			return
		map.load_map(currentcampaign, mapname)
	currentmap_name = mapname


	MusicStreamPlayer.play_music_map()
	map.set_ow_character_icon(GameGlobal.player_characters[0].icon)
#	GameState.map.focuscharacter.tile_position_x = x
#	GameState.map.focuscharacter.tile_position_y = y
	map.focuscharacter.set_tile_position(Vector2(x,y))
	map.owcharacter.set_tile_position(Vector2(x,y))
#	print("GAMEGLOBAL change_map Vector2(x,y)  ", Vector2(x,y))
	map.explore_tiles_from_tilepos(Vector2(x,y))
	#	GameState.map.focuscharacter.tile_position_x = pos_when_battle_started.x
#	GameState.map.focuscharacter.tile_position_y = pos_when_battle_started.y


func is_map_tile_walkable_by_char(chara, pos : Vector2)->bool : #battle mode, chara is creature
#	print("gamestate is_map_tile_walkable_by_char ",  chara.name, " ,pos: ", pos)
#	print("is_map_tile_walkable_by_char TODO check character itself :")
#	print("map.mapdata[pos.x][pos.y]", map.mapdata[pos.x][pos.y])
	print("GameGlobal is_map_tile_walkable_by_char "+chara.name+" pos:"+str(pos))
	var tileitemlightstack : Array = map.mapdata[pos.x][pos.y]
	if tileitemlightstack.is_empty() :
		return false
	var tilestack : Array = tileitemlightstack
	var stacksize = tilestack.size()
#	print("canc char walk, tilestack : ", tilestack)
#	print("tilestack : ", tilestack)
	for i  in range(stacksize) :
		var tiledict : Dictionary = tilestack[stacksize-i-1]
		var idef = tiledict#tiles_book[]
		if idef['wall'] != 0 or  (idef['swall'] != 0 and chara.size == Vector2.ONE):
			return false
	return true


func rest() -> bool:
	if is_classic_runtime_active():
		if not camping or classic_camping_disabled:
			return false
		set_party_fatigue(ClassicRestScript.fatigue_before_rest(fatigue))
		pass_time(classic_timeclick_pass_time_units(
			ClassicRestScript.REST_TIMECLICKS,
			_current_classic_base_scale()
		))
		await _check_classic_random_encounter()
		return true
	var mult : float = -2.0 if camping else -1.0
	pass_time(5, mult)
	return true


func advance_classic_camp_transition(entering_camp: bool) -> void:
	if not is_classic_runtime_active():
		return
	var timeclicks: int = (
		ClassicRestScript.REST_TIMECLICKS
		if entering_camp
		else ClassicRestScript.CAMP_EXIT_TIMECLICKS
	)
	pass_time(classic_timeclick_pass_time_units(
		timeclicks,
		_current_classic_base_scale()
	))
	if entering_camp:
		await _check_classic_random_encounter()


func advance_classic_camp_movement_exit() -> void:
	if not is_classic_runtime_active():
		return
	var base_scale := _current_classic_base_scale()
	var timeclicks: int = (
		ClassicRestScript.CAMP_EXIT_TIMECLICKS
		if base_scale != 0
		else ClassicRestScript.OUTDOOR_CAMP_MOVEMENT_EXIT_TIMECLICKS
	)
	pass_time(classic_timeclick_pass_time_units(timeclicks, base_scale))
	await _check_classic_random_encounter()


func _check_classic_random_encounter() -> bool:
	if not is_classic_runtime_active() \
			or StateMachine.is_combat_state() \
			or map == null \
			or map.owcharacter == null:
		return false
	var position := Vector2i(
		int(map.owcharacter.tile_position_x),
		int(map.owcharacter.tile_position_y)
	)
	return await check_classic_random_rectangles(position)


func check_classic_random_rectangles(
	position: Vector2i,
	context := {}
) -> bool:
	if not is_classic_runtime_active() \
			or StateMachine.is_combat_state() \
			or map == null \
			or not is_instance_valid(classic_runtime_host) \
			or not classic_runtime_host.has_method("get_random_rectangle"):
		return false
	var candidates: Dictionary = {}
	for area_name_value: Variant in map.mapscriptareas:
		var area_name := str(area_name_value)
		var area_value: Variant = map.mapscriptareas[area_name_value]
		if not (area_value is Dictionary):
			continue
		var area: Dictionary = area_value
		var identity: Dictionary = ClassicRandomRectangleScript.identity(
			area_name,
			area
		)
		if identity.is_empty():
			continue
		var rect_index := int(identity["rectIndex"])
		candidates[rect_index] = {
			"area": area,
			"areaName": area_name,
			"identity": identity,
		}

	for rect_index: int in range(
		ClassicRandomRectangleScript.MAX_RECTANGLES - 1,
		-1,
		-1
	):
		if not candidates.has(rect_index):
			continue
		var candidate: Dictionary = candidates[rect_index]
		var area: Dictionary = candidate["area"]
		var identity: Dictionary = candidate["identity"]
		var rectangle_value: Variant = classic_runtime_host.call(
			"get_random_rectangle",
			str(identity["levelType"]),
			int(identity["levelIndex"]),
			rect_index
		)
		if not (rectangle_value is Dictionary):
			continue
		var rectangle: Dictionary = rectangle_value
		if not ClassicRandomRectangleScript.contains(rectangle, area, position):
			continue
		var chance_succeeded: bool = bool(
			ClassicRandomRectangleScript.chance_succeeds(
				rectangle,
				area,
				randi_range(1, 10000)
			)
		)
		if chance_succeeded:
			for outcome: Dictionary in ClassicRandomRectangleScript.door_outcomes(
				rectangle
			):
				var trigger_index := int(outcome["triggerId"])
				var door_percent := int(outcome["percent"])
				if trigger_index <= 0 or not ClassicRandomRectangleScript.door_roll_succeeds(
					door_percent,
					randi_range(1, 100)
				):
					continue
				if door_percent > 0:
					var consumed: Dictionary = classic_runtime_host.call(
						"consume_random_rectangle_door",
						str(identity["levelType"]),
						int(identity["levelIndex"]),
						rect_index,
						int(outcome["doorIndex"])
					)
					if str(consumed.get("status", "")) == "error":
						push_error(str(consumed.get(
							"message",
							"Classic random-door state could not be saved"
						)))
						return false
					rectangle = consumed.get("rectangle", rectangle)
					ClassicRandomRectangleScript.apply_rectangle(
						area,
						str(identity["levelType"]),
						int(identity["levelIndex"]),
						rectangle,
						str(area.get("RR_Battle", {}).get("text", ""))
					)
					map.mapscriptareas[candidate["areaName"]] = area
				var trigger_id := "Data ED3:macro:%d" % trigger_index
				var dispatch_context: Dictionary = context.duplicate(true) \
					if context is Dictionary else {}
				dispatch_context.merge({
					"mapPosition": position,
					"randomRectangleIndex": rect_index,
					"randomDoorIndex": int(outcome["doorIndex"]),
				}, true)
				var dispatch := await dispatch_classic_map_script(
					trigger_id,
					dispatch_context
				)
				if not bool(dispatch.get("handled", false)):
					push_error(
						"Classic random rectangle references missing trigger %s"
						% trigger_id
					)
					return false
				var trigger_result: Variant = dispatch.get("result", {})
				if trigger_result is Dictionary \
						and str(trigger_result.get("status", "")) == "error":
					push_error(str(trigger_result.get(
						"message",
						"Classic random-rectangle trigger stopped"
					)))
				return true

			if random_battles_allowed() \
					and ClassicRandomRectangleScript.has_battle(rectangle, area):
				await ScriptHelperFuncsClass.do_RR_battle(area["RR_Battle"])
				return true
		if ClassicRandomRectangleScript.is_only(rectangle, area):
			break
	return false


func _consume_classic_rest_ration() -> bool:
	var resources := NodeAccess.__Resources()
	if resources == null or not resources.has_method("item_classic_ids"):
		return false
	for character: Variant in player_characters:
		if not (character is Object):
			continue
		var inventory_value: Variant = character.get("item_inventory")
		if not (inventory_value is Array):
			continue
		for item: Variant in inventory_value:
			if not (item is ItemInstance) \
					or not resources.item_classic_ids(item).has(877):
				continue
			if item.charges <= 0:
				return false
			item.charges -= 1
			var definition := resources.get_item_definition(item)
			if item.charges == 0 \
					and definition != null \
					and definition.delete_on_empty \
					and character.has_method("remove_inventory_item"):
				character.remove_inventory_item(item)
			return true
	return false


#if pc_participating is empty, use all PC
func start_battle(battlename : String, mapname : String, is_pos_relative : bool, is_ambush : bool, allow_loss : bool, allow_escape : bool, npcs_allowed : bool, pc_participating : Array, battle_overrides := {}) :
	print("GameGlobal start_battle " + battlename)
	StateMachine.combat_state.reset_battle_completion()
	var battle_data : Dictionary = GameGlobal.cmp_resources.battles_book[battlename].duplicate()
	for override_key: Variant in battle_overrides:
		battle_data[override_key] = battle_overrides[override_key]
	battle_data["battle_start"] = true
	battle_data["battlename"] = battlename
	if not mapname.is_empty() :
		battle_data["Map"] = mapname
	battle_data["is_ambush"] = is_ambush
	battle_data["allow_loss"] = allow_loss
	battle_data["allow_escape"] = allow_escape
	battle_data["npcs_allowed"] = npcs_allowed
	var pc_part : Array = player_characters if pc_participating.is_empty() else pc_participating
	battle_data["pc_participating"] = pc_part
	battle_data["end_in_map_name"] = currentmap_name
	#battle_data["is_relative_coords"] = is_pos_relative
	UI.ow_hud.combatBRPanel.escape_allowed = allow_escape
	var ow_character =  map.owcharacter
	pos_when_battle_started = Vector2(ow_character.tile_position_x,ow_character.tile_position_y)
	#map.targetingLayer.ensure_connection_with(StateMachine.cb_target_state)
	StateMachine.transition_to("Combat/CbDecideAction",battle_data)
	return








func end_battle(
	wonfledlost: String,
	reward_mode := BATTLE_REWARD_NORMAL
) :
	if not StateMachine.combat_state.begin_battle_completion():
		return
	print("GameGlobal end_battle", last_exploration_map_name,wonfledlost)
	StateMachine.combat_state.battle_creatures_yet_to_act_btns.clear()
	StateMachine.combat_state.all_battle_creatures_btns.clear()
	StateMachine.combat_state.action_queue.clear()
	map.focuscharacter.tile_position_x = pos_when_battle_started.x
	map.focuscharacter.tile_position_y = pos_when_battle_started.y

#
	#for cb in GameState.map.creatures_node.get_children() :
		#cb.queue_free()   #done in MAp.load map now
	#print("GameGlobal end_battle pos_when_battle_started : ", pos_when_battle_started)

	if not (wonfledlost == 'lost' and (not StateMachine.combat_state.cur_battle_data["allow_loss"])) :
		#if not game over...
		print("GameGlobal end battle : last_exploration_map_name : "+last_exploration_map_name)
		change_map(last_exploration_map_name,pos_when_battle_started.x,pos_when_battle_started.y)

	UI.ow_hud.exit_battle_mode()

	match wonfledlost :
		"won" :
			#print("GameGlobal end_battle : battle won !")
			if StateMachine.combat_state.cur_battle_data["Scripts"].has("_on_battle_win") :
				StateMachine.combat_state.cur_battle_data["Scripts"]["_on_battle_win"].win()
			#var textRect = UI.ow_hud.textRect
			var treasureControl = UI.ow_hud.treasureControl
##	var healpottemplate = NodeAccess.__Resources().items_book["Health Potion"]
			var rewards := {
				"treasure": [],
				"experience": 0,
				"money": [0, 0, 0],
			}
			if allow_next_battle_loot :
				rewards = BattleRewardRulesScript.collect(
					StateMachine.combat_state.battle_dead_enemies,
					str(reward_mode) == BATTLE_REWARD_EXPERIENCE_ONLY
				)
				if str(reward_mode) != BATTLE_REWARD_EXPERIENCE_ONLY:
					rewards["treasure"].append_array(
						StateMachine.combat_state.classic_fumbled_items
					)
			allow_next_battle_loot = true

			#this won't show the allies  screen
			#await UI.ow_hud.show_loot_menu(treasureitems,money_drop,experience)

			StateMachine.combat_state.all_battle_creatures_btns.clear()
			StateMachine.combat_state.battle_dead_enemies.clear()
			StateMachine.combat_state.battle_dead_party_members.clear()
			StateMachine.combat_state.classic_fumbled_items.clear()



			StateMachine.transition_to("Exploration/ExMenus", {
				"menu_name": "LootMenu",
				"treasure": rewards["treasure"],
				"money": rewards["money"],
				"exp": rewards["experience"],
				"classicBattleReward": true,
				"prev_state": "Exploration",
			})
			await UI.ow_hud.treasureControl.done_looting
			print("done looting")
			if not player_allies.is_empty():
				GameGlobal.show_allies_menu()
				await UI.ow_hud.alliesCtrl.done_allying
				print("done allying")



			#show_allies_menu()
			#await UI.ow_hud.alliesCtrl.done_allying
			##GameState._combat_state = eCombatStates.unchecked
			##GameState._state = eGameStates.inGame
			#map.focuscharacter = map.owcharacter
			#map.focuscharacter.show()
			## why is  set_tile_position still needed after change_map ?
			#map.focuscharacter.set_tile_position(pos_when_battle_started)
			#emit_signal("battle_end", "won")
			#
			#
		"fled" :
			allow_next_battle_loot = true
		"lost" :
			#print("GameGlobal end_battle : battle lost !")
			allow_next_battle_loot = true

			if StateMachine.combat_state.cur_battle_data["allow_loss"] :
				StateMachine.transition_to("Exploration",{})
				##GameState._combat_state = eCombatStates.unchecked
				##GameState._state = eGameStates.inGame
				#map.focuscharacter = GameGlobal.map.owcharacter
				#map.focuscharacter.show()
				## why is  set_tile_position still needed after change_map ?
				#map.focuscharacter.set_tile_position(pos_when_battle_started)
				#cur_battle_data["Scripts"]["lose"].lose()
				#emit_signal("battle_end", "lost")
			else :
				# Stop music on game over
				MusicStreamPlayer.stop()
				print("GameGlobal end_battle : GAME OVER")
				if cmp_resources.sounds_book.has("party loss.wav") :
					SfxPlayer.stream = cmp_resources.sounds_book["party loss.wav"]
					SfxPlayer.play()
				ScriptHelperFuncs.play_sound('party loss.wav', false)
				StateMachine.transition_to("Inactive",{})
				##GameState._state = eGameStates.unchecked
				##GameState._combat_state = eCombatStates.unchecked
				GameGlobal.player_characters.clear()
				cmp_resources.clear_ressources()
				UI.show_only(UI.main_menu)
				UI.main_menu.newCampaignPanel.hide()
				return
		#'_' :
			#print("GameGlobal end_battle, INVALID wonfledlost :")
	#
	#cur_battle_data = {}
	#cur_battle_data.clear() CLEARED THE RESOURCE DICT  LOL
	allow_next_battle_loot = true
	StateMachine.combat_state.classic_fumbled_items.clear()
	print("GAMEGLOBAL emit_signal('battle_end', wonfledlost)")
	emit_signal("battle_end", wonfledlost)
	map.focuscharacter = map.owcharacter
	map.focuscharacter.show()
	# why is  set_tile_position still needed after change_map ?
	map.focuscharacter.set_tile_position(pos_when_battle_started)
	return

func who_is_at_tile(pos : Vector2) -> CombatCreaButton : #for battle, returns the creature COMBAT BUTTON at that position
#	var all_creatures : Array = []
#	print("gameglobel who_is_at_tile ", pos)
	for b in StateMachine.combat_state.all_battle_creatures_btns :
		var c = b.creature
		var xsize = max(0,c.size.x)
		var ysize = max(0,c.size.y)
		for xs in range(xsize) :
#			print('  xs : '+str(xs))
			for ys in range(ysize) :
#				print("  "+c.name+' :  '+str(c.position))
				if c.position.x+xs == pos.x and c.position.y+ys==pos.y :
					return b
	return null


func add_pc_or_npcally_to_battle_map(crea : Creature, init_pos : Vector2) -> bool:
	return StateMachine.add_pc_or_npcally_to_battle_map(crea , init_pos)

func remove_creab_from_battle_map(cb : CombatCreaButton) :
	StateMachine.combat_state.remove_cb_from_battle(cb)

enum ELEMENTS {FIRE = 0, ICE = 1, ELECTRIC = 2, POISON = 3, CHEMICAL = 4, DISEASE = 5, HEALING = 6, MENTAL = 7, PHYSICAL = 8, MAGICAL =9}

const elements_ColorDict : Dictionary = {ELEMENTS.FIRE : Color.ORANGE, ELEMENTS.ICE : Color.CYAN,
				 ELEMENTS.ELECTRIC : Color.MEDIUM_SLATE_BLUE, ELEMENTS.POISON : Color.FOREST_GREEN,
				 ELEMENTS.CHEMICAL : Color.GREEN_YELLOW, ELEMENTS.DISEASE : Color.YELLOW,
				ELEMENTS.HEALING : Color.WHITE, ELEMENTS.MENTAL : Color.DEEP_PINK, 
				ELEMENTS.PHYSICAL : Color.LIGHT_CYAN, ELEMENTS.MAGICAL: Color.CORNFLOWER_BLUE}

var elements_names : Dictionary = {ELEMENTS.FIRE : "Fire", ELEMENTS.ICE :"Ice", ELEMENTS.ELECTRIC : "Electric", ELEMENTS.POISON : "Poison",
									ELEMENTS.CHEMICAL : "Chemical", ELEMENTS.DISEASE : "Disease", ELEMENTS.HEALING : "Healing",
									ELEMENTS.MENTAL : "Mental", ELEMENTS.PHYSICAL : "Physical", ELEMENTS.MAGICAL :"Magical"}
func get_element_name(elem : ELEMENTS) :
	print("GameGlobal elements_names : ", elements_names, ", has ", elem, " ? ", elements_names.has(elem))
	return elements_names[elem]


#still used for non-spells, ##TODO
const dmg_type_def_stats_dict : Dictionary = {
	"Fire"    : ["ResistanceFire","MultiplierFire"],
	"Ice"     : ["ResistanceIce","MultiplierIce"],
	"Electric": ["ResistanceElect","MultiplierElect"],
	"Poison"  : ["ResistancePoison","MultiplierPoison"],
	"Chemical": ["ResistanceChemical","MultiplierChemical"],
	"Disease" : ["ResistanceDisease","MultiplierDisease"],
	"Healing" : ["ResistanceHealing","MultiplierHealing"],
	"Mental"  : ["ResistanceMental","MultiplierMental"],
	"Physical": ["ResistancePhysical","MultiplierPhysical"],
	"Magical" : ["ResistanceMagic","MultiplierMagic"]
	}


#  name : [resistance, multiplier], resistance is +- reduction
const dmg_spell_elem_def_stats_dict : Dictionary = {
	ELEMENTS.FIRE    : ["ResistanceFire","MultiplierFire"],
	ELEMENTS.ICE     : ["ResistanceIce","MultiplierIce"],
	ELEMENTS.ELECTRIC: ["ResistanceElect","MultiplierElect"],
	ELEMENTS.POISON  : ["ResistancePoison","MultiplierPoison"],
	ELEMENTS.CHEMICAL: ["ResistanceChemical","MultiplierChemical"],
	ELEMENTS.DISEASE : ["ResistanceDisease","MultiplierDisease"],
	ELEMENTS.HEALING : ["ResistanceHealing","MultiplierHealing"],
	ELEMENTS.MENTAL  : ["ResistanceMental","MultiplierMental"],
	ELEMENTS.PHYSICAL: ["ResistancePhysical","MultiplierPhysical"],
	ELEMENTS.MAGICAL : ["ResistanceMagic","MultiplierMagic"]
	}


#returns a float  between 0.0 and 1.0, to use as a chance
func calculate_melee_accuracy(attacker : Creature, defender : Creature, weapon: Variant, should_check_script : bool = true) -> float :
	var weapon_instance: ItemInstance = attacker.get_item_instance(weapon)
	var resources = NodeAccess.__Resources()
	var compatibility_weapon: Dictionary = (
		resources.legacy_item_view_for_adapter(weapon_instance)
		if weapon_instance != null else weapon if weapon is Dictionary else {}
	)
	var accuracy : float = 0.0
	var evasion : float = 0.0
	if not ClassicMonsterWeaponRulesScript.can_hit(
		attacker,
		defender,
		compatibility_weapon,
	):
		return 0.0
	if weapon_instance != null and should_check_script \
			and resources.item_has_hook(weapon_instance, "melee_accuracy"):
		var hook_result: Dictionary = resources.run_item_hook(
			weapon_instance,
			"melee_accuracy",
			[attacker, defender],
		)
		if not bool(hook_result.get("ok", false)):
			for message: Variant in hook_result.get("errors", []):
				push_error(str(message))
			return 0.0
		accuracy = float(hook_result.get("value", 0.0))
	else :
		accuracy = attacker.get_stat("AccuracyMelee")  #checks traits too
		evasion = _classic_melee_evasion(defender)
		accuracy = clampf(0.5+0.05*(accuracy-evasion), 0.0, 1.0)
	accuracy = clampf(
		accuracy
			+ 0.05 * ClassicCharacterRulesScript.classic_foe_type_bonus(
				attacker,
				defender
			),
		0.0,
		1.0
	)
	return ClassicProtectionFromFoeScript.adjust_melee_accuracy(
		accuracy,
		attacker,
		defender
	)


func _classic_melee_evasion(defender: Variant) -> float:
	if defender is Object and defender.has_meta("classic_armor"):
		return float(defender.get_meta("classic_armor")) / 5.0
	return float(defender.get_stat("EvasionMelee"))


func calculate_melee_damage(attacker : Creature, defender : Creature, weapon: Variant, is_crit : bool, crit_mult : float, should_check_script : bool = true) -> Dictionary :
#	print("GameGlobal calculate_melee_damage, atker : ",attacker.name,", defnder : ",defender.name, " check script : ", should_check_script)
	var weapon_instance: ItemInstance = attacker.get_item_instance(weapon)
	var resources = NodeAccess.__Resources()
	var definition: ItemDefinition = resources.get_item_definition(weapon_instance) \
		if weapon_instance != null else null
	var weapon_damage : Dictionary = {"Physical": 0}
#	print(weapon)
	if weapon_instance != null and should_check_script \
			and resources.item_has_hook(weapon_instance, "melee_attack"):
		print("GameGlobal calculate_melee_damage USE CUSTOM ATK STRIPT")
		var hook_result: Dictionary = resources.run_item_hook(
			weapon_instance,
			"melee_attack",
			[attacker, defender, is_crit, crit_mult],
		)
		if not bool(hook_result.get("ok", false)):
			for message: Variant in hook_result.get("errors", []):
				push_error(str(message))
			return weapon_damage
		var custom_damage: Dictionary = hook_result.get("value", {})
		custom_damage = apply_classic_foe_type_damage_bonus(
			custom_damage,
			attacker,
			defender,
			is_crit,
			crit_mult
		)
		return apply_classic_party_weapon_protection(custom_damage, attacker, defender)
	#if weapon["name"] == "NO_MELEE_WEAPON" :
		#print("GameGlobal calculate_melee_damage NO_MELEE_WEAPON : ", weapon)
	var wpn_dmg_types: Dictionary = definition.weapon_damage() \
		if definition != null else weapon.get("weapon_dmg", {}) \
		if weapon is Dictionary else {}
	for t in wpn_dmg_types :
		var t_dmg_range : Array = wpn_dmg_types[t]
		if t == "Physical" and weapon is Dictionary:
			t_dmg_range = (
				ClassicCharacterRulesScript.adjusted_unarmed_damage_range(
					attacker,
					weapon,
					t_dmg_range
				)
			)
		var t_damage : float = float( randi_range(t_dmg_range[0], t_dmg_range[1]) )
		weapon_damage[t] = t_damage
	var tagged_weapon_damage: Dictionary = definition.tagged_weapon_damage() \
		if definition != null else weapon.get("weapon_tag_bonus_dmg", {}) \
		if weapon is Dictionary else {}
	if not tagged_weapon_damage.is_empty():
		for t in tagged_weapon_damage:
			if defender.tags.has(t) :
				for e in tagged_weapon_damage[t]:
					if not weapon_damage.has(e) :
						weapon_damage[e]=0
					var bonus_value: Variant = tagged_weapon_damage[t][e]
					if bonus_value is Array and bonus_value.size() >= 2:
						weapon_damage[e] += randi_range(
							int(bonus_value[0]),
							int(bonus_value[1])
						)
					else:
						weapon_damage[e] += bonus_value

	#}
	#print("GameGlobal calculate_melee_damage",weapon_damage)
	var def_stats : Dictionary = defender.stats
	var damage_detail : Dictionary = {}
	for t in weapon_damage :
		var res_name : String = dmg_type_def_stats_dict[t][0]
		var res_stat : float = def_stats[res_name]
		var mul_name : String = dmg_type_def_stats_dict[t][1]
		var mul_stat : float = def_stats[mul_name]
		#print("GameGlobal calculate damage : ,",res_name,res_stat, ' ',mul_name,mul_stat)
		if not damage_detail.has(t) :
			damage_detail[t]=0
		damage_detail[t] += max(0,weapon_damage[t] - res_stat) * mul_stat


	var damage_total : int = 0
	for t in damage_detail :
		damage_total+=damage_detail[t]

	var physical_damage_bonus : int = attacker.get_stat("Bonus_Physical_dmg") * sign(damage_total)
	damage_detail["Bonus_dmg"] = physical_damage_bonus
	damage_total += physical_damage_bonus
	damage_detail["total"]=int(damage_total)

	if is_crit :
		for dv in damage_detail.keys() :
			damage_detail[dv] = damage_detail[dv] * crit_mult
	damage_detail["is_crit"] = is_crit
	damage_detail["crit_mult"] = crit_mult
	damage_detail = apply_classic_foe_type_damage_bonus(
		damage_detail,
		attacker,
		defender,
		is_crit,
		crit_mult
	)
	return apply_classic_party_weapon_protection(damage_detail, attacker, defender)


func apply_classic_foe_type_damage_bonus(
	damage_detail: Dictionary,
	attacker: Object,
	defender: Object,
	is_crit: bool,
	crit_mult: float
) -> Dictionary:
	var base_bonus: int = ClassicCharacterRulesScript.classic_foe_type_bonus(
		attacker,
		defender
	)
	if base_bonus == 0:
		return damage_detail
	var result := damage_detail.duplicate()
	var applied_bonus := float(base_bonus) * (crit_mult if is_crit else 1.0)
	if applied_bonus < 0.0:
		applied_bonus = maxf(
			applied_bonus,
			-float(result.get("total", 0))
		)
	result["Bonus_dmg"] = float(result.get("Bonus_dmg", 0)) + applied_bonus
	result["total"] = float(result.get("total", 0)) + applied_bonus
	return result


func apply_classic_party_weapon_protection(
	damage_detail: Dictionary,
	attacker: Object,
	defender: Object
) -> Dictionary:
	var protects_target := not _is_player_controlled_character(attacker) \
		and _is_player_controlled_character(defender)
	return ClassicPartyConditionScript.adjust_weapon_damage(
		damage_detail,
		int(classic_party_conditions.get("2", 0)),
		protects_target
	)

func calculate_spell_damage(attacker : Creature, defender : Creature, spell : Spell, spellpower : int, _should_check_script : bool = true) -> int :
	#print("Gameglobal calculate_spell_damage : atker", attacker.name, ", defer", defender.name,", spell:", spell.name)

	var ignoreres : bool = spell.resist==Spell.RESIST_TYPE.IGNORE_MRES_DODGE or spell.resist==Spell.RESIST_TYPE.IGNORE_MRES

	var spell_attributes : Array= spell.elements
#	var hits : int = spell.get_hits(spellpower, attacker)  #for ninja stars  arrowstorm etc.. TBI  #TODO
	var spell_damage : float = 0
	if spell.has_method("get_damage_total") :
		return spell.get_damage_total(spellpower, attacker, defender)
	if spell.has_method("get_damage_roll") :
		spell_damage = spell.get_damage_roll(spellpower, attacker)
	else :
		var dmg = 0
		var mindmg = spell.get_min_damage(spellpower, attacker)
		var maxdmg = spell.get_max_damage(spellpower, attacker)
		for i in range(spellpower) :
			dmg += mindmg+ randi()%maxdmg
		spell_damage = dmg
#	print("gamestate spell_damage : ",spell.name, ' ',spell_damage)
#	var def_stats : Dictionary = defender.stats
	for a in spell_attributes :
		if not dmg_spell_elem_def_stats_dict.has(a) :
			continue
		var res_name : String = dmg_spell_elem_def_stats_dict[a][0]
		var res_stat : float = defender.get_stat(res_name)
		if ignoreres :
			res_stat = signi(res_stat)
		var mul_name : String = dmg_spell_elem_def_stats_dict[a][1]
		var mul_stat : float = defender.get_stat(mul_name)
		spell_damage = max(0,spell_damage - res_stat)*mul_stat

#	var spell_effect : Dictionary = {"attributes" : spell_attributes, "status_inflicted" : {}, "status_given" : {}}
	#  status infliction ! Done in CbAnimState
#	for h in range(hits)
	var is_crit : bool = false
	var crit_mult : float = 1.0
	if spell.has_method("get_is_critical") :
		is_crit = spell.get_is_critical(attacker, defender, spellpower)
		if spell.has_method("get_critical_mult") :
			crit_mult = spell.get_critical_mult(attacker, defender, spellpower)
		#else :
			#if spell.has_method("get_range") :
				#var spellrange = spell.get_range(spellpower, attacker)
				#if spellrange > 1 :
					#crit_mult = spell.get_critical_mult(attacker, defender, spellpower)
	if is_crit :
		spell_damage *= crit_mult
	return roundi(spell_damage)

func calculate_spell_accuracy(caster : Creature, defender : Creature, spell, spellpower : int) -> Array :
	#resist==0  ignores both resistance and dodge, resist==1 ignores resistance, resist==2 ignores evasion, resist==3 ignores neither
	print("GAMEGLOBAL calculate_spell_accuracy ",caster.name,"'s ", spell.name)
	var res : int = spell.resist
	if res==0 or res==2 :
		#print("GAMEGLOBAL calculate_spell_accuracy  if res==0 or res==2 : return 1.0 ")
		return [1.0, []]
	var accuracy = 0
	var evasion = 0
	if spell.has_method("get_accuracy") and spell.has_method("get_evasion"):
		accuracy = spell.get_accuracy(caster,defender,spellpower)
		evasion = spell.get_evasion(caster,defender,spellpower)
		#print("  using spell methods : base_accuracy ", accuracy, ", base_evasion", evasion)
		return [clampf(0.5+0.05*(accuracy-evasion), 0.0, 1.0), []]
	var spell_attributes : Array= spell.attributes
	var base_accuracy : float = 1.0
	var evasion_stats_used : Array = []
	for a in spell_attributes :
		var evasionstat : float = 0
		#var accuracystat : float = 0
		if a=='Magical' :
			evasion_stats_used.append(a)
			evasionstat = defender.get_stat("EvasionMagic")
		#if a=='Physical' :
			#evasionstat = defender.get_stat("EvasionMagic")
		if a=='Ranged' :
			evasion_stats_used.append(a)
			evasionstat = defender.get_stat("EvasionRanged")
		if a=='Melee' :
			evasion_stats_used.append(a)
			evasionstat = defender.get_stat("EvasionMelee")
		#print(a, ' accuracystat : ',accuracystat,', evasionstat  ', evasionstat )
		base_accuracy = base_accuracy * (1.0+(accuracy-evasion) )

	#print("GameGlobal calculate_spell_accuracy : calculated ",base_accuracy)
	#  [continue_action : bool, added_to_action_queue : Array]


	return [clampf(base_accuracy, 0.0, 1.0), evasion_stats_used]


func do_spell_field_effect(
	caster : Creature,
	target : Creature,
	spell,
	plvl : int,
	damage_scale := 1.0
) :
	# Some Classic effects scale a non-health value after the target saves.
	if spell.has_method("apply_classic_scaled_effect") :
		spell.apply_classic_scaled_effect(caster, target, plvl, damage_scale)
		return
	var spell_dmg := int(calculate_spell_damage(caster, target, spell, plvl, false) * damage_scale)
	target.change_cur_hp(-spell_dmg)
	if spell.has_method("add_traits_to_creature") :
		spell.add_traits_to_creature(caster, target, plvl)
	if spell.get("special_effect") :
		await spell.special_effect(caster, spell, plvl, Vector2.ZERO, [], [target], false)


func add_npc_ally(crea : Creature) :
	crea.is_npc_ally = true
	crea.curFaction = 0
	crea.baseFaction = 0
	player_allies.append(crea)
	UI.ow_hud.fillCharactersRect()

func show_allies_menu() :
	UI.ow_hud.alliesCtrl.fill(player_allies)
	UI.ow_hud.alliesWindow.show()

# returns true if a levelup occured
func give_exp_to_pcs(
	experience: int,
	pcs: Array,
	classic_battle_reward := false
) -> bool:
	print("GameGlobals give_exp_to_pcs ", experience,' to ', pcs.size())
	var leveledup : bool = false
	for pc in pcs :
		if not can_character_receive_experience(pc) :
			continue
		var awarded_experience := experience
		if classic_battle_reward:
			awarded_experience = (
				ClassicCharacterRulesScript.classic_battle_experience(
					pc,
					experience
				)
			)
		pc.exp_tnl -= awarded_experience
		while pc.exp_tnl <0 :
			# HUD level up !
			leveledup = true
			SfxPlayer.stream = NodeAccess.__Resources().sounds_book["level up.wav"]
			SfxPlayer.play()
			UI.ow_hud.levelupCtrl.levelup_character(pc)
			await UI.ow_hud.levelupCtrl.closed_lvlup_popup
			pc.exp_tnl += (
				ClassicCharacterRulesScript
				.post_level_up_experience_requirement(
					pc,
					pc.level,
					PlayerCharacter.get_exp_req_for_lvl(pc.level)
				)
			)
#	emit_signal("done_giving_exp")
	return leveledup


func can_character_receive_experience(character) -> bool:
	return ClassicAnimationScript.can_receive_experience(character)

#returns [boolean, character with item, item instance or null]
func does_party_have_same_item(item: Variant) -> Array:
	var candidate_definition_id := ""
	if item is ItemInstance:
		candidate_definition_id = item.definition_id
	elif item is Dictionary:
		var imported: ItemInstance = NodeAccess.__Resources().import_item_instance(item)
		if imported != null:
			candidate_definition_id = imported.definition_id
	for pc in player_characters :
		for carried: ItemInstance in pc.inventory_instances():
			if (
				not candidate_definition_id.is_empty()
				and carried.definition_id == candidate_definition_id
			):
				return [true, pc, carried]
	return [false, null, null]


func play_sfx(sfx_name : String) ->void :
	if NodeAccess.__Resources().sounds_book.has(sfx_name):
		SfxPlayer.stream = NodeAccess.__Resources().sounds_book[sfx_name]
		SfxPlayer.play()

func get_classic_secret_detection_chance() -> float:
	if is_classic_party_condition_active(3) \
			or is_classic_party_condition_active(5) \
			or is_global_effect_active("Awareness"):
		return 1.0
	if player_characters.is_empty():
		return 0.0
	var total := 0
	for character: Variant in player_characters:
		var abilities: Variant = character.get("classic_special_abilities") \
			if character is Object else null
		if abilities is Array and abilities.size() > CLASSIC_DETECT_SECRET_ABILITY_INDEX:
			total += clampi(
				int(abilities[CLASSIC_DETECT_SECRET_ABILITY_INDEX]),
				0,
				100
			)
	# checkforsecret.c uses the integer average across the entire party.
	var average_percent := floori(float(total) / float(player_characters.size()))
	return float(average_percent) / 100.0


func classic_secret_detection_succeeds(roll: float) -> bool:
	var chance := get_classic_secret_detection_chance()
	return chance > 0.0 and roll > 0.0 and roll <= chance


func roll_classic_secret_detection() -> bool:
	return (
		randi_range(1, 100)
		<= roundi(get_classic_secret_detection_chance() * 100.0)
	)


func get_mapsecret_detection_chance(pos: Vector2i) -> float:
	if is_instance_valid(classic_campaign_session):
		return get_classic_secret_detection_chance()
	if is_classic_party_condition_active(3) \
			or is_classic_party_condition_active(5) \
			or is_global_effect_active("Awareness"):
		return 1.0
	# Map's legacy name says "fail chance"; exploration stores and uses it as success chance.
	return clampf(map.get_secret_fail_chance(pos), 0.0, 1.0)


func map_secret_detection_succeeds(pos: Vector2i, roll: float) -> bool:
	return roll <= get_mapsecret_detection_chance(pos)


func random_battles_allowed() -> bool:
	return not (
		is_classic_party_condition_active(7)
		or is_global_effect_active("Sentry")
	) and classic_random_encounters_enabled()


func exploration_sight_ignores_blocking_tiles() -> bool:
	return is_classic_party_condition_active(4) \
		or is_global_effect_active("Scrying")


func classic_party_charm_resistance_bonus(character: Object) -> int:
	if not _is_player_controlled_character(character):
		return 0
	return 50 if (
		is_classic_party_condition_active(8)
		or is_global_effect_active("CharmProt")
	) else 0


func _is_player_controlled_character(character: Object) -> bool:
	if character == null:
		return false
	if character is PlayerCharacter:
		return true
	for property: Dictionary in character.get_property_list():
		if str(property.get("name", "")) == "is_player_controlled":
			return bool(character.get("is_player_controlled"))
	return false


func is_global_effect_active(effect_name: String) -> bool:
	var effect: Variant = global_effects.get(effect_name, {})
	return effect is Dictionary and int(effect.get("Duration", 0)) > 0


func identify_item(item: Variant) -> void:
	var instance: ItemInstance = item if item is ItemInstance \
		else NodeAccess.__Resources().import_item_instance(item)
	if instance == null:
		return
	instance.identified = true

# calculate the  range  counting diagonals as 1.5
func calculate_range_vi(vect : Vector2i)->int :
	var x  = abs(vect.x)
	var y  = abs(vect.y)
	var d = min(x,y)
	return floor(d*1.5+ x-d +y-d)
# calculate the  range  counting diagonals as 1.5
func calculate_range_v(vect : Vector2)->int :
	var x  = abs(vect.x)
	var y  = abs(vect.y)
	var d = min(x,y)
	return floor(d*1.5+ x-d +y-d)

func generate_item(itemname : String) -> ItemInstance:
	return NodeAccess.__Resources().create_item_instance(itemname)

#updates the current_map_script_name according to stuff done flags that disable or change the AP
#returns false iff AP should not be executed due to chance  (or disabled if chance==0)
func check_flags_for_current_map_script_name() -> bool:
	var chanceflagname : String = currentmap_name+'.'+"script_"+str(current_map_script_name)+'.chance'
	var replaceflagname : String = currentmap_name+'.'+"script_"+str(current_map_script_name)+'.replaced'
	var replacement: Variant = stuff_done.get(replaceflagname)
	if replacement == null and current_map_script_name.begins_with("AP"):
		var action_point_text := current_map_script_name.trim_prefix("AP").get_slice("x", 0)
		if action_point_text.is_valid_int():
			replacement = stuff_done.get(
				"%s.action_point_%d.replaced" % [currentmap_name, int(action_point_text)]
			)
	if not current_map_script_name.begins_with('X'):
		printerr("GameGlobal check_flags_for_current_map_script_name "+current_map_script_name+ " "+replaceflagname)

	if replacement != null:
		printerr("found replaced ap flag :  ",replaceflagname,':',replacement)
		current_map_script_name = str(replacement)
		# Check STOP - if yes stop script
		if current_map_script_name == "STOP" or current_map_script_name == "":
			return false

	if stuff_done.has(chanceflagname):
		if randf() > stuff_done[chanceflagname]:
			return false

	return true

	#var script_name = "script_"+str(_apname)
	#var flag_name : String = _mapname+'.'+script_name+'.chance'
	#GameGlobal.stuff_done[flag_name] = _chance


func get_rogue_skill_success(stat, difficulty) :
	return float(stat)+float(difficulty) >= float(randi()%100)
