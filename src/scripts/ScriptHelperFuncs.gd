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

## Divinity Code 3 Player Option , option
static func yesno_branch(continue_on_yes : bool, tg_type : int, tg_name : String, lefttxt : String, righttxt : String) ->bool :
	#return true iff branching, if continuing return false does nothing
	#continue_option=, target_type=, target=, left_prompt=, right_prompt=
	# 0: back  a step, 1: continue normally,  2:simple enc, 3:complex_end ; 4 : exit  and disable script
	var textRect : TextRect = UI.ow_hud.textRect
	if lefttxt=='' and righttxt=='' :
		textRect.display_multiple_choices(["YESNO"],["YESNO"])
	else :
		textRect.display_multiple_choices([lefttxt, righttxt],["YES", "NO"])
	var answer = await textRect.choice_pressed
	if (continue_on_yes and answer=='NO') or (not continue_on_yes and answer=='YES') :
		return false #don't branch, keep executing AP normally
	else:
		if tg_type==0 :
			GameGlobal.must_cancel_movement = true # that's  "cancel movement"
			print("yesno_branch back a step")
		if tg_type == 1 :
			print("yesno_branch continue normally")
		if tg_type == 2 :
			printerr("yesno_branch to simple  encounter "+str(tg_name)+", pleae fix manually and set the 2nd parameter 2 (simple enc) to 1 (continue manually)")
		if tg_type == 3 :
			printerr("yesno_branch to complex encounter "+str(tg_name)+", pleae fix manually and set the 2nd parameter 3 (complex enc) to 1 (continue manually)")
		if tg_type==4 :
			printerr("yesno_branch flag script as disabled, make sure to add a check at script start")
			flag_disabled_current_script()
		return true
			
	
	
## Divinity Code 4, Simple Encounter  , simple_enc
static func display_simple_encounter(enc_name : String) :
	print("display_simple_encounter must be translated by hand as they are not independent objects in realmzremake")

## Divinity Code 5: Complex Encounter, complex_enc
## Use: Send party to a Complex Encounter.
static func start_complex_encounter( comp_enc_name : String) :
	StateMachine.enter_ex_menu_state({"prev_state" : "Exploration", "menu_name" : "SpecEncounter_menu"})
	UI.ow_hud.encounterControl.show()
	UI.ow_hud.encounterControl.initialize(comp_enc_name)

## Divinity Code 9: Play Sound , sound
static func play_sound(sfx_name : String, stop : bool) :
	SfxPlayer.stream = NodeAccess.__Resources().sounds_book[sfx_name]
	SfxPlayer.play()
	if stop : await SfxPlayer.finished

##Divinity Code 21: Branch on Possession of Specific Item, jmp_if_item
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

## Divinity Code 24 exit_ap , Exit Action Point and Keep Codes,  doesn't need anything

##Divinity 25: Exit Action Point and Delete Action Point  , exit_ap_delete
static func flag_disabled_current_script() ->void :
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

#Divinity Code 101 : Back Up :
static func set_walk_back_once(should : bool) :
	GameGlobal.must_cancel_movement = should


## Divinity Code 2 : battle
static func start_battle_in_range(low : int, high : int, sfx_id : int, displaytext : String, give_treasure : int) :
	#low=, high=, sound_id=, string_id=, treasure_mode= 
	var battles_id_name_dict = GameGlobal.campaign_global_script.battles_id_name_dict
	var sfx_id_name_dict = GameGlobal.campaign_global_script.sfx_id_name_dict
	var battle_name = battles_id_name_dict[randi_range(low, high)]
	GameGlobal.allow_next_battle_loot = give_treasure!=5 # from divinity doc : A value of 5 here : no loot. 10 : no gameover.
	play_sound(sfx_id_name_dict[sfx_id], true)
	GameGlobal.start_battle(battle_name,"",true, false, give_treasure==10, true, true, [] ) # all party if pc_particiating is empty


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



## Divinity Code 7 : modify_ap    level=, id=, source_xap=, level_type=, result_code=
static func add_script_branch_flag( map_id : int, type : int, source_id : int, modified_script_id : int) :
	var flagname : String = "modify_ap_map"+str(map_id)+"_type"+str(type)+"_AP"+str(source_id)
	GameGlobal.stuff_done[flagname] = modified_script_id
	printerr("\n\n\n   USED add_script_branch_flag !!!\n    "+flagname+' '+str(modified_script_id)+"\nPlease make sure the script branches properly\n\n")

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
	var treasure_dict : Dictionary = GameGlobal.campaign_global_script.generate_treasure_with_id(treasure_id)
	await StateMachine.enter_ex_menu_state({"menu_name" : "LootMenu", "treasure" : treasure_dict["treasure"] ,"money" : treasure_dict["money"] ,"exp" : treasure_dict["exp"] })


##Divinity Code 13: Enable/Disable Action Point  level=, id=, percent_chance=, low=, high= 
static func set_scrip_enabled_flag(useless : int, map_id, exec_chance : float, ap_id : int, ap_upto_id : int) ->void :
	var map_name = "map_"+str(map_id)
	for id in range(ap_id, ap_upto_id) :
		var script_name = "script_"+str(id)
		var flag_name : String = map_name+'.'+script_name+'.chance'
		GameGlobal.stuff_done[flag_name] = exec_chance
		printerr("\n\n\n   USED set_scrip_enabled !!!\n    "+flag_name+' = '+str(exec_chance)+"\nPlease make sure the script checks this flag !\n\n")

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
				for i in pc.inventory :
					if i["name"]==parameter :
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


## Divinity Code 15: Heal/Hurt Picked     picked using a Code 14 or 30
static func heal_picked_Divinity(mult : int, low_range, high_range, sound, string, prev_picked) :
	print("calling ScriptHelperFuncs  heal_picked_Divinity")
	if prev_picked.is_empty() :
		printerr('heal_picked_Divinity,  dindt have any picked character')
	for pc in prev_picked :
		var hp_gained = randi_range(low_range,high_range)*mult
		pc.change_cur_hp(hp_gained)
	if sound>=0  and string >=0 :
		printerr("heal_picked_Divinity tried to play sound "+str(sound)+"and display string "+str(string))

static func heal_party(mult : int, low_range : int, high_range : int, sfxname : String) :
	var playsound : bool = false
	for pc in GameGlobal.player_characters :
		var hp_gained = randi_range(low_range,high_range)*mult
		pc.change_cur_hp(hp_gained)
		playsound = true
	if playsound :
		ScriptHelperFuncsClass.play_sound(sfxname, false)

## Divinity Code 27: Display Picture, from the campaign splash folder
static func display_picture_file(img_name : String) :
	UI.ow_hud.pictureRect.display_image(img_name)

## Divinity Code 28: Redraw Screen ,  after you have displayed a picture.
static func hide_picture() :
	UI.ow_hud.pictureRect.hide()


## Divinity Code 47: Set Clear Quest Flag , set_quest : quest_id
static func set_quest_id_flag_Divinity(quest_id : int) :
	var zeroone : int = 1
	if quest_id < 0:
		zeroone = 0
	GameGlobal.stuff_done["quest_"+str(abs(quest_id))] = zeroone

## Divinity Code 46: Branch on Quest (See code 72 & 77 for more options) , jmp_quest
static func branch_on_quest_Divinity(quest_id : int, go_on_if_done : int, target_type : int, target : int, code_index : int) :
	var quest_name : String = "quest_"+str(quest_id)
	var should_continue : bool = GameGlobal.stuff_done[quest_name] + go_on_if_done ==  1 #not brainching if true
	printerr("Code 46 branch_on_quest_Divinity : go_on_if_done:",go_on_if_done,", target_type:",target_type,", target:", target, ", code_index:", code_index)
	return should_continue

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
	print('""disablerButton, "pressed"')
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

static func CastSpellOnPickedCharacters(characters : Array, spell_name : String, power : int) :
	var spell = NodeAccess.__Resources().spells_book[spell_name]
	var character = Creature.new()
	for target in characters :
			SfxPlayer.stream = GameGlobal.cmp_resources.sounds_book[spell.sounds[1]]
			SfxPlayer.play()
			if spell.get("proj_hit") :
				UI.ow_hud.show_spell_effect_on_char_menu( target, spell.proj_hit  )
			await GameGlobal.do_spell_field_effect(character, target, spell, power)
			if spell.get("special_effect") : 
				var is_over : bool = await spell.special_effect(character, spell, power, Vector2.ZERO, [], [target], false)
			
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
	GameGlobal.set_temple_availlable(true)

static func remove_gold_from_party(gold_to_give : int) :
	for character : Creature in GameGlobal.player_characters :
		var gold_given : int = min (gold_to_give, character.money[0])
		gold_to_give -= gold_given
		character.money[0] -= gold_given


static func change_tileset(fromname : String, toname : String) :
	var map  : Map =  GameGlobal.map
	var resources : CampaignResources = GameGlobal.cmp_resources
	var tonamejson : String = toname + '.json'
	printerr(str(GameGlobal.map.mapdata[0][0]))
	for x in range(map.mapdata[0].size()) :
		for y in range(map.mapdata.size()) :
			var curtile : Dictionary = map.mapdata[y][x][0]
			if curtile["tileset_name"] == fromname :
				map.mapdata[y][x][0] = resources.tiles_book[tonamejson][curtile["id"]]
