extends TextureRect

var hud : OW_HUD
@onready var spellbutton : Button = $SpellButton
@onready var inventorybutton : Button= $InventoryButton

@onready var finishbutton : Button = $FinishButton
@onready var preparebutton : Button = $PrepareButton
@onready var buttons : Array = [spellbutton,inventorybutton,finishbutton]

var escape_allowed : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func prepare_for_creab( creab : CombatCreaButton ) :
	var controllable : bool =  creab.creature.curFaction == 0
	if controllable :
		var already_prepared : bool = false
		for t in creab.creature.traits :
			if t.get("trait_types") :
				if t.trait_types.has("Prep.") :
					if not t.prep_can_use_every_round :
						already_prepared = true
						break
		preparebutton.disabled = already_prepared
	
	for b in buttons :
		b.disabled = not controllable
	spellbutton.disabled = creab.creature.spells.is_empty()
	
func set_buttons_enabled(enabled : bool) -> void :
		for b in get_children() :
			if b.is_class("BaseButton"):
				if b == inventorybutton :
					b.disabled = false
				else :
					b.disabled = not enabled

func enable_all(crea : Creature) :
	for b in get_children() :
		if b.is_class("BaseButton"):
			b.disabled = false
	spellbutton.disabled = (crea.spells.size()==0)

func _on_finish_button_pressed():
	hud.creatureRect._on_mouse_entered()
	if StateMachine._state_name == "CbDecideAction" :
		if StateMachine.state.current_active_creabutton.creature.is_crea_player_controlled() :
			StateMachine.state.end_active_creature_turn(false)

func _on_InventoryButton_pressed():
	hud.creatureRect._on_mouse_entered()
	if StateMachine.cb_decide_state.current_active_creabutton.creature.is_crea_player_controlled() :
		if ["CbDecideAction","CbMenus"].has(StateMachine._state_name) :
			hud._on_InventoryButton_pressed()

func _on_SpellButton_pressed():
	hud.creatureRect._on_mouse_entered()
	if StateMachine._state_name == "CbDecideAction" :
		hud._on_SpellButton_pressed()


func _on_debug_win_pressed():
	for cb in StateMachine.combat_state.all_battle_creatures_btns :
		if cb.creature.curFaction!=0 :
			cb.creature.change_cur_hp(-999999999)
	pass # Replace with function body.


func _on_debug_kill_pressed():
	hud.selected_character.change_cur_hp(-100)
	pass # Replace with function body.


func _on_guard_button_pressed():
	
	hud.creatureRect._on_mouse_entered()
	if StateMachine._state_name == "CbDecideAction" :
		var active_cb : CombatCreaButton = StateMachine.combat_state.get_selected_character_combatbutton()
		if active_cb.creature.get("classgd") : #is a PlayerCharacter
			active_cb.creature.start_guarding()
		else :
			var traitscript = load('res://shared_assets/traits/'+'guarding.gd')
			active_cb.creature.add_trait(traitscript, [active_cb.creature])
		hud._on_guard_button_pressed()
		StateMachine.state.end_active_creature_turn(false)


func _on_parry_button_pressed():
	hud.creatureRect._on_mouse_entered()
	if StateMachine._state_name == "CbDecideAction" :
		var active_cb : CombatCreaButton = StateMachine.combat_state.get_selected_character_combatbutton()
		if active_cb.creature.get("classgd") : #is a PlayerCharacter
			active_cb.creature.start_parrying()
		else :
			var traitscript = load('res://shared_assets/traits/'+'parrying.gd')
			active_cb.creature.add_trait(traitscript, [active_cb.creature])
		hud._on_parry_button_pressed()
		StateMachine.state.end_active_creature_turn(false)


func _on_delay_button_pressed():
	hud.creatureRect._on_mouse_entered()
	if StateMachine._state_name == "CbDecideAction" :
		if StateMachine.state.current_active_creabutton.creature.is_crea_player_controlled() :
			StateMachine.state.delay_active_creature_turn()


func _on_prepare_button_pressed():
	hud.creatureRect._on_mouse_entered()
	if StateMachine._state_name == "CbDecideAction" :
		var active_cb : CombatCreaButton = StateMachine._state.get_selected_character_combatbutton()
		if active_cb.creature.get("classgd") : #is a PlayerCharacter
			active_cb.creature.start_preparing()
		else :
			var traitscript = load('res://shared_assets/traits/'+'preparing.gd')
			active_cb.creature.add_trait(traitscript, [active_cb.creature])
		hud._on_parry_button_pressed()


func _on_escape_button_pressed():
	var sounds_book = NodeAccess.__Resources().get_sounds_book()
	if StateMachine._state_name == "CbDecideAction" :
		var success : bool = true
		var active_cb : CombatCreaButton = StateMachine.combat_state.get_selected_character_combatbutton()
		var crea : Creature = active_cb.creature
		for cb : CombatCreaButton in StateMachine.combat_state.all_battle_creatures_btns :
			if cb.creature.curFaction != 0 and active_cb.creature.position.distance_to(cb.creature.position)<=10:
				success = false
		if success :
			crea.fled_battle = true
			StateMachine.cb_decide_state.end_active_creature_turn(true)
			active_cb.leave_combat()
		else :
			SfxPlayer.stream = sounds_book["target error.wav"]
			SfxPlayer.play()
		#_on_finish_button_pressed()
		#print("CombatBRPanel _on_escape_button_pressed success ? "+str(success))
		

func _on_bandage_button_pressed():
	if not StateMachine._state_name == "CbDecideAction" :
		return
	var picked_characters : Array = await StateMachine.state.request_picked_menu_charas(1, true)

	var sounds_book = GameGlobal.cmp_resources.get_sounds_book()

	if not picked_characters.is_empty() and picked_characters[0].life_status==1 :
		var crea : Creature = picked_characters[0]
		crea.life_status = 2
		crea.change_cur_hp(0)
		SfxPlayer.stream = sounds_book["Target On.wav"]
		UI.ow_hud.updateCharPanelDisplay()
		StateMachine.cb_decide_state.end_active_creature_turn(true)
		UI.ow_hud.creatureRect.logrect.log_bandage(StateMachine.state.current_active_creabutton.creature, crea)
	else :
		SfxPlayer.stream = sounds_book["target error.wav"]
	SfxPlayer.play()
