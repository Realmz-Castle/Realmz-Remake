extends State
class_name CbAnimationState


@onready var combat_state : CombatState = get_parent()

#@export var timer : Timer

const SPELL_ANIMATION_TSCN : PackedScene = preload("res://scenes/Map/SpellAnimation/SpellAnimation.tscn")

var cur_action : Dictionary

var timer : float = -1000000

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
var spell_must_add_terrain : bool = true

signal timer_over

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _state_process(delta : float) -> void :
	#print(timer)
	timer -= delta * (1.0/GameGlobal.gamespeed)
	if timer <=0 and timer >-999999:
		timer = -1000000
		_on_timer_over()
		


func enter(_msg : Dictionary = {}) -> void:
	#print("CbAnimationState enter _msg : ", _msg)
	print("comabt aniim queue size : "+str(combat_state.action_queue.size()))
	Input.set_custom_mouse_cursor(UI.cursor_sword)
	while not combat_state.action_queue.is_empty() :
		cur_action = combat_state.action_queue.pop_front()
		print("CBAnimState : cur action : "+str(cur_action)+" , left : "+str(combat_state.action_queue.size()))
		match cur_action["type"] :
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
					if  movercb.creature.get_movement_left() >=canmoveandtime[1] :
						
						if cur_action.has("check_before_scripts") :
							if cur_action["check_before_scripts"] :
								var extra_act_before_move : Array = movercb.creature._on_before_move(dir)
								if not extra_act_before_move.is_empty() :
									cur_action["check_before_scripts"] = false
									var added_acts = extra_act_before_move + [cur_action]
									combat_state.add_to_action_queue(added_acts)
									continue
						
						var extra_actions : Array = movercb.creature.move(dir)
						print("CbAnim onmove extra_actions : ", extra_actions)
						var xdiff : float = abs(GameGlobal.map.focuscharacter.tile_position_x-movercb.creature.position.x)
						var ydiff : float = abs(GameGlobal.map.focuscharacter.tile_position_y-movercb.creature.position.y)
						if xdiff>3 or ydiff>4 :
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
				
			"Swap" :
				perform_swap(cur_action)
				
			"MeleeAttack" :
				if not (is_instance_valid(cur_action["attacker"]) and is_instance_valid(cur_action["defender"])) :
					continue
				var attackercb : CombatCreaButton = cur_action["attacker"]
				var defendercb : CombatCreaButton = cur_action["defender"]

				var returned_evasion_array : Array = perform_melee_attack(cur_action)
				var continue_action : bool = returned_evasion_array[0]
				var extra_actions : Array = returned_evasion_array[1]
				if not extra_actions.is_empty() :
					combat_state.add_to_action_queue(extra_actions)
				if not continue_action :
					continue
				
				timer = 1.0 *2
				print("combat animations tate : waiting for timer  for melee anm")
				UI.ow_hud.updateCharPanelDisplay()
				if is_instance_valid(cur_action["defender"]) :
					UI.ow_hud.creatureRect.display_crea_info(cur_action["defender"])
				await timer_over
				
			"Spell" :
				if not is_instance_valid(cur_action["caster"]) :
					continue
				var a_caster : CombatCreaButton = cur_action["caster"]
				#print("CbAnimationState Spell action ! "+cur_action["spell"].name)
				var targetinglayer : TargetingLayer = GameGlobal.map.targetingLayer
				#recalculate the affected creas and tiles !
				var a_spell = cur_action["spell"]
				var a_power : int = cur_action["s_plvl"]
				
				var a_all_targeted_tiles : Array = cur_action["Targeted Tiles"]
				var a_main_targeted_tile : Vector2i= Vector2i(cur_action["Main Targeted Tile"])
				var a_effected_tiles : Array = []
				if cur_action["override_aoe"].is_empty() :
					a_effected_tiles = targetinglayer.get_affected_tiles(a_spell, a_power, a_caster, a_main_targeted_tile, [])
				else :
					a_effected_tiles = cur_action["override_aoe"]
					for i in range(a_effected_tiles.size()) :
						a_effected_tiles[i] = Vector2i(a_effected_tiles[i])+Vector2i(a_main_targeted_tile)
				var a_effected_creas : Array = targetinglayer.get_cbs_touching_tiles(a_effected_tiles)
				var a_add_terrain : bool = cur_action["add_terrain"]
				var a_from_terrain : bool = cur_action["from_terrain"]
				var a_castercrea : Creature = cur_action["castercrea"] if a_from_terrain else a_caster.creature
				var who_there : CombatCreaButton = GameGlobal.who_is_at_tile(a_main_targeted_tile)
				
				UI.ow_hud.creatureRect.logrect.log_spell_cast(a_castercrea, a_spell ,a_power , '')
				
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
					#call_deferred("play_projectile_animation", a_spell.proj_tex, a_caster, a_main_targeted_tile)
				if not a_spell.sounds[1].is_empty() :
						SfxPlayer.stream = GameGlobal.cmp_resources.sounds_book[ a_spell.sounds[1] ]
						SfxPlayer.play()
				await play_spell_resolution(a_spell.proj_hit, a_castercrea, a_effected_tiles, a_effected_creas)
				var used_item : Dictionary = cur_action["used_item"]
				if not used_item.is_empty() :
					if used_item.has("ammo_type") :
						a_castercrea.current_ammo_weapon["charges"] -= 1
					else :
						if used_item["charges_max"]>0 :
							used_item["charges"] -=1
				#call_deferred("play_spell_resolution", a_spell.proj_hit, a_caster, a_effected_tiles, a_effected_creas)
				await after_spell_anim_finished(a_castercrea,a_spell,a_power,a_main_targeted_tile,a_effected_tiles, a_effected_creas, a_add_terrain)
				#call_deferred("after_spell_anim_finished", a_caster,a_spell,a_power,a_main_targeted_tile,a_effected_tiles, a_effected_creas, a_add_terrain)
				
				
			"Spawn" : #from creature.change_hp or spells   return ["Spawn", self, Vector2i.ZERO]
				pass
		UI.ow_hud.updateCharPanelDisplay()

		print("cbanimstate  check deaths l116")
		var dying : Array = get_new_deads() #those will do on_death script
		if not dying.is_empty() :
			
			timer = 1.0
			var sounds_book : Dictionary = GameGlobal.cmp_resources.get_sounds_book()
			SfxPlayer.stream = sounds_book["Death.wav"]
			SfxPlayer.play()
			for ded in dying:
				#ded.creature.doing_on_death_action = true
				if is_instance_valid(ded) :
					ded.atkSprite.frame = ded.pic_frame_dict["ATK_SKL"]
					ded.atkSprite.show()
					var added_to_queue : Array = []
					for t in ded.creature.traits :
						if t.has_method("_on_crea_death") :
							added_to_queue += t._on_crea_death(ded.creature)
					if added_to_queue.is_empty() :
						ded.creature.please_remove_from_combat = true
						ded.creature.doing_on_death_action = false
					else :
						ded.creature.please_remove_from_combat = false
						ded.creature.doing_on_death_action = true
						combat_state.add_to_action_queue(added_to_queue)
			#print("CbANimSTate l140 await tilmer over")
			await timer_over
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
		combat_state.battle_dead_enemies.append(cb.creature)
		combat_state.remove_cb_from_battle(cb)
		cb.creature.please_remove_from_combat = false
		cb.creature.doing_on_death_action = false
		
	var battle_end_str : String = combat_state.check_battle_end()  # 0=nope 1=won 2=lost 3=fled
	if not battle_end_str.is_empty() :
		GameGlobal.end_battle(battle_end_str)
		return
	StateMachine.transition_to("Combat/CbDecideAction")
	
	



func _on_timer_over() :
	print("CbAnilState signal timer_over")
	emit_signal("timer_over")

func play_projectile_animation(gfxname : String, castercrea : Creature, targ_tpos : Vector2) :
	print("CbAnim play_projectile_animation "+gfxname+" start")
	var who_there : CombatCreaButton = GameGlobal.who_is_at_tile(targ_tpos)
	var origin : Vector2 = 32*castercrea.position + 16*(castercrea.size-Vector2.ONE)
	var dest : Vector2 = 32*targ_tpos
	if is_instance_valid(who_there) :
		dest = who_there.position + 16*(who_there.creature.size-Vector2.ONE)
	var s_anim : SpellAnimation = SPELL_ANIMATION_TSCN.instantiate()
	GameGlobal.map.gfx_node.add_child(s_anim)
	s_anim.init(gfxname,origin,dest, true)
	timer = 1.0 *2
	await timer_over
	print("CbAnim play_projectile_animation "+gfxname+" over")

func play_spell_resolution(gfxname : String, castercrea : Creature, effected_tiles : Array, effected_creas: Array) :
	print("CbAnim play_spell_resolution "+gfxname+" start", effected_tiles)
	var gfx_node : Node2D = GameGlobal.map.gfx_node
	#print(effected_tiles)
	for t in effected_tiles :
		var s_anim : SpellAnimation = SPELL_ANIMATION_TSCN.instantiate()
		gfx_node.add_child(s_anim)
		s_anim.init(gfxname,t*32,t*32, false)
	for cb in effected_creas :
		var s_anim : SpellAnimation = SPELL_ANIMATION_TSCN.instantiate()
		var anim_pos = cb.position+16*(cb.creature.size-Vector2.ONE)
		gfx_node.add_child(s_anim)
		s_anim.init(gfxname,anim_pos,anim_pos, false)
	timer = 1.0 *2
	await timer_over
	print("CbAnim play_spell_resolution "+gfxname+" over")

func after_spell_anim_finished(castercrea : Creature, spell, power:int, main_targeted_tile : Vector2, effected_tiles : Array, effected_creas : Array, add_terrain : bool) :
	print("CbAnimState after_spell_anim_finished : "+castercrea.name+'s '+spell.name)
	if spell.get("special_effect") :
		var is_over : bool = spell.special_effect(castercrea, spell, power, main_targeted_tile, effected_tiles, effected_creas, add_terrain)
		if is_over :
			return
	for c in effected_creas :
		var accuracy_array : Array = GameGlobal.calculate_spell_accuracy(castercrea, c.creature, spell, power)
		var accuracy = accuracy_array[0]
		var evasion_stats_used : Array = accuracy_array[1]
		var  returned_evasion_array : Array = c.creature.on_evasion_check(evasion_stats_used, castercrea, spell, power)
		var continue_action : bool = returned_evasion_array[0]
		var extra_actions : Array = returned_evasion_array[1]
		if not extra_actions.is_empty() :
			combat_state.add_to_action_queue(extra_actions)
		if not continue_action :
			continue
		
		if accuracy < randf() :
			UI.ow_hud.creatureRect.logrect.log_spell_miss(castercrea, c, spell , power, accuracy)
			continue
		var spell_damage : int = GameGlobal.calculate_spell_damage(castercrea, c.creature, spell, power, true)
		
		
		var spell_effect_array : Array = c.creature.on_hit_by_spell(castercrea,spell,power, -spell_damage)
		if spell_effect_array[0] :
			c.display_effect("ATK_NUL", spell_damage, 2.0)  # the spells animation plays behind the text
			c.creature.change_cur_hp(spell_effect_array[1])
			UI.ow_hud.creatureRect.logrect.log_spell_damage(castercrea, c, spell , power, {"total":spell_damage}, accuracy)
			if spell.has_method("add_traits_to_target") :
				spell.add_traits_to_target(castercrea, c, power)
		else :
			UI.ow_hud.creatureRect.logrect.log_spell_no_effect(castercrea,c,spell)
		combat_state.add_to_action_queue(spell_effect_array[2])

	if spell.get("terrain_tex") and spell_must_add_terrain :
		print("CBAnimState add_terrain_effects")
		GameGlobal.map.add_terrain_effect_from_spell(spell,power, effected_tiles,Vector2i.ZERO,castercrea )
	
	
	
	

func get_new_deads() -> Array :
	var returned : Array = []
	for cb in combat_state.all_battle_creatures_btns :
		if cb.creature.get_stat("curHP") <=0 :
			if not cb.creature.doing_on_death_action :
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

	var weapon : Dictionary = msg["weapon"]
	attackercb.creature.used_apr += 1
	var accuracy : float = GameGlobal.calculate_melee_accuracy(attackercb.creature, defendercb.creature, weapon, true)
	var hit_success : bool = accuracy > randf()
	var evasion_check_array : Array = defendercb.creature.on_evasion_check(['Melee'], attackercb.creature, null, 0) #null for melee attacks, spell for spells
	var continue_action : bool = evasion_check_array[0]
	var extra_actions : Array = evasion_check_array[1]
	returned_action_queue += extra_actions
	

	
	
	
	if not continue_action :
		#print("CbAnimation.perform_melee_attack : not continue_action , returned_action_queue = ", returned_action_queue)
		return [continue_action, returned_action_queue]
	var picture : String = "ATK_WPN"
	if attackercb.creature.current_melee_weapons[0].has("melee_atk_anim_icon") :
		picture = attackercb.creature.current_melee_weapons[0]["melee_atk_anim_icon"]
	else :
		if attackercb.creature.current_melee_weapons[0]["name"]=="NO_MELEE_WEAPON" :
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
		
		
		
		var attacker = msg["attacker"]
		var defender = msg["defender"]
		
		SfxPlayer.stream = NodeAccess.__Resources().sounds_book[ attacker.creature.current_melee_weapons[0]["sound"] ]
		UI.ow_hud.creatureRect.logrect.log_melee_attack(attacker,defender,damage_detail, accuracy, is_crit, crit_mult, crit_rate)
		defender.display_effect(picture, damage_detail["total"], 0.8 *2)
		SfxPlayer.play()
		#await defender.atkanimTimer.timeout
		defender.creature.focus_counter +=1 
		defender.creature.change_cur_hp(-damage_detail["total"])
		print('GameGlobal weapon.has("melee_inflicted_traits") ? ', weapon.has("melee_inflicted_traits"))
		if weapon.has("melee_inflicted_traits") :
			var inflicted_traits_array : Array = attacker.creature.current_melee_weapons[0]["melee_inflicted_traits"]
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
