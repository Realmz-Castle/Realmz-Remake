extends NinePatchRect
class_name SaveLoadCtrl

var can_save : bool = false

@export var scenarios_panel : SaveLoad_Scenarios_Panel
@export var saves_panel : SaveLoad_Saves_Panel
@export var preview_panel : SaveLoad_Preview_Panel

var selected_scenario_name : String = "Unitialized Selected Scenario Name"
var selected_save_name : String = "Unitialized Selected Save Name"

@export var new_save_lineedit : LineEdit
@export var new_save_err_label : Label
@export var create_save_button : Button
@export var new_save_panel : Panel

var new_save_name : String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func fill(campaignname : String, cansave : bool) :
	can_save = cansave
	new_save_panel.visible = cansave
	preview_panel.save_button.visible = can_save
	preview_panel.load_button.disabled = true
	new_save_name = ""
	new_save_err_label.hide()
	create_save_button.disabled = true
	new_save_lineedit.text = ''
	scenarios_panel.my_menu = self
	preview_panel.my_menu = self
	scenarios_panel.fill(campaignname)
	selected_scenario_name = campaignname 
	#does Player Profile have a  save folder for this scenario ? if not, create one
	var dir_exists : bool = DirAccess.dir_exists_absolute(Paths.profilesfolderpath + GameGlobal.currentprofile + "/"+ campaignname)
	print("SaveLoadCtrl save dir exists ? ",  dir_exists )
	if not dir_exists :
		DirAccess.make_dir_recursive_absolute(Paths.profilesfolderpath  + GameGlobal.currentprofile + "/Saves/" + campaignname)
	saves_panel.my_menu = self
	saves_panel.fill(selected_scenario_name)



func _on_scenario_selected(scen_name : String) :
	print("SaveLoadCtrl _on_scenario_selected ", scen_name)
	selected_scenario_name = scen_name
	disable_create_new_save(scen_name != GameGlobal.currentcampaign)
	saves_panel.fill(scen_name)

func on_save_selected(save_name : String) :
	print("SaveLoadCtrl on_save_selected ", save_name)
	selected_save_name = save_name
	if save_name.is_empty() :
		preview_panel.display_this_game_preview()
	else :
		preview_panel.display_save_preview(selected_scenario_name, save_name)
	#display save stuff in details panel

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_close_button_pressed():
	if is_instance_of(get_parent(), Window) :
		get_parent().hide()
	hide()
	StateMachine.transition_to("Exploration")


func _on_newsavelineedit_text_changed(new_text):
	new_save_err_label.show()
	var validity_array : Array = Utils.FileHandler.is_valid_file_name(new_text)
	if validity_array[0]<=0 :
		new_save_err_label.set('custom_colors/font_color' , Color(1,0,0,1) )
		create_save_button.disabled = true
		new_save_name = ""
	else :
		new_save_err_label.set('custom_colors/font_color' , Color(0,1,0,1) )
		create_save_button.disabled = false
		new_save_name = new_text
	new_save_err_label.text = validity_array[1]


func _on_create_button_pressed():
	new_save_err_label.hide()
	create_save_button.disabled = true
	new_save_lineedit.text = ''
	#SAVE THE GAME
	print("_on_create_button_pressed save game " + new_save_name + ", campaign : "+ selected_scenario_name)
	save_game(selected_scenario_name, new_save_name)
	
	
	hide()
	_on_close_button_pressed()

func save_game(campaignname : String, savename : String) :
#	print("save_game  savename : ", savename)
	#is there already a save folder here ? If so, empty it
	GameGlobal.cur_save_name = savename
	var save_path : String = Paths.profilesfolderpath + GameGlobal.currentprofile + "/Saves/"+ campaignname + "/"+ savename
	var prof_path : String = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/Characters/'
	var dir_exists : bool = DirAccess.dir_exists_absolute(save_path)
#	print(save_path)
	if dir_exists :
#		print("SaveLoadCtrl save_game dir_exists=true ! ")
		OS.move_to_trash(save_path)  #or DirAccess.remove() ? faster ?
	if not GameGlobal.honest_mode :
		DirAccess.make_dir_recursive_absolute(save_path)
	else :
		DirAccess.make_dir_recursive_absolute(save_path + "/Characters")
	
	for pc in GameGlobal.player_characters :
#		print(" path: ",save_path + "/Characters/"+pc.name)
		
		if GameGlobal.honest_mode :
			Utils.FileHandler.save_character(prof_path + pc.name, pc)
		else :
			DirAccess.make_dir_recursive_absolute(save_path + "/Characters/"+pc.name)
			Utils.FileHandler.save_character(save_path + "/Characters/" + pc.name, pc)
			Utils.FileHandler.save_character(prof_path + pc.name, pc)
		
		
		#print("TODO SaveLoadCtrl save_game wont update the character data in profile/characters folder yet. Disabled for easy debugging.")
	
	var save_data_file : FileAccess = FileAccess.open(save_path+"/data.json", FileAccess.ModeFlags.WRITE)
	if save_data_file==null :
		print("ERROR save_game save_data_file get_open_error() : ", FileAccess.get_open_error() )
#	var data_text : String = save_data_file.get_as_text()
	#save simple stuff
	var pc_order : Array = []
	var preview_arr : Array = []
	for pc in GameGlobal.player_characters :
		pc_order.append(pc.name)
		preview_arr.append([pc.name, pc.level, pc.classgd.classrace_name, floor(100.0*pc.get_stat("curHP")/pc.get_stat("maxHP"))])
	
	var notes : String = preview_panel.notesTextEdit.text
	notes = notes.replace("'",' ')
	notes = notes.replace('"',' ')
	
	var dict_to_save : Dictionary = {
		"fatigue" : GameGlobal.fatigue,
		"time" : GameGlobal.time,
		"money_pool" : GameGlobal.money_pool,
		"money_banked" : GameGlobal.money_banked,
		"light_time" : GameGlobal.light_time,
		"light_power" : GameGlobal.light_power,
		"camping" : int(GameGlobal.camping),
		"currentmap_name" : GameGlobal.currentmap_name,
		"position" : [GameGlobal.map.owcharacter.tile_position_x, GameGlobal.map.owcharacter.tile_position_y],
		"allow_char_swap" : int(UI.ow_hud.party_swap_enabled),
		"curr_shop" : GameGlobal.currentShop,
		"stuff_done" : GameGlobal.stuff_done,
		"map_boats_dict" : GameGlobal.map_boats_dict,
		"is_sailing_boat" : int(GameGlobal.is_sailing_boat),
		"boat_image" : GameGlobal.boat_sailed_image_name,
		"pc_order" : pc_order,
		"preview" : preview_arr,
		"notes" : notes,
		"GlobalEffects" : GameGlobal.global_effects
		}
	print("SAVE RECT position : ", dict_to_save["position"])
	if GameGlobal.honest_mode :
		dict_to_save.erase("money_banked")
		#set_cfg_setting(path, section, key, value) :
		var profile_settings_path : String = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/profile_settings.cfg'
		Utils.FileHandler.set_cfg_setting(profile_settings_path,"HONEST_MODE", "money_banked", str(GameGlobal.money_banked))
	save_data_file.store_line(str(dict_to_save))
	save_data_file.close()
	save_data_file = FileAccess.open(save_path+"/shops.json", FileAccess.ModeFlags.WRITE)
	var shops_data = GameGlobal.shops_dict.duplicate()
	for shopname in shops_data.keys() :
		for i in shops_data[shopname]["BuyBack"]:
			i.erase("texture")
	save_data_file.store_line(str(shops_data))
	save_data_file.close()
	
	var allies_array : Array = []
	for a in GameGlobal.player_allies :
		allies_array.append(a.get_save_string()+"}")
	save_data_file = FileAccess.open(save_path+"/allies.json", FileAccess.ModeFlags.WRITE)
	save_data_file.store_line('{"allies" : [')
	var comma : String = ''
	for a_str in allies_array :
		save_data_file.store_line(comma)
		comma = ','
		save_data_file.store_line(a_str)
	save_data_file.store_line(']}')
	save_data_file.close()
	
	var resources = NodeAccess.__Resources()
	var campaign_maps_array : Array = resources.maps_book.keys()
	var maps_secrets_dict : Dictionary = {}
	for mapname in campaign_maps_array :
		maps_secrets_dict[mapname] = {}
		maps_secrets_dict[mapname]["explored_tiles"] = resources.maps_book[mapname][8]
		maps_secrets_dict[mapname]["secret_paths"] =  resources.maps_book[mapname][1]["Paths"]
		maps_secrets_dict[mapname]["secrets"] = []
		for s in resources.maps_book[mapname][1]["Secrets"] :
			maps_secrets_dict[mapname]["secrets"].append([s[0],s[1],s[2]])
	save_data_file = FileAccess.open(save_path+"/map_exploration.json", FileAccess.ModeFlags.WRITE)
	save_data_file.store_line('{')
	comma = ''
	for mapname in campaign_maps_array :
		save_data_file.store_line(comma)
		comma = ','
		save_data_file.store_line('"'+mapname + '" : {')
		save_data_file.store_line('    "explored_tiles"' + ' : ' + str(maps_secrets_dict[mapname]["explored_tiles"]) +',')
		save_data_file.store_line('    "secret_paths"' + ' : ' + str(maps_secrets_dict[mapname]["secret_paths"]) +',')
		save_data_file.store_line('    "secrets"' + ' : ' + str(maps_secrets_dict[mapname]["secrets"]) + ' }')
	save_data_file.store_line('}')
	save_data_file.close()
	
	
	# also save :
	# time,  money_pool, torch/shine, charposition, currentmap DONE
	#GameGlobals.stuff_done,   shops inventories DONE
	# Resources.for each map, exploredtiles  and secretpaths  and mapsecrets
	# player_characters in order, maybe details for the preview too
	# allies like vodalian/summons

func on_load_button_pressed() :
	load_game(selected_scenario_name, selected_save_name)

func disable_create_new_save(dis : bool) :
	create_save_button.visible = not dis
	new_save_lineedit.text = "New Save Creation Disabled" if dis else ""
	new_save_lineedit.editable = not dis


func load_game(campaignname : String, savename : String) :
	var prevCampaign : String = GameGlobal.currentcampaign+''
	# GameGlobal.init_globals_before_game_start....
	var save_path : String = Paths.profilesfolderpath + GameGlobal.currentprofile + "/Saves/"+ campaignname + "/"+ savename
	print("load_game save_path : ", save_path)
	var data_dict : Dictionary = Utils.FileHandler.read_json_dic_from_file(save_path+"/data.json")
	var shop_data : Dictionary = Utils.FileHandler.read_json_dic_from_file(save_path+"/shops.json")
	var money_banked : Array = []
	if GameGlobal.honest_mode :
		var profile_settings_path : String = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/profile_settings.cfg'
		var banked_str : String = Utils.FileHandler.get_cfg_setting(profile_settings_path,"HONEST_MODE", "money_banked",0)
		print("SAVELOADRECT LOAD honest banked_str : ", banked_str)
		money_banked = JSON.parse_string(banked_str)
		print("SAVELOADRECT LOAD honest money_banked : ", money_banked)
	else :
		money_banked = data_dict["money_banked"]
	var globals_dict : Dictionary = {
		"fatigue" = data_dict["fatigue"],
		"position" = Vector2(data_dict["position"][0],data_dict["position"][1]),
		"time" = data_dict["time"],
		"money_pool" = data_dict["money_pool"],
		"money_banked" = money_banked,
		"light_time" = data_dict["light_time"],
		"light_power" = data_dict["light_power"],
		"camping" = bool(data_dict["camping"]),
		"allow_char_swap" = bool(data_dict["allow_char_swap"],),
		"curr_shop" = data_dict["curr_shop"],
		"stuff_done" = data_dict["stuff_done"],
		"map_boats_dict" = data_dict["map_boats_dict"],
		"is_sailing_boat" = data_dict["is_sailing_boat"],
		"boat_image" = data_dict["boat_image"],
		"save_name" = savename,
		"save_descr" = data_dict["notes"],
		"campaign" = campaignname,
		"currentmap_name" = data_dict["currentmap_name"],
		"shops_dict" = shop_data,
		"GlobalEffects" = data_dict["GlobalEffects"]
	}
	print("load_game : data_dict[currentmap_name] : ", data_dict["currentmap_name"])
	
	GameGlobal.init_globals_before_game_start(globals_dict)
	# load the player characters
	var pcs_names_array : Array = data_dict["pc_order"]
	GameGlobal.player_characters.clear()
	var profcharfolderpath : String = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/Characters/'
	var charafolderpath : String = profcharfolderpath if GameGlobal.honest_mode else save_path+'/Characters/'
	for n in pcs_names_array :
		var pc : PlayerCharacter = Utils.FileHandler.load_character(charafolderpath+n)
		GameGlobal.player_characters.append(pc)

	
	#reload resources for this scenario if  different
	print("campaignname currentcampaign : ", campaignname, '!=',prevCampaign+"? ",campaignname != prevCampaign )
	if campaignname != prevCampaign :
		NodeAccess.__Resources().load_campaign_ressources(campaignname)
#	GameState._state = GameGlobal.eGameStates.startGame  #to do  GameState.DoStartGame
	#StateMachine.transition_to("Exploration/ExWalking", {"load_campaign_msg" : {"initialize_campaign" : false}} )
	#map exploration, done after loading resources
	var exploration_data : Dictionary = Utils.FileHandler.read_json_dic_from_file(save_path+"/map_exploration.json")
	var maps_book = NodeAccess.__Resources().maps_book
	print("load_game maps_book : ", maps_book.keys())
	for mapname in exploration_data.keys() :
		print("save_load_rect maps_book keys : ", maps_book.keys())
		maps_book[mapname][8] = exploration_data[mapname]["explored_tiles"]
		maps_book[mapname][1]["Paths"] = exploration_data[mapname]["secret_paths"]
		for s in exploration_data[mapname]["secrets"] :
#			print("load game secrets : ",s)
			if bool(s[2]) :
				GameGlobal.map.set_secret_seen(Vector2i(s[0], s[1]))
		
	var resources = NodeAccess.__Resources()
	var mapname = GameGlobal.currentmap_name
	GameGlobal.map.mapsecretpaths.clear()
	for p in resources.maps_book[mapname][1]["Paths"] :
		GameGlobal.map.mapsecretpaths[Vector2i(p[0],p[1])] = p[2]
	GameGlobal.map.mapsecrets.clear()
	for p in resources.maps_book[mapname][1]["Secrets"] :
		GameGlobal.map.mapsecrets[Vector2i(p[0],p[1])] = [ p[2], p[3] , p[4] ]  #seen, fucntionname,  failchance
		
#			maps_secrets_dict[mapname]["explored_tiles"] = resources.maps_book[mapname][8]
#		maps_secrets_dict[mapname]["secret_paths"] =  resources.maps_book[mapname][1]["Paths"]
#		maps_secrets_dict[mapname]["secrets"] = []
#		for s in resources.maps_book[mapname][1]["Secrets"] :
#			maps_secrets_dict[mapname]["secrets"].append([s[0],s[1],s[2]])
	
	#load allies : must be done after  loading resources
	var allies_data : Dictionary = Utils.FileHandler.read_json_dic_from_file(save_path+"/allies.json")
	var CreatureGD : GDScript = load('res://Creature/Creature.gd')
	for crea_dict in allies_data["allies"] :
		var creascript : Creature = CreatureGD.new()
		creascript.initialize_from_bestiary_dict(crea_dict["name"])
		creascript.name = crea_dict["name"]
		creascript.level = crea_dict["level"]
		creascript.is_npc_ally = bool(crea_dict["is_npc_ally"])
		creascript.is_summoned = bool(crea_dict["is_summoned"])
		creascript.summoner_name = crea_dict["summoner_name"]
		creascript.joins_combat = bool(crea_dict["joins_combat"])
		creascript.base_stats = crea_dict["base_stats"]
		creascript.inventory = crea_dict["inventory"]
		creascript.spells = crea_dict["spells"]
		creascript.traits = crea_dict["traits"]
		creascript.recalculate_stats()
		creascript.stats["curHP"] = crea_dict["curHP"]
		if creascript.stats["curHP"]<0 :
			#var life_status : int = 0  #0=fine  1=ko'd bleeding 2=ko'd bandaged 3=dead
			creascript.life_status = 2
		creascript.stats["curSP"] = crea_dict["curSP"]
		GameGlobal.add_npc_ally(creascript)
	GameGlobal.map.queue_redraw()
	StateMachine.transition_to("Exploration", {"campaign_continue" = true})
	_on_close_button_pressed()
