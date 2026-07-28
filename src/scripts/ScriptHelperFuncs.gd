extends Node
class_name ScriptHelperFuncsClass


const NativeEncounterBranch = preload(
	"res://scripts/native_encounters/native_encounter_branch.gd"
)

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

## Divinity Code 1, string
static func display_text(txt) -> void :
	var textRect = UI.ow_hud.textRect
	textRect.set_text(str(txt), false)

## Divinity Code 1, string  more convenient
static func display_text_wait_noise(txt : String, sfxname : String) -> void :
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound(sfxname, false) #'message nod.wav'
	textRect.set_text(str(txt), true)
	await textRect.interruption_over

static func display_multiple_choices(choices : Array, answers : Array = []) :
	if answers.is_empty():
		answers = range(choices.size())
	var choices_container = UI.ow_hud.textRect.choicesContainer
	choices_container.show()
	choices_container.display_multiple_choices(choices, answers)
	var answer = await choices_container.choice_pressed
	choices_container.hide()
	return answer

## Divinity Code 3 Player Option , option
static func yesno_branch_Divinity(continue_on_yes : bool, tg_type : int, tg_id : int , lefttxt : String, righttxt : String) ->String :
	#return true iff branching, if continuing return false does nothing
	#continue_option=, target_type=, target=, left_prompt=, right_prompt=
	# 0: back  a step, 1: continue normally,  2:simple enc, 3:complex_end ; 4 : exit  and disable script
	var answer = await display_multiple_choices(
		["YESNO"] if lefttxt == '' and righttxt == '' else [lefttxt, righttxt],
		["YESNO"] if lefttxt == '' and righttxt == '' else ["YES", "NO"]
	)
	if (continue_on_yes and answer=='YES') or (not continue_on_yes and answer=='NO') :
		return ''
	else:
		var apname : String = ''
		if tg_type==0 :
			GameGlobal.must_cancel_movement = true # that's  "cancel movement"
			print("yesno_branch back a step")
			return 'STOP'
		if tg_type == 1 :
			print("ScriptHelperFuncs returns "+'XAP'+str(tg_id))
			return 'XAP'+str(tg_id)
		if tg_type == 2 :
			print("ScriptHelperFuncs returns "+GameGlobal.prev_simple_enc_name+'XAP'+str(tg_id))
			return GameGlobal.prev_simple_enc_name+'XAP'+str(tg_id)
		if tg_type == 3 :
			return await run_complex_result_Divinity(tg_id)
		if tg_type==4 :
			printerr("yesno_branch flag script as disabled, make sure to add a check at script start")
			flag_disabled_current_script()
			return 'STOP'
	return ''



## Divinity Code 4, Simple Encounter  , simple_enc
static func display_simple_encounter_Divinity(enc_id : int) :
	return await display_simple_encounter_from_data("SE"+str(enc_id))


## Divinity Code 5: Complex Encounter, complex_enc
## Use: Send party to a Complex Encounter.
static func start_complex_encounter(comp_enc_name: String) -> void:
	StateMachine.enter_ex_menu_state({"prev_state" : "Exploration", "menu_name" : "SpecEncounter_menu"})
	UI.ow_hud.encounterControl.show()
	await UI.ow_hud.encounterControl.initialize(comp_enc_name)

static func start_complex_encounter_Divinity(ce_id: int) -> void:
	await start_complex_encounter("CE"+str(ce_id))


static func complex_encounter_branch(ce_id: int) -> Dictionary:
	return NativeEncounterBranch.create(ce_id)


static func is_complex_encounter_branch(branch: Variant) -> bool:
	return NativeEncounterBranch.is_branch(branch)


static func transition_complex_encounter_Divinity(ce_id: int) -> bool:
	return UI.ow_hud.encounterControl.transition_to("CE%d" % ce_id)


static func dispatch_complex_result_Divinity(result_index: int) -> Variant:
	return await UI.ow_hud.encounterControl.run_result(result_index)


static func run_complex_result_Divinity(result_index: int, code_index := 0) -> String:
	if code_index != 0:
		push_error(
			"Native GDScript encounters cannot branch to instruction %d within result %d"
			% [code_index, result_index]
		)
		return "STOP"
	await dispatch_complex_result_Divinity(result_index)
	return "STOP"


static func complex_result_replacement_flag(encounter_name: String, result_index: int) -> String:
	return "complex_encounter.%s.result_%d.replaced" % [
		encounter_name.trim_suffix(".gd"),
		result_index,
	]


static func get_complex_result_replacement_Divinity(
	encounter_name: String,
	result_index: int
) -> String:
	return str(GameGlobal.stuff_done.get(
		complex_result_replacement_flag(encounter_name, result_index),
		""
	))


static func run_replacement_action_point_Divinity(script_name: String) -> Variant:
	var map_scripts: Variant = get_current_map_scripts_Divinity()
	if map_scripts == null:
		push_error("Cannot run replacement action point %s without loaded map scripts" % script_name)
		return null

	var previous_script_name := GameGlobal.current_map_script_name
	var next_script: Variant = script_name
	var result: Variant = null
	while next_script is String and not str(next_script).is_empty() and next_script != "STOP":
		var method_name := str(next_script)
		if not map_scripts.has_method(method_name):
			push_error("Replacement action point %s was not found on the loaded map" % method_name)
			break
		GameGlobal.current_map_script_name = method_name
		result = await map_scripts.call(method_name)
		if is_complex_encounter_branch(result):
			transition_complex_encounter_Divinity(int(result["encounter"]))
			result = true
			break
		next_script = result
	GameGlobal.current_map_script_name = previous_script_name
	return result


static func play_sound(sfx_name : String, stop : bool) :
	SfxPlayer.stream = NodeAccess.__Resources().sounds_book[sfx_name]
	SfxPlayer.play()
	if stop : await SfxPlayer.finished

#code 9, use with await
static func play_sound_divinity(sfx_id : int) :
	if SfxIdDivinity.mapping.has(sfx_id) :
		await play_sound(SfxIdDivinity.mapping[sfx_id], sfx_id<0)

##Divinity Code 21: Branch on Possession of Specific Item, jmp_if_item
static func branch_on_posession_of_item(item_name : String, tg_type : int, should_ignore_if_no : bool, exec_if_yes : String, exec_if_no : String) :
#0 = X-AP, 1 = Simple Encounter, 2 = Complex Encounter
	var cur_script_name : String = GameGlobal.current_map_script_name
	if does_party_have_item_named(item_name) :
		if tg_type==0 :
			await GameGlobal.map.mapscripts.call (exec_if_yes)  #like in StateMachine script
		if tg_type==1 :
			await display_simple_encounter_from_data(exec_if_yes)
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
				await display_simple_encounter_from_data(exec_if_no)
			if tg_type==2 :
				UI.ow_hud.encounterControl.initialize(exec_if_no)
				await UI.ow_hud.encounterControl.encounter_over
	GameGlobal.current_map_script_name = cur_script_name

## Divinity Code 24 exit_ap , Exit Action Point and Keep Codes,  doesn't need anything

##Divinity 25: Exit Action Point and Delete Action Point  , exit_ap_delete
static func flag_disabled_current_script() ->void :
	printerr("flag_disabled_current_script() won't work from XAP, be careful !")
	var map_name = GameGlobal.currentmap_name
	var script_name = GameGlobal.current_map_script_name
	GameGlobal.stuff_done[map_name+'.'+script_name+'.disabled'] = 1

## Divinity Code 32: Offer Temple : temple
static func allow_temple_menu(price_mult : float) :
	print("allow_temple_menu TBI when temple menu is done")

## DivinityCode 38: Continue On Possession, Else Branch Within Encounters
static func branch_item_pos_encounter(item_name : String, continue_on_pos : bool, target_type:int, target:String, code_index:int) :
	print('branch_item_pos_encounter  TBI  when encounters are understood')

## Divinity Code 45: Teleport Only , tele
static func teleport_to_map_and_pos(mapname : String, pos : Vector2, sfx_name : String) :
	if not sfx_name.is_empty() :
		SfxPlayer.stream = NodeAccess.__Resources().sounds_book[sfx_name]
		SfxPlayer.play()
	if mapname == GameGlobal.currentmap_name :
		#GameGlobal.map.focuscharacter.move(pos)
		GameGlobal.map.focuscharacter.set_tile_position(Vector2(pos.x,pos.y))
		GameGlobal.map.owcharacter.set_tile_position(Vector2(pos.x,pos.y))
	else :
		GameGlobal.change_map(mapname, pos.x, pos.y)

static func teleport_to_map_and_pos_divinity(map_id : int, posx : int, posy : int, sfx_id : int) :
	teleport_to_map_and_pos('map_'+str(map_id), Vector2(posx,posy), SfxIdDivinity.mapping[sfx_id])

#Divinity Code 101 : Back Up :
static func set_walk_back_once(should : bool) :
	GameGlobal.must_cancel_movement = should


static func do_RR_battle(rr_dict : Dictionary) :
	var answer = "YES"
	var randi : int = randi()%100
	var offered_encounter := false
	var classic_adapter: Object = null
	var classic_session: Object = GameGlobal.classic_campaign_session
	if is_instance_valid(classic_session):
		classic_adapter = classic_session.get("command_adapter")
	#printerr("ScriptHelperFuncs do_RR_battle chance : " ,rr_dict["option_chance"],'>=',randi,' : start fight ? ', rr_dict["option_chance"]<=randi )
	if rr_dict["option_chance"]>=randi :
		offered_encounter = true
		if is_instance_valid(classic_adapter) \
				and classic_adapter.has_method("play_classic_map_sound"):
			classic_adapter.call("play_classic_map_sound", int(rr_dict.get("sfx_id", 0)))
		else:
			play_sound("generation error.wav", false)
		var textRect : TextRect = UI.ow_hud.textRect
		textRect.display_multiple_choices([rr_dict['text'],"YESNO"],["TEXT","YESNO"])
		answer = await textRect.choice_pressed
		textRect.choicesContainer.hide()
	if answer == "YES" :
		var battle_range: Array = rr_dict.get("battle_range", [])
		if battle_range.size() < 2 or int(battle_range[0]) <= 0:
			return
		if is_instance_valid(classic_adapter) \
				and classic_adapter.has_method("start_classic_random_battle"):
			var result: Variant = await classic_adapter.call(
				"start_classic_random_battle",
				battle_range,
				offered_encounter
			)
			if result is Dictionary and str(result.get("status", "")) == "error":
				push_error("Classic random battle stopped: %s" % result.get(
					"message",
					"unknown compatibility error"
				))
			return
		await start_battle_in_range(
			int(battle_range[0]),
			int(battle_range[1]),
			10049,
			'',
			0
		)

## Divinity Code 2 : battle
static func start_battle_in_range(low : int, high : int, sfx_id : int, displaytext : String, give_treasure : int) :
	#low=, high=, sound_id=, string_id=, treasure_mode=
	var sound_name_from_mapping : String = ''
	if SfxIdDivinity.mapping.has(sfx_id) :
		sound_name_from_mapping = SfxIdDivinity.mapping[sfx_id]
	else:
		if sfx_id != 0:  # Don't log for sfx_id 0 as it's mapped to empty string intentionally
			print("Warning: SFX ID ", sfx_id, " not found in SfxIdDivinity mapping in start_battle_in_range")
	if not displaytext.is_empty() :
		await ScriptHelperFuncsClass.display_text_wait_noise(displaytext, sound_name_from_mapping)
	#var battles_id_name_dict = GameGlobal.campaign_global_script.battles_id_name_dict
	else:
		play_sound(sound_name_from_mapping, true)
	var battle_name = 'Battle_'+str(randi_range(low, high))#battles_id_name_dict[randi_range(low, high)]
	GameGlobal.allow_next_battle_loot = give_treasure!=5 # from divinity doc : A value of 5 here : no loot. 10 : no gameover.

	GameGlobal.start_battle(battle_name,"",true, false, give_treasure==10, true, true, [] ) # all party if pc_particiating is empty
	var wonfledlost = await GameGlobal.battle_end
	return wonfledlost

#Divinity Code 26 : Branching Battle, jmp_battle
#1) Battle Number: Low Battle Number for Range Battle
#2) High Battle Number for Range Battle
#3) If defeated branch to X-AP, Else -1 = Backstep
#4) Sound. (Optional)
#5) String ID to display prior to battle. (Optional)
#uUse :
#var branch = await ScriptHelperFuncs.branching_battle_Divinity()
#if branch != "GO_ON" : return branch
static func branching_battle_Divinity(low: int, high : int, xap_or_backstep : int, sfx_id : int, displaytext : String) :
	start_battle_in_range(low, high, sfx_id , displaytext, 0)
	var wonfledlost = await GameGlobal.battle_end
	if wonfledlost != "won" :
		if xap_or_backstep < 0 :
			GameGlobal.must_cancel_movement = true # that's  "cancel movement"
			return
		return "XAP"+str(xap_or_backstep)
	return "GO_ON"


## DIVINITY : Random Rectangle battles with no actual AP :
static func randomrect_battle(b : Array, o : int, s : String, t : String, battle_text : String) :
	var textRect = UI.ow_hud.textRect
	var text : String  = ''
	if randi_range(0,100)<= o :
		ScriptHelperFuncsClass.play_sound(s, false)
		text = t
		textRect.set_text(text)
		textRect.display_multiple_choices([text, "YESNO"],["TEXT","YESNO"])
		var answer = await textRect.choice_pressed
		if answer == "NO" :
			return
	#this is  the starting text of  all battles in b
	text = battle_text
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	# b = [24, 31]
	printerr("randomrect_battle b :", b)
	var rand_battle_id : int = range(b[0], b[1]+1).pick_random()
	GameGlobal.start_battle("Battle_"+str(rand_battle_id),"", true, false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end



#Code 7: Change Action Point Script
#ID: Extra Codes ID
#Use: Allows you to change the codes for an Action Point anywhere in the scenario.
## Divinity Code 7 : modify_ap    level=, id=, source_xap=, level_type=, result_code=
#1) Land ID of Action Point codes to change. -2 = Replace Simple
#Encounter Script, -3 = Replace Complex Encounter Script
#2) AP/Simple Enc ID/Complex Enc ID To Modify
#3) Extra Action Point ID that contains the new codes
#4) For AP replacement: 0 = Default to same land type, 1 = Land Level, 2 = Dungeon Level
#5) For Encounter Script Replacement: Result Code to Replace
static func add_Divinity_script_branch_flag(
	map_id: int,
	target_id: int,
	replacement_xap_id: int,
	level_type: int,
	result_to_replace: int = 0
) -> bool:
	var new_ap_name := get_extra_ap_name(replacement_xap_id)
	if new_ap_name.is_empty():
		push_error("Code 7 replacement XAP%d was not found on the loaded map" % replacement_xap_id)
		return false

	if map_id == -3:
		GameGlobal.stuff_done[
			complex_result_replacement_flag("CE%d" % target_id, result_to_replace)
		] = new_ap_name
		return true
	if map_id == -2:
		var encounter_data_key := GameGlobal.currentmap_name + ".SEdata"
		var encounter_name := "SE%d" % target_id
		var encounter_book: Variant = GameGlobal.stuff_done.get(encounter_data_key)
		if not encounter_book is Dictionary:
			var encounter_path := Paths.campaignsfolderpath.path_join(
				GameGlobal.currentcampaign
			).path_join("Maps").path_join(GameGlobal.currentmap_name).path_join(
				"map_SimpleEncounters.json"
			)
			encounter_book = Utils.FileHandler.read_json_dic_from_file(encounter_path)
			GameGlobal.stuff_done[encounter_data_key] = encounter_book
		if not encounter_book is Dictionary or not encounter_book.has(encounter_name):
			push_error("Code 7 simple encounter %s was not found" % encounter_name)
			return false
		var result_scripts: Array = encounter_book[encounter_name][2]
		if result_to_replace < 0 or result_to_replace >= result_scripts.size():
			push_error(
				"Code 7 result %d is outside simple encounter %s"
				% [result_to_replace, encounter_name]
			)
			return false
		result_scripts[result_to_replace] = new_ap_name
		return true

	var map_prefix := "mapd_" if level_type == 2 else "map_"
	if level_type == 0 and GameGlobal.currentmap_name.begins_with("mapd_"):
		map_prefix = "mapd_"
	var map_name := map_prefix + str(map_id)
	GameGlobal.stuff_done[
		"%s.action_point_%d.replaced" % [map_name, target_id]
	] = new_ap_name
	return true


static func get_extra_ap_name(ap_id: int) -> String:
	var exact_name := "XAP%d" % ap_id
	var coordinate_prefix := exact_name + "x"
	var map_scripts: Variant = get_current_map_scripts_Divinity()
	if map_scripts == null:
		return ""
	for method: Dictionary in map_scripts.get_script_method_list():
		var method_name := str(method["name"])
		if method_name == exact_name or method_name.begins_with(coordinate_prefix):
			return method_name
	return ""


static func get_current_map_scripts_Divinity() -> Variant:
	# Campaign-folder GDScript execution ended with scenario format v2.
	return null

## Divinity Code 29: Give/Display Map  id:int , if negative, give |id| and also display
static func give_minimap(id : int) :
	GameGlobal.minimaps[abs(id)][6] = 1
	if id<0 :
		show_minimap(abs(id))

static func show_minimap(id : int) :
	GameGlobal.minimaps[id][6] = 1
	UI.ow_hud.minimapRect.cur_map = GameGlobal.minimaps[id]
	UI.ow_hud.minimapRect.show()
	UI.ow_hud.minimapRect.on_display()
	StateMachine.enter_ex_menu_state(({"menu_name" : "MiniMapsMenu"}))

## Divinity Code 10: Give Treasure(treasure_id)
static func give_treasure_with_id(treasure_id : int) :
	var treasure_dict : Dictionary = GameGlobal.campaign_global_script.give_treasure_with_id(treasure_id)
	await StateMachine.enter_ex_menu_state({"menu_name" : "LootMenu", "treasure" : treasure_dict["treasure"] ,"money" : treasure_dict["money"] ,"exp" : treasure_dict["exp"] })


static func get_ap_name_starting_with(startstring : String) -> String :
	var mapscript_methods_dicts : Array = GameGlobal.map.mapscripts.get_script_method_list()
	for d in mapscript_methods_dicts :
		var ap_name : String = d["name"]
		if ap_name.begins_with(startstring) :
			return ap_name
	return ''


##Divinity Code 13: Enable/Disable Action Point  level=, id=, percent_chance=, low=, high=
#Use: Use this to enable or disable an Action Point or to alter the percent chance that you encounter it.
static func set_divinity_script_enabled_flag(map_id : int, ap_id : int, exec_chance : float, ap_downto_id : int, ap_upto_id : int) ->void :
	printerr("ScripHelperFuncs set_divinity_script_enabled_flag("+str(map_id)+','+str(ap_id)+','+str(exec_chance)+','+str(ap_upto_id)+')')
	var map_name = "map_"+str(map_id)
	var apnames_array = []
	var ap_name : String = get_ap_name_starting_with('AP'+str(ap_id)+'x')
	if not ap_name.is_empty() :
		apnames_array.append(ap_name)
	for id in range(ap_downto_id, ap_upto_id+1) :
		var apn : String = get_ap_name_starting_with('AP'+str(id)+'x')
		if not apn.is_empty() :
			apnames_array.append(apn)
	#printerr(mapscript_methods_arr)
	for apn in apnames_array :
		set_ap_enabled_flag(map_name, str(apn), exec_chance)


#sets a GameGlobal flag for this AP  name, chance between 0 and 1
static func set_ap_enabled_flag(_mapname : String, _apname : String, _chance : float) :
	var script_name = "script_"+str(_apname)
	var flag_name : String = _mapname+'.'+script_name+'.chance'
	GameGlobal.stuff_done[flag_name] = _chance
	printerr("\n USED ScriptHelperFuncs set_ap_enabled_flag !! "+flag_name+' = '+str(_chance))

## Divinity Code 52: Pick on Miscellaneous type=, parameter=, who=
static func filter_PCs_Divinity(type : int, parameter : int, who : int, previously_picked = []) -> Array :
	var picked_array : Array = []
	if previously_picked.is_empty() or who!=2:
		previously_picked = GameGlobal.player_characters.duplicate()
	var pc_picked_pre_filter: Array = []
	for pc in previously_picked :
			if who == 1 :
				if pc.get_stat("curHP") > 0 :
					pc_picked_pre_filter.append(pc)
			else :
				pc_picked_pre_filter.append(pc)
	match type :
		0 : #move
			for pc in pc_picked_pre_filter :
				if pc.get_stat("MaxMovement") > parameter :
					picked_array.append(pc)
		1 : #position
			if UI.ow_hud.charsVContainer.get_child_count() > parameter :
				var candidate = UI.ow_hud.charsVContainer.get_child(parameter)
				if pc_picked_pre_filter.has(candidate) :
					picked_array.append(candidate)
			if pc_picked_pre_filter.has(UI.ow_hud.selected_character) :
				picked_array.append(UI.ow_hud.selected_character)
		2 : #Item
			if typeof(parameter) != TYPE_STRING :
				printerr("filter_PCs_Divinity on item posession, parameter must be a String, it is ", parameter)
				while(true) :{
				}
			for pc in pc_picked_pre_filter :
				for i: ItemInstance in pc.inventory_instances():
					var definition := NodeAccess.__Resources().get_item_definition(i)
					if definition != null \
							and definition.display_name == str(parameter):
						picked_array.append(pc)
						break
		3 : #%chance
			for pc in pc_picked_pre_filter :
				if randf() <= parameter :
					picked_array.append(pc)
		4 : #attribute
			var attrnamesarray : Array = ["Strength", "Intellect", "Wisdom", "Dexterity", "Vitality", "???Divinity is weird???", "Luck"]
			var attributename : String = attrnamesarray[parameter]
			for pc in pc_picked_pre_filter :
				if randi_range(1,20) <= pc.get_stat(attributename) :
					picked_array.append(pc)
		5 : #DRVs, restist pspell type
			var elementnamesarray : Array = ["ResistanceMental", "ResistanceFire", "ResistanceIce", "ResistanceElect", "ResistanceChemical", "ResistanceMental", "ResistanceMagic", "ResistanceHealing"]
			var elementname : String = elementnamesarray[parameter]
			for pc in pc_picked_pre_filter :
				if randf() <= pc.get_stat(elementname) :
					picked_array.append(pc)
		6 : #currently selected
			if pc_picked_pre_filter.has(UI.ow_hud.selected_character) :
				picked_array.append(UI.ow_hud.selected_character)
	return picked_array

#takes this amount of gold from party if possible, and returns bool  of whether it's successful
# Similar to Divinity's  take_money
static func take_money_if_possible(gold : int) -> bool :
	var totalgold : int = 0
	for character in GameGlobal.player_characters :
		totalgold += character.money[0] #0 is gold
	if totalgold >= gold :
		remove_gold_from_party(gold)
		return true
	return false

## Divinity Code 15: Heal/Hurt Picked     picked using a Code 14 or 30
static func heal_picked_Divinity(mult : int, low_range, high_range, sound, string : String) :
	print("calling ScriptHelperFuncs  heal_picked_Divinity")
	var prev_picked = GameGlobal.last_picked_characters
	if prev_picked.is_empty() :
		printerr('heal_picked_Divinity,  dindt have any picked character')
	for pc in prev_picked :
		var hp_gained = randi_range(low_range,high_range)*mult
		pc.change_cur_hp(hp_gained)
	if sound>=0 :
		play_sound_divinity(sound)
	if not string.is_empty() :
		UI.ow_hud.textRect.set_text(string, false)

static func heal_party_Divinity(mult : int, low_range : int, high_range : int, sfx_id : int) :
	play_sound_divinity(sfx_id)
	heal_party(mult, low_range, high_range,  '')

static func heal_party(mult : int, low_range : int, high_range : int, sfxname : String) :
	var playsound : bool = false
	for pc in GameGlobal.player_characters :
		var hp_gained = randi_range(low_range,high_range)*mult
		pc.change_cur_hp(hp_gained)
		playsound = true
	if playsound and (not sfxname.is_empty()):
		ScriptHelperFuncsClass.play_sound(sfxname, false)

## Divinity Code 27: Display Picture, from the campaign splash folder
static func display_picture_file(img_name : String) :
	UI.ow_hud.pictureRect.display_image(img_name)

## Divinity Code 28: Redraw Screen ,  after you have displayed a picture.
static func hide_picture() :
	UI.ow_hud.pictureRect.hide()


## Divinity Code 47: Set Clear Quest Flag , set_quest : quest_id
static func set_quest_id_flag_Divinity(quest_id : int) :
	if quest_id < 0:
		GameGlobal.stuff_done.erase("quest_"+str(abs(quest_id)))
		return
	GameGlobal.stuff_done["quest_"+str(abs(quest_id))] = 1

static func clear_quest_id_flag_Divinity(quest_id : int) :
	GameGlobal.stuff_done.erase("quest_"+str(abs(quest_id)))

## Divinity Code 46: Branch on Quest (See code 72 & 77 for more options) , jmp_quest
static func branch_on_quest_Divinity(quest_id : int, go_on_if_done : int, target_type : int, target : int, code_index : int) -> String:
	var quest_name : String = "quest_"+str(quest_id)
	var should_continue : bool = GameGlobal.stuff_done[quest_name] + go_on_if_done ==  1 #not brainching if true
	if should_continue : return "GO_ON"
	var next_ap_name : String = ''
	match target_type :
		0 : #XAP
			next_ap_name = 'XAP'+str(target)
		1 : #SEXAP :
			var cur_se = GameGlobal.prev_simple_enc_name
			next_ap_name = cur_se+'XAP'+str(target)
		2  : #Complex :
			return await run_complex_result_Divinity(target, code_index)
	return next_ap_name

## Divinity Code 12: Change Land Tile
static func change_map_tile_Divinity(map_id : int, xcoord : int, ycoord : int, tileid : int, useless) :
	var map_name = 'map_'+str(map_id)
	if map_name==GameGlobal.currentmap_name :
		var map = NodeAccess.__Map()
		map.mapdata[ycoord][xcoord][0]= NodeAccess.__Resources().tiles_book["ForestDay.json"][181]
	printerr("change_map_tile_Divinity, mapid:",map_id,', x:', xcoord, ', y:',ycoord, 'tile_id:', tileid )

## Divinity Code 106: Set Dark Land • Line of Sight Status, must exit AP is  returns true
static func change_dark_los_Divinity(is_dark:int, skip_if_dark_same:int, los:int, skip_if_los_same: int) -> bool :
	#if skip_if_dark_same or skip_if_los_same :
		#printerr("Divinity Code 106: change_dark_los_Divinity causes brainching, make sure the script does!  return true=skip rest of AP")

	var map : Map = NodeAccess.__Map()
	var new_dark = 7-7*is_dark  #0=darkest, 7 =  alwayslight
	if new_dark==0 and map.darkness_level<=0 and skip_if_dark_same :
		return true
	map.darkness_level = new_dark
	if los and map.display_explored_only and skip_if_los_same :
		return true
	map.display_explored_only = los==1
	return false

## Divinity Code 26: Get Mouse Click
static func request_click() :
	UI.ow_hud.textRect.disablerButton.show()
	Input.set_custom_mouse_cursor(UI.cursor_click)
	await UI.ow_hud.textRect.disablerButton.pressed
	print('""ScriptHelperFuncs request_click() disablerButton, "pressed"')
	Input.set_custom_mouse_cursor(UI.cursor_sword)
	UI.ow_hud.textRect.disablerButton.hide()


## Divinity Code 11: Give Victory Points
static func give_exp(exp : int) :
	await StateMachine.enter_ex_menu_state({"menu_name" : "LootMenu", "treasure" : [] ,"money" : [0,0,0] ,"exp" : exp })

## Divinity Code 30: Pick on Check Vs. Attribute • Special Abilities
static func filter_PCs_ability_Divinity(ability_id:int, success_mod:int, who:int, what_type:int, previously_picked : Array = []) :
	var ability_arr : Array =["Melee_Crit_Mult",'','','Melee_Crit_Rate', 'Detect_Secret', 'Acrobatics', "Detect_Trap", "Disable_Trap",'',"Force_Lock",'',"Pick_Lock", 'read lv1 scrolls', 'Turn_Undead' ]
	var ability_name : String = ability_arr[ability_id]
	var picked_array : Array = []
	if previously_picked.is_empty() or who!=0:
		previously_picked = GameGlobal.player_characters.duplicate()
	var pc_picked_pre_filter: Array = []
	for pc in previously_picked :
			if who == 2 :
				if pc.get_stat("curHP") > 0 :
					pc_picked_pre_filter.append(pc)
			else :
				pc_picked_pre_filter.append(pc)
	for pc in pc_picked_pre_filter :
		if pc.get_stat(ability_name)+success_mod >= randi_range(1,20) :
			picked_array.append(pc)
	return picked_array

##Divinity Code 18: Cast Spell on Party
static func castSpellOnPartyDivinity(spell_id, power, drv_modifier, can_drv) :
	printerr("Divinity Code 18: Cast Spell on Party, use castspellonpickedcharacters instead.")
	var spell_name : String = SpellsIdDivinity.mappings[spell_id]
	CastSpellOnPickedCharacters(GameGlobal.player_characters, spell_name, power)

#Divinity Code 17: Cast Spell on Picked
static func castSpellOnPickedDivinity(spell_id, power, drv_modifier, can_drv) :
	var spell_name : String = SpellsIdDivinity.mappings[spell_id]
	CastSpellOnPickedCharacters(GameGlobal.last_picked_characters, spell_name, power)


static func CastSpellOnPickedCharacters(
	characters : Array,
	spell_name : String,
	power : int,
	damage_scale := 1.0
) :
	var spell_entry = NodeAccess.__Resources().spells_book[spell_name]
	var spell = spell_entry.get("script") if spell_entry is Dictionary else spell_entry
	await ApplySpellOnPickedCharacters(characters, spell, power, damage_scale)


static func ApplySpellOnPickedCharacters(
	characters : Array,
	spell : Spell,
	power : int,
	damage_scale := 1.0
) :
	var character = Creature.new()
	var uses_group_effect: bool = spell.has_method("apply_classic_group_effect")
	if uses_group_effect:
		spell.apply_classic_group_effect(character, characters, power, damage_scale)
	for target in characters :
		if spell.sounds.size() > 1 \
				and GameGlobal.cmp_resources.sounds_book.has(spell.sounds[1]) :
			SfxPlayer.stream = GameGlobal.cmp_resources.sounds_book[spell.sounds[1]]
			SfxPlayer.play()
		var projectile_hit: Variant = spell.get("proj_hit")
		if projectile_hit != null and int(projectile_hit) >= 0 :
			await UI.ow_hud.show_spell_effect_on_char_menu(target, projectile_hit)
		if not uses_group_effect:
			await GameGlobal.do_spell_field_effect(character, target, spell, power, damage_scale)

# Divinity code : Code 32: Offer Temple
static func enable_default_temple(price_mult) :
	GameGlobal.currentTemple = [
		["Heal Small Wounds", 1, roundi(100*price_mult/10)*10 ],
		["Heal Medium Wounds", 1,roundi(140*price_mult/10)*10 ],
		["Heal Large Wounds", 1, roundi(330*price_mult/10)*10 ],
		["Heal Disease", 1, roundi(75*price_mult/10)*10 ],
		["Flesh", 1,roundi(290*price_mult/10)*10 ],
		["Heal Poison", 1, roundi(75*price_mult/10)*10 ],
		["Heal Blindness", 1, roundi(140*price_mult/10)*10 ],
		["Remove Items", 1,roundi(250*price_mult/10)*10 ],
		["Revive Dead", 1, roundi(615*price_mult/10)*10 ]
	]
	GameGlobal.allow_temple(true)

static func remove_gold_from_party(gold_to_give : int) :
	for character : Creature in GameGlobal.player_characters :
		var gold_given : int = min (gold_to_give, character.money[0])
		gold_to_give -= gold_given
		character.money[0] -= gold_given

#affects current map
static func change_tileset(fromname : String, toname : String) :
	var map  : Map =  GameGlobal.map
	var resources : CampaignResources = GameGlobal.cmp_resources
	var tonamejson : String = toname + '.json'
	#printerr("ScriptHelperFuncs  change_tileset  topleft tile : ",str(GameGlobal.map.mapdata[0][0]))
	for x in range(map.mapdata[0].size()) :
		for y in range(map.mapdata.size()) :
			var curtile : Dictionary = map.mapdata[y][x][0]
			if curtile["tileset_name"] == fromname :
				map.mapdata[y][x][0] = resources.tiles_book[tonamejson][curtile["id"]]
	map.queue_redraw()

#changes a single tile on a map, adds a flag so change can be applied on map load. Returns stuffdoneflag name.
static func change_tile_anymap_add_flag(map_name : String, x:int, y:int, tileset_name : String, tile_id : int, layer : int = 0) -> Array:
	var mapflagname : String = 'TileSwaps.'+map_name
	var flagname : String = 'x'+str(x)+'y'+str(y)+'l'+str(layer)
	var flagvalue : Array = [x,y,layer,tileset_name, tile_id]
	if map_name==GameGlobal.currentmap_name :
		change_currmap_tile(x,y,layer,tileset_name, tile_id )
	if not GameGlobal.stuff_done.has(mapflagname) :
		GameGlobal.stuff_done[mapflagname] = {}
	GameGlobal.stuff_done[mapflagname][flagname]=flagvalue
	return [mapflagname, flagname, flagvalue]

static func change_currmap_tile(x:int,y:int,l:int, ts_name : String, tile_id : int) :
	var resources : CampaignResources = GameGlobal.cmp_resources
	#var curtile : Dictionary = GameGlobal.map.mapdata[y][x][l]
	GameGlobal.map.mapdata[y][x][l] = resources.tiles_book[ts_name+'.json'][tile_id-1]
	GameGlobal.map.queue_redraw()

static func request_pc_pick(n : int) :
	UI.ow_hud.request_pc_pick(n)
	GameGlobal.last_picked_characters = await UI.ow_hud.pc_picked
	return GameGlobal.last_picked_characters

#Code 43: Give Condition
#Use: Will allow you to give characters a specified condition.
#Negative values will be permanent unless that character alreadysuffers from the specified condition in a permanent way.
#1) Affect Who: 0 = Party, 1 = Picked, 2 = Alive
static func give_Divinity_condition(affect_who : int, condition_id : int, powerperm : int, sound_name_id ):
	var affected_characters : Array = []
	var permanent : bool =  powerperm<0
	var power : int = absi(powerperm)
	match affect_who :
		0 :
			affected_characters = GameGlobal.player_characters
		1 :
			affected_characters = GameGlobal.last_picked_characters
		2:
			for c : Creature in GameGlobal.player_characters :
				if c.life_status <3 : affected_characters.append(c) #not dead
	var traitscript_filename : String = ''
	var trait_array : Array = []
	if(permanent) :
		trait_array = []
		traitscript_filename = 'p_'
	else :
		trait_array = [power]
		traitscript_filename = 't_'
	match condition_id :
		0: #run
			traitscript_filename += "fleeing.gd"
		1 : #Helpless
			traitscript_filename = "t_helpless.gd"
			if(permanent) : trait_array = [9999]
		2 : #Tangled
			traitscript_filename += "slow.gd"
		3: #Curse
			traitscript_filename += "cursed.gd"
		4: #Magic Aura
			traitscript_filename += "aura.gd"
		5: #Stupid
			traitscript_filename += "dumb.gd"
		6: #Slow
			traitscript_filename += "slow.gd"
		7:#Shield from hits :
			traitscript_filename += "pro_hits.gd"
			trait_array = [power] # permanent still stacks !
		8: #Shielded from Projectiles
			traitscript_filename += "pro_proj.gd"
		9: #Poison
			traitscript_filename += "poison.gd"
			trait_array = [power] # permanent still stacks !
		10: #Regenerate
			traitscript_filename += "hp_regen.gd"
			trait_array = [power] # permanent still stacks !
		11: #Protection from Fire
			traitscript_filename += "prot_fire.gd"
		12:
			traitscript_filename += "prot_ice.gd"
		13:
			traitscript_filename += "prot_elect.gd"
		14:
			traitscript_filename += "prot_chem.gd"
		15:
			traitscript_filename += "prot_mental.gd"
		16,17,18,19,20: #Protection from 1-5th Level Spells
			traitscript_filename += "spell_lvl_prot.gd"
			if(permanent) :trait_array = [condition_id-15]
			else : trait_array = [power,condition_id-15 ]
		21 : #Strong
			traitscript_filename += "strong.gd"
		22 : #Protection from evil
			traitscript_filename += "prot_evil.gd"
			trait_array = [power]
		23: #Speedy
			traitscript_filename += "speedy.gd"
		24: #invisible
			traitscript_filename += "invisible.gd"
		25: #Animated
			traitscript_filename += "animated.gd"
		26: #SToned
			traitscript_filename = "p_petrified.gd"
			trait_array = [] #always permanent
		27: #Blind
			traitscript_filename += "blind.gd"
		28: #Diseased
			traitscript_filename += "disease.gd"
		29: #Confused
			traitscript_filename += "confused.gd"
		30: #Reflecting Spells
			traitscript_filename += "reflect_spells.gd"
		31: #Reflecting Melee
			traitscript_filename += "reflect_melee.gd"
		32: #Attack Bonus
			traitscript_filename += "phys_dmg_bonus.gd"
			trait_array = [power]
		33: #Absorbing Energy
			traitscript_filename += "sp_regen.gd"
			trait_array = [power]
		34: #Energy Drain
			traitscript_filename += "sp_regen.gd"
			trait_array = [-power]
		35: #Absorb SP from Attacks
			traitscript_filename += "sp_absorb.gd"
		36: #Hinder Attack
			traitscript_filename += "hindered_atk.gd"
			trait_array = [power]
		37: #Hinder Defense
			traitscript_filename += "hindered_def.gd"
			trait_array = [power]
		38: #Defense Bonus
			traitscript_filename += "increased_def.gd"
			trait_array = [power]
		39: #Silenced
			traitscript_filename += "silenced.gd"
			trait_array = [power]
	var traitscript = load("res://shared_assets/traits/"+traitscript_filename)
	for c in affected_characters :
		c.add_trait(traitscript, trait_array)
		if sound_name_id is String :
			await play_sound(sound_name_id, true)
# Code 52: Pick on Miscellaneous
# Use: Allows you to PICK characters on a number of conditions.
#1) Type Of Check, 0 = Move, 1 = Position, 2 = Item Poss, 3 = % Chance, 4 = Save Vs Attr, 5 = Save Vs Spell Type, 6 = Pick Currently Selected PC, 7 8 = Pick Character In Specific
#2) < Move, < Pos, Item ID, % Chance, Attr No., Spell Type No., Item ID, Position (1-6)
#3) 0 = Check All, 1 = Alive Only, 2 = Check picked only.
static func pick_chara_Divinity_misc(type:int, challenge : int, checkwho : int, item_poss_id : int) ->Array :
	var tested_charas : Array = []
	var picked_charas : Array = []
	match checkwho :
		0 :
			tested_charas = GameGlobal.player_characters
		1 :
			for c : Creature in GameGlobal.player_characters :
				if c.life_status <3 : tested_charas.append(c) #not dead
		2:
			tested_charas = GameGlobal.last_picked_characters

	match type :
		0: #Move
			for c : Creature in tested_charas :
				if c.get_stat("MaxMovement") > challenge : picked_charas.append(c)
		1 : #Position
			var i = 0
			for c : Creature in tested_charas :
				if i==challenge : picked_charas.append(c)
				i+=1
		2: #Item Possession
			var item_poss_name : String = ''
			if ItemIdDivinity.mapping.has(item_poss_id) :
				item_poss_name = ItemIdDivinity.mapping[item_poss_id]
			if item_poss_name.is_empty() :
				printerr("ScriptHelperFunc pick_chara_Divinity_misc : "+GameGlobal.current_map_script_name+' : please manually fix by adding the item name as argument : '+str(challenge))
				return []
			var definition_id := (
				GameGlobal.cmp_resources.item_catalog.resolve_active_catalog_key(
					item_poss_name
				)
			)
			for c : Creature in tested_charas :
				for carried: ItemInstance in c.inventory_instances():
					if carried.definition_id == definition_id:
						picked_charas.append(c)
						break
		3: # %chance
			for c : Creature in tested_charas :
				if randi()%100>=challenge : picked_charas.append(c)
		4: #save vs attribute
			var attribute_name : String = ["Strength", "Intellect", "Wisdom","Dexterity","Vitality", "ERROR IN SCRIPT", "Luck" ][challenge]
			for c : Creature in tested_charas :
				if c.get_stat(attribute_name)>=randi()%25 : picked_charas.append(c)
		5: #Save vs Spell Type
			var spelltype_name : String = ["Mental", "Fire", "Ice","Elect","Chemical", "Mental", "Magic", "Healing" ][challenge]
			for c : Creature in tested_charas :
				var chance : float = 2*(1-c.get_stat('Multiplier'+spelltype_name)) + 0.1*c.get_stat('Resistance'+spelltype_name)
				if randf()<=chance : picked_charas.append(c)
		6: #Pick currently selected PC :
			picked_charas.append(UI.ow_hud.selected_character)
		7, 8 : #Pick Character In Specific   WHAT DOES IT EVEN MEAN
			printerr("ScriptHelperFunc pick_chara_Divinity_misc : "+GameGlobal.current_map_script_name+' : supposedly PICK CHARACTER ON SPECIFIC? no idea what to do, TBI : '+str(challenge))
		_ :
			printerr("ScriptHelperFunc pick_chara_Divinity_misc : "+GameGlobal.current_map_script_name+' : UNHANDLED CHALLENGE  VALUE : '+str(challenge))
	return picked_charas




#Code 30: Pick on Check Vs. Attribute • Special Abilities
#ID: Extra Codes ID
#Use: This will allow you to PICK characters from the party according to the success
#of a check vs. a speci ability.
# Example: You could have each character who fails to perform an "Acrobatic Act" fall in a pit and take damage.
#Options: None
#E-Codes:
#1) What Attribute/Special Ability To Check (Negative = Set on Fail)
#2) +/- Modifer (Negative values hurt success odds)
#3) Who to check: 0 = Picked, 1 = Everyone, 2 = Alive
#4) 0 = Check Special Ability, 1 = Check Attribute
#Note: The +/- Modifier for checks vs. special abilities is a percentage check.
# Example: If the character has a 40% chance to perform an acrobatic act, they will be successful 40% of the time. If you have a Modifier of + 20 they will be successful 60% of the time.
#Checks on attributes is base 25. Example: If a character has a agility score of 16,
#then 16 out of 25 times they will be successful on a check vs.. agility.
#If you put a modifier of -5 then they will only be successful 9 out of 25 times.
static func pick_chara_on_attribute_or_special_Divinity(what : int, modifier : int, checkwho : int, specorattr : int) -> Array :
	var tested_charas : Array = []
	var picked_charas : Array = []
	match checkwho :
		0 :
			tested_charas = GameGlobal.last_picked_characters
		1 :
			tested_charas = GameGlobal.player_characters
		2:
			for c : Creature in GameGlobal.player_characters :
				if c.life_status <3 : tested_charas.append(c) #not dead
	var attributes_arr : Array = ["Strength", "Intellect", "Wisdom","Dexterity","Vitality", "ERROR IN SCRIPT", "Luck" ]
	var specskills_arr : Array = ["Melee_Crit_Mult","N/A","N/A","Melee_Crit_Rate","Detect_Secret","Acrobatics", "Detect_Trap", "Disable_Trap", "N/A", "Force_Lock", "N/A", "Pick_Lock", "ERROR read_scrolls", "Turn_Undead" ]
	var setonfail : bool = what<0
	var checked_arr = [specskills_arr, attributes_arr][specorattr]
	var checked_skill_name : String = checked_arr[what]
	for c : Creature in tested_charas :
		var c_skill = c.get_stat(checked_skill_name)
		var succeed : bool = false
		match specorattr :
			0 : #special skill
				if c_skill+modifier > 1+randi()%100 : succeed = true
			1 : #attribute
				if c_skill+modifier > 1+randi()%25 : succeed = true
		if (setonfail and (not succeed)) or (succeed and (not setonfail)) :
			picked_charas.append(c)
	return picked_charas




#returns next AP name, check around l305 of StateMachine script.
# use as
# return await ScriptHelperFuncsClass.display_simple_encounter_from_data('SE0')
static func display_simple_encounter_from_data(_enc_name : String) :
	printerr("HELPER display_simple_encounter_from_data")
	var se_data : Array = GameGlobal.stuff_done[GameGlobal.currentmap_name+'.SEdata'][_enc_name]
	GameGlobal.prev_simple_enc_name = _enc_name
	var prompt : String = se_data[0]
	var choices_data_arr : Array = se_data[1]
	var sexap_arr : Array = se_data[2]
	var canleave : bool = se_data[3]

	var choices : Array = [prompt]
	var answers : Array = ["TEXT"]
	for c in choices_data_arr :
		if c[2]>0 :
			choices.append(c[0])
			answers.append(str(c[1]))
	if canleave :
			choices.append('STOP')
			answers.append('STOP')
	display_text(prompt)
	var answer = await display_multiple_choices(choices,answers)
	var sexap_name : String = ''
	if answer=="STOP" : return
	else : return sexap_arr[choices_data_arr[int(answer)][1]]


#Divinity Code 38: Continue On Possession, Else Branch Within Encounters
#ID: Extra Codes ID
#Use: Allows you to check for a specific item and branch depending on whether or not someone in the party possess it. This is similar to CODE 21 which allows you to branch to different encounters/Action Points, however, this code lets you branch to different scripts within a specific encounter.
#Options: None
#E-Codes:
#1) Item ID to check for.
#2) 0 = Cont On Poss, 1 = Cont not Poss
#3) 0 = X-AP, 1 = Within simple, 2 = Within complex
#4) X-AP/Branch No. (0-3 if within encounter)
#5) Code No. (0 = top Code/ID)
#use :
#var branch : String = branch_item_possession_divinity()
#if not branch.is_empty() :
	#return branch
static func branch_item_possession_divinity(item_id : int, cont_not_poss : int, type : int, xap_id : int, code_no : int)->String :
	var has_item : bool  = does_party_have_item_named(ItemIdDivinity.mapping[item_id])
	if (cont_not_poss and (not has_item)) or ((not cont_not_poss) and has_item) :
		return ''
	var returned : String = 'xapid'
	match type :
		0 :
			return "XAP"+str(xap_id)
		1 :
			return "SEXAP"+str(xap_id)
		2 :
			return await run_complex_result_Divinity(xap_id, code_no)
		_:
			return ''

#Code 41: Eliminate Other Encounter Choice
#ID: Extra Codes ID
#Use: Similar to CODE 35, this will eliminate one of the 4 possible choices for a Simple Encounter. However, will eliminate the choice of ANY encounter at any time.
#Options: None
#E-Codes:
#1) Simple Encounter No.
#2) Choice No. To Eliminate (1-4)
static func eliminate_se_option_divinity(enc_id : int, choice_id : int) :
	var se_name : String = 'SE'+str(enc_id)
	eliminate_se_option(se_name, choice_id )

#Divinity Code 35, calls 41, simple_enc_del
static func eliminate_current_se_option_divinity(choice_id : int) :
	var se_name : String = GameGlobal.prev_simple_enc_name
	eliminate_se_option(se_name, choice_id )

static func eliminate_se_option(se_name : String, choice_id : int) :
	var se_data : Array = GameGlobal.stuff_done[GameGlobal.currentmap_name+'.SEdata'][se_name]
	se_data[1][choice_id][2]=0

#code 19  random_string
static func display_random_text_from_array_wait(text_arr : Array) :
	var textRect = UI.ow_hud.textRect
	play_sound('message nod.wav', false)
	textRect.set_text(str(text_arr.pick_random()), true)
	await textRect.interruption_over

#Code 85: Branch on Random
#1) Type:0 = X-AP, 1 = Simple, 2 = Complex
#2) Low Range Value.
#3) High Range Value.
#4) Sound --- Optional ---
#5) Message --- Optional ---
#for XAP use  with
#var branch = ScriptHelperFuncs.branch_on_random_divinity()
#if not branch.is_empty() :
	#return branch
# for SE,   call it  istead of using return
static func branch_on_random_divinity(type:int, low:int, high:int, sound_id:int, message : String) :
	var  rand_id : int = randi_range(low, high)
	match type :
		0: #XAP
			return 'XAP'+str(rand_id)
		1 :#SEeeee
			return 'SE'+str(rand_id)
		2: #Complex encounter
			return complex_encounter_branch(rand_id)


#Code 42: Branch on Percent Chance
#ID: Extra Codes ID
#Use: Allows you to specify a percent chance that an action of a specified type will happen.
#Otherwise, the c will continue to be executed.
#Options: Code -42 will add current script to the stack. The next Code 111 will return control
#to the calling script where it left off.
#See chapter "Action Points • Gosubs" for more info on the Stack and GOSUBS.
#E-Codes:
#1) Percent Chance of Happening, Else Continue Codes
#2) 1 = Branch, 2 = Exit & Save Codes, -2 = Exit & Erase Codes
#3) 0 = X-AP, 1 = Within Simple, 2 = Within Complex
#4) X-AP/Branch No. (0-3)
#5) Code No. (0 = Top Code/ID)
#use :
#var branch : String = branch_percent_chance_divinity()
#if not branch.is_empty() :
	#return branch
static func branch_percent_chance_divinity(percent : int, whatdo : int, type : int, number : int, lineskip : int) :
	if randf() > float(percent) / 100.0:
		return ''
	match whatdo :
		1 :
			match type :
				0 : #XAP
					return 'XAP'+str(number)
				1 : #SEXAP :
					return GameGlobal.prev_simple_enc_name+'XAP'+str(number)
				2 : #CEXAP :
					return await run_complex_result_Divinity(number, lineskip)
		2 :
			return "STOP"
		-2 :
			flag_disabled_current_script()
			return "STOP"
	return ''


#Code 54: Alter Time Encounter
#ID: Extra Codes ID
#Use: Use this code to change a time based encounter.
#Options: None
#E-Codes:
#1) Time Encounter ID
#2) New % Chance Of Activation (-1 = No Change)
#3) New Day Increment (-1 = No Change)
#4) 1 = Reset to current date  :  4) If you want the encounter to be activated 3 days from
#	the present time, then place a 1 in this field. It will change the day of activation to
#	the present day PLUS the value in 5).
#5) Days to add to next activation (-1 = No Change)
#check campaign's campaign_global_script.gd and on_campaign_start.gd,   ===== TIME ENCOUNTER in dump
static func alter_time_event_divinity(_tenc_id : int, _newchance_prct : int, _new_incr : int, _reset : int, _to_next_act : int ) :
	var tenc_name : String = 'Time_Enc_'+str(_tenc_id)
	var enc_dict : Dictionary = GameGlobal.stuff_done["Timed_Encounters"][tenc_name]
	if _newchance_prct>=0 :
		enc_dict["chance_prct"] = _newchance_prct
	if _new_incr >=0 :
		enc_dict["chance_prct"] = _new_incr
	if _reset >=0 :
		if enc_dict.has("after") :
			enc_dict["after"] = enc_dict["after"] + 86400*_to_next_act
		if enc_dict.has("before") :
			if enc_dict["before"] >= 0 :
				enc_dict["before"] = enc_dict["before"] + 86400*_to_next_act

static func set_time_event_chance( _tenc_name : String, _newchance_prct : int) :
	GameGlobal.stuff_done["Timed_Encounters"][_tenc_name]["chance_prct"] = _newchance_prct

#Code 87: Branch on Special Character (NPC) Present
#1) Monster number to check for.
#2) If Present, Branch To: 0 = X-AP, 1 = Simple Encounter, 2 = Complex Encounter
#3) If Not Present, 0 = Branch as in Item 2, 1 = Continue Codes, 2 = Display String
#4) X-AP/Encounter No. If Present.
#5) X-AP/Encounter No./String ID If Not Present.
# use :
#var branch : String = branch_NPC_in_party_Divinity()
#if not branch.is_empty() :
	#return branch
static func branch_NPC_in_party_Divinity(creature_name : String, ifpresenttype : int, ifabsenttype : int, ifpresentto : int, ifabsentto : int) :
	#var npc_name = 'Vodalian'
	var present : bool = false
	for c in GameGlobal.player_allies :
		if c.name == creature_name :
			present = true
			break
	if present :
		match ifpresenttype :
			0 : #XAP
				return 'XAP'+str(ifpresentto)
			1 : #SEXAP
				return GameGlobal.prev_simple_enc_name+str(ifpresentto)
			2: #complex :
				return complex_encounter_branch(ifpresentto)
	else :
		match ifabsenttype :
			0 : #like in item 2 if present
				match ifpresenttype :
					0 : #XAP
						return 'XAP'+str(ifabsentto)
					1 : #SEXAP
						return GameGlobal.prev_simple_enc_name+str(ifabsentto)
					2: #complex :
						return complex_encounter_branch(ifabsentto)
			1 : #continue
				return ''#GameGlobal.prev_simple_enc_name+str(ifabsentto)
			2: #complex :
				printerr("ScriptHelperFuncs branch_NPC_in_party_Divinity : displaying an absent-ally string is not supported")
				assert(false)
	return ''

static func is_NPC_in_party(npc_name : String) :
	var present : bool = false
	for c in GameGlobal.player_allies :
		if c.name == npc_name :
			present = true
			break
	return present


#Divinity Code 150 destroy_related_monsters
static func destroy_related_monsters(cname : String, number : int,  allies_too : bool) :
	for cb in StateMachine.combat_state.all_battle_creatures_btns :
		if cb.creature.name ==  cname and not GameGlobal.player_characters.has(cb.creature):
			if cb.creature.baseFaction == 0 and (not allies_too) :
				continue
			cb.creature.change_cur_hp(-999999999)
