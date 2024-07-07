extends Object
class_name test_crea_script

#const target_pos : Vector2i = Vector2i(51,87)

# returns : depends of  fint int in array :
#  [0]==0 means  walk in  the direction Vector2i  at  [1]
#  [1, selectedSpell, selectedplvl, spell_target_pos].......aoe_shape : Array, picked_targets : Dictionary, picked_tiles:Dictionary, chain_start : bool, must_add_terrain : bool)
static func decide_action(crea : Creature) -> Array :
	print("test_crea_script decide_action : "+crea.name)
	var target_crea : Creature = null
	if crea.creature_script_memory.has("target_crea") :
		target_crea = crea.creature_script_memory["target_crea"]
	#check if  target_crea is next to me, else find closest one :
	var is_targ_next_to_crea : bool = false
	if target_crea :
		if target_crea.combat_button != null :
			target_crea = null
			is_targ_next_to_crea = false
		else :
			is_targ_next_to_crea = is_other_in_range(crea, target_crea, 1)
	var targ_range = 1
	if is_targ_next_to_crea :
		targ_range = 1
	if not is_targ_next_to_crea :
		var closest_enemies : Array = get_closest_creas_not_of_side(crea, crea.curFaction)
		if not closest_enemies.is_empty():
			target_crea = closest_enemies[0]
			targ_range = get_range_between_creas(crea, target_crea)
		else :
			target_crea = null
			targ_range = 9999
	
	#if have a target and it's close enough, walk to it and attack
	if target_crea :
		var target_pos : Vector2 = target_crea.position
		print("   target_crea : ", target_crea.name,   "position : ", target_pos)
		if targ_range<=crea.get_movement_left() and int(crea.ai_variables["cast_chance"])<randi_range(0,100) :
			var path : Array = GameGlobal.map.find_path(crea.position, target_pos, true, false, false, crea, true)
			if crea.get_apr_left() == 0 or  path.size() < 2 :
				print("ai decideaction : crea.get_apr_left() == 0 : "+str(crea.get_apr_left())+"  or  path.size() < 2 : "+str( path.size() < 2)  )
				return [0, Vector2i.ZERO ]
			else :
				print("ai decideaction : "+crea.name+" 's path is : "+str(path.size())+' long')
				return [0,Vector2i(path[1])-Vector2i(crea.position) ]
		else :
			# CAST MAGIC or use bow !!!
			var spell_target_pos : Vector2 = target_pos
			var sp_left = crea.get_stat("curSP")
			var allspellsArray : Array = crea.get_all_spells()
			if allspellsArray.size()>0 :
				allspellsArray.shuffle()
			var selectedSpell = null
			var selectedplvl : int = 0
			if crea.current_range_weapon != crea.ITEM_NO_RANGE_WEAPON :
				var weapon_spell_arr : Array =  crea.current_range_weapon["_on_combat_use_spell"]
				var weapon_spell = NodeAccess.__Resources().spells_book[weapon_spell_arr[0]]["script"]
				var weapon_power : int = weapon_spell_arr[1]
				if weapon_spell.get_range(weapon_power, crea) >= targ_range :
					var affected_tiles : Array = GameGlobal.map.targetingLayer.get_affected_tiles(weapon_spell, weapon_power, crea.combat_button, target_pos, [])
					var affected_creas : Array = GameGlobal.map.targetingLayer.get_cbs_touching_tiles(affected_tiles)
					if affected_creas.size()>0 :
						print("    DECIDED TO USE BOW")
					var aoe_name = weapon_spell.get_aoe(weapon_power, crea)
					var aoe_shape = GameGlobal.map.targetingLayer.get_aoe_from_name(aoe_name)
					return [1, weapon_spell, weapon_power, spell_target_pos, aoe_shape, {},Vector2i(target_pos), affected_tiles, affected_creas]
					#return [1, weapon_spell, weapon_power, spell_target_pos, aoe_shape, {},Vector2i(target_pos), true, true]
			
			if allspellsArray.is_empty() :
				return [0, Vector2i.ZERO ] 
			var affected_tiles : Array = []
			var affected_creas : Array = []
			for spelldict in allspellsArray :
				var spell = spelldict["script"]
				for plvl in range(1,8) :
					var cost = crea.get_spell_resource_cost(spell,plvl)
					if cost > sp_left or spell.get_range(plvl, crea)<targ_range :
						break
					print("  DECIDEACTION crea : ", crea,  "  , combatbutton ? : ", crea.combat_button)
					#(s_spell, rotation : int, s_power : int, s_caster : CombatCreaButton, s_targeted_pos : Vector2) :
					#get_affected_tiles(s_spell, s_power : int, s_caster : CombatCreaButton, s_targeted_pos : Vector2, s_aoe_override = []) :
					affected_tiles = GameGlobal.map.targetingLayer.get_affected_tiles(spell, plvl, crea.combat_button, target_pos, [])
					affected_creas = GameGlobal.map.targetingLayer.get_cbs_touching_tiles(affected_tiles)
					#func get_spell_affected_creas(s_spell, rotation : int, s_power : int, s_caster : CombatCreaButton, s_targeted_pos : Vector2) :
					if affected_creas.size()>0 :
						selectedSpell = spell
						selectedplvl = plvl
			if selectedSpell :
				print("    DECIDED TO USE MAGIC")
				var aoe_name = selectedSpell.get_aoe(selectedplvl, crea)
				var aoe_shape = GameGlobal.map.targetingLayer.get_aoe_from_name(aoe_name)
				return [1, selectedSpell, selectedplvl, spell_target_pos, aoe_shape, {},Vector2i(spell_target_pos), affected_tiles, affected_creas]
			#picked_targets : Dictionary, picked_tiles:Dictionary, chain_start : bool, must_add_terrain : bool)
					

	
	#if cant find anything to do, do nothing...
	print("decideaction : "+crea.name+" does nothing")
	return [0, Vector2i.ZERO ]
				
#	if not crea.scripts_memory.has("prev_dir") :
#		crea.scripts_memory["prev_dir"] = [Vector2.UP, Vector2.RIGHT].pick_random()
#	crea.scripts_memory["prev_dir"] = - crea.scripts_memory["prev_dir"]
#	return [0, - crea.scripts_memory["prev_dir"] ]


	#if not crea.scripts_memory.has("target_pos") :
		#crea.scripts_memory["target_pos"] = target_pos
	##find_path(from : Vector2i, to : Vector2i, swimmer : bool, flying : bool, big : bool)
	#var path : Array = GameState.map.find_path(crea.position, target_pos, true, false, false)
	#
	#if path.size() < 1 :
##		print("test_crea_script : ", crea.position, ' path empty :c ')
		#return [0, Vector2.ZERO ]
	#else :
		#print("test_crea_script : ", crea.position, ' path: ', path[0])
		#print("TileDict : ", GameState.map.mapdata[path[0].x][path[0].y])
		#return [0,Vector2(path[1])-crea.position ]
	

# return true iff the other crea is "range"  or less tiles away.
static func is_other_in_range(crea :Creature, othercrea : Creature, mrange : int) ->bool :
	for cx in range(0,crea.size.x) :
		for cy in range(0,crea.size.y) :
			for tx in range(0,othercrea.size.x) :
				for ty in range(0,othercrea.size.y) :
					if GameGlobal.calculate_range_v(Vector2(cx,cy)-Vector2(tx,ty)) <= mrange :
						return true
	return false

#useful for bigger creatures !
# ignores terrain
static func get_range_between_creas(crea : Creature, othercrea : Creature) ->int :
	var min_range : int = 9999
	for cx in range(0,crea.size.x) :
		for cy in range(0,crea.size.y) :
			for tx in range(0,othercrea.size.x) :
				for ty in range(0,othercrea.size.y) :
					var r : int = GameGlobal.calculate_range_v(Vector2(cx,cy)-Vector2(tx,ty))
					min_range = min(min_range, r)
	return min_range

#ignores terrain
static func get_closest_creas_not_of_side(crea : Creature, notside : int) -> Array :
	var found_creas : Array = []
	var found_range : int = 9999
	for cb in StateMachine.combat_state.all_battle_creatures_btns :
		if cb.creature.curFaction != notside :
			var r : int = get_range_between_creas(crea, cb.creature)
			if r < found_range :
				found_creas.clear()
				found_range = r
			if r == found_range :
				found_creas.append(cb.creature)
	found_creas.shuffle()
	return found_creas
