extends Control
class_name OW_HUD


var charsmallpanelTSCN : PackedScene = preload("res://scenes/UI/HUD/Characters Panel/CharacterSmallPanel.tscn")

#var characters : Array =  []

var selected_character = null

@onready var charsVContainer : VBoxContainer = $VBoxScreen/HBoxTop/VBoxCharTime/CharactersRect/CharScrollContainer/VBoxContainer
@onready var timeCntrLabel : Label = $VBoxScreen/HBoxTop/VBoxCharTime/TimeRect/TimeCntrLabel
@onready var lightcntrLabel : Label = $VBoxScreen/HBoxTop/VBoxCharTime/TimeRect/LightCntrLabel
@onready var lightpwrLabel : Label  = $VBoxScreen/HBoxTop/VBoxCharTime/TimeRect/LightPCntrLabel
@onready var xPosLabel : Label = $VBoxScreen/HBoxTop/VBoxCharTime/TimeRect/XnumberLabel
@onready var yPosLabel : Label = $VBoxScreen/HBoxTop/VBoxCharTime/TimeRect/YnumberLabel
@onready var fatigueBar : TextureProgressBar = $VBoxScreen/HBoxTop/VBoxCharTime/TimeRect/FatigueBar


@onready var textRect = $VBoxScreen/HBoxBot/TextRect

@onready var inventoryRect = $VBoxScreen/HBoxTop/MapArea/InventoryRect#$InventoryRect
@onready var bestiaryRect = $VBoxScreen/HBoxTop/MapArea/BestiaryRect
@onready var turnorderPanel : TurnOrderPanel = $VBoxScreen/HBoxTop/MapArea/TurnOrderPanel

@onready var canvaslayer : CanvasLayer = $Canvaslayer

@onready var charactersrect = $VBoxScreen/HBoxTop/VBoxCharTime/CharactersRect
@onready var charscrollcont = $VBoxScreen/HBoxTop/VBoxCharTime/CharactersRect/CharScrollContainer
@onready var timerect = $VBoxScreen/HBoxTop/VBoxCharTime/TimeRect
@onready var botrightpanel = $VBoxScreen/HBoxBot/BotRightPanel

@onready var creatureRect = $VBoxScreen/HBoxBot/CreatureRect
@onready var combatBRPanel = $VBoxScreen/HBoxBot/CombatBRPanel
@onready var globaleffectsRect : GlobalEffectsRect = $VBoxScreen/HBoxBot/BotRightPanel/GlobalEffectsRect
#onready var inventoryBoxCont = $"InventoryRect/InvScrollContainer/VBoxContainer"


@onready var charSwapRect = $CharSwapRect

@onready var honestStorageControl = $VBoxScreen/HBoxTop/MapArea/StorageRect

@onready var treasureControl = $TreasureControl
@onready var settingsControl = $SettingsRect
@onready var encounterControl = $EncounterControl
@onready var moneyControl = $MoneyRect
@onready var spellcastButton : Button = $VBoxScreen/HBoxBot/BotRightPanel/SpellButton
@onready var abilistButton   : Button = $VBoxScreen/HBoxBot/BotRightPanel/AbiListButton
@onready var spellcastMenu = $SpellsRect
@onready var abilitesmngtMenu = $VBoxScreen/HBoxTop/MapArea/AbilitiesMngtRect
@onready var restTimer : Timer = $VBoxScreen/HBoxBot/BotRightPanel/RestButton/RestTimer
@export var storage_rect : Honest_Storage


@onready var levelupWindow : Window = $LevelUpWindow
@onready var levelupCtrl : LevelupRect = $LevelUpWindow/LevelUpRect
@onready var alliesWindow : Window = $AlliesWindow
@onready var alliesCtrl : AlliesRect = $AlliesWindow/AlliesRect
@onready var saveloadCtrl : SaveLoadCtrl = $SaveLoadRect


var timebetweenrests : float = 0.05  #in seconds
#var timesincelastrest : float = timebetweenrests

var selecting_several_characters : bool = false
var selecting_several_characters_needed : int = 0
var selecting_several_characters_count : int = 0
var selected_several_characters : Array = []

var party_swap_enabled : bool = false

signal done_picking_pc
signal pc_picked
#signal done_looting

func initialize() : # takes an array of Characters GD class objects !
	inventoryRect.infoRect = textRect
#	for c in ncharacters :
#		print(c.charname)
	charsVContainer.add_theme_constant_override ("separation",0)
#	inventoryBoxCont.add_theme_constant_override ("separation",0)
#	characters = GameGlobal.player_characters
	fillCharactersRect()
	called_on_CharPanel_SelectButton_pressed(charsVContainer.get_child(0))
	selected_character = GameGlobal.player_characters[0]
	charsVContainer.get_child(0).toggle_SelectButton_Icon(true)
	updateTimeDisplay()
	updateGlobalEffectsDisplay()
	NodeAccess.__Map().set_ow_character_icon(GameGlobal.player_characters[0].icon)
	set_party_swap_enabled(false)
	settingsControl._initialize()
	bestiaryRect._initialize()
	if GameGlobal.allow_character_swap_anywhere :
		set_party_swap_enabled(true)
#	spellcastMenu.connect("spell_picked", self,"_on_spell_picked"
	#Error connect(signal: String,Callable(target: Object,method: String).bind(binds: Array = [  ),flags: int = 0)
	combatBRPanel.hud = self
	
	MusicStreamPlayer.play_music_map()

func _on_viewport_size_changed() :
#	if self.visible :
	var screensize : Vector2 = get_window().get_size()
	var newscalex = min(1.0, screensize.x/800)
	var newscaley = min(1.0, screensize.y/400)
#	set_scale(Vector2(newscalex,newscaley))
	print(screensize)
#	screensize.x = (1/newscalex)*screensize.x
#	screensize.y = (1/newscaley)*screensize.y
	if screensize.x<800 :
		screensize.x = 800
	if screensize.y<400 :
		screensize.y = 400
	set_scale(Vector2(newscalex, newscaley))
	
	levelupWindow.size = screensize-Vector2(360,200)
	alliesWindow.size = screensize
#	botrightpanel._set_position(Vector2(screensize.x-320, screensize.y-200))
	#timerect._set_position(Vector2(screensize.x-320, screensize.y-200-40))
	#charactersrect._set_position(Vector2(screensize.x-320,0))
	#charactersrect._set_size(Vector2(320, screensize.y-200-40))
#	charsVContainer._set_size(Vector2(320, screensize.y-200-40))
	charscrollcont._set_size(Vector2(320, screensize.y-200-40))
	inventoryRect.on_viewport_size_changed(screensize)
	#textRect.on_viewport_size_changed(screensize)
	encounterControl.on_viewport_size_changed(screensize)
	
	#botrightpanel._set_position(Vector2(screensize.x-320,screensize.y-200))

	treasureControl.on_viewport_size_changed(screensize)
	charSwapRect.on_viewport_size_changed(screensize)
	settingsControl.on_viewport_size_changed(screensize)
	moneyControl.on_viewport_size_changed(screensize)

	spellcastMenu.on_viewport_size_changed(screensize)

func get_mofified_screensize() :
	var screensize : Vector2 = get_window().get_size()
	#var newscalex = min(1.0, screensize.x/800)
	#var newscaley = min(1.0, screensize.y/400)
#	set_scale(Vector2(newscalex,newscaley))
#	print(screensize)
#	screensize.x = (1/newscalex)*screensize.x
#	screensize.y = (1/newscaley)*screensize.y
	if screensize.x<800 :
		screensize.x = 800
	if screensize.y<400 :
		screensize.y = 400
	return screensize

func show_owhudcontrol() :
	print("show_owhudcontrol")
	super.show()
	for c in canvaslayer.get_children() :
		c.show()

func hide_owhudcontrol() :
	print("hide_owhudcontrol")
	super.hide()
	for c in canvaslayer.get_children() :
		c.hide()

func update_fatigue_bar() :
	print("ow_hud update_fatigue_bar : ", GameGlobal.fatigue ,", bar:", GameGlobal.fatigue * 128 / 172800, "/128" )
	fatigueBar.value = GameGlobal.fatigue * 128 / GameGlobal.max_fatigue

func fillCharactersRect() :
	for child in charsVContainer.get_children() :
		charsVContainer.remove_child(child)
		child.queue_free()
	for c  in GameGlobal.player_characters :
		var charpanel = charsmallpanelTSCN.instantiate()
		charsVContainer.add_child(charpanel)
#		charpanel._set_global_position(Vector2(0,300*i) )
		charpanel.set_character(c)
		charpanel.update_display()
		charpanel.chara_small_panel_selected.connect(self._on_chara_panel_selected.bind(charpanel))
		
	for c  in GameGlobal.player_allies :
		var charpanel = charsmallpanelTSCN.instantiate()
		charpanel.paneltype = 1  #marks as NPC
		charsVContainer.add_child(charpanel)
#		charpanel._set_global_position(Vector2(0,300*i) )
		charpanel.set_character(c)
		charpanel.update_display()
		charpanel.chara_small_panel_selected.connect(self._on_chara_panel_selected.bind(charpanel))

func _on_chara_panel_selected(cp : CharaSmallPanel) :
	print("OWHUDControl _on_chara_panel_selected "+ cp.character.name+ ' is exmenu ? ', StateMachine.state == StateMachine.ex_menu_state)
	print("     StateMachine.state : ", StateMachine.state.name)
	match StateMachine.state :
		StateMachine.exploration_state :
			#print("OWHUDControl _on_chara_panel_selected BOOP EXPLORATIONSTATE")
			set_selected_creature(cp.character)
		StateMachine.ex_menu_state :
			#print("OWHUDControl _on_chara_panel_selected BOOP EXMENUSTATE ")
			set_selected_creature(cp.character)
			StateMachine.ex_menu_state.set_selected_chara(selected_character)
		StateMachine.cb_decide_state :
			pass #cannot change selected character during combat....
			StateMachine.cb_decide_state._on_selected_charpanel(cp.character)#BUT  they should be targetable !
		

func set_charactersRect_type(t : int, showdropmenu : bool = true) :
	#type :  0:map 1:loot 2:combat
		for child in charsVContainer.get_children() :
			child.set_type(t,showdropmenu)


func updateTimeDisplay() :
	var time = GameGlobal.time
	var day = time / 86400
	var hour = (time-86400*day) / 3600
	var minute = (time-86400*day-3600*hour) / 60
	var second = (time-86400*day-3600*hour-60*minute) % 60
	timeCntrLabel.text = "Day %02d, %02dh %02dm %02ds" % [day, hour, minute, second]
	var ltime = GameGlobal.light_time
	if ltime >= 86400 :
		lightcntrLabel.text = str(ltime/86400)+' d'
	elif ltime >= 3600 :
		lightcntrLabel.text = str(ltime/3600)+' h'
	elif ltime >= 60 :
		lightcntrLabel.text = str(ltime/60)+' m'
	else :
		lightcntrLabel.text = str(ltime)+' s'
#	lightcntrLabel.text = String(GameGlobal.light_time)+' s'
	lightpwrLabel.text = 'P:'+ str(GameGlobal.light_power)
	var mapdisplay = NodeAccess.__Map()
	xPosLabel.text = str(mapdisplay.focuscharacter.tile_position_x)
	yPosLabel.text = str(mapdisplay.focuscharacter.tile_position_y)

func updateCharPanelDisplay() :
	for p in charsVContainer.get_children() :
		p.update_display()

func updateGlobalEffectsDisplay() :
	globaleffectsRect.update_display()

func called_on_CharPanel_SelectButton_pressed(panel) :
	print("called_on_CharPanel_SelectButton_pressed. Selecting several?", selecting_several_characters, ', ',panel.character.name)
	if selecting_several_characters :
		if panel.select_several_counter_label.text != '' :
			#remove_at that character from selection
#			print("should remove_at this char frm array")
			selected_several_characters.erase(panel.character)
			panel.set_targeted_number(0)
			selecting_several_characters_count += 1
			UI.set_cursor_number(selecting_several_characters_count)
			# reset the number display checked the other selected characters
			for cp in charsVContainer.get_children() :
				var cindex = selected_several_characters.find(cp.character)
				if cindex >= 0 :
					cp.set_targeted_number(selecting_several_characters_needed-cindex)
		else :
			# add that character to selection
			selected_several_characters.append( panel.character )
			panel.set_targeted_number(selecting_several_characters_count)
			selecting_several_characters_count -= 1
			UI.set_cursor_number(selecting_several_characters_count)
			if selecting_several_characters_count == 0 :
				selecting_several_characters = false
				# emit a signal for the yield in the script
				print("selected characters : ", selected_several_characters)
				emit_signal("done_picking_pc")
				# remove_at the selcted graphics/label
				for cp in charsVContainer.get_children() :
					cp.set_targeted_number(0)
#				# reset the array
#				selected_several_characters = []
				return
	# just selecting...
	else :
		if StateMachine.is_combat_state() :
			print("OW HUD : can't select other character during combat !")
			return
		
		for p in charsVContainer.get_children() :
			if p==panel :
				p.toggle_SelectButton_Icon(true)
			else :
				p.toggle_SelectButton_Icon(false)
		selected_character = panel.character
		spellcastButton.disabled = (selected_character.spells.size()==0)
		
		abilistButton.disabled = !(selected_character.can_show_ability_list() or GameGlobal.can_show_ability_list)
		
		inventoryRect.reset_trade_panel()
		if inventoryRect.visible :
			inventoryRect.when_Items_Button_pressed()
			if inventoryRect.shopRect.visible :
				inventoryRect.shopRect._on_character_selected(panel.character)
		elif abilitesmngtMenu.visible :
			if selected_character.get("selection_pts")!=null :
				abilitesmngtMenu.set_displayed_character(selected_character)
			else :
				GameGlobal.play_sfx("target error.wav")
		if GameGlobal.honest_mode :
			honestStorageControl._on_character_selected(selected_character)


func request_pc_pick(n : int) :
	print("OW HUD request_pc_pick "+str(n))
	if StateMachine.is_combat_state() :
		pass
	else :
		for cp : CharaSmallPanel in charsVContainer.get_children() :
			cp.chara_small_panel_selected.connect(StateMachine.ex_menu_state._on_chara_panel_selected_for_picking.bind(cp))
		
		StateMachine.enter_ex_menu_state({"PC_Pick" : n, "menu_name" : "PC_Pick" })
		
		selected_several_characters = await StateMachine.ex_menu_state.characters_picked
		
		for cp : CharaSmallPanel in charsVContainer.get_children() :
			cp.chara_small_panel_selected.disconnect(StateMachine.ex_menu_state._on_chara_panel_selected_for_picking)
		print("got!")
		emit_signal( "pc_picked", selected_several_characters)
		Input.set_custom_mouse_cursor(UI.cursor_sword)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	var i : int = 0

#		print(c.charname)
#		i +=1
#	print(characters[0].charname)



func _on_InventoryButton_pressed():
	#print("OW HUD _on_InventoryButton_pressed")
	if moneyControl.visible or encounterControl.visible or bestiaryRect.visible or textRect.choicesContainer.visible or abilitesmngtMenu.visible or spellcastMenu.visible or charSwapRect.visible or saveloadCtrl.visible or settingsControl.visible or treasureControl.visible :
		return
	if StateMachine._state_name=="Exploration" :
		StateMachine.enter_ex_menu_state({"menu_name" : "InventoryMenu", "selected_character" : selected_character})
		return
	if StateMachine._state_name=="ExMenus" :
		StateMachine.exit_ex_menu_state({})
		return
	if StateMachine._state_name=="CbDecideAction" :
		StateMachine.enter_cb_menu_state({"menu_name" : "InventoryMenu", "selected_character" : selected_character})
		return
	if StateMachine._state_name=="CbMenus" :
		StateMachine.exit_cb_menu_state({})
		return
#	print("inventory : ", selected_character.name)

	#if StateMachine._state_name=="CbDecideAction" and is_instance_valid(selected_character.combat_button) :
		##print("OW HUD _on_InventoryButton_pressed  update creatureRect.display_crea_info" , selected_character.name)
##		print("owhud _on_InventoryButton_pressed creatureRect.my_crea_button", creatureRect.my_crea_button)
		#creatureRect.display_crea_info(selected_character.combat_button)


		
		#if StateMachine.is_combat_state() :
			#print("OWHUD _on_InventoryButton_pressed enter_battle_mode()")
			#
			#enter_battle_mode()
		
		return



func set_party_swap_enabled(enabled : bool) :
	party_swap_enabled = enabled
	$VBoxScreen/HBoxBot/BotRightPanel/CharSwapButton.disabled = not enabled

func _on_CharSwapButton_pressed():
	print('_on_CharSwapButton_pressed')
	if charSwapRect.visible :
		charSwapRect.hide()
		#GameState.set_paused(false)
		MusicStreamPlayer.play_music_map()
		return
	#if GameState.paused :
		#return
#	print("inventory : ", selected_character.name)
#	if inventoryRect.visible :
#		inventoryRect.hide()
#		NodeAccess.__Map().show()
	if not charSwapRect.visible :
		#GameState.set_paused(true)
		charSwapRect.show_charswaprect()
		MusicStreamPlayer.play_music_type("Create")
#	else :
#		GameState.set_paused(false)


func show_loot_menu(items:Array, money : Array, experience : int) :
#	if GameState.paused :
#		return
##	if inventoryRect.visible :
##		inventoryRect.hide()
##		NodeAccess.__Map().show()
#	else :
	NodeAccess.__Map().hide()
	set_charactersRect_type(1) #loot style !
	
	
	#GameState.set_paused(true)
	treasureControl.display(items, money, experience)
	MusicStreamPlayer.play_music_type("Treasure")
	await treasureControl.done_looting
	MusicStreamPlayer.play_music_map()
	#GameState.set_paused(false)


func show_abilitiesmngt_menu(show_class_abilities : bool, extra_learnable : Array) :
	if selected_character.get("selection_pts")==null :
		var go_on : bool = false
		for pc in GameGlobal.player_characters :
			if selected_character.get("selection_pts")!=null :
				go_on = true
				set_selected_creature(pc)
				break
#		print("go on ? ", go_on)
		if not go_on :
			return
	
	
	#GameState.set_paused(true)
	abilitesmngtMenu.set_displayed_character(selected_character, show_class_abilities, extra_learnable)
	abilitesmngtMenu.show()
	await abilitesmngtMenu.on_closed
	abilitesmngtMenu.hide()
	#GameState.set_paused(false)

func _on_SettingsButton_pressed():
	#if GameState.paused :
	#	return
	#GameState.set_paused(true)
	settingsControl.show()
	MusicStreamPlayer.play_music_type("Create")



func _on_EncounterButton_pressed():
	print("OWHUD _on_EncounterButton_pressed, visible ? "+str(encounterControl.visible))
	if not encounterControl.visible :
		#if not GameState.paused :
			StateMachine.enter_ex_menu_state({"prev_state" : "Exploration", "menu_name" : "SpecEncounter_menu"})
			encounterControl.show()
		#	encounterControl.disablerButton.show()
		#	textRect.disablerButton.show()
			encounterControl.initialize(GameGlobal.currentSpecialEncounterName)
	else :
		if encounterControl.stopButton.visible :
			#encounterControl.close()
			close_special_encounter(true)

func close_special_encounter(go_to_exploration_mode : bool) :
	encounterControl.hide()
	if go_to_exploration_mode :
		StateMachine.transition_to("Exploration")

func _on_CampButton_pressed():
	#if GameState.paused :
	#	return
	GameGlobal.camping = ! GameGlobal.camping
	if GameGlobal.camping :
		MusicStreamPlayer.play_music_type("Camp")
	else :
		MusicStreamPlayer.play_music_map()
	NodeAccess.__Map().set_ow_character_icon(GameGlobal.player_characters[0].icon)



func _on_RestTimer_timeout():
	GameGlobal.rest()
	restTimer.start(timebetweenrests)

func _on_RestButton_button_down():
	#if GameState.paused :
	#	return
	restTimer.set_paused(false)
	restTimer.start(0.00001)

func _on_RestButton_button_up():
	restTimer.set_paused(true)


func _on_MoneyButton_pressed():
	pass # Replace with function body.moneyControl
	if not moneyControl.visible :
		#if (not GameState.paused) or (treasureControl.visible or inventoryRect.visible) :
			#GameState.set_paused(true)
			moneyControl.show()
		#	encounterControl.disablerButton.show()
		#	textRect.disablerButton.show()
			moneyControl.initialize(GameGlobal.player_characters)
	else :
			moneyControl.close()
			

func on_moneyControl_close() :
	if GameGlobal.honest_mode and moneyControl.banking_available :
		_on_q_save_button_pressed()
	#if not (treasureControl.visible or inventoryRect.visible) :
		#GameState.set_paused(false)

func set_money_change_enabled(yes : bool) :
	moneyControl.set_money_change_enabled(yes)

func set_banking_availlable(yes : bool) :
	moneyControl.set_banking_availlable(yes)

func _on_SpellButton_pressed():
	if selected_character == null :
		return
	#GameState.set_paused(true)
	if StateMachine.is_combat_state() :
		print("owhud : am in combat, go to cbmenustate")
		StateMachine.enter_cb_menu_state(({"menu_name" : "SpellsMenu", "selected_character" : selected_character}))
	else :
		StateMachine.enter_ex_menu_state(({"menu_name" : "SpellsMenu", "selected_character" : selected_character}))

#	await spellcastMenu.spell_picked

func _on_spell_picked(character, spell, powerlevel, item : Dictionary) :
	if typeof(spell) == TYPE_STRING :
		print("OW HUD ERROR : spell from spells menu was a STRING not a  gdscript ! "+spell)
		return
	StateMachine.state.on_spell_picked(character, spell, powerlevel, item)
	#GameState.set_paused(false)

func _on_spell_menu_closed() :
	if StateMachine.is_combat_state() :
			creatureRect.show()
			creatureRect.display_crea_info(creatureRect.my_crea_button)
			print("OW_hud hiding txtrect")
			textRect.hide()
	textRect.set_text('', false)
	#GameState.set_paused(false)


func show_spell_effect_on_char_menu(chara, graphic_name : String) :
	var effect_texture_frame : int = SpellAnimation.name_to_frame_dict[graphic_name]*8
	for p in charsVContainer.get_children() :
		if p.character == chara :
			p.show_spell_effect(effect_texture_frame)


func _on_bestiary_button_pressed():
	#if not bestiaryRect.visible:
		#return
	if bestiaryRect.visible :
		bestiaryRect.hide()
		#GameState.set_paused(false)
	else :
		bestiaryRect.show()
		#GameState.set_paused(true)

func enter_battle_mode() :
	textRect.hide()
	botrightpanel.hide()
	creatureRect.show()
	combatBRPanel.show()
	combatBRPanel.set_buttons_enabled(true)
	if creatureRect.turnorderButton.button_pressed :
		turnorderPanel.show()
		turnorderPanel.update_display()
	
	for p in charsVContainer.get_children() : 
		p.set_type(2, false) #type :  0:map 1:loot 2:combat
		p.update_display()
	creatureRect._on_battle_start()

func exit_battle_mode() :
	textRect.show()
	botrightpanel.show()
	creatureRect.hide()
	combatBRPanel.hide()
	turnorderPanel.hide()
	for p in charsVContainer.get_children() : 
		p.set_type(0, false) #type :  0:map 1:loot 2:combat
		p.update_display()
	
	
func set_selected_creature(c : Creature) : # for battle, any creature on field not just pc
	#also check called_on_CharPanel_SelectButton_pressed
	print("OWHUD set_selected_creature "+c.name)
	selected_character = c
	if GameGlobal.player_characters.has(c) or GameGlobal.player_allies.has(c) : #select the right character
		for p in charsVContainer.get_children() :
			if p.character==c :
				p.toggle_SelectButton_Icon(true)
			else :
				p.toggle_SelectButton_Icon(false)
		spellcastButton.disabled = (selected_character.spells.size()==0)
		
	else : 
		print("OWHUD #deselect all characters,  it's a NPC/enemy")
		for p in charsVContainer.get_children() :
			p.toggle_SelectButton_Icon(false)
		spellcastButton.disabled = true

func _on_mouse_enter_combat_crea_button(creabutton : CombatCreaButton) :
	var map = GameGlobal.map
	for cb in map.creatures_node.get_children() :
		cb.bgsprite.visible = cb.creature == selected_character
	creabutton.bgsprite.show()
	creatureRect.display_crea_info(creabutton)

func _on_mouse_exit_combat_crea_button() :
#	print("OWHUD _on_mouse_exit_combat_crea_button selected_character : ",selected_character.name)
	var map = NodeAccess.__Map()
	#var selected_cb = null
	for cb in map.creatures_node.get_children() :
		if cb.creature == selected_character :
			cb.bgsprite.visible = true
			creatureRect.display_crea_info(cb)
		else :
			cb.bgsprite.visible = false

func _on_finish_button_pressed():
	pass
	#GameState.end_active_creature_turn(true)

func _on_delay_button_pressed() :
	pass
	#GameState.delay_active_creature_turn()

func _on_guard_button_pressed() :
	pass
	#GameState.end_active_creature_turn(false)

func _on_parry_button_pressed() :
	pass
	#GameState.end_active_creature_turn(false)


func _on_abi_list_button_pressed():
#	print("OWHUD _on_abi_list_button_pressed : ")
	#if GameState.paused and (not abilitesmngtMenu.visible):
		#return
	if abilitesmngtMenu.visible :
		abilitesmngtMenu.hide()
		#GameState.set_paused(false)
	else :
#		if selected_character.get("selection_pts")!=null :
		show_abilitiesmngt_menu(true, [])
#		else :
#			GameGlobal.play_sfx("target error.wav")
		#GameState.set_paused(true)


func _on_save_button_pressed():
	#if GameState.paused and (not saveloadCtrl.visible):
	#	return
	if saveloadCtrl.visible :
		saveloadCtrl.hide()
		StateMachine.transition_to("Exploration")
		#StateMachine.exit_ex_menu_state()
		#GameState.set_paused(false)
	else :
		if StateMachine.state == StateMachine.ex_menu_state :
			return
		saveloadCtrl.fill(GameGlobal.currentcampaign, true)
		StateMachine.enter_ex_menu_state({"prev_state" : "Exploration", "menu_name" : "SaveLoad_menu"})
		saveloadCtrl.show()
		#GameState.set_paused(true)


func _on_q_save_button_pressed():
	#check if  GameGlobal.cur_save_name is ok and there s a save witth this name
	if GameGlobal.cur_save_name.is_empty() :
#		GameGlobal.play_sfx("target error.wav")
#		return
		GameGlobal.cur_save_name = "QuickSave"
	var save_path : String = Paths.profilesfolderpath + GameGlobal.currentprofile + "/Saves/"+ GameGlobal.currentcampaign + "/"+ GameGlobal.cur_save_name
	if DirAccess.dir_exists_absolute(save_path) :
		saveloadCtrl.save_game(GameGlobal.currentcampaign, GameGlobal.cur_save_name)
	else :
		saveloadCtrl.save_game(GameGlobal.currentcampaign, "QuickSave")


func set_allow_honest_storage(yes : bool) :
	inventoryRect.set_allow_honest_storage(yes)

func open_storage_rect() :
	storage_rect.initialize()
	inventoryRect.hide()
	storage_rect.show()

func close_storage_rect() :
	storage_rect.hide()
	inventoryRect.hide()
	_on_InventoryButton_pressed()
	inventoryRect.show()


func _on_turn_order_button_toggled(toggled_on : bool) :
	turnorderPanel.visible = toggled_on
	if toggled_on : turnorderPanel.update_display()
