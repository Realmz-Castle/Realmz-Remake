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
#func _process(delta):
	#pass

func enter(_msg : Dictionary = {} ) ->void :
	print("ExMenusState Enter , msg: ",_msg)
	var menu_name = _msg["menu_name"]
	Input.set_custom_mouse_cursor(UI.cursor_sword)
	#some menus cant be left so easily !
	if ["PC_Pick"].has(cur_menu_name) :
		printerr("ExMenuState : you can t pcik charcaters whilepicking characters")
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
			UI.ow_hud.inventoryRect.shopButtonsRect.hide()
			UI.ow_hud.combatBRPanel.hide()
			UI.ow_hud.combatBRPanel.set_buttons_enabled(false)
			UI.ow_hud.botrightpanel.disable_all_except('InventoryButton', _msg["selected_character"])
			UI.ow_hud.botrightpanel.show()
			UI.ow_hud.inventoryRect.when_Items_Button_pressed()
			MusicStreamPlayer.play_music_type("Items")
		"SpellsMenu" :
			cur_menu_name = menu_name
			UI.ow_hud.spellcastMenu.initialize(_msg["selected_character"])
			UI.ow_hud.spellcastMenu.show()
		"LootMenu" :
			cur_menu_name = menu_name
			await GameGlobal.show_loot_menu(
				_msg["treasure"],
				_msg["money"],
				_msg["exp"],
				bool(_msg.get("classicBattleReward", false))
			)
			#if not GameGlobal.player_allies.is_empty() :
		"MiniMapsMenu" :
			cur_menu_name = menu_name
			UI.ow_hud.minimapRect.show()
			UI.ow_hud.minimapRect.on_display()
		"ClassicPlayerMapMenu" :
			cur_menu_name = menu_name
			UI.ow_hud.classicPlayerMapRect.show()
		"SpecEncounter_menu" :
			cur_menu_name = menu_name
			UI.ow_hud.encounterControl.disablerButton.hide()
		"TempleMenu" :
			cur_menu_name = menu_name
			UI.ow_hud.temple_rect.show_temple_window()
		"CharacterInfoMenu", "MultipleChoices" :
			cur_menu_name = menu_name
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
	
	if cur_menu_name == "MiniMapsMenu" :
		UI.ow_hud.minimapRect.hide()
	if cur_menu_name == "ClassicPlayerMapMenu" :
		UI.ow_hud.classicPlayerMapRect.hide()
	
	if cur_menu_name == "TempleMenu" :
		UI.ow_hud.temple_rect.close_temple_window()
	if cur_menu_name == "CharacterInfoMenu" :
		UI.ow_hud.characterStatRect.hide()
	if cur_menu_name == "MultipleChoices" :
		UI.ow_hud.textRect.choicesContainer.hide()

	cur_menu_name = ''



func _state_process(_delta : float) -> void :
	#print("ExMenusState cur_menu_name : " , cur_menu_name)
	if cur_menu_name== "PC_Pick" :
		var cursorid : int = min(8, need_to_pick_n - picked_charapanels.size() )
		#print(cursorid)
		Input.set_custom_mouse_cursor(UI.cursor_numbers[cursorid])
	#if cur_menu_name== "LootMenu" :
		#Input.set_custom_mouse_cursor((UI.cursor_sword))

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

func use_inventory_item(item: ItemInstance, user: Creature) -> void:
	var resources = NodeAccess.__Resources()
	var definition := resources.get_item_definition(item)
	if definition == null:
		return
	print("ExMenusState use_inventory_item " + definition.display_name_for(item))
	if resources.item_has_hook(item, "field_use"):
		var hook_result: Dictionary = resources.run_item_hook(
			item,
			"field_use",
			[user],
		)
		if not bool(hook_result.get("ok", false)):
			for message: Variant in hook_result.get("errors", []):
				push_error(str(message))
			return
		if definition.delete_on_empty:
			if item.charges <= 0:
				var dropped = user.drop_inventory_item(item)
				if dropped :
					SfxPlayer.stream = NodeAccess.__Resources().sounds_book["drop item.ogg"]
					SfxPlayer.play()
			GameGlobal.refresh_OW_HUD()
		return
	var spell_use := resources.item_spell_use(item, "field")
	if spell_use.size() >= 2:
			print("ItemSmallBUtton ITEM RIGHT CLICKED HAS A _on_field_use_spell")
			print("ItemSmallBUtton _on_field_use_spell TBI :(")
			var spellname : String = spell_use[0]
			var spellpower : int = spell_use[1]
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
func get_num_of_targs_of_spell_in_field(spell : Spell, spellpower, user : Creature) -> int :
	var s_spell_aoe : Array[Vector2i] = spell.get_aoe(spellpower, user)
	if spell.autotarget_type==Spell.AUTOTARGET_TYPE.SELF :
		return -2
	if [Spell.AUTOTARGET_TYPE.PARTY,Spell.AUTOTARGET_TYPE.ALL_ALLIES,Spell.AUTOTARGET_TYPE.ALL_ENEMIES, Spell.AUTOTARGET_TYPE.EVERYONE].has(spell.autotarget_type) :
		return -1
	var how_many_targets = spell.get_targets(spellpower, user)
	#var aoe : Array = GameGlobal.map.targetingLayer.get_aoe_from_name(s_spell_aoe_name)
	how_many_targets = max(how_many_targets, s_spell_aoe.size()) * spell.get_target_number(spellpower, user)
	how_many_targets = min(how_many_targets, GameGlobal.player_allies.size()+GameGlobal.player_characters.size())
	return how_many_targets

func on_spell_picked(character : Creature, spell, powerlevel : int, item : Dictionary) :
	print("ExMenus state on_spell_picked : ",character.name," ", spell.name)
	if item.is_empty() and not spell.get("is_not_spell") and not character.can_cast_spells():
		return
	var _spelldata :  Dictionary = character.get_spell_data(spell, powerlevel)
	var how_many_targets : int = get_num_of_targs_of_spell_in_field(spell, powerlevel, character)
	var targets : Array = []
	var must_pick : bool = true
	if how_many_targets == -2 :  # sf
		targets.append(character)
		how_many_targets = 1
		must_pick = false
		#targs_picked = true
	if how_many_targets == -1 :  #["pt","af","ae", "eo"]
		targets = GameGlobal.player_characters + GameGlobal.player_allies
		must_pick = false
		how_many_targets = 1
		#targs_picked = true

	if how_many_targets > 0 :
		print("ow hud pick targets among party members")
		UI.ow_hud.spellcastMenu.hide()
		pass
		#request PC pick
		if must_pick :
			UI.ow_hud.request_pc_pick(how_many_targets)
			targets = await UI.ow_hud.pc_picked
		pass
		#print("MenusState entered PC_Pick")
		#picked_charapanels.clear()
		#need_to_pick_n = how_many_targets
		#cur_menu_name = "PC_Pick"
		#targets = await characters_picked
		#print("ExMenu : cast "+spell.name+" on  :")
		#for p in targets :
			#print("    "+p.name)
		

		character.on_ability_use(spell, powerlevel)
		var uses_group_effect: bool = spell.has_method("apply_classic_group_effect")
		if uses_group_effect:
			spell.apply_classic_group_effect(character, targets, powerlevel)

		for target in targets :
			print ("cast "+spell.name+" on "+target.name)
			#do the spells effect !
			
			SfxPlayer.stream = GameGlobal.cmp_resources.sounds_book[spell.sounds[1]]
			SfxPlayer.play()
			
			if spell.get("proj_hit") :
				print("ExMenusState : OW HUD display spell effect ",spell.proj_hit)
				await UI.ow_hud.show_spell_effect_on_char_menu( target, spell.proj_hit  )
			if not uses_group_effect:
				await GameGlobal.do_spell_field_effect(character, target, spell, powerlevel)
			
			if not uses_group_effect and spell.get("special_effect") :
				print("FIELD SPECIAL EFFECT")
				var _is_over : bool = await spell.special_effect(character, spell, powerlevel, Vector2.ZERO, [], [target], false)
			
			UI.ow_hud._on_spell_menu_closed()
			UI.ow_hud.updateCharPanelDisplay()
			
			StateMachine.exit_ex_menu_state()
			
#			charactersrect._set_position(Vector2(screensize.x-320,0) )
#			charactersrect._set_size(Vector2(320,charrectheight))
	else :
		print("ExMenusState : spell targ number = 0 ,  not implemented :(")

	UI.ow_hud.spellcastMenu.hide()
	UI.ow_hud.textRect.textLabel.parse_bbcode('')


func set_selected_chara(_c : Creature) :
	print("ExMenusState set_selected_chara "+_c.name)
	if UI.ow_hud.inventoryRect.visible :
		UI.ow_hud.inventoryRect.when_Items_Button_pressed()
