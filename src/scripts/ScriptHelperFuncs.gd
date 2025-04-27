extends Node
class_name ScriptHelperFuncsClass

static func get_random_creature_of_size(needed_size : Vector2i, pickstrongest : bool, picks_to_compare : int) -> String :
	var bestiary : Dictionary = GameGlobal.cmp_resources.crea_book
	var right_size_crea_namesandlvl : Array = []
	for crea_name : String in bestiary.keys() :
		var crea_data : Dictionary = bestiary[crea_name]
		var crea_size : Vector2i = Vector2i(crea_data["data"]["size"][0], crea_data["data"]["size"][1])
		var crea_summonable : bool = crea_data["data"][ "summonable"]>0
		if crea_size == needed_size and crea_summonable :
			right_size_crea_namesandlvl.append([ crea_name, crea_data["data"]["level"] ])
	if right_size_crea_namesandlvl.is_empty() :
		print("ERROR ScriptHelperFuncs get_random_creature_of_size :  couldnt find creature of size "+str(needed_size))
		return("returned ScriptHelperFuncs get_random_creature_of_size :  couldnt find creature of size "+str(needed_size))
	else:
		return pick_random_crea_from_array(right_size_crea_namesandlvl, pickstrongest, picks_to_compare)

static func pick_random_crea_from_array(arr : Array, pickstrong : bool, picks : int) -> String :
	var picked_arr : Array = []
	for i in range(picks) :
		picked_arr.append(arr.pick_random())
	var picked_name : String = "ERROR ScriptHelperFuncs  pick_random_crea_from_array"
	if pickstrong :
		var highest_lvl : int = 0
		for ca in picked_arr :
			if ca[1]>=highest_lvl :
				picked_name = ca[0]
				highest_lvl = ca[1]
	else :
		var lowest_lvl : int = 999999999
		for ca in picked_arr :
			if ca[1]<=lowest_lvl :
				picked_name = ca[0]
				lowest_lvl = ca[1]
	return picked_name


#Misc helped scripts
static func does_party_have_item_named(item_name : String)-> bool :
	var item_dict : Dictionary = GameGlobal.cmp_resources.items_book[item_name]
	return GameGlobal.does_party_have_same_item(item_dict)[0]


#Divinity Codes !

# Divinity Code 1, string
static func display_text(txt : String) -> void :
	var textRect = UI.ow_hud.textRect
	textRect.set_text("Your old friend Vodada is here waiting for you !", false)

# Divinity Code 3 Player Option , option
static func yesno_branch(continue_on_yes : bool, tg_type : int, tg_name : String, lefttxt : String, righttxt : String) ->void :
	#continue_option=, target_type=, target=, left_prompt=, right_prompt=
	# 0: back  a step, 1: continue normally,  2:simple enc, 3:complex_end ; 4 : exit  and disable script
	var textRect : TextRect = UI.ow_hud.textRect
	if lefttxt=='0' and righttxt=='0' :
		textRect.display_multiple_choices(["YESNO"],["YESNO"])
	else :
		textRect.display_multiple_choices([lefttxt, righttxt],["YES", "NO"])
	var answer = await textRect.choice_pressed
	if (continue_on_yes and answer=='NO') or (not continue_on_yes and answer=='YES') :
		return
	else:
		if tg_type==0 :
			GameGlobal.must_cancel_movement = true
			return
		if tg_type == 1 :
			return
		if tg_type == 2 :
			print("yesno_branch TBI when simple encounters are  understood")
		if tg_type==4 :
			flag_disabled_current_script()
			return
			
	
	
#Divinity Code 4, Simple Encounter  , simple_enc
static func display_simple_encounter(enc_name : String) :
	print("display_simple_encounter must be translated by hand as they are not independent objects in realmzremake")

# Divinity Code 5: Complex Encounter, complex_enc
# Use: Send party to a Complex Encounter.
static func start_complex_encounter( comp_enc_name : String) :
	StateMachine.enter_ex_menu_state({"prev_state" : "Exploration", "menu_name" : "SpecEncounter_menu"})
	UI.ow_hud.encounterControl.show()
	UI.ow_hud.encounterControl.initialize(comp_enc_name)

# Divinity Code 9: Play Sound , sound
static func play_sound(sfx_name : String, stop : bool) :
	SfxPlayer.stream = NodeAccess.__Resources().sounds_book[sfx_name]
	SfxPlayer.play()
	if stop : await SfxPlayer.finished

#Divinity Code 21: Branch on Possession of Specific Item, jmp_if_item
static func branch_on_posession_of_item(item_name : String, tg_type : int, should_ignore_if_no : bool, exec_if_yes : String, exec_if_no : String) :
#0 = X-AP, 1 = Simple Encounter, 2 = Complex Encounter 
	var cur_script_name : String = GameGlobal.current_map_script_name
	if does_party_have_item_named(item_name) :
		if tg_type==0 :
			await GameGlobal.map.mapscripts.call (exec_if_yes)  #like in StateMachine script
		if tg_type==1 :
			await display_simple_encounter(exec_if_yes)
		if tg_type==2 :
			UI.ow_hud.encounterControl.initialize(exec_if_yes)
			await UI.ow_hud.encounterControl.encounter_over
	else :
		if should_ignore_if_no :
			return
		else:
			if tg_type==0 :
				await GameGlobal.map.mapscripts.call (exec_if_no)  #like in StateMachine script
			if tg_type==1 :
				await display_simple_encounter(exec_if_no)
			if tg_type==2 :
				UI.ow_hud.encounterControl.initialize(exec_if_no)
				await UI.ow_hud.encounterControl.encounter_over
	GameGlobal.current_map_script_name = cur_script_name

# Divinity Code 24 exit_ap , Exit Action Point and Keep Codes,  doesn't need anything

#Divinity 25: Exit Action Point and Delete Action Point  , exit_ap_delete
static func flag_disabled_current_script() ->void :
	var map_name = GameGlobal.currentmap_name
	var script_name = GameGlobal.current_map_script_name
	GameGlobal.stuff_done[map_name+'.'+script_name+'.disabled'] = true

# Divinity Code 32: Offer Temple : temple
static func allow_temple_menu(price_mult : float) :
	print("allow_temple_menu TBI when temple menu is done")

# DivinityCode 38: Continue On Possession, Else Branch Within Encounters 
static func branch_item_pos_encounter(item_name : String, continue_on_pos : bool, target_type:int, target:String, code_index:int) :
	print('branch_item_pos_encounter  TBI  when encounters are understood')

# Divinity Code 45: Teleport Only , tele
static func teleport_to_map_and_pos(mapname : String, pos : Vector2, sfx_name : String) :
	if not sfx_name.is_empty() :
		SfxPlayer.stream = NodeAccess.__Resources().sounds_book[sfx_name]
		SfxPlayer.play()
	if mapname == GameGlobal.currentmap_name :
		GameGlobal.map.focuscharacter.move(pos)
	else :
		GameGlobal.change_map(mapname, pos.x, pos.y)

#Divinity Code 101 : Back Up :
static func set_walk_back_once(should : bool) :
	GameGlobal.must_cancel_movement = should


# Divinity Code 2 : battle
static func start_battle_in_range(low : int, high : int, sfx_id : int, displaytext : String, give_treasure : int) :
	#low=, high=, sound_id=, string_id=, treasure_mode= 
	var battles_id_name_dict = GameGlobal.campaign_global_script.battles_id_name_dict
	var sfx_id_name_dict = GameGlobal.campaign_global_script.sfx_id_name_dict
	var battle_name = battles_id_name_dict[randi_range(low, high)]
	GameGlobal.allow_next_battle_loot = give_treasure!=5 # from divinity doc : A value of 5 here : no loot. 10 : no gameover.
	play_sound(sfx_id_name_dict[sfx_id], true)
	GameGlobal.start_battle(battle_name, false, give_treasure==10, true, true, [] ) # all party if pc_particiating is empty

# Divinity Code 7 : modify_ap    level=, id=, source_xap=, level_type=, result_code=
static func add_script_branch_flag( map_id : int, type : int, source_id : int, modified_script_id : int) :
	var flagname : String = "modify_ap_map"+str(map_id)+"_type"+str(type)+"_AP"+str(source_id)
	GameGlobal.stuff_done[flagname] = modified_script_id
	printerr("\n\n\n   USED add_script_branch_flag !!!\n    "+flagname+' '+str(modified_script_id)+"\nPlease make sure the script branches properly\n\n")
