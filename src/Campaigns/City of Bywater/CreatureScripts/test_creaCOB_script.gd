extends Object

#const target_pos : Vector2i = Vector2i(51,87)

# returns : depends of  fint int in array :
#  [0]==0 means  walk in  the direction Vector2i  at  [1]
#  [1, selectedSpell, selectedplvl, spell_target_pos].......aoe_shape : Array, picked_targets : Dictionary, picked_tiles:Dictionary, chain_start : bool, must_add_terrain : bool)
static func decide_action(crea : Creature) -> Array :
	print("test_crea_script decide_action : "+crea.name)
	
	if crea.get_apr_left() <= 0 :
		print("ai decideaction : crea.get_apr_left() <= 0 : "+str(crea.get_apr_left())  )
		return [0, Vector2i.ZERO ]
	
	var missile_chance : int = int(crea.ai_variables["missile_chance"]) # 100  is 100%
	var cast_chance : int = int(crea.ai_variables["cast_chance"])
	var flees_at : int = crea.ai_variables["flees_at"]
	var target_crea = find_target_crea(crea)
	var targ_range : int = AiFunctions.get_range_between_creas(crea, target_crea)
	
	printerr(missile_chance,' ',cast_chance,' ',flees_at,' ',target_crea.name,' ',targ_range)
	
	print("TestCreaScript "+crea.name+' tg is '+target_crea.name+ " targ_range : " + str(targ_range))
	
	#if have a target and it's close enough, walk to it and attack
	if target_crea :
		var target_pos : Vector2 = target_crea.position
		if targ_range<=crea.get_movement_left()*3 and int(crea.ai_variables["cast_chance"])<randi_range(0,100) :
			var path : Array = GameGlobal.map.find_path(crea.position, target_pos, true, false, false, crea, true)
			print("TestCreaScript "+crea.name+' path size is ', path.size() )

			if path.size() > 1 :
				print("ai decideaction : "+crea.name+" 's path is : "+str(path.size())+' long')
				return [0,Vector2i(path[1])-Vector2i(crea.position) ]
		else :
			# CAST MAGIC or use bow !!!
			print("test_crea_script.gd "+crea.name+" considers using item or maguc")
			#print(crea.inventory)
			var spell_target_pos : Vector2 = target_pos
			var sp_left = crea.get_stat("curSP")
			var allspellsArray : Array = crea.get_all_spells()
			if not crea.can_cast_spells():
				allspellsArray.clear()
			if allspellsArray.size()>0 :
				allspellsArray.shuffle()
			#var allitemspellsArray : Array = []  # array of [spellname : String, spellevel : int]
			var allitemswspellsArray : Array = []
			for i: ItemInstance in crea.inventory_instances():
				var definition := NodeAccess.__Resources().get_item_definition(i)
				if definition != null \
						and not definition.spell_use("combat").is_empty() \
						and (
							definition.maximum_charges == 0
							or i.charges > 0
						):
					allitemswspellsArray.append(i)
			if allitemswspellsArray.size()>0 :
				allitemswspellsArray.shuffle()
			var selectedSpell = null
			var selectedplvl : int = 0
			
			var randint : int = randi_range(0,100)
			var want_use_item : bool = missile_chance>randint and allitemswspellsArray.size()>0
			var want_use_spell : bool =  cast_chance>randint and allspellsArray.size()>0
			var ignore_cost : bool = false
			var used_an_item : bool = false
			var item_used: ItemInstance = null
			print("test crea script.gd want_use_item ? ", want_use_item, " , missile_chance :", missile_chance, '  , randint : ', randint)
			if want_use_item :
				#var weapon_spell_arr : Array =  crea.current_range_weapon["_on_combat_use_spell"]
				item_used = allitemswspellsArray[0]
				var item_spell_use := (
					NodeAccess.__Resources().item_spell_use(item_used, "combat")
				)
				var item_spell_name: String = item_spell_use[0]
				selectedSpell = NodeAccess.__Resources().spells_book[item_spell_name]["script"]
				selectedplvl = item_spell_use[1]
				ignore_cost = true
				used_an_item = true
			if want_use_spell :
				selectedSpell = allspellsArray[0]["script"]
				selectedplvl  = randi_range(1,7)
			if not (want_use_item or want_use_spell) :
				print("test crea script.gd decideaction : "+crea.name+" wants to do nothing")
				return [0, Vector2i.ZERO ]
			
			#var spell_cast_message :  Array = [0, Vector2i.ZERO ]
			if crea.get_spell_resource_cost(selectedSpell,selectedplvl)>=sp_left or ignore_cost :
				print("test crea script.gd going to get_spell_cast_message")
				var spell_cast_message : Array = get_spell_cast_message(crea, selectedSpell,selectedplvl, target_crea, used_an_item, item_used)
				return spell_cast_message
	print("decideaction : "+crea.name+" can do nothing")
	return [0, Vector2i.ZERO ]
	
static func get_spell_cast_message (caster: Creature, spell, plvl : int, target_crea: Creature, used_an_item : bool, item_used: ItemInstance) :
	var targ_range : int = AiFunctions.get_range_between_creas(caster, target_crea)
	print(spell.name,plvl, ' ',spell.get_range(plvl, caster) , '<=>' ,targ_range)
	if spell.get_range(plvl, caster) >= targ_range :
		var affected_tiles : Array = GameGlobal.map.targetingLayer.get_affected_tiles(spell, plvl, caster.combat_button, target_crea.position, [])
		var affected_creas : Array = GameGlobal.map.targetingLayer.get_cbs_touching_tiles(affected_tiles)
		if affected_creas.size()>0 :
			print("Test_Crea_Script.gd : "+caster.name + "'s spell hits at least "+ target_crea.name )
		var aoe_shape = spell.get_aoe(plvl, caster)
		return [1, spell, plvl, target_crea.position, aoe_shape, item_used,Vector2i(target_crea.position), affected_tiles, affected_creas]
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
	



#useful for bigger creatures !
# ignores terrain


#ignores terrain



static func find_target_crea(crea : Creature) :
	var tg_crea = null
	if crea.creature_script_memory.has("target_crea") :
		tg_crea = crea.creature_script_memory["target_crea"]
	
	#check if  target_crea is next to me, else find closest one :
	var is_targ_next_to_crea : bool = false
	if is_instance_valid(tg_crea) :
		if is_instance_valid(tg_crea.combat_button) :
			is_targ_next_to_crea = AiFunctions.get_range_between_creas(crea, tg_crea)<=1
		else :
			tg_crea = null
	else :
		var closest_enemies : Array = AiFunctions.get_closest_creas_not_of_side(crea, crea.curFaction)
		if not closest_enemies.is_empty():
			tg_crea = closest_enemies[0]
		else :
			tg_crea = null
	return tg_crea
