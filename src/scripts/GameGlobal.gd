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

@onready var cmp_resources : CampaignResources = NodeAccess.__Resources()

var map : Map

var playerCharacterGD : GDScript = preload("res://Creature/PlayerCharacter.gd")
var combatCreatureGD : GDScript = preload("res://Creature/Creature.gd")


var spellAnimationTSCN : PackedScene = preload("res://scenes/Map/SpellAnimation/SpellAnimation.tscn")


var gameScreenTSCN : PackedScene = preload("res://scenes/UI/HUD/OWHUDControl.tscn")


#var gamescreenInstance

var fatigue :float = 0 #(max=128)
var max_fatigue : float = 86400.0
var time_scale : float = 10.0

enum eGameStates {unchecked,startGame,inGame,saveGame,endGame}
enum eCombatStates {unchecked,startCombat,inCombat,inCombatTargeting,combatAnim,endCombatFail,endCombatSuccess,combatShortPause}
var dontlognext_execute_spell : bool = false

var honest_mode : bool = false
var currentcampaign : String = ''
var currentcampaign_onload_script : GDScript = null
var campaign_global_script = null
var currentprofile : String = 'Default Profile'
var profile_characters_list : Array = []
var cur_save_name : String = "Game not Saved !"
var cur_save_descrition : String = ''

var currentmap_name : String = 'Default Map'
var last_exploration_map_name : String = 'Default Map'
var pos_when_battle_started : Vector2 = Vector2.ZERO

var currentShop : String = ''
var currentSpecialEncounterName : String = "default.gd"



#settings
var gamespeed : float = 0.2
var enforce_unique_items : bool = true

var setting_play_spell_resolution_on_every_aoe_tile : bool = false

var time : int = -1  #the time (date) in-game. -1 = invalid
var player_characters : Array = []
var player_allies : Array = []  #NPCs and summons

var light_time : int = 0
var light_power : int = 0
var camping : bool = false
var money_pool : Array = [0,0,0] # coins gems jewels
var money_banked : Array = [0,0,0] # coins gems jewels

var is_sailing_boat : bool = false
var boat_sailed_image_name : String = ''

var shopScript = null # a script that initializes shops checked campaign start and may run script checked accessing shops
var shops_dict : Dictionary = {}
var allow_character_swap_anywhere : bool = false
var stuff_done : Dictionary = {}
var map_boats_dict : Dictionary = {}

signal battle_end

func _ready():
	map = NodeAccess.__Map()
	
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
	Utils.FileHandler.set_cfg_setting(Paths.realmzfolderpath+"settings.cfg","SETTINGS","current_profile", profilename)
	#load the settings from this profile
	var path = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/profile_settings.cfg'
	#get_cfg_setting(path, section, key, default) :
	var musicvolume : float = Utils.FileHandler.get_cfg_setting(path, "VOLUME", "volume_music", 50)
	MusicStreamPlayer.volume_db = (musicvolume -100)*0.5
	if MusicStreamPlayer.modplayer :
		MusicStreamPlayer.modplayer.volume_db = musicvolume-20
	var sfxvolume : float = Utils.FileHandler.get_cfg_setting(path, "VOLUME", "volume_sound", 50)
	SfxPlayer.volume_db = (sfxvolume -100)*0.5
	honest_mode = bool(Utils.FileHandler.get_cfg_setting(path, "SET_IN_STONE", "honest_mode", 0))
	for type in MusicStreamPlayer.oneofeachtype.keys() :
		var favofthistype : String = Utils.FileHandler.get_cfg_setting(path, "MUSIC", type, "No Music")
		MusicStreamPlayer.set_type_music_choice(type,favofthistype)
	GameGlobal.load_profile_characters()


func load_profile_characters() :
	profile_characters_list.clear()
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

func init_globals_before_game_start(data_dict : Dictionary) :
	# used in  load_game()
	map.owcharacter.set_tile_position(data_dict["position"])
	fatigue = data_dict["fatigue"]
	UI.ow_hud.update_fatigue_bar()
	time = data_dict["time"]
	money_pool = data_dict["money_pool"]
	money_banked = data_dict["money_banked"]
	light_time = data_dict["light_time"]
	light_power = data_dict["light_power"]
	camping = bool(data_dict["camping"])
	cur_save_name = data_dict["save_name"]
	cur_save_descrition = data_dict["save_descr"]
	allow_character_swap(bool(data_dict["allow_char_swap"]))
	currentShop = data_dict["curr_shop"]
	stuff_done = data_dict["stuff_done"]
	map_boats_dict = data_dict["map_boats_dict"]
	is_sailing_boat = bool(data_dict["is_sailing_boat"])
	boat_sailed_image_name = data_dict["boat_image"]
	
	cur_save_name = data_dict["save_name"]
	cur_save_descrition = data_dict["save_descr"]
	set_current_campaign(data_dict["campaign"])
	currentmap_name = data_dict["currentmap_name"]
	shops_dict = data_dict["shops_dict"]

func pass_time(seconds : int, fatiguemultiplier : float = 1.0) :
	time += seconds *time_scale
	fatigue+= fatiguemultiplier * seconds *0.25 *time_scale
	fatigue = clampf(fatigue, 0.0, 172800.0)
	UI.ow_hud.update_fatigue_bar()
	
	if campaign_global_script.has_on_time_pass :
		campaign_global_script._on_time_pass(seconds)
	
	for character in player_characters :
		character._on_time_pass(seconds)
	for character in player_allies :
		character._on_time_pass(seconds)
	
#	player_characters[0].stats["curHP"] = seconds
	UI.ow_hud.updateTimeDisplay()
	UI.ow_hud.updateCharPanelDisplay()
	light_time = clamp(light_time-seconds,0,31536000)
	if light_time == 0 :
		light_power = 0

func add_light_effect(p : int, t : int) :
	light_power = max(light_power, p)
	light_time = (light_power*light_time+p*t)/light_power

func load_shops_script(campaign : String) :
	var shopsgd_path = Paths.campaignsfolderpath+ campaign + "/shops.gd"
	shopScript = load(shopsgd_path).new()
	print("GameGlobal loaded shops script : ", shopScript)


func campaign_start_load_shops_data(itemsbook : Dictionary) :
	# only checked starting new campaign, not loading
	if shops_dict.is_empty() :
		shops_dict = shopScript.build_shops(itemsbook)
		return
	# else, rebuild the image textures of the items in  buyback :
	#"imgdatasize": 236, "imgdata": "H4
	var resourcesnode = NodeAccess.__Resources()
	for shopname in shops_dict.keys() :
		for arr in shops_dict[shopname]["BuyBack"] :
			# arr[0] is the item dict
			arr[0] = resourcesnode.generate_item_from_json_dict(arr[0])
#			print('arr[0]["imgdata"]) : ', arr[0]["imgdata"])
#			#extract the image from the compressed poolbytearray, copied from Resource  script
#			var imgdatacompressed : PackedByteArray = Marshalls.base64_to_raw(arr[0]["imgdata"])
#			var imgdata : PackedByteArray = imgdatacompressed.decompress(arr[0]["imgdatasize"], FileAccess.COMPRESSION_GZIP)
#			var image : Image = Image.new()
#			image.load_png_from_buffer(imgdata)
#			var texture : ImageTexture = ImageTexture.new()
#			texture.create_from_image(image) #,0 # no flags, no filter
#			arr[0]["texture"] = texture
func get_shop(shopname : String) :
	return shopScript.get_shop(shopname, shops_dict[shopname])

func refresh_OW_HUD() :
	UI.ow_hud.update_fatigue_bar()
	UI.ow_hud.updateCharPanelDisplay()
	UI.ow_hud.updateTimeDisplay()
	var invrect = UI.ow_hud.inventoryRect
	if invrect.visible :
#		invrect.when_Items_Button_pressed()
		invrect.fill_inventory_Vbox(invrect.inventoryBoxRight, UI.ow_hud.selected_character)
		if invrect.traderect.visible :
			invrect.fill_inventory_Vbox(invrect.inventoryBoxLeft, invrect.selectedTradeCharacter)
	
func show_loot_menu(items:Array, money : Array, experience : int) :
	await UI.ow_hud.show_loot_menu(items,money,experience)



func set_current_campaign(campname : String) :
	currentcampaign = campname
	# get the campaign's info and restrictions script
	currentcampaign_onload_script = load(Paths.campaignsfolderpath + currentcampaign + "/on_select.gd" )


func get_currentcampaign_description() -> String:
	if currentcampaign_onload_script==null :
		print("NO currentcampaign_onload_script loaded !!!")
		return "NO currentcampaign_onload_script loaded !!!"
	return currentcampaign_onload_script.description

func get_currentcampaign_restrictions_description() -> String:
	if currentcampaign_onload_script==null :
		print("NO currentcampaign_onload_script loaded !!!")
		return "Pick a campaign first !"
	return currentcampaign_onload_script.restrictions_description

func can_character_enter_currentcampaign(chara) -> bool :
	if currentcampaign_onload_script==null :
		print("NO currentcampaign_onload_script loaded !!!")
		return false
	var honesty : bool = true
	honesty = GameGlobal.currentcampaign == chara.cur_campaign or chara.cur_campaign=="Free"
	honesty = honesty or (not honest_mode)
	return honesty and currentcampaign_onload_script.can_character_enter(chara)

func get_currentcampaign_max_party_size() -> int :
	if currentcampaign_onload_script==null :
		print("NO currentcampaign_onload_script loaded !!!")
		return 0
	return currentcampaign_onload_script.characters_limit


func allow_character_swap(yes : bool) :
	# enables the party swap button until you move
	UI.ow_hud.set_party_swap_enabled(yes)

func allow_money_change(yes : bool) :
	# enables the party swap button until you move
	UI.ow_hud.set_money_change_enabled(yes)
func allow_banking(yes : bool) :
	UI.ow_hud.set_banking_availlable(yes)

func allow_honest_storage(yes : bool) :
	UI.ow_hud.set_allow_honest_storage(honest_mode and yes)

func change_map(mapname : String, x : int, y : int) :
	print("change_map : "+mapname+" ; "+ str(Vector2(x,y)))
	currentmap_name = mapname
	map.load_map(currentcampaign, currentmap_name)
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


func rest() :
	var mult : float = -2.0 if camping else -1.0
	pass_time(5, mult)


#if pc_participating is empty, use all PC
func start_battle(battlename : String, is_ambush : bool, allow_loss : bool, allow_escape : bool, npcs_allowed : bool, pc_participating : Array) :
	print("GameGlobal start_battle " + battlename)
	var battle_data : Dictionary = GameGlobal.cmp_resources.battles_book[battlename]
	battle_data["battle_start"] = true
	battle_data["battlename"] = battlename
	battle_data["is_ambush"] = is_ambush
	battle_data["allow_loss"] = allow_loss
	battle_data["allow_escape"] = allow_escape
	battle_data["npcs_allowed"] = npcs_allowed
	var pc_part : Array = player_characters if pc_participating.is_empty() else pc_participating
	battle_data["pc_participating"] = pc_part
	battle_data["end_in_map_name"] = currentmap_name
	UI.ow_hud.combatBRPanel.escape_allowed = allow_escape
	var ow_character =  map.owcharacter
	pos_when_battle_started = Vector2(ow_character.tile_position_x,ow_character.tile_position_y)
	#map.targetingLayer.ensure_connection_with(StateMachine.cb_target_state)
	StateMachine.transition_to("Combat/CbDecideAction",battle_data)
	return








func end_battle( wonfledlost : String ) :
	print("GameGlobal end_battle")
	map.focuscharacter.tile_position_x = pos_when_battle_started.x
	map.focuscharacter.tile_position_y = pos_when_battle_started.y
	
#
	#for cb in GameState.map.creatures_node.get_children() :
		#cb.queue_free()   #done in MAp.load map now
	#print("GameGlobal end_battle pos_when_battle_started : ", pos_when_battle_started)
	change_map(last_exploration_map_name,pos_when_battle_started.x,pos_when_battle_started.y)
	UI.ow_hud.exit_battle_mode()

	match wonfledlost :
		"won" :
			#print("GameGlobal end_battle : battle won !")
			StateMachine.combat_state.cur_battle_data["Scripts"]["win"].win()
			#var textRect = UI.ow_hud.textRect
			var treasureControl = UI.ow_hud.treasureControl
##	var healpottemplate = NodeAccess.__Resources().items_book["Health Potion"]
			var treasureitems = []
			var experience : int = 0
			var money_drop : Array = [0,0,0]
			for c  in StateMachine.combat_state.battle_dead_enemies :
				#print("dead : "+c.name)
				experience += c.experience
				for g in  range(money_drop.size()) :
					money_drop[g] += c.money[g]
				for i in c.inventory :
					treasureitems.append(i)
			
			#this won't show the allies  screen
			#await UI.ow_hud.show_loot_menu(treasureitems,money_drop,experience)
			
			
			StateMachine.transition_to("Exploration/ExMenus", {"menu_name" : "LootMenu", "treasure" : treasureitems, "money" : money_drop, "exp" : experience, "prev_state" : "Exploration"})
			await UI.ow_hud.treasureControl.done_looting
			print("done looting")
			
			
			
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

			if map.mapscripts.has_method("_on_battle_escaped") :
				map.mapscripts.call("_on_battle_escaped")
		"lost" :
			#print("GameGlobal end_battle : battle lost !")
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
				print("GameGlobal end_battle : GAME OVER")
				SfxPlayer.stream = cmp_resources.sounds_book["party loss.wav"]
				SfxPlayer.play()
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

#  name : [resistance, multiplier], resistance is +- reduction
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


#returns a float  between 0.0 and 1.0, to use as a chance
func calculate_melee_accuracy(attacker : Creature, defender : Creature, weapon : Dictionary, should_check_script : bool = true) -> float :
	#var weapon : Dictionary = attacker.current_melee_weapons[weapon_index] 
	var accuracy : float = 0.0
	var evasion : float = 0.0
	if weapon.has("_calculate_melee_accuracy_source") and should_check_script :
		#print("GameGlobal calculate_melee_accuracy USE CUSTOM ACC STRIPT")
		return weapon["_calculate_melee_accuracy"]._calculate_melee_accuracy(attacker,defender, weapon)
	else :
		accuracy = attacker.get_stat("AccuracyMelee")  #checks traits too
		evasion = defender.get_stat("EvasionMelee")
		return clampf(0.5+0.05*(accuracy-evasion), 0.0, 1.0)


func calculate_melee_damage(attacker : Creature, defender : Creature, weapon : Dictionary, is_crit : bool, crit_mult : float, should_check_script : bool = true) -> Dictionary :
#	print("GameGlobal calculate_melee_damage, atker : ",attacker.name,", defnder : ",defender.name, " check script : ", should_check_script)
	#var weapon : Dictionary = attacker.current_melee_weapons[0] #TODO use left hand  weapon too ?
	var weapon_damage : Dictionary = {"Physical": 0}
#	print(weapon)
	if weapon.has("_calculate_melee_attack_source") and should_check_script :
		print("GameGlobal calculate_melee_damage USE CUSTOM ATK STRIPT")
		return weapon["_calculate_melee_attack"]._calculate_melee_attack(attacker,defender, weapon, is_crit, crit_mult)
	#if weapon["name"] == "NO_MELEE_WEAPON" :
		#print("GameGlobal calculate_melee_damage NO_MELEE_WEAPON : ", weapon)
	var wpn_dmg_types : Dictionary = weapon["weapon_dmg"]
	if weapon.has("weapon_tag_bonus_dmg") :
		for t in weapon["weapon_tag_bonus_dmg"] :
			if defender.tags.has(t) :
				for e in weapon["weapon_tag_bonus_dmg"][t] :
					if not weapon_damage.has(e) :
						weapon_damage[e]=0
					weapon_damage[e] += weapon["weapon_tag_bonus_dmg"][t][e]
	for t in wpn_dmg_types :
		var t_dmg_range : Array = wpn_dmg_types[t]
		var t_damage : float = float( randi_range(t_dmg_range[0], t_dmg_range[1]) )
		weapon_damage[t] = t_damage

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
	return damage_detail

func calculate_spell_damage(attacker : Creature, defender : Creature, spell, spellpower : int, _should_check_script : bool = true) -> int :
	#print("Gameglobal calculate_spell_damage : atker", attacker.name, ", defer", defender.name,", spell:", spell.name)
	
	var res : int = spell.resist==0
	var ignoreres : bool = res==0 or res==1
	
	var spell_attributes : Array= spell.attributes
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
		if not dmg_type_def_stats_dict.has(a) :
			continue
		var res_name : String = dmg_type_def_stats_dict[a][0]
		var res_stat : float = defender.get_stat(res_name)
		if ignoreres :
			res_stat = signi(res_stat)
		var mul_name : String = dmg_type_def_stats_dict[a][1]
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
	#print("GAMEGLOBAL calculate_spell_accuracy ",caster.name,"'s ", spell.name)
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


func do_spell_field_effect(caster : Creature, target : Creature, spell, plvl : int) :
	var spell_dmg : int =  calculate_spell_damage(caster,target, spell, plvl, false)
	target.change_cur_hp(-spell_dmg)
	if spell.has_method("add_traits_to_target") :
		spell.add_traits_to_target(caster, target, plvl)

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
func give_exp_to_pcs(experience : int, pcs : Array) -> bool:
	print("GameGlobals give_exp_to_pcs ", experience,' to ', pcs.size())
	var leveledup : bool = false
	for pc in pcs :
		for t in pc.traits :
			if t.trait_types.has('no_exp') :
				continue
		pc.exp_tnl -= experience
		while pc.exp_tnl <0 :
			# HUD level up !
			leveledup = true
			SfxPlayer.stream = NodeAccess.__Resources().sounds_book["level up.wav"]
			SfxPlayer.play()
			UI.ow_hud.levelupCtrl.levelup_character(pc)
			await UI.ow_hud.levelupCtrl.closed_lvlup_popup
			pc.exp_tnl += PlayerCharacter.get_exp_req_for_lvl(pc.level)
#	emit_signal("done_giving_exp")
	return leveledup

#returns [boolean, character with item, item itself  or emptydict] 
func does_party_have_same_item(item : Dictionary)->Array :
	for pc in player_characters :
		var got_dict : Dictionary = pc.get_item(item)
		if not got_dict.is_empty() :
			return [true, pc, got_dict]
	return [false, null, {}]


func play_sfx(sfx_name : String) ->void :
	SfxPlayer.stream = NodeAccess.__Resources().sounds_book[sfx_name]
	SfxPlayer.play()

func get_mapsecret_detection_chance(pos : Vector2i) ->float :
	return 1.0-GameGlobal.map.get_secret_fail_chance(pos)


func identify_item(item : Dictionary) :
	item["is_identified"] = 1

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
