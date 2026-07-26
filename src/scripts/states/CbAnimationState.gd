extends State
class_name CbAnimationState


@onready var combat_state : CombatState = get_parent()

#@export var timer : Timer

const SPELL_ANIMATION_TSCN : PackedScene = preload("res://scenes/Map/SpellAnimation/SpellAnimation.tscn")
const CLASSIC_MAGIC_RESISTANCE_SCRIPT = preload(
	"res://scripts/classic_runtime/classic_magic_resistance.gd"
)
const CLASSIC_SPELL_SAVES_SCRIPT = preload(
	"res://scripts/classic_runtime/classic_spell_saves.gd"
)
const CLASSIC_SPELL_REFLECTION_SCRIPT = preload(
	"res://scripts/classic_runtime/classic_spell_reflection.gd"
)
const CLASSIC_MONSTER_SPECIAL_ATTACK_SCRIPT = preload(
	"res://scripts/classic_runtime/classic_monster_special_attack.gd"
)
const CLASSIC_MONSTER_DECISION_SCRIPT = preload(
	"res://scripts/classic_runtime/classic_monster_decision.gd"
)
const CLASSIC_MONSTER_GENERATION_SCRIPT = preload(
	"res://scripts/classic_runtime/classic_monster_generation.gd"
)
const CLASSIC_HELPLESS_SCRIPT = preload(
	"res://scripts/classic_runtime/classic_helpless.gd"
)

var cur_action : Dictionary

var timer : float = -1000000
# Invalidates animation coroutines that resume after this state has been exited.
var entry_serial := 0

#to handle spell castingduring combat  and chains
#var spell_chain : Array = [] #the list of spells to cast in  this execution phase
#var spell_chain_index : int = 0
#var spellcasterbutton : CombatCreaButton  # a creature
#var spellpower : int = 0
#var spell = null # a  script from Resources Spellbook
#var spell_affected_crea : Array = [] #array of creacombatbuttons affected by the spells that's bveing animated/executed
#var spell_affected_tiles: Array = [] #array of vector2 showing tiles in AoE with no creature inside
#var spell_anim_is_proj : bool = false
#var item_used_to_cast : Dictionary = {}

var spell_clicked_tile : Vector2i = Vector2i.ZERO
var spell_aoe_array : Array = []
var spell_picked_targets : Dictionary = {}
var spell_picked_tiles : Dictionary = {}
signal timer_over

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _state_process(delta : float) -> void :
	#print(timer)
	timer -= delta * (1.0/GameGlobal.gamespeed)
	if timer <=0 and timer >-999999:
		timer = -1000000
		_on_timer_over()
		

func exit() -> void:
	entry_serial += 1


func enter(_msg : Dictionary = {}) -> void:
	entry_serial += 1
	var current_entry := entry_serial
	#print("CbAnimationState enter _msg : ", _msg)
	print("CbANimState anim queue size : "+str(combat_state.action_queue.size()) )#,  combat_state.action_queue)
	Input.set_custom_mouse_cursor(UI.cursor_sword)
	while not combat_state.action_queue.is_empty() :
		cur_action = combat_state.action_queue.pop_front()
		print("CBAnimState : cur action : "+str(cur_action)+" , left : "+str(combat_state.action_queue.size()))
		pass
		match cur_action["type"] :
			"TurnUndead" :
				await perform_turn_undead(cur_action)
				if current_entry != entry_serial:
					return
			"Move" :
				if not is_instance_valid( cur_action["mover"]):
					print("CBAnimationState : Move : MoverCb invalid. skipped.")
					continue
				var movercb : CombatCreaButton = cur_action["mover"]

				var dir  : Vector2 = Vector2(cur_action["Direction"])
				if dir == Vector2.ZERO and (not movercb.creature.is_crea_player_controlled()) :
					movercb.creature.used_apr+=999999
					print("CBAnimationState : Move :"+movercb.creature.name+"'s action does NOTHING , so its APR left is  set negative")
					continue
				var canmoveandtime : Array = cur_action["canmoveandtime"]
				if canmoveandtime[0] :
					var destination := movercb.creature.position + dir
					if not combat_state.creature_footprint_is_open(
						movercb.creature,
						destination,
						movercb
					):
						printerr(
							"CBAnimationState: Move destination became occupied for "
							+ movercb.creature.name
						)
						movercb.creature.used_apr += 999999
						continue
					printerr("CBAnimationState : Move :"+movercb.creature.name+"tries to move. MP"+str(movercb.creature.get_movement_left())+", MP needed"+str(canmoveandtime[1]) )
					if  movercb.creature.get_movement_left() >=canmoveandtime[1] :
						if cur_action.has("check_before_scripts") :
							if cur_action["check_before_scripts"] :
								var extra_act_before_move : Array = movercb.creature._on_before_move(dir)
								if not extra_act_before_move.is_empty() :
									cur_action["check_before_scripts"] = false
									var added_acts = extra_act_before_move + [cur_action]
									combat_state.add_to_action_queue(added_acts)
									continue

						if cur_action.get("check_guarding", true) :
							var guarding_actions : Array = []
							for creabtn : CombatCreaButton in combat_state.all_battle_creatures_btns :
								for t in creabtn.creature.traits :
									if t.has_method("_on_other_creature_walked") :
										guarding_actions += t._on_other_creature_walked(movercb)
							if not guarding_actions.is_empty() :
								cur_action["check_guarding"] = false
								combat_state.add_to_action_queue(guarding_actions + [cur_action])
								continue

						var extra_actions : Array = movercb.creature.move(dir)
						print("CbAnim onmove extra_actions : ", extra_actions)
						var routed_off_battlefield := combat_state.mark_classic_rout_exit_if_at_edge(
							movercb.creature,
							_battlefield_size()
						)
						if routed_off_battlefield:
							UI.ow_hud.creatureRect.logrect.log_other_text(
								movercb.creature,
								" flees from battle.",
								null,
								""
							)
						else:
							var xdiff : float = abs(GameGlobal.map.focuscharacter.tile_position_x-movercb.creature.position.x)
							var ydiff : float = abs(GameGlobal.map.focuscharacter.tile_position_y-movercb.creature.position.y)
							if combat_state.is_cam_too_far(int(xdiff), int(ydiff)) :
								GameGlobal.map.focuscharacter.set_tile_position(movercb.creature.position)
							UI.ow_hud.updateCharPanelDisplay()
							UI.ow_hud.creatureRect.display_crea_info(movercb)

						if not extra_actions.is_empty() :
							#for ea in extra_actions :
								#print("    "+ea["type"])
							combat_state.add_to_action_queue(extra_actions)
					else :
						print("CBAnimationState : Move :"+movercb.creature.name+"'s didnt have enough movement left, so its APR left is  set negative")
						movercb.creature.used_apr+=999999
				else :
					print("CBAnimationState : Move :"+movercb.creature.name+"'s cant walk to this tile, so its APR left is  set negative")
					movercb.creature.used_apr+=999999
				timer = 0.2
				await timer_over
				if current_entry != entry_serial:
					return
			"Swap" :
				perform_swap(cur_action)
				timer = 0.2
				await timer_over
				if current_entry != entry_serial:
					return
			"MeleeAttack" :
				if not (is_instance_valid(cur_action["attacker"]) and is_instance_valid(cur_action["defender"])) :
					continue
				var _attackercb : CombatCreaButton = cur_action["attacker"]
				var _defendercb : CombatCreaButton = cur_action["defender"]

				var returned_evasion_array : Array = perform_melee_attack(cur_action)
				var continue_action : bool = returned_evasion_array[0]
				var extra_actions : Array = returned_evasion_array[1]
				if not extra_actions.is_empty() :
					combat_state.add_to_action_queue(extra_actions)
				if not continue_action :
					timer = 0.5
					await timer_over
					if current_entry != entry_serial:
						return
					continue
				
				timer = 1.0 *2
				print("combat animations tate : waiting for timer  for melee anm")
				UI.ow_hud.updateCharPanelDisplay()
				if is_instance_valid(cur_action["defender"]) :
					UI.ow_hud.creatureRect.display_crea_info(cur_action["defender"])
				await timer_over
				if current_entry != entry_serial:
					return
				
			"Spell" :
				if not is_instance_valid(cur_action["caster"]) :
					continue
				var a_caster : CombatCreaButton = cur_action["caster"]
				#print("CbAnimationState Spell action ! "+cur_action["spell"].name)
				var targetinglayer : TargetingLayer = GameGlobal.map.targetingLayer
				#recalculate the affected creas and tiles !
				var a_spell = cur_action["spell"]
				var a_power : int = cur_action["s_plvl"]
				var used_item: Variant = cur_action.get("used_item")
				var suppress_spell_reflection := bool(
					cur_action.get("suppress_spell_reflection", false)
				)
				
				var _a_all_targeted_tiles : Array = cur_action["Targeted Tiles"]
				var a_main_targeted_tile : Vector2i= Vector2i(cur_action["Main Targeted Tile"])
				var a_effected_tiles : Array = []
				if cur_action.has("absolute_aoe"):
					a_effected_tiles = cur_action["absolute_aoe"].duplicate()
				elif cur_action["override_aoe"].is_empty() :
					a_effected_tiles = targetinglayer.get_affected_tiles(a_spell, a_power, a_caster, a_main_targeted_tile, [])
					#print("CBANILSTATE a_effected_tiles : ", a_effected_tiles,  ', a_main_targeted_tile : ',a_main_targeted_tile)
					#pass
				else :
					a_effected_tiles = cur_action["override_aoe"]
					for i in range(a_effected_tiles.size()) :
						a_effected_tiles[i] = Vector2i(a_effected_tiles[i])+Vector2i(a_main_targeted_tile)
				var a_effected_creas : Array = targetinglayer.get_cbs_touching_tiles(a_effected_tiles)
				var a_add_terrain : bool = cur_action["add_terrain"]
				var a_from_terrain : bool = cur_action["from_terrain"]
				var a_castercrea : Creature = cur_action["castercrea"] if a_from_terrain else a_caster.creature
				var _who_there : CombatCreaButton = GameGlobal.who_is_at_tile(a_main_targeted_tile)
				
				UI.ow_hud.creatureRect.logrect.log_spell_cast(a_castercrea, a_spell ,a_power , '')
				
				if not a_from_terrain:
					a_castercrea.used_apr +=1
				
				if cur_action.has("oob_creas") :#and a_spell.in_field :
					# similar to ExMenus state :
					a_castercrea.on_ability_use(a_spell, a_power)
					for oobcrea in cur_action["oob_creas"] :
						var prev_life_status = oobcrea.life_status
						print("CbAnimState "+a_spell.name+" on oobcrea "+oobcrea.name)
						#do the spells effect !
						SfxPlayer.stream = GameGlobal.cmp_resources.sounds_book[a_spell.sounds[1]]
						SfxPlayer.play()
						if a_spell.get("proj_hit") :
							UI.ow_hud.show_spell_effect_on_char_menu( oobcrea, a_spell.proj_hit  )
						GameGlobal.do_spell_field_effect(a_castercrea, oobcrea, a_spell, a_power)
						UI.ow_hud.updateCharPanelDisplay()
						if prev_life_status>0 and oobcrea.life_status==0 :
							#SPAWN OOBCREA BUTTON
							combat_state.add_pc_or_npcally_to_battle_map(oobcrea, a_castercrea.position)
					
					

				
				
				
				
				
				
				if a_spell.get("proj_tex") and (not a_from_terrain) :
					if not a_spell.sounds[0].is_empty() :
						SfxPlayer.stream = GameGlobal.cmp_resources.sounds_book[ a_spell.sounds[0] ]
						SfxPlayer.play()
					await play_projectile_animation(a_spell.proj_tex, a_castercrea, a_main_targeted_tile)
					if current_entry != entry_serial:
						return
					#call_deferred("play_projectile_animation", a_spell.proj_tex, a_caster, a_main_targeted_tile)
				if not a_spell.sounds[1].is_empty() :
						SfxPlayer.stream = GameGlobal.cmp_resources.sounds_book[ a_spell.sounds[1] ]
						SfxPlayer.play()
				await play_spell_resolution(a_spell.proj_hit, a_castercrea, a_effected_tiles, a_effected_creas)
				if current_entry != entry_serial:
					return
				print("CbAnim l 196 just played anim for spell "+a_spell.name)
				if used_item is ItemInstance:
					var used_definition := (
						GameGlobal.cmp_resources.get_item_definition(used_item)
					)
					if used_definition != null \
							and used_definition.ammo_type != "cantuse":
						a_castercrea.consume_item_charges(
							a_castercrea.current_ammo_weapon_instance,
						)
					elif used_definition != null \
							and used_definition.maximum_charges > 0:
						a_castercrea.consume_item_charges(used_item)
				elif used_item is Dictionary and not used_item.is_empty():
					if used_item.has("ammo_type"):
						a_castercrea.consume_item_charges(
							a_castercrea.current_ammo_weapon_instance,
						)
					elif int(used_item.get("charges_max", 0)) > 0:
						a_castercrea.consume_item_charges(used_item)
				#call_deferred("play_spell_resolution", a_spell.proj_hit, a_caster, a_effected_tiles, a_effected_creas)
				CLASSIC_SPELL_REFLECTION_SCRIPT.begin_resolution(
					a_spell,
					suppress_spell_reflection
				)
				await after_spell_anim_finished(a_castercrea,a_spell,a_power,a_main_targeted_tile,a_effected_tiles, a_effected_creas, a_add_terrain)
				if current_entry != entry_serial:
					return
				CLASSIC_SPELL_REFLECTION_SCRIPT.end_resolution(a_spell)
				#call_deferred("after_spell_anim_finished", a_caster,a_spell,a_power,a_main_targeted_tile,a_effected_tiles, a_effected_creas, a_add_terrain)
				
				
			"Spawn" : #from creature.change_hp or spells   return ["Spawn", self, Vector2i.ZERO]
				print("CBAnimState  Spawn  action TBI  :c")
		UI.ow_hud.updateCharPanelDisplay()

		print("cbanimstate  check deaths l216")
		var dying : Array = get_new_deads() #those will do on_death script
		if not dying.is_empty() :
			
			timer = 1.0
			var sounds_book : Dictionary = GameGlobal.cmp_resources.get_sounds_book()
			SfxPlayer.stream = sounds_book["Death.wav"]
			SfxPlayer.play()
			for ded in dying:
				#ded.creature.doing_on_death_action = true
				if is_instance_valid(ded) :
					combat_state.queue_classic_death_macro(ded.creature)
					ded.atkSprite.frame = ded.pic_frame_dict["ATK_SKL"]
					ded.atkSprite.show()
					var added_to_queue : Array = []
					for t in ded.creature.traits :
						if t.has_method("_on_crea_death") :
							added_to_queue += t._on_crea_death(ded.creature)
					pass
					if added_to_queue.is_empty() :
						ded.creature.please_remove_from_combat = true
						ded.creature.doing_on_death_action = false
					else :
						ded.creature.please_remove_from_combat = false
						ded.creature.doing_on_death_action = true
						combat_state.add_to_action_queue(added_to_queue)
			#print("CbANimSTate l140 await tilmer over")
			await timer_over
			if current_entry != entry_serial:
				return
		
	#end while
	print("CbAnimState END OF WHILE<")
	print("combat_state.all_battle_creatures_btns.size()? ", combat_state.all_battle_creatures_btns.size())
	print("list for cb in combat_state.all_battle_creatures_btns :")
	for cb in combat_state.all_battle_creatures_btns :
		print("    cbanim cb : "+cb.creature.name+" plsremove ? "+str(cb.creature.please_remove_from_combat)+" , ondeath ? "+str(cb.creature.doing_on_death_action))
	#now remove all please_remove_from_combat combat buttons
	var to_be_removed : Array = []
	for cb in combat_state.all_battle_creatures_btns :
		#print("    cbanim cb : "+cb.creature.name+" plsremove ? "+str(cb.creature.please_remove_from_combat)+" , ondeath ? "+str(cb.creature.doing_on_death_action))
		if cb.creature.doing_on_death_action or cb.creature.please_remove_from_combat :
			to_be_removed.append(cb)
	for cb in to_be_removed :
		print("    cbanim remove cb "+cb.creature.name)
		combat_state.remove_registered_combatant(cb)
		cb.creature.please_remove_from_combat = false
		cb.creature.doing_on_death_action = false
		
	var battle_end_str : String = combat_state.check_battle_end()  # 0=nope 1=won 2=lost 3=fled
	print("CbAnim l263 before check balle end")
	# Classic drains queued death macros before deciding whether combat is over.
	if not battle_end_str.is_empty() and not combat_state.has_classic_combat_macros() :
		GameGlobal.end_battle(battle_end_str)
		return
	print("Cbanim m 266 transition_to(Combat/CbDecideAction)")
	StateMachine.transition_to("Combat/CbDecideAction")
	
	



func _on_timer_over() :
	print("CbAnilState signal timer_over")
	emit_signal("timer_over")


func _battlefield_size() -> Vector2i:
	var mapdata: Variant = GameGlobal.map.mapdata
	if not (mapdata is Array) or mapdata.is_empty() or not (mapdata[0] is Array):
		return Vector2i.ZERO
	return Vector2i(mapdata.size(), mapdata[0].size())


func perform_turn_undead(msg: Dictionary) -> void:
	var caster_button: Variant = msg.get("caster")
	if not is_instance_valid(caster_button):
		return
	var caster: Creature = caster_button.creature
	var result := combat_state.perform_turn_undead(caster_button)
	if str(result.get("status", "")) != "ok":
		return
	var logrect = UI.ow_hud.creatureRect.logrect
	logrect.log_other_text(caster, " attempts to turn the undead.", null, "")
	for outcome_value: Variant in result.get("outcomes", []):
		if not (outcome_value is Dictionary):
			continue
		var outcome: Dictionary = outcome_value
		var target: Variant = outcome.get("creature")
		var target_button: Variant = outcome.get("combatant")
		if not (target is Creature):
			continue
		match str(outcome.get("outcome", "resisted")):
			"destroyed":
				logrect.log_other_text(target, " is destroyed.", null, "")
			"turned":
				logrect.log_other_text(target, " is turned.", null, "")
				if is_instance_valid(target_button):
					target_button.set_creature_represented(target)
			_:
				logrect.log_other_text(target, " resists.", null, "")
	var bonus_experience := int(result.get("bonusExperience", 0))
	if bonus_experience > 0:
		await GameGlobal.give_exp_to_pcs(bonus_experience, [caster])
	timer = 0.5
	await timer_over

func play_projectile_animation(gfx : Spell.GFX, castercrea : Creature, targ_tpos : Vector2) :
	print("CbAnim play_projectile_animation gfx ",gfx,", ... start")
	var who_there : CombatCreaButton = GameGlobal.who_is_at_tile(targ_tpos)
	var origin : Vector2 = 32*castercrea.position + 16*(castercrea.size-Vector2.ONE)
	var dest : Vector2 = 32*targ_tpos
	if is_instance_valid(who_there) :
		dest = who_there.position + 16*(who_there.creature.size-Vector2.ONE)
	var s_anim : SpellAnimation = SPELL_ANIMATION_TSCN.instantiate()
	GameGlobal.map.gfx_node.add_child(s_anim)
	#print("SpellAimation in CbANimState : GameGlobal.map.gfx_node position;", GameGlobal.map.gfx_node.position)
	s_anim.init(gfx,origin,dest, true)
	print("CbAnim play_projectile_animation gfx,origin,dest: ",gfx,origin, dest,  ",  position:", s_anim.position, ", globalposiiton:",s_anim.global_position)
	timer = 1.0 *2
	await timer_over
	print("CbAnim play_projectile_animation gfx ",gfx," over")

func play_spell_resolution(gfx : Spell.GFX, _castercrea : Creature, effected_tiles : Array, effected_creas: Array) :
	print("CbAnim play_spell_resolution gfx ",gfx," start", effected_tiles)
	var gfx_node : Node2D = GameGlobal.map.gfx_node
	#print(effected_tiles)
	for t in effected_tiles :
		var s_anim : SpellAnimation = SPELL_ANIMATION_TSCN.instantiate()
		gfx_node.add_child(s_anim)
		s_anim.init(gfx,t*32,t*32, false)
	for cb : CombatCreaButton in effected_creas :
		var s_anim : SpellAnimation = SPELL_ANIMATION_TSCN.instantiate()
		var anim_pos = cb.position+16*(cb.creature.size-Vector2.ONE)
		gfx_node.add_child(s_anim)
		s_anim.init(gfx,anim_pos,anim_pos, false)
	timer = 1.0 *2
	await timer_over
	print("CbAnim play_spell_resolution gfx ",gfx," over")

func after_spell_anim_finished(castercrea : Creature, spell, power:int, main_targeted_tile : Vector2, effected_tiles : Array, effected_creas : Array, add_terrain : bool) :
	print("CbAnimState after_spell_anim_finished : "+castercrea.name+'s '+spell.name)
	var unresisted_creatures : Array = []
	var uses_repeated_missile_hits: bool = spell.has_method("uses_classic_repeated_hits") \
		and bool(spell.uses_classic_repeated_hits())
	for cb : CombatCreaButton in effected_creas :
		if CLASSIC_SPELL_REFLECTION_SCRIPT.is_classic_spell(spell):
			var reflection: Array = cb.creature.on_classic_spell_targeted(
				castercrea,
				spell,
				power
			)
			if not reflection[1].is_empty():
				combat_state.add_to_action_queue(reflection[1])
			if not bool(reflection[0]):
				continue
			cb.creature.on_classic_spell_targeted_before_resistance(
				castercrea,
				spell,
				power
			)
		if uses_repeated_missile_hits:
			# Classic reruns projectile resistance for every missile.
			unresisted_creatures.append(cb)
			continue
		var pre_resistance_roll := -1
		if CLASSIC_MAGIC_RESISTANCE_SCRIPT.spell_uses_pre_resistance(spell) :
			pre_resistance_roll = randi_range(1, 100)
		var general_resistance_roll := randi_range(1, 100)
		var resistance : Dictionary = CLASSIC_MAGIC_RESISTANCE_SCRIPT.spell_resolution(
			cb.creature,
			spell,
			power,
			general_resistance_roll,
			false,
			castercrea,
			pre_resistance_roll,
			GameGlobal.classic_party_charm_resistance_bonus(cb.creature)
		)
		if bool(resistance.get("resisted", false)) :
			UI.ow_hud.creatureRect.logrect.log_spell_no_effect(castercrea, cb, spell)
			continue
		unresisted_creatures.append(cb)
	var use_group_effect: bool = not spell.has_method("uses_classic_group_effect") \
		or bool(spell.uses_classic_group_effect())
	if spell.has_method("apply_classic_group_effect") and use_group_effect :
		var group_targets: Array = []
		for cb: CombatCreaButton in unresisted_creatures:
			group_targets.append(cb.creature)
		spell.apply_classic_group_effect(castercrea, group_targets, power)
		return
	if spell.get("special_effect") :
		var is_over : bool = await spell.special_effect(castercrea, spell, power, main_targeted_tile, effected_tiles, unresisted_creatures, add_terrain)
		if is_over :
			return
	# A few Classic spells roll a condition once before resolving each target.
	if spell.has_method("begin_classic_target_resolution") :
		spell.begin_classic_target_resolution(castercrea, power)
	for cb : CombatCreaButton in unresisted_creatures :
		if uses_repeated_missile_hits:
			_resolve_classic_repeated_missile_hits(castercrea, cb, spell, power)
			continue
		var accuracy_array : Array = GameGlobal.calculate_spell_accuracy(castercrea, cb.creature, spell, power)
		var accuracy = accuracy_array[0]
		var evasion_stats_used : Array = accuracy_array[1]
		var  returned_evasion_array : Array = cb.creature.on_evasion_check(evasion_stats_used, castercrea, spell, power)
		var continue_action : bool = returned_evasion_array[0]
		var extra_actions : Array = returned_evasion_array[1]
		if not extra_actions.is_empty() :
			combat_state.add_to_action_queue(extra_actions)
		if not continue_action :
			continue
		
		if accuracy < randf() :
			UI.ow_hud.creatureRect.logrect.log_spell_miss(castercrea, cb, spell , power, accuracy)
			continue
		var save_resolution: Dictionary = CLASSIC_SPELL_SAVES_SCRIPT.target_resolution(
			cb.creature,
			spell,
			power,
			randi_range(1, 100)
		)
		if str(save_resolution.get("status", "")) == "error" :
			UI.ow_hud.creatureRect.logrect.log_spell_no_effect(castercrea, cb, spell)
			continue
		if bool(save_resolution.get("saved", false)) \
				and float(save_resolution.get("effectScale", 0.0)) <= 0.0 :
			UI.ow_hud.creatureRect.logrect.log_spell_no_effect(castercrea, cb, spell)
			continue
		# Charm changes the target's faction, so retain the relationship from
		# the moment this effect passed resistance and saves.
		var was_hostile := CLASSIC_MONSTER_DECISION_SCRIPT.are_opponents(
			castercrea,
			cb.creature
		)
		if spell.has_method("apply_classic_scaled_effect") :
			var effect_result: Variant = spell.apply_classic_scaled_effect(
				castercrea,
				cb.creature,
				power,
				float(save_resolution.get("effectScale", 1.0))
			)
			CLASSIC_MONSTER_DECISION_SCRIPT.mark_attacked_by_effect(
				cb.creature,
				effect_result,
				was_hostile
			)
			continue
		var spell_damage : int = GameGlobal.calculate_spell_damage(castercrea, cb.creature, spell, power, true)
		spell_damage = floori(
			spell_damage * float(save_resolution.get("effectScale", 1.0))
		)
		
		
		var spell_effect_array : Array = cb.creature.on_hit_by_spell(castercrea,spell,power, -spell_damage)
		if spell_effect_array[0] :
			cb.display_effect("ATK_NUL", spell_damage, 2.0)  # the spells animation plays behind the text
			if spell_damage > 0:
				cb.creature.mark_classic_attacked()
			cb.creature.change_cur_hp(spell_effect_array[1])
			UI.ow_hud.creatureRect.logrect.log_spell_damage(castercrea, cb, spell , power, {"total":spell_damage}, accuracy)
			if spell.has_method("add_traits_to_creature") :
				spell.add_traits_to_creature(castercrea, cb.creature, power)
				if spell_damage <= 0:
					CLASSIC_MONSTER_DECISION_SCRIPT.mark_attacked_by_effect(
						cb.creature,
						true,
						was_hostile
					)
		else :
			UI.ow_hud.creatureRect.logrect.log_spell_no_effect(castercrea,cb,spell)
		combat_state.add_to_action_queue(spell_effect_array[2])
	if spell.has_method("end_classic_target_resolution") :
		spell.end_classic_target_resolution()

	if not spell.terrain_tex.is_empty() and add_terrain:
		print("CBAnimState add_terrain_effects")
		GameGlobal.map.add_terrain_effect_from_spell(spell,power, effected_tiles,Vector2i.ZERO,castercrea )


func _resolve_classic_repeated_missile_hits(
	castercrea: Creature,
	cb: CombatCreaButton,
	spell,
	power: int
) -> void:
	var hit_count := maxi(1, int(spell.get_hits(power, castercrea)))
	for _hit_index: int in range(hit_count):
		var pre_resistance_roll := -1
		if CLASSIC_MAGIC_RESISTANCE_SCRIPT.spell_uses_pre_resistance(spell):
			pre_resistance_roll = randi_range(1, 100)
		var resistance: Dictionary = CLASSIC_MAGIC_RESISTANCE_SCRIPT.spell_resolution(
			cb.creature,
			spell,
			power,
			randi_range(1, 100),
			false,
			castercrea,
			pre_resistance_roll,
			GameGlobal.classic_party_charm_resistance_bonus(cb.creature)
		)
		if bool(resistance.get("resisted", false)):
			UI.ow_hud.creatureRect.logrect.log_spell_no_effect(castercrea, cb, spell)
			break

		var accuracy_array: Array = GameGlobal.calculate_spell_accuracy(
			castercrea,
			cb.creature,
			spell,
			power
		)
		var accuracy = accuracy_array[0]
		var returned_evasion_array: Array = cb.creature.on_evasion_check(
			accuracy_array[1],
			castercrea,
			spell,
			power
		)
		if not returned_evasion_array[1].is_empty():
			combat_state.add_to_action_queue(returned_evasion_array[1])
		if not bool(returned_evasion_array[0]):
			break
		if accuracy < randf():
			UI.ow_hud.creatureRect.logrect.log_spell_miss(
				castercrea,
				cb,
				spell,
				power,
				accuracy
			)
			break

		var save_resolution: Dictionary = CLASSIC_SPELL_SAVES_SCRIPT.target_resolution(
			cb.creature,
			spell,
			power,
			randi_range(1, 100)
		)
		if str(save_resolution.get("status", "")) == "error" \
				or (
					bool(save_resolution.get("saved", false))
					and float(save_resolution.get("effectScale", 0.0)) <= 0.0
				):
			UI.ow_hud.creatureRect.logrect.log_spell_no_effect(castercrea, cb, spell)
			break

		var spell_damage := GameGlobal.calculate_spell_damage(
			castercrea,
			cb.creature,
			spell,
			power,
			true
		)
		spell_damage = floori(
			spell_damage * float(save_resolution.get("effectScale", 1.0))
		)
		var spell_effect_array: Array = cb.creature.on_hit_by_spell(
			castercrea,
			spell,
			power,
			-spell_damage
		)
		if bool(spell_effect_array[0]):
			cb.display_effect("ATK_NUL", spell_damage, 2.0)
			if spell_damage > 0:
				cb.creature.mark_classic_attacked()
			cb.creature.change_cur_hp(spell_effect_array[1])
			UI.ow_hud.creatureRect.logrect.log_spell_damage(
				castercrea,
				cb,
				spell,
				power,
				{"total": spell_damage},
				accuracy
			)
		else:
			UI.ow_hud.creatureRect.logrect.log_spell_no_effect(castercrea, cb, spell)
		combat_state.add_to_action_queue(spell_effect_array[2])
		if not bool(spell_effect_array[0]) or cb.creature.get_stat("curHP") <= 0:
			break
	
	
	
	

func get_new_deads() -> Array :
	var returned : Array = []
	for cb in combat_state.all_battle_creatures_btns :
		if cb.creature.get_stat("curHP") <=0 :
			if not cb.creature.doing_on_death_action :
				print("CbAnimationState : get_new_deads() : "+cb.creature.name)
				returned.append(cb)
	return returned


func perform_swap(msg : Dictionary) :
	
	#{"type" : "Swap", "mover" : current_active_creabutton, "Moved" : whothere }
	var movercb :  CombatCreaButton = msg["mover"]
	var movedcb : CombatCreaButton = msg["moved"]

	print("     mover : "+str(movercb.creature.name), " moved : "+str(movedcb.creature.name))
	print("     CbAnimationState perform swap b4 : mover:",movercb.position,', moved',movedcb.position) 
	
	var moved_old_creapos = movedcb.creature.position
	var moved_old_cb_pos = movedcb.position
	movedcb.position = movercb.position
	movedcb.creature.position = movercb.creature.position
	movercb.position = moved_old_cb_pos
	movercb.creature.position = moved_old_creapos
	movercb.creature.used_movepoints +=5
	
	if movercb.creature.doing_on_death_action :
		movercb.creature.doing_on_death_action = false
		if movercb.creature.get_stat("curHP")<=0 :
			movercb.creature.please_remove_from_combat = true
	
	UI.ow_hud.updateCharPanelDisplay()
	UI.ow_hud.creatureRect.display_crea_info(movercb)
	print("     CbAnimationState perform swap after : mover:",movercb.position,', moved',movedcb.position)
	#GameGlobal.map.queue_redraw()


#returns [continue_action, returned_action_queue] where returnedactionqueue is an array of attack/spell/mve messages
func perform_melee_attack(msg : Dictionary) -> Array:
	var returned_action_queue : Array = []
	#{"type" : "MeleeAttack", "attacker" : Crea, "defender" : Crea, "weapon": {} }
	var attackercb : CombatCreaButton = msg["attacker"]
	var defendercb : CombatCreaButton = msg["defender"]

	var weapon: Variant = msg["weapon"]
	attackercb.creature.used_apr += 1
	attackercb.creature.mark_classic_attack_attempt()
	var accuracy : float = GameGlobal.calculate_melee_accuracy(attackercb.creature, defendercb.creature, weapon, true)
	var classic_helpless := CLASSIC_HELPLESS_SCRIPT.is_helpless(
		defendercb.creature
	)
	var hit_success : bool = classic_helpless or accuracy > randf()
	var evasion_check_array : Array = [true, []] if classic_helpless else (
		defendercb.creature.on_evasion_check(
			['Melee'],
			attackercb.creature,
			null,
			0
		)
	) #null for melee attacks, spell for spells
	var continue_action : bool = evasion_check_array[0]
	var extra_actions : Array = evasion_check_array[1]
	returned_action_queue += extra_actions
	

	
	
	
	if not continue_action :
		#print("CbAnimation.perform_melee_attack : not continue_action , returned_action_queue = ", returned_action_queue)
		return [continue_action, returned_action_queue]
	var weapon_instance: ItemInstance = attackercb.creature.get_item_instance(
		weapon
	)
	var item_resources = NodeAccess.__Resources()
	var compatibility_weapon: Dictionary = (
		item_resources.legacy_item_view_for_adapter(weapon_instance)
		if weapon_instance != null
		else weapon if weapon is Dictionary else {}
	)
	# Classic redirects an attack that already hit; it does not queue a second
	# attack with another accuracy roll or action cost.
	if hit_success and defendercb.creature.on_melee_reflection_check(
		attackercb.creature,
		compatibility_weapon
	):
		defendercb = attackercb
	var weapon_definition := item_resources.get_item_definition(weapon_instance) \
		if weapon_instance != null else null
	var picture : String = "ATK_WPN"
	if weapon_definition != null and not weapon_definition.melee_animation.is_empty():
		picture = weapon_definition.melee_animation
	elif weapon is Dictionary:
		if weapon.has("melee_atk_anim_icon"):
			picture = weapon["melee_atk_anim_icon"]
		elif str(weapon.get("name", "")) == "NO_MELEE_WEAPON":
			picture = "ATK_HTH"
	var crit_rate : float = attackercb.creature.get_stat("Melee_Crit_Rate")
	var crit_mult : float = attackercb.creature.get_stat("Melee_Crit_Mult")
	var is_crit : bool = crit_rate > randf()
	var damage_detail : Dictionary = GameGlobal.calculate_melee_damage(attackercb.creature, defendercb.creature, weapon, is_crit, crit_mult)
	var attack_result_array : Array = defendercb.creature._on_before_melee_attack(attackercb, damage_detail)
	hit_success = hit_success and attack_result_array[0]
	attackercb = attack_result_array[1]
	defendercb = attack_result_array[2]
	damage_detail = attack_result_array[3]
	if hit_success :
		damage_detail = CLASSIC_HELPLESS_SCRIPT.force_physical_damage(
			damage_detail,
			defendercb.creature
		)
		
		
		
		var attacker = attackercb
		var defender = defendercb
		defender.creature.mark_classic_attacked()
		
		var weapon_sound := weapon_definition.sound_key \
			if weapon_definition != null else str(weapon.get("sound", "")) \
			if weapon is Dictionary else ""
		if weapon_definition != null \
				and attacker.creature.has_meta("classic_monster_generation"):
			weapon_sound = CLASSIC_MONSTER_GENERATION_SCRIPT.armed_attack_sound_name(
				weapon_definition,
				weapon
			)
		SfxPlayer.stream = item_resources.sounds_book[weapon_sound]
		UI.ow_hud.creatureRect.logrect.log_melee_attack(attacker,defender,damage_detail, accuracy, is_crit, crit_mult, crit_rate)
		defender.display_effect(picture, damage_detail["total"], 0.8 *2)
		SfxPlayer.play()
		#await defender.atkanimTimer.timeout
		defender.creature.focus_counter +=1 
		var classic_special: Dictionary = CLASSIC_MONSTER_SPECIAL_ATTACK_SCRIPT.apply_from_weapon(
			attacker.creature,
			defender.creature,
			item_resources.legacy_item_view_for_adapter(weapon_instance)
				if weapon_instance != null else weapon,
			-1,
			GameGlobal.classic_party_charm_resistance_bonus(defender.creature)
		)
		if str(classic_special.get("status", "ok")) == "error":
			push_error(str(classic_special.get(
				"message", "Classic monster special attack failed"
			)))
		defender.creature.change_cur_hp(-damage_detail["total"])
		if weapon_instance != null:
			var resolved_traits: Dictionary = item_resources.item_trait_bindings(
				weapon_instance,
				true,
			)
			if not bool(resolved_traits.get("ok", false)):
				for message: Variant in resolved_traits.get("errors", []):
					push_error(str(message))
			for binding_value: Variant in resolved_traits.get("bindings", []):
				var binding: Dictionary = binding_value
				if randf() <= float(binding.get("chance", 1.0)):
					var traitinstance = defender.creature.add_trait(
						binding.get("script"),
						binding.get("arguments", []),
					)
					UI.ow_hud.creatureRect.logrect.log_other_text(
						attacker.creature,
						"'s attack inflicted " + traitinstance.menuname + " to ",
						defender.creature,
						"",
					)
		elif weapon is Dictionary and weapon.has("melee_inflicted_traits") :
			var inflicted_traits_array : Array = weapon["melee_inflicted_traits"]
			# looks like [traitname:String, traitinitargs : Array, chance : float]
			for itr : Array in inflicted_traits_array :
				print("itr : ", itr)
				if randf()<= itr[2] : #inflict status to  target
					var traitname : String = itr[0]
					print("GameGlobal inflicting status on melee atack ",weapon[traitname])
	#				new_item[traitname] = [newscript,traitinit]#new_trait_script
					var traitinstance = defender.creature.add_trait(weapon[traitname][0],weapon[traitname][1])
					#log_other_text(creaone : Creature, textone : String, creatwo : Creature ,texttwo : String) -> void :
					UI.ow_hud.creatureRect.logrect.log_other_text(attacker.creature, "'s attack inflicted "+traitinstance.menuname+' to ',defender.creature,'')
		
		
		
		
		
	#now we will need the actual animation... original in ld GameGlobal Godot 4 Projects\Realmz Remake Folder - before game logic update
	else :
		SfxPlayer.stream = NodeAccess.__Resources().sounds_book["Attack Miss.wav"]
		SfxPlayer.play()
		UI.ow_hud.creatureRect.logrect.log_melee_attack_miss(attackercb,defendercb, accuracy)
	
	if attackercb.creature.doing_on_death_action :
		attackercb.creature.doing_on_death_action = false
		if attackercb.creature.get_stat("curHP")<=0 :
			attackercb.creature.please_remove_from_combat = true
	
	return [continue_action, returned_action_queue]
