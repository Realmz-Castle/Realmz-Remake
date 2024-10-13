extends State
class_name CombatState

#var spell_picked_tiles : Dictionary

const combatcreaturemapobjectTSCN : PackedScene = preload("res://scenes/Map/CombatCharacter.tscn")
@export var cbanimstate : CbAnimationState


var cur_battle_round : int = 0

var cur_battle_data : Dictionary = {}

var all_battle_creatures_btns : Array = []	#array of  combatcreabuttons
var battle_creatures_yet_to_act_btns : Array = []#array of  combatcreabuttons
var battle_allows_loss : bool = false
var battle_dead_enemies : Array = []
var battle_dead_party_members : Array = []

#var pcs_who_joined_battle : Array = []  #is in bartle data dict

var action_queue : Array = []

#signal battle_end

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


#func _state_process(delta : float) -> void :
	#pass


func get_selected_character_combatbutton() :
	for cb in battle_creatures_yet_to_act_btns :
		if is_instance_valid(cb) :
			if cb.creature == UI.ow_hud.selected_character :
				return cb
	print("Combat State ERROR CANT FIND SELECTER CHARACTER'S COMBATCREABUTTON")
	return null



func is_map_tile_walkable_by_char(chara : Creature, pos : Vector2)->bool : #battle mode, chara is creature
#	print("gamestate is_map_tile_walkable_by_char ",  chara.name, " ,pos: ", pos)
#	print("is_map_tile_walkable_by_char TODO check character itself :")
#	print("map.mapdata[pos.x][pos.y]", map.mapdata[pos.x][pos.y])
	
	var tileitemlightstack : Array = GameGlobal.map.mapdata[pos.x][pos.y]
	if tileitemlightstack.is_empty() :
		return false
	var tilestack : Array = tileitemlightstack
	var stacksize = tilestack.size()
#	print("canc char walk, tilestack : ", tilestack)
#	print("tilestack : ", tilestack)
	for i  in range(stacksize) :
		var tiledict : Dictionary = tilestack[stacksize-i-1]
		var idef = tiledict#tiles_book[]
		if idef['wall'] != 0 or  (idef['swall'] != 0 and chara.size == Vector2.ONE):
			return false
	return true



	

func find_pos_for_crea_on_battlefield(crea : Creature, coords : Vector2, _is_failure_ok : bool, max_move_attempts : int, max_los_attempts : int) ->Vector2 :
	var move_attempts : int = 0
	var los_attempts : int = 0
#	var max_los_attempts : int = player_characters.size()*100
	var is_los : bool = true
	var pos = Vector2(coords)
	while not (is_map_tile_walkable_by_char(crea, pos) and GameGlobal.who_is_at_tile(pos)==null and is_los):
			pos = pos + GameGlobal.UDLR[randi_range(0,3)]
			var whodere = GameGlobal.who_is_at_tile(pos)
			var whoname = 'nobody'
			if whodere != null :
				whoname = whodere.name
			
			is_los = check_los(coords, pos)
			print("GameGlobal place_crea_on_battlefield "+crea.name+" pos : ", pos, "who there : ",whoname)
			if move_attempts > max_move_attempts :
				move_attempts = 0
				pos = coords
				print("  reset pos")
			los_attempts +=1
			if los_attempts > max_los_attempts :
				is_los = true
				max_move_attempts +=1
	return pos


func check_los(fromV : Vector2, toV : Vector2) -> bool :
	var tiles_line_array : Array = GameGlobal.map.targetingLayer.bresenham_line(fromV,toV, 0, 500)
#		print("Targeting bresentham : ",tiles_line_array)
	#var _breakagain : bool = false
	for ts_pos in tiles_line_array :
		#_breakagain = false
		var tilestack : Array = GameGlobal.map.mapdata[ts_pos.x][ts_pos.y]
		for tiledict in tilestack :
			if tiledict["wall"]==1 or tiledict["swall"]==1:
				return false
	return true



func add_pc_or_npc_ally_to_battle_map(crea : Creature, init_pos : Vector2) -> bool:
	if crea.get_stat("curHP")<=0 or (not crea.joins_combat):
		return false
	var _move_attempts : int = 0
	var max_move_attempts = GameGlobal.player_characters.size()+1 #how far from initpos the PC can spawn
	var _los_attempts : int = 0
	var max_los_attempts : int = GameGlobal.player_characters.size()*100
	var _is_los : bool = true
	var pos : Vector2 = find_pos_for_crea_on_battlefield(crea, init_pos, false, max_move_attempts, max_los_attempts)
	crea.position = pos
	crea.creature_script_memory.clear()
	#todo look for empty spots instead
	var pc_mapb = combatcreaturemapobjectTSCN.instantiate()
	GameGlobal.map.creatures_node.add_child(pc_mapb)
	crea.combat_button = pc_mapb
	all_battle_creatures_btns.append(pc_mapb)
	#print("cbstate all_battle_creatures_btns size : ", all_battle_creatures_btns.size())
	pc_mapb.set_creature_represented(crea)
	pc_mapb.bgsprite.hide()
	return true

func remove_cb_from_battle(cb) ->void :  #do this in   CbAnimState !
	cb.queue_free()
	all_battle_creatures_btns.erase(cb)
	battle_creatures_yet_to_act_btns.erase(cb)

func add_to_action_queue(arr : Array) :
	if not arr.is_empty() :
		pass
		action_queue = arr + action_queue




func on_trying_to_move_to_position(crea : Creature, position : Vector2, notreally : bool = false) : #exporation mode
	var canwalk : bool = true
	
	var soundfound : bool = false
	var soundslist : Array = []

	var timetowalk : int = 999999
	var idef : Dictionary = {}
	
	for x in range(crea.size.x) :
		for y in range(crea.size.y) :
			var tilestack : Array = GameGlobal.map.mapdata[position.x+x][position.y+y]
			var stacksize : int = tilestack.size()
			var canwalkxy : bool = true
			var timetowalkxy : int = 999999
			for i  in range(stacksize) :
				idef = tilestack[stacksize-i-1]
				canwalkxy = not ( idef['wall'] != 0 or (idef['swall'] != 0 and crea.size==Vector2.ONE) )
				timetowalkxy =  crea.get_mp_cost_for_tile_stack(tilestack)
				canwalk = canwalk and canwalkxy
				timetowalk = min(timetowalk, timetowalkxy)
				if not soundfound and idef['sound'] != [] :
					soundfound = true
					soundslist = idef['sound']
	if notreally :
		return [canwalk, timetowalk ]
	# check for scripts checked the map :
	var canwalk_path : bool = GameGlobal.map.mapsecretpaths.has(Vector2i(position))
	var canwalk_secret : bool = false
	if GameGlobal.map.mapsecrets.has(Vector2i(position)) :
		if GameGlobal.map.mapsecrets[Vector2i(position)][0]== 1 :
			canwalk_secret  = true
	
	canwalk = (canwalk or canwalk_path or canwalk_secret) 
	if canwalk :
		
		if canwalk_path :
			GameGlobal.map.set_secretpath_seen( Vector2i(position) )
		if canwalk_secret :
			GameGlobal.map.set_secret_seen( Vector2i(position) )

	soundslist.shuffle()
	SfxPlayer.stream = GameGlobal.cmp_resources.sounds_book[soundslist[0]]
	SfxPlayer.play()

	return [canwalk, timetowalk ]








func check_battle_end() -> String :	 # '':continue 'won'  'fled' lost
	var all_pc_dead : bool = true
	print('cur_battle_data["pc_participating"]  \n ', cur_battle_data["pc_participating"])
	#print("cbstate pc participating : ", cur_battle_data["pc_participating"].size())
	for crea : Creature in cur_battle_data["pc_participating"] :
		#var life_status : int = 0  #0=fine  1=ko'd bleeding 2=ko'd bandaged 3=dead
		if crea.life_status == 0 and crea.curFaction==0 and crea.joins_combat :
			all_pc_dead = false
			break
	#if cur_battle_data["pc_participating"].is_empty() :
		#all_pc_dead = true
	print("all_pc_dead : ", all_pc_dead)
	if all_pc_dead :
		return "lost"
	var all_pc_dead_or_fled : bool = true
	for crea : Creature in cur_battle_data["pc_participating"] :
		if (not(crea.fled_battle or crea.life_status > 0)) and crea.curFaction==0 :
			all_pc_dead_or_fled = false
			break
	if all_pc_dead_or_fled :
		return "fled"
	for cb in all_battle_creatures_btns :
		if cb.creature.curFaction != 0 :
			return ''
	return "won"
