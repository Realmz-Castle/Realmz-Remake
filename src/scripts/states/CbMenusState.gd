extends State
class_name CbMenusState

var prev_state_path : String = "CbDecideAction"
var cur_menu_name : String = ''

var picked_charapanels : Array = []
var need_to_pick_n : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#UI.ow_hud.textRect.choicesContainer.choice_pressed.connect(_on_choicebox_choice_picked)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func enter(_msg : Dictionary = {} ) ->void :
	print("CbMenusState Enter , msg: ",_msg)
	var menu_name = _msg["menu_name"]
	#some menus cant be left so easily !

	
	if _msg["prev_state"] != "ExMenus" :
		prev_state_path = _msg["prev_state"]
		if prev_state_path.begins_with("Cb") :
			prev_state_path = "Combat/"+prev_state_path


	match menu_name :
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
			cur_menu_name = menu_name
			UI.ow_hud.spellcastMenu.initialize(_msg["selected_character"])
			UI.ow_hud.spellcastMenu.show()
		"CharacterInfoMenu", "MultipleChoices" :
			cur_menu_name = menu_name


func exit() :
	print("CbMenuState Exit menu:" +cur_menu_name)
	#if cur_menu_name== "PC_Pick" :
		#emit_signal("characters_picked", [])
	
	picked_charapanels.clear()
	need_to_pick_n = 0
	
	if cur_menu_name == "InventoryMenu" :
		UI.ow_hud.inventoryRect.shopRect._on_LeaveShopButton_pressed()
		UI.ow_hud.inventoryRect.hide()
		UI.ow_hud.textRect.hide()
		UI.ow_hud.creatureRect.show()
		UI.ow_hud.set_charactersRect_type(0)	##type :  0:map 1:loot 2:combat
		print("CBMenusState Exiting Inventory, enable BRpael  buttons")
		UI.ow_hud.combatBRPanel.enable_all(UI.ow_hud.selected_character)
		GameGlobal.map.show()
		MusicStreamPlayer.play_music_map()
		#UI.ow_hud.botrightpanel.enable_all(selected_character)
		UI.ow_hud.textRect.set_text('', false)
	if cur_menu_name == "SpellsMenu" :
		UI.ow_hud.spellcastMenu.hide()
		UI.ow_hud._on_spell_menu_closed()
	if cur_menu_name == "CharacterInfoMenu" :
		UI.ow_hud.characterStatRect.hide()
	if cur_menu_name == "MultipleChoices" :
		UI.ow_hud.textRect.choicesContainer.hide()

		
	cur_menu_name = ''


func _state_process(_delta : float) -> void :
	pass
	#print("cur_menu_name : "+cur_menu_name)
	#if cur_menu_name== "PC_Pick" :
		#var cursorid : int = need_to_pick_n - picked_charapanels.size()
		##print(cursorid)
		#Input.set_custom_mouse_cursor(UI.cursor_numbers[cursorid])

#func _on_chara_panel_selected(cp : CharaSmallPanel) :
#
	#if picked_charapanels.has(cp) :
		#picked_charapanels.erase(cp)
	#else :
		#picked_charapanels.append(cp)
	#print("MENUSTATE CP " + cp.character.name +" "+str(picked_charapanels.size()))
	#var n = need_to_pick_n
	#for p : CharaSmallPanel in picked_charapanels :
			#p.set_targeted_number(n - picked_charapanels.size())
			#n += 1
	#if picked_charapanels.size() >= need_to_pick_n :
		#var picked_charas : Array = []
		#for p : CharaSmallPanel in picked_charapanels :
			#picked_charas.append(p.character)
		##StateMachine.transition_to("Inactive")
		#emit_signal("characters_picked", picked_charas)
		#

#func _on_choicebox_choice_picked(ans : String) :
	#print("answer : " + ans )

func use_inventory_item(item: ItemInstance, user: Creature) -> void:
	var resources = NodeAccess.__Resources()
	var definition := resources.get_item_definition(item)
	if definition == null:
		return
	print("CbMenusState use_inventory_item " + definition.display_name_for(item))
	if resources.item_has_hook(item, "combat_use"):
		var hook_result: Dictionary = resources.run_item_hook(
			item,
			"combat_use",
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
	var spell_use := resources.item_spell_use(item, "combat")
	if spell_use.size() >= 2:
		print("ItemSmallBUtton ITEM RIGHT CLICKED HAS A _on_combat_use_spell")
		var spellname : String = spell_use[0]
		var spellpower : int = spell_use[1]
		var spell = GameGlobal.cmp_resources.spells_book[spellname]["script"]
		var msg : Dictionary = {
			"used_item": item,
			"caster": user,
			"spell": spell,
			"power": spellpower,
		}
		StateMachine.transition_to("Combat/CbDecideAction", msg)





#spell picked from spell menu
func on_spell_picked(character: Creature, spell, powerlevel: int, item: Variant) -> void:
	print("CbMenus state on_spell_picked : ",character.name," ", spell)
	if item is ItemInstance:
		var definition := NodeAccess.__Resources().get_item_definition(item)
		if definition == null:
			return
		if definition.ammo_type != "cantuse":
			var ammo: ItemInstance = character.current_ammo_weapon_instance
			var ammo_definition := (
				NodeAccess.__Resources().get_item_definition(ammo)
			)
			if ammo == null \
					or ammo_definition == null \
					or ammo_definition.ammo_type != definition.ammo_type:
				print(
					"   CbMenus state on_spell_picked : wrong ammo type, need "
					+ definition.ammo_type
				)
				return
			if ammo_definition.maximum_charges > 0 and ammo.charges == 0:
				print(
					"   CbMenus state on_spell_picked : out of ammo "
					+ ammo_definition.display_name
				)
				return
		elif definition.maximum_charges > 0 and item.charges == 0:
			print("   CbMenus state on_spell_picked : item has no charges")
			return
	elif item is Dictionary:
		if item.is_empty():
			pass
		else:
			var imported_item := NodeAccess.__Resources().import_item_instance(item)
			if imported_item == null:
				return
			on_spell_picked(
				character,
				spell,
				powerlevel,
				imported_item,
			)
			return
	StateMachine.transition_to("Combat/CbDecideAction", {
		"used_item": item,
		"caster": character,
		"spell": spell,
		"power": powerlevel,
	})
