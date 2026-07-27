extends State
class_name CbDecideState

const ClassicCombatRoutRulesScript = preload(
	"res://scripts/classic_runtime/classic_combat_rout_rules.gd"
)
const PermanentFleeingTraitScript = preload(
	"res://shared_assets/traits/p_classic_fleeing.gd"
)
const ClassicPlayerAutoCombatScript = preload(
	"res://scripts/classic_runtime/classic_player_auto_combat.gd"
)
const CLASSIC_BATTLE_MINIMUM_OFFSET := 5
const CLASSIC_BATTLE_MAXIMUM_LOCAL_COORDINATE := 7

@export var combat_state : CombatState

var is_spell_targeting : bool = false
var is_picking_menu_chara : bool = false
var need_pick_how_many : int = 0
var is_bandaging : bool = false
var picked_charas : Array = []
var pleaseconfirmspell : bool = false
var current_active_creabutton : CombatCreaButton
var pending_classic_terrain_phase_owner: Creature
var classic_combat_macro_flush_active := false
var auto_turn_creature: Creature

signal cbdecide_picked_characters_done
signal cbdecide_charpanel_clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	#GameGlobal is initialized after...?
	#GameGlobal.map.targetingLayer.player_spell_confirmed.connect(_on_player_cb_action_signal_received)
	pass # Replace with function body.


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):



func _state_process(_delta: float) -> void:
	check_camera_movement_command()
	#Set the mouse cursor...
	if is_picking_menu_chara :
		if Input.is_action_just_pressed("escape") :
			emit_signal("cbdecide_charpanel_clicked", null)
		if Input.is_action_just_pressed("ValidateTargeting") :
			emit_signal("cbdecide_charpanel_clicked", Creature.new())
		return
	if is_spell_targeting :
		Input.set_custom_mouse_cursor((UI.cursor_sword))
		GameGlobal.map.targetingLayer.update_targeting()
		return
	var mousepos : Vector2 = UI.ow_hud.get_local_mouse_position()
	var wsize : Vector2 = ScreenUtils.get_logical_window_size(self)
	if mousepos.x+320<wsize.x and mousepos.y+200<wsize.y :
		var targoffset : Vector2 = GameGlobal.map.focuscharacter.get_pixel_position()
		var cursordir = StateMachine.get_dir_input_from_mouse(_delta, targoffset)
		Input.set_custom_mouse_cursor(UI.cursor_map_dict[cursordir])
	else :
		Input.set_custom_mouse_cursor((UI.cursor_sword))

func exit() :
	is_picking_menu_chara = false
	need_pick_how_many = 0
	is_spell_targeting = false

func enter(_msg : Dictionary = {}) -> void:
	print("CbDecideAction State : Enter")
	var resources = GameGlobal.cmp_resources
	var map = GameGlobal.map
	UI.ow_hud.textRect.hide()
	UI.ow_hud.creatureRect.show()
	UI.ow_hud.botrightpanel.hide()
	UI.ow_hud.combatBRPanel.show()



	if _msg.has("battle_start") :
		await initialize_battle(_msg, resources, map)
		#printerr("CBDecideAction combat_state.all_battle_creatures_btns after  init : ", combat_state.all_battle_creatures_btns)
		printerr("CBDecideAction combat_state.battle_creatures_yet_to_act_btns after  init : ", combat_state.battle_creatures_yet_to_act_btns)
	if StateMachine.state != self:
		return
	await _flush_classic_combat_macros()
	if StateMachine.state != self:
		return
	if pending_classic_terrain_phase_owner != null:
		var completed_phase_owner := pending_classic_terrain_phase_owner
		pending_classic_terrain_phase_owner = null
		GameGlobal.map.advance_missing_classic_terrain_phases(
			combat_state.all_battle_creatures_btns
		)
		var phase_owner_is_live := false
		for button: Variant in combat_state.all_battle_creatures_btns:
			if is_instance_valid(button) and button.creature == completed_phase_owner:
				phase_owner_is_live = true
				break
		if phase_owner_is_live:
			GameGlobal.map.advance_classic_terrain_phase(completed_phase_owner)
		if not combat_state.battle_creatures_yet_to_act_btns.has(
			current_active_creabutton
		):
			current_active_creabutton = null
			if not combat_state.battle_creatures_yet_to_act_btns.is_empty():
				current_active_creabutton = \
					combat_state.battle_creatures_yet_to_act_btns[0]
				_select_active_creature(current_active_creabutton)
				GameGlobal.map.advance_classic_terrain_phase(
					current_active_creabutton.creature
				)

	if UI.ow_hud.turnorderPanel.visible :
		UI.ow_hud.turnorderPanel.update_display()


	var battle_end_str : String = combat_state.check_battle_end()  # 0=nope 1=won 2=lost 3=fled
	if not battle_end_str.is_empty() :
		GameGlobal.end_battle(battle_end_str)
		return
	if _msg.has("spell") :
		print("CbDecideAction should now use TargetingLayer !")
		set_spell_targeting_mode(true, _msg)
	else :
		set_spell_targeting_mode(false, {})
	if not is_instance_valid(current_active_creabutton) :
		#current_active_creabutton = combat_state.get_selected_character_combatbutton()
		#UI.ow_hud.set_selected_creature(current_active_creabutton.creature)
		await start_new_round()
		if StateMachine.state != self or not is_instance_valid(current_active_creabutton):
			return
	var cur_act_crea : Creature = current_active_creabutton.creature
	print("    CBDecideAction : cur_act_crea is "+cur_act_crea.name+", out of apr ? ", cur_act_crea.get_apr_left() <= 0)
	while  cur_act_crea.get_apr_left() <= 0 :
		await end_active_creature_turn(true)
		if StateMachine.state != self or not is_instance_valid(current_active_creabutton):
			return
		cur_act_crea = current_active_creabutton.creature

	print("    CBDecideAction : cur_act_crea is "+cur_act_crea.name+", player controlled ? ", cur_act_crea.is_crea_player_controlled())
	if cur_act_crea.get_apr_left() <=0 :
		await end_active_creature_turn(true)
		StateMachine.transition_to("Combat/CbAnimation")
		pass

	UI.ow_hud.xPosLabel.text = str(cur_act_crea.position.x)
	UI.ow_hud.yPosLabel.text = str(cur_act_crea.position.y)



	print("CbDecideActipon "+cur_act_crea.name+" is_crea_player_controlled() ", cur_act_crea.is_crea_player_controlled())
	if cur_act_crea.is_crea_player_controlled() :
		if auto_turn_creature == cur_act_crea:
			do_ai_creature_action(cur_act_crea)
			return
		print("CbDecideActipon "+cur_act_crea.name+" is_crea_player_controlled() true so skipping dcideaction")
		#action_msg = await player_cb_action_msg_signal
		return

	do_ai_creature_action(cur_act_crea)

	#now wait for walk/spell/item_use/

func initialize_battle(_msg :  Dictionary, _resources : CampaignResources, map : Map) :
	combat_state.cur_battle_round = 0
	combat_state.cur_battle_data = _msg
	combat_state.clear_classic_combat_macros()
	classic_combat_macro_flush_active = false
	pending_classic_terrain_phase_owner = null
	auto_turn_creature = null
	is_bandaging = false
	var _battle_pos : Array = [map.focuscharacter.tile_position_x, map.focuscharacter.tile_position_y]
	if _msg.has("Position") :
		_battle_pos = _msg["Position"]
	UI.ow_hud.enter_battle_mode()
	map.owcharacter.hide()
	var ow_character =  map.owcharacter  #SO WE reset map.focuscharacter LATER ???
	GameGlobal.pos_when_battle_started = Vector2(ow_character.tile_position_x,ow_character.tile_position_y)
	print("State CbDecideAction start_battle pos_when_battle_started : ", GameGlobal.pos_when_battle_started)
	GameGlobal.last_exploration_map_name = _msg["end_in_map_name"]
	print("State CbDecideAction start_battle , battlename : ",_msg["battlename"],", battle_data : ",  _msg)
	var map_name : String = _msg["Map"]
	print("CbDecideAction mapname : ,", map_name)
	if map_name.is_empty() :
		map_name = "temporary_zoomed_map"
	print("CbDecideAction mapname : ,", map_name)
	pass

	GameGlobal.change_map(map_name,map.owcharacter.tile_position_x,map.owcharacter.tile_position_y)
	combat_state.all_battle_creatures_btns.clear()
	combat_state.classic_monster_slots_used = 0
	combat_state.classic_fumbled_items.clear()

	var battle_position_offset : Vector2 = Vector2.ZERO
	#var init_pos : Vector2 = Vector2(battle_pos[0],battle_pos[1])
	if  bool(_msg["is_relative_coords"]) :
		var map_focus_char = map.focuscharacter
		
		#init_pos = Vector2.ZERO#(map.owcharacter.tile_position_x,map.owcharacter.tile_position_y)
		if map_name == "temporary_zoomed_map" :
			battle_position_offset = 3*GameGlobal.pos_when_battle_started
			if _msg.has("classicBattleId"):
				battle_position_offset = fit_classic_battle_position_offset(
					battle_position_offset,
					GameGlobal.map.map_size,
				)
		else :
			battle_position_offset = Vector2(map_focus_char.tile_position_x,map_focus_char.tile_position_y)
		print("CbDecidAction init batle battle_position_offset : ", battle_position_offset, " , init pos : ", battle_position_offset )

	for creaArray in _msg["Creatures"] :
		print(" creaArray : ", creaArray)
		var creascript = GameGlobal.combatCreatureGD.new()
		creascript.initialize_from_bestiary_dict(
			creaArray[0],
			GameGlobal.classic_monster_generation_context("battle")
		)
		if creaArray.size() > 2 and creaArray[2] is Dictionary:
			_apply_classic_battle_metadata(creascript, creaArray[2])
		if creascript.get_stat("curHP")<=0 :
			continue
		var posArray : Array = creaArray[1]
		creascript.position = Vector2(posArray[0],posArray[1])+battle_position_offset
		#find_pos_for_crea_on_battlefield(crea : Creature, coords : Vector2, _is_failure_ok : bool, max_move_attempts : int, max_los_attempts : int) ->Vector2 :
		creascript.position = combat_state.find_pos_for_crea_on_battlefield(creascript, creascript.position, true, 15,10)

		var crea_mapb = combat_state.combatcreaturemapobjectTSCN.instantiate()
		# creatures_node charactersnode
		map.creatures_node.add_child(crea_mapb)
		crea_mapb.set_creature_represented(creascript)
		creascript.combat_button = crea_mapb
		crea_mapb.bgsprite.hide()
#		crea_mapb.tile_position_x = creascript.position.x
#		crea_mapb.tile_position_y = creascript.position.y
		combat_state.all_battle_creatures_btns.append(crea_mapb)
		if not creascript.is_player_controlled:
			combat_state.classic_monster_slots_used += 1
		#print("all_battle_creatures_btns size : ", combat_state.all_battle_creatures_btns.size())
		print("Gameglobal start_battle  : added a "+ creaArray[0] +" at ", creascript.position)
	#spawn combatcharacters for the player s party  around battle_pos

	var pc_joining = _msg["pc_participating"]
	if pc_joining.is_empty() :
		pc_joining = GameGlobal.player_characters

	#combat_state.pcs_who_joined_battle = pc_joining

	#combat_state.pcs_in_battle = pc_joining


	for pc in pc_joining :
		pc.has_turned_undead = false
		combat_state.add_pc_or_npc_ally_to_battle_map(pc, battle_position_offset)
	if _msg["npcs_allowed"] and not GameGlobal.classic_allies_suspended():
		for npc in GameGlobal.player_allies :
			npc.has_turned_undead = false
			combat_state.add_pc_or_npc_ally_to_battle_map(npc, battle_position_offset)

	# order Ambush ?
#	print(" all_battle_creatures ",all_battle_creatures,' ',all_battle_creatures[0].name,all_battle_creatures[1].name,all_battle_creatures[2].name,all_battle_creatures[3].name)
	if _msg["is_ambush"] :
		combat_state.all_battle_creatures.sort_custom(func(a, b): return a.cur_faction>b.cur_faction)
	else :
		combat_state.all_battle_creatures_btns.sort_custom(func(a, b): return a.creature.get_stat("Dexterity") > b.creature.get_stat("Dexterity") )
	combat_state.cur_battle_data = _msg
	print("beep")
	print("GameGlobal start_battle cur_battle_data : ", combat_state.cur_battle_data)
	#if combat_state.cur_battle_data["Scripts"].has("Start") :
		#combat_state.cur_battle_data["Scripts"]["start"].start()

	await start_new_round()


static func fit_classic_battle_position_offset(
	offset: Vector2,
	battlefield_size: Vector2,
) -> Vector2:
	# Compiled formations use local coordinates -5 through +7. Shift the
	# complete formation inward at map edges so creature placement never starts
	# outside the temporary battlefield.
	return Vector2(
		clampf(
			offset.x,
			CLASSIC_BATTLE_MINIMUM_OFFSET,
			battlefield_size.x - CLASSIC_BATTLE_MAXIMUM_LOCAL_COORDINATE - 1,
		),
		clampf(
			offset.y,
			CLASSIC_BATTLE_MINIMUM_OFFSET,
			battlefield_size.y - CLASSIC_BATTLE_MAXIMUM_LOCAL_COORDINATE - 1,
		),
	)


static func _apply_classic_battle_metadata(
	creature: Object,
	metadata: Dictionary,
) -> void:
	var generated := creature.has_meta("classic_monster_generation")
	if metadata.has("classicMonsterId"):
		creature.set_meta("classic_monster_id", int(metadata["classicMonsterId"]))
	if metadata.has("classicMonsterNameId"):
		creature.set_meta(
			"classic_monster_name_id",
			int(metadata["classicMonsterNameId"])
		)
	if metadata.has("classicDeathMacro"):
		creature.set_meta("classic_death_macro", int(metadata["classicDeathMacro"]))
	if metadata.has("classicTurnUndeadEligible"):
		creature.set_meta(
			"classic_turn_undead_eligible",
			bool(metadata["classicTurnUndeadEligible"])
		)
	if metadata.has("classicHitDice"):
		creature.set_meta("classic_hit_dice", int(metadata["classicHitDice"]))
	if metadata.has("classicArmor") and not generated:
		creature.set_meta("classic_armor", int(metadata["classicArmor"]))
	if metadata.has("classicMagicResistance") and not generated:
		creature.set_meta(
			"classic_magic_resistance",
			int(metadata["classicMagicResistance"])
		)
	if metadata.has("classicSpellSaves") and not generated:
		creature.set_meta("classic_spell_saves", metadata["classicSpellSaves"].duplicate())
	if metadata.has("classicSpellImmunities") and not generated:
		creature.set_meta(
			"classic_spell_immunities",
			metadata["classicSpellImmunities"].duplicate()
		)
	if metadata.has("classicRegenerationPerRound"):
		creature.set_meta(
			"classic_regeneration_per_round",
			int(metadata["classicRegenerationPerRound"])
		)
	if metadata.has("classicSpellScreenLevel"):
		creature.set_meta(
			"classic_spell_screen_level",
			int(metadata["classicSpellScreenLevel"])
		)
	if metadata.has("classicCanSummon"):
		creature.set_meta("classic_can_summon", int(metadata["classicCanSummon"]))
	if metadata.has("classicRunPercent"):
		creature.set_meta("classic_run_percent", int(metadata["classicRunPercent"]))
	if metadata.has("classicSurrenderPercent"):
		creature.set_meta(
			"classic_surrender_percent",
			int(metadata["classicSurrenderPercent"])
		)
	if bool(metadata.get("classicForceFriend", false)):
		creature.baseFaction = 0
		creature.curFaction = 0

func start_new_round() :
	print("CbDecideAction.start_new_round()")
	combat_state.cur_battle_round += 1
	GameGlobal.reduce_classic_light_condition()
	GameGlobal.reduce_classic_party_conditions()
	UI.ow_hud.creatureRect.logrect.log_new_round(combat_state.cur_battle_round)
	var classic_dispatch: Dictionary = await _dispatch_classic_battle_round(
		combat_state.cur_battle_data,
		combat_state.cur_battle_round,
		_classic_battle_round_context()
	)
	if bool(classic_dispatch.get("handled", false)):
		var classic_result: Variant = classic_dispatch.get("result", {})
		if (
			classic_result is Dictionary
			and str(classic_result.get("status", "")) not in ["completed", ""]
		):
			printerr(
				"Classic battle-round action point stopped: ",
				classic_result.get("message", classic_result)
			)
	if StateMachine.state != self:
		return
	var battle_end_str: String = combat_state.check_battle_end()
	if not battle_end_str.is_empty():
		GameGlobal.end_battle(battle_end_str)
		return
	var terrain_actions: Array = GameGlobal.map._on_new_round(
		combat_state.all_battle_creatures_btns
	)

	for creab in combat_state.all_battle_creatures_btns :
		creab.creature._on_new_round()

	if combat_state.cur_battle_round == 1 :
		if combat_state.cur_battle_data["Scripts"].has("Start") :
			combat_state.cur_battle_data["Scripts"]["start"].start()
	else :
		if combat_state.cur_battle_data["Scripts"].has("turn") :
			combat_state.cur_battle_data["Scripts"]["turn"].turn()
		combat_state.all_battle_creatures_btns.sort_custom(func(a, b): return a.creature.get_stat("Dexterity") > b.creature.get_stat("Dexterity") )


	combat_state.battle_creatures_yet_to_act_btns = combat_state.all_battle_creatures_btns.duplicate(false)
	printerr("CBDecideAction combat_state.battle_creatures_yet_to_act_btns on new turn : ", combat_state.battle_creatures_yet_to_act_btns)

	UI.ow_hud.set_selected_creature(combat_state.battle_creatures_yet_to_act_btns[0].creature)
	UI.ow_hud._on_mouse_exit_combat_crea_button()
	current_active_creabutton = combat_state.battle_creatures_yet_to_act_btns[0]
	UI.ow_hud.creatureRect.charbutton_this_turn = current_active_creabutton
	UI.ow_hud.creatureRect.display_crea_info( current_active_creabutton )
	UI.ow_hud.combatBRPanel.prepare_for_creab(current_active_creabutton)
	GameGlobal.map.focuscharacter.set_tile_position( current_active_creabutton.creature.position )
	var all_creatures : Array = []
	for cb : CombatCreaButton in combat_state.battle_creatures_yet_to_act_btns :
		all_creatures.append(cb.creature)

	#combat_state.all_battle_creatures_btns.clear()
	#combat_state.battle_dead_enemies.clear()
	#combat_state.battle_dead_party_members.clear()

	get_parent().all_battle_creatures_btns.sort_custom(func(a, b): return a.creature.get_stat("Dexterity") > b.creature.get_stat("Dexterity") )
	GameGlobal.map.pathfinder_update_characters(all_creatures,current_active_creabutton.creature)
	GameGlobal.map.pathfinder_clear_pos(Vector2i(current_active_creabutton.creature.position))
	if not terrain_actions.is_empty():
		pending_classic_terrain_phase_owner = current_active_creabutton.creature
		combat_state.add_to_action_queue(terrain_actions)
		StateMachine.transition_to("Combat/CbAnimation")
		return
	GameGlobal.map.advance_missing_classic_terrain_phases(
		combat_state.all_battle_creatures_btns
	)
	GameGlobal.map.advance_classic_terrain_phase(current_active_creabutton.creature)
	#enter()
	if not current_active_creabutton.creature.is_player_controlled :
		do_ai_creature_action(current_active_creabutton.creature)


func _apply_classic_opening_morale(creature: Creature) -> bool:
	if not creature.is_classic_monster_record():
		return false
	var outcome := ClassicCombatRoutRulesScript.apply_opening_morale(
		creature,
		PermanentFleeingTraitScript
	)
	if outcome == ClassicCombatRoutRulesScript.OUTCOME_NONE:
		return false
	var message := " is running away!"
	if outcome == ClassicCombatRoutRulesScript.OUTCOME_SURRENDER:
		message = " surrenders."
	elif outcome == ClassicCombatRoutRulesScript.OUTCOME_PANIC:
		message = " flees from battle!"
	UI.ow_hud.creatureRect.logrect.log_other_text(creature, message, null, "")
	if outcome == ClassicCombatRoutRulesScript.OUTCOME_RUN:
		return false

	var surrendering_button := current_active_creabutton
	combat_state.battle_creatures_yet_to_act_btns.erase(surrendering_button)
	if combat_state.battle_creatures_yet_to_act_btns.is_empty():
		current_active_creabutton = null
	else:
		current_active_creabutton = combat_state.battle_creatures_yet_to_act_btns[0]
		_select_active_creature(current_active_creabutton)
		GameGlobal.map.advance_classic_terrain_phase(
			current_active_creabutton.creature
		)
		GameGlobal.refresh_OW_HUD()
	combat_state.action_queue.clear()
	StateMachine.transition_to("Combat/CbAnimation")
	return true


func _select_active_creature(button: CombatCreaButton) -> void:
	UI.ow_hud.set_selected_creature(button.creature)
	UI.ow_hud._on_mouse_exit_combat_crea_button()
	UI.ow_hud.creatureRect.charbutton_this_turn = button
	UI.ow_hud.creatureRect.display_crea_info(button)
	UI.ow_hud.combatBRPanel.prepare_for_creab(button)
	GameGlobal.map.focuscharacter.set_tile_position(button.creature.position)
	var creatures: Array = []
	for combat_button: Variant in combat_state.all_battle_creatures_btns:
		if is_instance_valid(combat_button):
			creatures.append(combat_button.creature)
	GameGlobal.map.pathfinder_update_characters(creatures, button.creature)
	GameGlobal.map.pathfinder_clear_pos(Vector2i(button.creature.position))


func _dispatch_classic_battle_round(
	battle_data: Dictionary,
	combat_round: int,
	context: Dictionary
) -> Dictionary:
	var host: Variant = GameGlobal.classic_runtime_host
	if not is_instance_valid(host) or not host.has_method("run_battle_round_macro"):
		return {"handled": false}
	var dispatch: Variant = await host.call(
		"run_battle_round_macro",
		battle_data,
		combat_round,
		context
	)
	return dispatch if dispatch is Dictionary else {
		"handled": true,
		"result": {
			"status": "error",
			"message": "Classic battle-round dispatcher returned an invalid result",
		},
	}


func _flush_classic_combat_macros() -> void:
	# Several combat callbacks can re-enter this state while a macro awaits UI.
	# Let the first caller finish the queue instead of starting a second runtime.
	while classic_combat_macro_flush_active:
		await get_tree().process_frame
		if StateMachine.state != self:
			return
	if not combat_state.has_classic_combat_macros():
		return
	classic_combat_macro_flush_active = true
	var host: Variant = GameGlobal.classic_runtime_host
	if not is_instance_valid(host) or not host.has_method("run_queued_combat_macro"):
		printerr("Classic combat macro queue has no registered runtime host")
		combat_state.clear_classic_combat_macros()
		classic_combat_macro_flush_active = false
		return
	while combat_state.has_classic_combat_macros():
		var entry: Dictionary = combat_state.pop_classic_combat_macro()
		var dispatch: Variant = await host.call(
			"run_queued_combat_macro",
			entry,
			{
				"combatRound": combat_state.cur_battle_round,
				"battleMacro": int(combat_state.cur_battle_data.get("battleMacro", 0)),
			}
		)
		if not (dispatch is Dictionary):
			printerr("Classic queued combat macro returned an invalid result")
			continue
		var result: Variant = dispatch.get("result", {})
		if result is Dictionary and str(result.get("status", "")) not in ["completed", ""]:
			printerr(
				"Classic queued combat action point stopped: ",
				result.get("message", result)
			)
		if StateMachine.state != self:
			classic_combat_macro_flush_active = false
			return
	classic_combat_macro_flush_active = false


func _classic_battle_round_context() -> Dictionary:
	var actor_button: Variant = current_active_creabutton
	if (
		not is_instance_valid(actor_button)
		and not combat_state.all_battle_creatures_btns.is_empty()
	):
		actor_button = combat_state.all_battle_creatures_btns[0]
	if not is_instance_valid(actor_button):
		return {}
	var actor: Variant = actor_button.creature
	if not is_instance_valid(actor):
		return {}
	return {
		"actorPosition": actor.position,
		"actorFaction": int(actor.curFaction),
	}

func check_camera_movement_command()->void :
	if Input.is_action_just_pressed("MoveCamera") :
			print('CBDecideAction "MoveCamera"')
			GameGlobal.map.focuscharacter.set_tile_position( GameGlobal.map.targetingLayer.get_world_mousepos() )

func _on_dir_input_received(input : Vector2i, is_keyboard : bool) -> void :
	print("CbDecideAction _on_dir_input_received "+str(input))
	if is_spell_targeting or is_picking_menu_chara :
		if is_keyboard :
			var camfocus = GameGlobal.map.focuscharacter
			var focuspos = Vector2(camfocus.tile_position_x,camfocus.tile_position_y)
			camfocus.set_tile_position(focuspos+3*Vector2(input))
		return
	if input!=Vector2i.ZERO :

		var cur_act_crea : Creature = current_active_creabutton.creature
		var _inputv2 : Vector2 = Vector2(input)
		var attemptedpos = cur_act_crea.position + Vector2(input)
		#var tilestack : Array = GameGlobal.map.mapdata[cur_act_crea.position.x+inputv2.x][cur_act_crea.position.y+inputv2.y]
		#var canmoveandtime : Array = StateMachine.on_trying_to_move_to_tile_stack(current_active_creabutton.creature, tilestack, attemptedpos )
		var canmoveandtime = combat_state.on_trying_to_move_to_position(cur_act_crea, attemptedpos)
		var action_msg : Dictionary= {"type" : "Move", "mover" : current_active_creabutton, "Direction" : input , "canmoveandtime" : canmoveandtime, "check_before_scripts" : true}

		var whothere = null

		for x : int in range(current_active_creabutton.creature.size.x) :
			for y : int in range(current_active_creabutton.creature.size.y) :
				print("cbdecide checked : ", attemptedpos+Vector2(x,y), "all_battle_creatures_btns size ?"+str(combat_state.all_battle_creatures_btns.size()))
				var whotherexy = GameGlobal.who_is_at_tile(attemptedpos+Vector2(x,y)) #combatbutton
				if whotherexy != null and whotherexy != current_active_creabutton :
					whothere = whotherexy
		print(whothere)
		if is_instance_valid(whothere) :
			print("CbDecideState is_instance_valid(whothere)")
			var sameside : bool = whothere.creature.curFaction == current_active_creabutton.creature.curFaction
			if sameside :
				var bothsmall : bool = whothere.creature.size == Vector2.ONE and current_active_creabutton.creature.size == Vector2.ONE
				if bothsmall :
					#SWAP ?
					var textRect = UI.ow_hud.textRect
					#textRect.set_text("MULTIPLE CHOICE !", false)
					var askswaptext : String = "Swap posiition with "+whothere.creature.name+' ? \nThis costs 5 Movement Points.'
					var hasmvmnt : bool = current_active_creabutton.creature.get_stat("MaxMovement") - current_active_creabutton.creature.used_movepoints >= 5
					var hasapr : bool = current_active_creabutton.creature.get_stat("MaxActions") - current_active_creabutton.creature.used_apr >= 5
					var answer : String = "NO"# if (hasmvmnt and canmoveandtime[0]) else "NO"

					if hasmvmnt and canmoveandtime[0]:
						if hasapr :
							textRect.display_multiple_choices([askswaptext, "YESNO", "Attack ally !"],["TEXT", "YESNO", "ATTACK"])
						else :
							textRect.display_multiple_choices([askswaptext, "YESNO"],["TEXT", "YESNO"])
					else :
						if hasapr :
							textRect.display_multiple_choices(["Attack ally ?", "Attack !","NO"],["TEXT", "ATTACK", "NO"])
						else :
							print("GameState manage_map_inputs : Swap : This turn should already be over...")
							return
					answer = await textRect.choice_pressed

					if answer == "YES" :
						action_msg = {"type" : "Swap", "mover" : current_active_creabutton, "moved" : whothere }
						combat_state.add_to_action_queue([action_msg])
						StateMachine.transition_to("Combat/CbAnimation")
						return
					if answer == "NO" :
						UI.ow_hud.updateCharPanelDisplay()
						return
					if answer == "ATTACK" :
						var used_weapon: Variant = current_active_creabutton.creature.get_melee_weapon_for_next_attack()
						action_msg = {"type" : "MeleeAttack", "attacker" : current_active_creabutton, "defender" : whothere, "weapon": used_weapon }
					combat_state.add_to_action_queue([action_msg])
					StateMachine.transition_to("Combat/CbAnimation")
					return

			else :
				if current_active_creabutton.creature.get_apr_left()>0 :
					var used_weapon: Variant = current_active_creabutton.creature.get_melee_weapon_for_next_attack()
					action_msg = {"type" : "MeleeAttack", "attacker" : current_active_creabutton, "defender" : whothere, "weapon": used_weapon }
					combat_state.add_to_action_queue([action_msg])
					StateMachine.transition_to("Combat/CbAnimation")
					return

				else :
					# end its turn ?  CBDecideAction should take care of that
					return

		if GameGlobal.is_map_tile_walkable_by_char(current_active_creabutton.creature, attemptedpos) :
			combat_state.add_to_action_queue([action_msg])
			StateMachine.transition_to("Combat/CbAnimation")

func _on_player_cb_action_signal_received(msg : Dictionary) :
	print("CbDecideAction _on_player_cb_action : ", msg)
	pass




func do_ai_creature_action(cur_act_crea : Creature) :

		#await get_tree().create_timer(1.0*GameGlobal.gamespeed).timeout

	if _apply_classic_opening_morale(cur_act_crea):
		return
	print("CbDecideAction : "+ cur_act_crea.name+" is going to take a decision")
	var decision_array: Array
	if auto_turn_creature == cur_act_crea \
			and GameGlobal.is_classic_campaign(GameGlobal.currentcampaign):
		decision_array = ClassicPlayerAutoCombatScript.decide_action(cur_act_crea)
	else:
		decision_array = cur_act_crea.get_creature_script().decide_action(
			current_active_creabutton.creature
		)
	print("CbDecideAction : "+ cur_act_crea.name+"'s decision taken !", decision_array)
	var action_msg : Dictionary = {}
	if decision_array[0] == 0 :  #MOVE  (or finish ?)


		var attemptedpos = Vector2(cur_act_crea.position + Vector2(decision_array[1]))
		#var tilestack : Array = GameGlobal.map.mapdata[cur_act_crea.position.x+decision_array[1].x][cur_act_crea.position.y+decision_array[1].y]
		#var canmoveandtime : Array = StateMachine.on_trying_to_move_to_tile_stack(cur_act_crea, tilestack, attemptedpos )
		var canmoveandtime : Array = combat_state.on_trying_to_move_to_position(cur_act_crea, attemptedpos)


		action_msg = {"type" : "Move", "mover" : current_active_creabutton, "Direction" : decision_array[1], "canmoveandtime" : canmoveandtime , "check_before_scripts" : true}
		if decision_array[1]==Vector2i.ZERO :
			end_active_creature_turn(true)
			return
		var whothere = null

		for x : int in range(cur_act_crea.size.x) :
			for y : int in range(cur_act_crea.size.y) :
				var whotherexy = GameGlobal.who_is_at_tile(attemptedpos+Vector2(x,y)) #combatbutton
				if whotherexy != null and whotherexy != current_active_creabutton :
					whothere = whotherexy
		if is_instance_valid(whothere) :
			var sameside : bool = whothere.creature.curFaction == cur_act_crea.curFaction
			if sameside :
				end_active_creature_turn(true)
				return
			else :
				var used_weapon: Variant = cur_act_crea.get_melee_weapon_for_next_attack()
				action_msg = {"type" : "MeleeAttack", "attacker" : current_active_creabutton, "defender" : whothere, "weapon": used_weapon }
	if decision_array[0] == 1 : #cast spell
		#return [1, selectedSpell, selectedplvl, spell_target_pos, aoe_shape, {},[Vector2i(spell_target_pos)] , true, true]
		var spell = decision_array[1]
		var power : int = decision_array[2]
		var _target_pos : Vector2i = decision_array[3]
		var _aoe_shape : Array = decision_array[4]
		var item: Variant = decision_array[5]
		var _main_tpos : Vector2i = decision_array[6]
		var tg_tiles : Array = decision_array[7]
		var _tg_creas : Array = decision_array[8]
		if (
			decision_array.size() > 9
			and decision_array[9] is Dictionary
			and bool(decision_array[9].get("classicConsumesTurn", false))
		):
			cur_act_crea.used_apr = ceili(cur_act_crea.get_stat("MaxActions"))

		action_msg = {"type" : "Spell", "spell" : spell, "s_plvl" : power, "targeted_tiles" : tg_tiles, "used_item" : item , "must_add_terrain" : true, "override_aoe" : [] }
		on_spellcast_confirmed(action_msg)
		return

	combat_state.add_to_action_queue([action_msg])
	await get_tree().create_timer(GameGlobal.gamespeed).timeout
	StateMachine.transition_to("Combat/CbAnimation")




func end_active_creature_turn(set_apr_zero : bool)->void :

	if is_instance_valid(current_active_creabutton):
		if auto_turn_creature == current_active_creabutton.creature:
			auto_turn_creature = null
		await current_active_creabutton.creature.on_turn_end()
	if set_apr_zero :
		current_active_creabutton.creature.used_movepoints = current_active_creabutton.creature.get_stat("MaxMovement")
		current_active_creabutton.creature.used_apr = current_active_creabutton.creature.get_stat("MaxActions")

	combat_state.battle_creatures_yet_to_act_btns.erase(current_active_creabutton)

	if combat_state.battle_creatures_yet_to_act_btns.is_empty() :
		await start_new_round()
		return
	UI.ow_hud.set_selected_creature(combat_state.battle_creatures_yet_to_act_btns[0].creature)

	UI.ow_hud._on_mouse_exit_combat_crea_button()
	current_active_creabutton = combat_state.battle_creatures_yet_to_act_btns[0]
	GameGlobal.map.advance_classic_terrain_phase(current_active_creabutton.creature)
	UI.ow_hud.creatureRect.charbutton_this_turn = current_active_creabutton
	UI.ow_hud.creatureRect.display_crea_info( current_active_creabutton )
	UI.ow_hud.combatBRPanel.prepare_for_creab(current_active_creabutton)
	GameGlobal.map.focuscharacter.set_tile_position(current_active_creabutton.creature.position)

	var crealist : Array = []
	for cb in combat_state.all_battle_creatures_btns :
		crealist.append(cb.creature)
	GameGlobal.map.pathfinder_update_characters(crealist, current_active_creabutton.creature)

	GameGlobal.refresh_OW_HUD()

	combat_state.action_queue.clear()
	StateMachine.transition_to("Combat/CbAnimation")


func begin_player_auto_turn(creature: Creature) -> void:
	if not is_instance_valid(current_active_creabutton) \
			or current_active_creabutton.creature != creature \
			or not creature.is_crea_player_controlled():
		return
	auto_turn_creature = creature
	do_ai_creature_action(creature)


func delay_active_creature_turn() :
	combat_state.battle_creatures_yet_to_act_btns.erase(current_active_creabutton)
	combat_state.battle_creatures_yet_to_act_btns.append(current_active_creabutton)
	UI.ow_hud.set_selected_creature(combat_state.battle_creatures_yet_to_act_btns[0].creature)
	current_active_creabutton = combat_state.battle_creatures_yet_to_act_btns[0]
	GameGlobal.map.advance_classic_terrain_phase(current_active_creabutton.creature)

	UI.ow_hud._on_mouse_exit_combat_crea_button()
	UI.ow_hud.creatureRect.charbutton_this_turn = current_active_creabutton
	UI.ow_hud.creatureRect.display_crea_info( current_active_creabutton )
	UI.ow_hud.combatBRPanel.prepare_for_creab(current_active_creabutton)
	GameGlobal.map.focuscharacter.set_tile_position(current_active_creabutton.creature.position)
	var crealist : Array = []
	for cb in combat_state.all_battle_creatures_btns :
		crealist.append(cb.creature)
	GameGlobal.map.pathfinder_update_characters(crealist, current_active_creabutton.creature)
	StateMachine.transition_to("Combat/CbAnimation")


func _on_selected_charpanel(c : Creature) : #selected from the menu on the right.
	#Used for targeting dead characters or if range is enough.
	print("CbDecideActionSTate _on_selected_charpanel TBI !!!!!!!!!!!!!!!!")
	var targlayer : TargetingLayer = GameGlobal.map.targetingLayer
	if is_spell_targeting and (not is_instance_valid(c.combat_button)):
		if picked_charas.has(c):
			picked_charas.erase(c)
		else :
			picked_charas.append(c)
		print("CBDecideAction picked_charas : ", picked_charas)
		if targlayer.picked_targets.keys().size()+targlayer.picked_tiles.keys().size()+ picked_charas.size() >= targlayer.max_targets :
			print("CbDecideAction pleaseconfirmspell, picked charas : ", picked_charas)
			pleaseconfirmspell = true
		return
	if is_picking_menu_chara :
		emit_signal("cbdecide_charpanel_clicked", c)

func request_picked_menu_charas(howmany : int, bandaging : bool) :
	is_picking_menu_chara = true
	need_pick_how_many = howmany
	if bandaging :
		Input.set_custom_mouse_cursor((UI.cursor_bandaid))
	var canceled : bool = false
	while picked_charas.size() < need_pick_how_many :
		var clickedcrea : Creature = await cbdecide_charpanel_clicked
		if not is_instance_valid(clickedcrea) :
			canceled = true
			break
		if clickedcrea.name=='Base Creature' :
			break
		if picked_charas.has(clickedcrea) :
			picked_charas.erase(clickedcrea)
		else :
			picked_charas.append(clickedcrea)
		if not bandaging :
			var cursorid : int = min(8,need_pick_how_many - picked_charas.size())
			Input.set_custom_mouse_cursor(UI.cursor_numbers[cursorid])
	is_picking_menu_chara = false
	need_pick_how_many = 0
	if canceled :
		return []
	else :
		return picked_charas
		#else :
			#Input.set_custom_mouse_cursor((UI.cursor_sword))


func set_spell_targeting_mode(onoff : bool, msg : Dictionary) :
	#targetinglayer.func start_targ(tspell, tspellpower : int, tcaster : CombatCreaButton) :
	#msg is {"item" : item, "caster" : user, "spell" : spell, "power" : spellpower}   user is creature
	var  targlayer : TargetingLayer = GameGlobal.map.targetingLayer

	if onoff == false :
		is_spell_targeting = false
		is_picking_menu_chara = false
		emit_signal("cbdecide_picked_characters_done", [])
		targlayer.spell = null
		targlayer.hide()
		return
	else :
		picked_charas.clear()
	is_spell_targeting = true
	targlayer.start_targ(msg["spell"], msg["power"], msg["caster"].combat_button, msg["used_item"])

func on_spellcast_confirmed(msg : Dictionary) :
	#var msg : Dictionary = {"type" : "Spell", "spell" : spell, "s_plvl" : power, "targeted_tiles" : trgt_tiles, "used_item" : used_item , "add_terrain" : must_add_terrain }
	#action_msg = {"type" : "Spell", "caster" : current_active_creabutton, "Effected Tiles" : [], "effected creas" : [], "targeted_tiles" : [], "spell":0, "s_plvl" : 0, "used_item" : null , "add_terrain" : true}
	pleaseconfirmspell = false
	print("CbDecidAction on_spellcast_confirmed, pciked charas : ", picked_charas)
	var targ_creas : Array = picked_charas.duplicate()
	picked_charas.clear()
	var spell = msg["spell"]
	#print("CbDecideState on_spellcast_confirmed, spell is ", spell.name)
	var power : int = msg["s_plvl"]
	var used_item: Variant = msg["used_item"]
	var no_used_item: bool = used_item == null \
		or (used_item is Dictionary and used_item.is_empty())
	if no_used_item \
			and not spell.get("is_not_spell") \
			and not current_active_creabutton.creature.can_cast_spells():
		set_spell_targeting_mode(false, {})
		if not current_active_creabutton.creature.is_crea_player_controlled():
			end_active_creature_turn(true)
		return

	var chain : Array =[]
	if spell.has_method("get_chain") :
		chain = spell.get_chain()
		var spells_book : Dictionary = GameGlobal.cmp_resources.spells_book
		for c in chain :
			var s_name : String = c[0]
			c[0] = spells_book[s_name]
	else :
		chain = [ [ spell, power ] ]
	# chains are [  [spell1, power1] , [spell2, power2] , ... ]
	var must_add_terrain : bool = msg["must_add_terrain"]
	var targeted_tiles : Array = msg["targeted_tiles"]
	var targetinglayer : TargetingLayer = GameGlobal.map.targetingLayer
	var override_aoe : Array = msg["override_aoe"]
	var actions_array = []
	#print("CBdecidestat chain ? ",chain)
	for c in chain :
		#print("CBDecideAction print c l 396 : ", c[0].name)
		#print(" DecideAction  on_spellcast_confirmed current_active_creabutton : ", current_active_creabutton , )
		var c_act_msg = {"type" : "Spell", "caster" : current_active_creabutton, "spell" : c[0], "s_plvl" : c[1], "used_item" : used_item , "add_terrain" : must_add_terrain, "override_aoe" : override_aoe, "from_terrain" : false , "oob_creas" : targ_creas}
		#print("398 c_act_msg s", c_act_msg["spell"].name)
		#action_msg = {"Effected Tiles" : [], "effected creas" : [], "targeted_tiles" : [] }
		#get_affected_tiles(s_spell, s_power : int, s_caster : CombatCreaButton, s_targeted_pos : Vector2, s_aoe_override = []) :
		#print("CbDecideAction spell_confirmed : chain[0] has targetedtiles : ", targeted_tiles)
		for tpos in targeted_tiles :
			var effected_tiles = targetinglayer.get_affected_tiles(c[0], c[1], current_active_creabutton, tpos, [])
			var effected_creas = targetinglayer.get_cbs_touching_tiles(effected_tiles)
			var c_tg_act_msg : Dictionary = c_act_msg.duplicate(true)  #true for the chain [0] [1]
			#print("406 c_tg_act_msg ", c_tg_act_msg["spell"].name)
			c_tg_act_msg["Effected Tiles"] = effected_tiles
			c_tg_act_msg["Effected Creas"] = effected_creas
			c_tg_act_msg["Targeted Tiles"] = targeted_tiles
			c_tg_act_msg["Main Targeted Tile"] = tpos
			actions_array.append(c_tg_act_msg)
		if targeted_tiles.is_empty() :
			var c_tg_act_msg : Dictionary = c_act_msg.duplicate(true)  #true for the chain [0] [1]
			#print("406 c_tg_act_msg ", c_tg_act_msg["spell"].name)
			c_tg_act_msg["Effected Tiles"] = []
			c_tg_act_msg["Effected Creas"] = []
			c_tg_act_msg["Targeted Tiles"] = []
			c_tg_act_msg["Main Targeted Tile"] = Vector2.LEFT #current_active_creabutton.creature.position
			actions_array.append(c_tg_act_msg)
		#var c_act_msg : Dictionary = {"type" : "Spell", "caster" : current_active_creabutton, fuck}
	print("CbDecideAction spell_confirmed queue length : "+str(actions_array.size())+", chain length : "+str(chain.size()))
	combat_state.add_to_action_queue(actions_array)
	picked_charas.clear()
	current_active_creabutton.creature.used_spr +=1
	StateMachine.transition_to("Combat/CbAnimation")



func use_inventory_item(item: ItemInstance, user: Creature) -> void:
	var resources = NodeAccess.__Resources()
	var definition := resources.get_item_definition(item)
	if definition == null:
		return
	print("CbDecideState use_inventory_item " + definition.display_name_for(item))
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
		print("CbDecideState ITEM CLICKED HAS A _on_combat_use_spell")
		var spellname : String = spell_use[0]
		var spellpower : int = spell_use[1]
		var spell = GameGlobal.cmp_resources.spells_book[spellname]["script"]
		var msg: Dictionary = {
			"used_item": item,
			"caster": user,
			"spell": spell,
			"power": spellpower,
		}
		StateMachine.transition_to("Combat/CbDecideAction", msg)
