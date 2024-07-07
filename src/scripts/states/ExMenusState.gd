extends State
class_name ExMenusState

var prev_state_path : String = "Exploration"
var cur_menu_name : String = ''

var picked_charapanels : Array = []
var need_to_pick_n : int = 0

signal characters_picked

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#UI.ow_hud.textRect.choicesContainer.choice_pressed.connect(_on_choicebox_choice_picked)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func enter(_msg : Dictionary = {} ) ->void :
	print("ExMenusState Enter , msg: ",_msg)
	var menu_name = _msg["menu_name"]
	Input.set_custom_mouse_cursor(UI.cursor_sword)
	#some menus cant be left so easily !
	if ["PC_Pick"].has(cur_menu_name) :
		print("MenuState : you can t pcik charcaters whilepicking characters")
		#emit_signal("pcs_picked", [])
		return
	
	if _msg["prev_state"] != "ExMenus" :
		prev_state_path = _msg["prev_state"]
		if prev_state_path.begins_with("Cb") :
			prev_state_path = "Combat/"+prev_state_path


	match menu_name :
		"PC_Pick" :
			print("MenusState entered PC_Pick")
			picked_charapanels.clear()
			need_to_pick_n = int( min( _msg["PC_Pick"] , GameGlobal.player_characters.size()+GameGlobal.player_allies.size()) )
			cur_menu_name = menu_name
		"InventoryMenu" :
			cur_menu_name = menu_name
			GameGlobal.map.hide()
			UI.ow_hud.textRect.show()
			UI.ow_hud.creatureRect.hide()
			UI.ow_hud.combatBRPanel.hide()
			UI.ow_hud.combatBRPanel.set_buttons_enabled(false)
			UI.ow_hud.botrightpanel.disable_all_except('InventoryButton', _msg["selected_character"])
			UI.ow_hud.botrightpanel.show()
			UI.ow_hud.inventoryRect.when_Items_Button_pressed()
			MusicStreamPlayer.play_music_type("Items")
		"SpellsMenu" :
			UI.ow_hud.spellcastMenu.initialize(_msg["selected_character"])
			UI.ow_hud.spellcastMenu.show()
		"LootMenu" :
			await GameGlobal.show_loot_menu(_msg["treasure"],_msg["money"],_msg["exp"])
			#if not GameGlobal.player_allies.is_empty() :
			GameGlobal.show_allies_menu()
			await UI.ow_hud.alliesCtrl.done_allying
			pass

func exit() :
	print("MenuState Exit menu:" +cur_menu_name)
	#if cur_menu_name== "PC_Pick" :
		#emit_signal("characters_picked", [])
	
	picked_charapanels.clear()
	need_to_pick_n = 0
	
	if cur_menu_name == "InventoryMenu" :
		UI.ow_hud.inventoryRect.shopRect._on_LeaveShopButton_pressed()
		UI.ow_hud.inventoryRect.hide()
		UI.ow_hud.set_charactersRect_type(0)	##type :  0:map 1:loot 2:combat
		UI.ow_hud.botrightpanel.enable_all(UI.ow_hud.selected_character)
		GameGlobal.map.show()
		MusicStreamPlayer.play_music_map()
		#UI.ow_hud.botrightpanel.enable_all(selected_character)
		UI.ow_hud.textRect.set_text('', false)
	
	cur_menu_name = ''


func _state_process(_delta : float) -> void :
	#print("cur_menu_name : "+cur_menu_name)
	if cur_menu_name== "PC_Pick" :
		var cursorid : int = min(8, need_to_pick_n - picked_charapanels.size() )
		#print(cursorid)
		Input.set_custom_mouse_cursor(UI.cursor_numbers[cursorid])

func _on_chara_panel_selected_for_picking(cp : CharaSmallPanel) :

	if picked_charapanels.has(cp) :
		picked_charapanels.erase(cp)
	else :
		picked_charapanels.append(cp)
	print("MENUSTATE CP " + cp.character.name +" "+str(picked_charapanels.size()))
	var n = need_to_pick_n
	for p : CharaSmallPanel in picked_charapanels :
			p.set_targeted_number(n - picked_charapanels.size())
			n += 1
	if picked_charapanels.size() >= need_to_pick_n :
		var picked_charas : Array = []
		for p : CharaSmallPanel in picked_charapanels :
			picked_charas.append(p.character)
		#StateMachine.transition_to("Inactive")
		emit_signal("characters_picked", picked_charas)
		

#func _on_choicebox_choice_picked(ans : String) :
	#print("answer : " + ans )

func use_inventory_item(item : Dictionary, user : Creature) :  #from inventory menu
	print('ExMenusState use_inventory_item '+item["name"])
	if item.has("_on_field_use") :
		print('ExMenusState use_inventory_item '+item["name"]+" has _on_field_use script")
		item["_on_field_use"]._on_field_use(user, item)
		if item.has("delete_on_empty") and (item["delete_on_empty"] == 1) :
			if item.has("charges") and item["charges"]<=0 :
				var dropped = user.drop_inventory_item(item)
				if dropped :
					SfxPlayer.stream = NodeAccess.__Resources().sounds_book["drop item.ogg"]
					SfxPlayer.play()
		GameGlobal.refresh_OW_HUD()
		return
		if item.has("_on_field_use_spell" ) :
			print("ItemSmallBUtton ITEM RIGHT CLICKED HAS A _on_field_use_spell")
			print("ItemSmallBUtton _on_field_use_spell TBI :(")
			var spellname : String = item["_on_field_use_spell"][0]
			var spellpower : int =  item["_on_field_use_spell"][1]
			var spell = GameGlobal.cmp_resources.spells_book[spellname]["script"]
			
			
			var targs_picked : bool = false
			var targets : Array = []
			
			var how_many_targets : int = get_num_of_targs_of_spell_in_field(spell, spellpower, user)
			if how_many_targets == -2 :
				targets.append(user)
				targs_picked = true
			if how_many_targets == -1 :
				targets = GameGlobal.player_characters + GameGlobal.player_allies
				targs_picked = true
			
			if how_many_targets>0 and (not targs_picked) :
				#request PC pick
				print("MenusState entered PC_Pick")
				picked_charapanels.clear()
				need_to_pick_n = how_many_targets
				cur_menu_name = "PC_Pick"
				targets = await characters_picked
				print("ExMenu : cast "+spell.name+" on  :")
				for p in targets :
					print("    "+p.name)



#-1 = everyone  -2=self only
func get_num_of_targs_of_spell_in_field(spell, spellpower, user : Creature) -> int :
	var s_spell_aoe_name = spell.get_aoe(spellpower, user)
	if s_spell_aoe_name=="sf" :
		return -2
	if ["pt","af","ae", "eo"].has(s_spell_aoe_name) :
		return -1
	var how_many_targets = spell.get_targets(spellpower, user)
	var aoe : Array = GameGlobal.map.targetingLayer.get_aoe_from_name(s_spell_aoe_name)
	how_many_targets = max(how_many_targets, aoe.size()) 
	how_many_targets = min(how_many_targets, GameGlobal.player_allies.size()+GameGlobal.player_characters.size())
	return how_many_targets

func on_spell_picked(character, spell, powerlevel) :
	print("ExMenus state on_spell_picked : ",character.name," ", spell)
	var spelldata :  Dictionary = character.get_spell_data(spell, powerlevel)
	var how_many_targets : int = get_num_of_targs_of_spell_in_field(spell, powerlevel, character)
	var targets : Array = []
	if how_many_targets == -2 :
		targets.append(character)
		#targs_picked = true
	if how_many_targets == -1 :
		targets = GameGlobal.player_characters + GameGlobal.player_allies
		#targs_picked = true

	if how_many_targets > 0 :
		print("ow hud pick targets among party members")
		UI.ow_hud.spellcastMenu.hide()
		#request PC pick
		UI.ow_hud.request_pc_pick(how_many_targets)
		targets = await UI.ow_hud.pc_picked
		#print("MenusState entered PC_Pick")
		#picked_charapanels.clear()
		#need_to_pick_n = how_many_targets
		#cur_menu_name = "PC_Pick"
		#targets = await characters_picked
		#print("ExMenu : cast "+spell.name+" on  :")
		#for p in targets :
			#print("    "+p.name)
		

		character.on_ability_use(spell, powerlevel)
		for target in targets :
			print ("cast "+spell.name+" on "+target.name)
			
			#do the spells effect !
			GameGlobal.do_spell_field_effect(character, target, spell, powerlevel)
			
			SfxPlayer.stream = GameGlobal.cmp_resources.sounds_book[spell.sounds[1]]
			SfxPlayer.play()
			if spell.get("proj_hit") :
				print("OW HUD display spell effect ",spell.proj_hit)
				UI.ow_hud.show_spell_effect_on_char_menu( target, spell.proj_hit  )

			UI.ow_hud._on_spell_menu_closed()
			UI.ow_hud.updateCharPanelDisplay()
			
			StateMachine.exit_ex_menu_state()
			
#			charactersrect._set_position(Vector2(screensize.x-320,0) )
#			charactersrect._set_size(Vector2(320,charrectheight))
	else :
		print("Ow HUD : spell targ number = 0 ,  not implemented :(")

	UI.ow_hud.spellcastMenu.hide()
	UI.ow_hud.textRect.textLabel.parse_bbcode('')


func set_selected_chara(c : Creature) :
	if UI.ow_hud.inventoryRect.visible :
		UI.ow_hud.inventoryRect.when_Items_Button_pressed()
