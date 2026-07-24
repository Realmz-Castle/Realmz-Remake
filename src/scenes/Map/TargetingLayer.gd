extends Node2D
class_name TargetingLayer


const tilepixelsize : Vector2 = Vector2(32,32)

var targetTexture = preload("res://scenes/Map/MapTarget.png")

var map

var is_obstructed : bool = false

var spell
#var spell_chain : Array = []
var power : int = 0
var caster : CombatCreaButton
var used_item: Variant = null

var spell_max_targets : int = 0
var spell_targettile : Spell.TARGET_TILE = Spell.TARGET_TILE.ANY
var picked_targets : Dictionary = {}  #dict of  CombatCreaBUttons : number
var picked_tiles : Dictionary = {}  # dict of  vector2i : number
var spell_aoe : Array[Vector2i] 

#var attrColorDict : Dictionary = {"Fire" : Color.ORANGE, "Ice" : Color.CYAN, "Electric" : Color.MEDIUM_SLATE_BLUE,
	#"Poison" : Color.FOREST_GREEN, "Chemical" : Color.GREEN_YELLOW, "Disease" : Color.YELLOW, "Healing" : Color.WHITE, "Mental" : Color.DEEP_PINK, 
	#"Physical" : Color.LIGHT_CYAN, "Magical" : Color.CORNFLOWER_BLUE}

var aoe_color : Color = Color.LIGHT_GRAY
#var aoe_type : int = 0  #0=no targeting 1=ballb1etc 2=ray 3=wall
var spell_autotarget_type : Spell.AUTOTARGET_TYPE = Spell.AUTOTARGET_TYPE.NONE
var spell_skip_targeting : bool = false
var spell_aoe_los : bool = false
var spell_aoe_ray : bool = false # if true, add spell's ray to the aoe
var spell_allow_rotation : bool = false

var spell_max_range : int = 0

var built_aoe : Array[Vector2i] = [] #the array of all tile positions that are part of the AoE

const OBSTRUCTEDTEXT : String = "Obstructed !"

var mousepos_local : Vector2i = Vector2i.ZERO
var mousepos_world : Vector2i = Vector2i.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	map = get_parent()
	set_process(false)
	hide()
#	print("B2 : ", b2)


#func ensure_connection_with(anode : Node) :
	#print("TargetingLayer ensure connection to "+str(anode.name))
	#if not is_connected("player_spell_confirmed",anode._on_player_spell_signal_received) :
		#print("TargetingLayer connection to "+str(anode.name))
		#player_spell_confirmed.connect(anode._on_player_spell_signal_received)
	

func is_tile_empty(pos : Vector2i) ->bool :	#checks walls
#	print("Targeting is_tile_empty : ", pos)
	var mapsize = GameGlobal.map.map_size
	if pos.x<0 or pos.y<0 or pos.x>=mapsize.x or pos.y>=mapsize.y :
		return false
	var tile : Array = GameGlobal.map.mapdata[pos.x][pos.y]
	for t in tile :
		if t["wall"]!=0 or t["swall"]!=0 :
			return false
	return true

func is_aoe_empty(pos : Vector2i, aoe : Array[Vector2i]) :	#checks walls
#	print("Targeting is_aoe_empty : ", pos,' ',aoe)
	for a in aoe :
		if not is_tile_empty(pos+a) :
			return false
	return true

#called every frame by targeting cb state
func update_targeting()->void:
	#print("TargetingLayer.update_targeting, spell_max_targets", spell_max_targets)
	built_aoe.clear()
	#print("TargetingLayer _process, gamestate is ", StateMachine._state_name)
	
#	if GameState._combat_state == GameGlobal.eCombatStates.unchecked :
#		set_process(false)
#		return
	if spell_skip_targeting : #skip targeting 
		print("spell.spell_skip_targeting is true , skip targeting")
		if spell.autotarget_type == Spell.AUTOTARGET_TYPE.SELF : #self
			#GameGlobal.execute_spell(caster,spell,power,caster.creature.position, b1, {caster : 0}, {}, true, true)
			#var msg : Dictionary = {"type" : "Spell", "caster" : caster, "Effected Tiles" : [], "Effected Creas" : [caster], "targeted_tiles" : [], "spell": spell, "s_plvl" : power, "used_item" : used_item , "add_terrain" : true}
			built_aoe = get_tiles_affected_by_aoe_targeted_at_pos(spell_aoe, caster.creature.position)
			execute_spell(caster,spell,power,built_aoe, used_item, true, [])
			return
		if spell_autotarget_type==Spell.AUTOTARGET_TYPE.ALL_ALLIES or spell_autotarget_type==Spell.AUTOTARGET_TYPE.ALL_ENEMIES or spell_autotarget_type==Spell.AUTOTARGET_TYPE.EVERYONE:
			var caster_faction : int = caster.creature.curFaction
			var targ_faction_picked_tileposes : Array[Vector2i] = []
			match spell_autotarget_type :
				Spell.AUTOTARGET_TYPE.EVERYONE :
					for cb in StateMachine.combat_state.all_battle_creatures_btns :
						targ_faction_picked_tileposes.append(cb.creature.position)
				Spell.AUTOTARGET_TYPE.ALL_ALLIES :
					for cb in StateMachine.combat_state.all_battle_creatures_btns :
						if cb.creature.curFaction == caster_faction : targ_faction_picked_tileposes.append(cb.creature.position)
				Spell.AUTOTARGET_TYPE.ALL_ENEMIES :
					for cb in StateMachine.combat_state.all_battle_creatures_btns :
						if cb.creature.curFaction != caster_faction : targ_faction_picked_tileposes.append(cb.creature.position)

			for t:Vector2i in targ_faction_picked_tileposes :
				built_aoe = merge_aoes(get_tiles_affected_by_aoe_targeted_at_pos(spell_aoe, t), built_aoe)
			print("TargetingLayer  calls execute_spell !")
			execute_spell(caster,spell,power,built_aoe, used_item, true, [Vector2i.ZERO]) 
			return
	
	mousepos_world = get_world_mousepos()
	built_aoe = merge_aoes(get_tiles_affected_by_aoe_targeted_at_pos(spell_aoe, mousepos_world), built_aoe)
	#print("targetinglayer mousepos : ", mousepos, ", caster pos:", caster.creature.position, ", built aoe:", built_aoe)
	
	if StateMachine.state == StateMachine.cb_decide_state :
		if StateMachine.cb_decide_state.is_spell_targeting :
			queue_redraw()

	if Input.is_action_just_pressed("escape") :
		built_aoe.clear()
		StateMachine.cb_decide_state.set_spell_targeting_mode(false, {})
		hide()
		return
	
	if spell_allow_rotation :
		if Input.is_action_just_pressed("RotateAoE") :
			if _same_aoe(spell_aoe, Spell.AoE_WALL_H) :
				spell_aoe=Spell.AoE_WALL_L
			elif _same_aoe(spell_aoe, Spell.AoE_WALL_L) :
				spell_aoe=Spell.AoE_WALL_V
			elif _same_aoe(spell_aoe, Spell.AoE_WALL_V) :
				spell_aoe=Spell.AoE_WALL_J
			elif _same_aoe(spell_aoe, Spell.AoE_WALL_J) :
				spell_aoe=Spell.AoE_WALL_H
	
	if Input.is_action_just_pressed("LeftClick") :
		#var mousepos : Vector2i = get_world_mousepos()
		var who = GameGlobal.who_is_at_tile(mousepos_world)
		var range_mouse : int = GameGlobal.calculate_range_vi( mousepos_world - Vector2i(caster.creature.position) )
#		var mousepos : Vector2i = Vector2i(map.get_local_mouse_position() )
		# targettile_type #0=anywhere 1=creature 2=empty 3=nowall
		print("Targeting mousepos ",mousepos_world )
		if range_mouse>spell_max_range or (spell_aoe_los and is_obstructed) or ((spell_targettile==Spell.TARGET_TILE.EMPTY or spell_targettile==Spell.TARGET_TILE.NOWALL) and is_aoe_empty(mousepos_world, spell_aoe)==false):
			SfxPlayer.stream = NodeAccess.__Resources().sounds_book["target error.wav"]
			SfxPlayer.play()
			return
		if spell_targettile==Spell.TARGET_TILE.EMPTY and who!=null :
			SfxPlayer.stream = NodeAccess.__Resources().sounds_book["target error.wav"]
			SfxPlayer.play()
			return
		#pick a target !
		if spell_max_targets > 0 :
			
			
			
			if who != null and spell_targettile!=Spell.TARGET_TILE.EMPTY :
				print("TargetingLayer target ? ",who.creature.name)
				if picked_targets.has(who) :
					picked_targets.erase(who)
					SfxPlayer.stream = NodeAccess.__Resources().sounds_book["Target Off.wav"]
					SfxPlayer.play()
				else :
					if picked_targets.keys().size() < spell_max_targets :
						picked_targets[who] = picked_targets.keys().size()
						SfxPlayer.stream = NodeAccess.__Resources().sounds_book["Target On.wav"]
						SfxPlayer.play()
					else :
						SfxPlayer.stream = NodeAccess.__Resources().sounds_book["target error.wav"]
						SfxPlayer.play()
			else :
				if spell_targettile!=Spell.TARGET_TILE.CREATURE :  #can target unoccipied tiles
					if picked_tiles.has(mousepos_world) :
						picked_tiles.erase(mousepos_world)
						SfxPlayer.stream = NodeAccess.__Resources().sounds_book["Target Off.wav"]
						SfxPlayer.play()
					else :
						if picked_tiles.keys().size()+picked_targets.keys().size() + StateMachine.cb_decide_state.picked_charas.size() < spell_max_targets :
							picked_tiles[mousepos_world] = picked_tiles.keys().size()
						else :
							SfxPlayer.stream = GameGlobal.cmp_resources.sounds_book["target error.wav"]
							SfxPlayer.play()


	
	if ( StateMachine.cb_decide_state.pleaseconfirmspell or (Input.is_action_just_pressed("LeftClick") and spell_max_targets==0) or (Input.is_action_just_pressed("ValidateTargeting") ) and picked_targets.keys().size()+picked_tiles.keys().size()+ StateMachine.cb_decide_state.picked_charas.size() >0 ) :
		StateMachine.cb_decide_state.pleaseconfirmspell = false
#		print("targetibng blah")
#		if aoe_los and is_obstructed :
#			SfxPlayer.stream = NodeAccess.__Resources().sounds_book["target error.wav"]
#			SfxPlayer.play()
#			return 0
		#var clickedtile : Vector2i = get_world_mousepos()
		hide()
		print("TargetingLayer picked_targets : ", picked_targets, " and picked_tiles", picked_tiles)
		
		#execute_spell(caster : CombatCreaButton,spell,power : int, trgt_tiles : Array, used_item : Dictionary, must_add_terrain : bool)
		var all_picked_tiles : Array = []
		for cb in picked_targets :
			all_picked_tiles.append(cb.creature.position)
		for t in picked_tiles :
			all_picked_tiles.append(t)
		#all_picked_tiles.append(clickedtile)
		#spell_aoe was modified by rotating here.
		var aoe_override : Array = spell_aoe if spell_allow_rotation else []
		#execute_spell(_caster : CombatCreaButton, s_spell, s_power : int, trgt_tiles : Array, spell_used_item : Dictionary, must_add_terrain : bool, override_aoe : Array)
		execute_spell(caster,spell,power,all_picked_tiles, used_item, true, aoe_override)
		return
	return


func _same_aoe(left: Array, right: Array) -> bool:
	if left.size() != right.size():
		return false
	for point: Variant in left:
		if not right.has(Vector2i(point)):
			return false
	return true

#	print(mousepos,', ',caster.creature.position )

func get_world_mousepos()->Vector2i :
#	return map.get_local_mouse_position()/32
#	+ map.get_local_mouse_position()
	var chara =  map.focuscharacter
	var chara_g_pos = chara.global_position
	var chara_l_pos = 32*Vector2(chara.tile_position_x, chara.tile_position_y)
	return ( -(chara_g_pos - chara_l_pos)   + map.get_local_mouse_position() )/32
	#return ( -(caster.global_position - caster.creature.position*32)   + map.get_local_mouse_position() )/32 #+  (map.get_local_mouse_position() - caster.position )


#	var mousepos : Vector2 = map.get_local_mouse_position() + map.focuscharacter.get_pixel_position()
#	var screensize : Vector2 = get_window().get_size()
#	print(" screensize : ", screensize)
#	mousepos = mousepos -screensize/2 +Vector2(160,90) + Vector2(0,0)
##	mousepos = mousepos -screensize/2 +Vector2(160,90) + Vector2(0,10)# ok avec screensize%32==(0,8) #- Vector2(320,180)
#	mousepos = mousepos/32
#	mousepos.x = floor(mousepos.x)
#	mousepos.y = floor(mousepos.y)
#	return Vector2i(mousepos)

func get_wold_pos_from_screen_pos(screen_pos : Vector2) ->Vector2 :
#	var mapfocus_pos : Vector2 = Vector2( map.focuscharacter.tile_position_x, focuscharacter.tile_position_y)
	return ( -(caster.global_position - caster.creature.position*32)   + screen_pos )/32

func _draw() :
	
#	print("TargetingLayer _draw, gamestate is ", GameState._combat_state)
	
	#draw target textures on picked_targets :
	for targ in picked_targets :
		# get position on screen :
		var targpos : Vector2 = targ.global_position
		var targsideoofset : Vector2 = targ.size*0.5-Vector2(8,8)
#		draw_texture(texture: Texture2D, position: Vector2, modulate: Color = Color(1, 1, 1, 1))
		draw_texture(targetTexture, targpos+targsideoofset)
	var campos = Vector2i(GameGlobal.map.cam_x,GameGlobal.map.cam_y)
	for tpos in picked_tiles :
		draw_texture(targetTexture, Vector2(((tpos-campos)*32)+Vector2i(6,6) ) )
	
	
	mousepos_local= Vector2i(map.get_local_mouse_position() ) #+ map.focuscharacter.get_pixel_position()
#	var screensize : Vector2 = get_window().get_size()
#	mousepos = mousepos -screensize/2 +Vector2(160,90)#- Vector2(320,180)
	@warning_ignore("integer_division")
	mousepos_local = mousepos_local/32
#	mousepos = Vector2i(mousepos)
#	var aoecolor : Color

			
	
	var temp_is_obstructed : bool = false
	var obstructed_at : Vector2 = Vector2.ZERO
	
	var tiles_line_array : Array = []
	if spell_aoe_los or spell_aoe_ray :
		tiles_line_array = TargetingLayer.bresenham_line(caster.creature.position, get_world_mousepos(), 0, spell_max_range)

	#var tilev : Vector2 = Vector2(32,32)
	#var aoe_modified_shape = aoe_shape.duplicate()
	#var aoe_type : int = 0  #0=no targeting 1=ballb1etc 2=ray 3=wall
	#if aoe_type==1 or aoe_type==3:
	built_aoe = merge_aoes(built_aoe, spell_aoe)

	if spell_aoe_ray :
		for t in tiles_line_array :
			
			#aoe_modified_shape = GameGlobal.add_ray_to_spell_aoe(aoe_modified_shape, caster, )
			
			var c = Vector2i(t)  - get_world_mousepos()
			var overlaps_caster : bool = false
			for x in range(caster.creature.size.x) :
				for y in range(caster.creature.size.y) :
					if t+Vector2(x,y)== caster.creature.position :
						overlaps_caster = true
			if not built_aoe.has(c) and (not overlaps_caster ) :
				built_aoe.append(c)
				#print('added c : ' , c)
	print("TargetingLayer _draw DBUG  built_aoe ", built_aoe, ", aoe_color:",aoe_color)
	for t in built_aoe :
		var posv : Vector2 =  t - mousepos_world+mousepos_local
		print("mousepos_local : ", mousepos_local, ", mousepos world : ",mousepos_world)
		#posv = Vector2i(10,10)
		draw_rect(Rect2(32*posv,tilepixelsize), aoe_color ,false, 2)


	if spell_aoe_los :
		#● void draw_line(from: Vector2, to: Vector2, color: Color, width: float = -1.0, antialiased: bool = false)
#		var aoecolor = Color.RED if TODO
		#var tiles_line_array : Array = bresenham_line(caster.creature.position, get_world_mousepos(), 0, max_range)
#		print("Targeting bresentham : ",tiles_line_array)
		for ts_pos in tiles_line_array :
			var tilestack : Array = map.mapdata[ts_pos.x][ts_pos.y]
			for tiledict in tilestack :
#				print(tiledict)
				if tiledict["blkproj"]==1 :
					temp_is_obstructed = true
			if temp_is_obstructed :
				obstructed_at = ts_pos
				break
		is_obstructed = temp_is_obstructed
		
		var line_color : Color = Color.DARK_RED if is_obstructed else Color.WHITE
		draw_line(caster.global_position+0.5*caster.size, mousepos_local*32+Vector2i(16,16), line_color, 1, true )

	else :
		var wmousepos = get_world_mousepos()
		# targettile_type #0=anywhere 1=creature 2=empty 3=nowall
		if ((spell_targettile!=Spell.TARGET_TILE.EMPTY or spell_targettile!=Spell.TARGET_TILE.NOWALL) ) :
			var aoe_modified_shape = []
			#var mouseworldpos : Vector2i = get_world_mousepos()
			for t in spell_aoe :
				aoe_modified_shape.append( wmousepos + t)
			var cbs_touching : Array = get_cbs_touching_tiles(aoe_modified_shape)
			#print("targetinglayer cbs_touching ", cbs_touching)
			if is_aoe_empty(wmousepos, spell_aoe)==false or (spell_targettile!=Spell.TARGET_TILE.EMPTY and cbs_touching.size()>0 ) :
				is_obstructed = true
				obstructed_at = wmousepos
#			get_parent().debuglabel.text+=str(obstructed_at)
		#else :
			#is_obstructed = false
	
	if is_obstructed :
		
		var obstextpos : Vector2 = (caster.global_position - caster.creature.position*32)+(obstructed_at*32)
#			print(obstructed_at, obstextpos)
		
		draw_rect(Rect2(obstextpos,Vector2(32,32)), Color.DARK_RED ,false, 2)
#			draw_line(obstextpos+Vector2(16,16),mousepos*32+Vector2i(16,16) , Color.RED, 3, true )
		draw_string_outline(ThemeDB.fallback_font, obstextpos-Vector2(16,0), OBSTRUCTEDTEXT, HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size ,4, Color.BLACK )
		draw_string(ThemeDB.fallback_font, obstextpos-Vector2(16,0), OBSTRUCTEDTEXT, HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size , Color.RED )

	var range_mouse : int = GameGlobal.calculate_range_vi( get_world_mousepos() - Vector2i(caster.creature.position) )
	var rangetext : String = str(range_mouse)+'/'+str(spell_max_range)
	var rangecolor = Color.WHITE if range_mouse<=spell_max_range else Color.RED
	var rangetextpos : Vector2 = 32*mousepos_local - Vector2i(8,0)
#	draw_string(font: Font, pos: Vector2, text: String, alignment: HorizontalAlignment = 0, width: float = -1, font_size: int = 16, modulate: Color = Color(1, 1, 1, 1), jst_flags: JustificationFlag = 3, direction: Direction = 0, orientation: Orientation = 0) const
	#draw_string_outline(font: Font, pos: Vector2, text: String, alignment: HorizontalAlignment = 0, width: float = -1, font_size: int = 16, size: int = 1, modulate: Color = Color(1, 1, 1, 1), jst_flags: JustificationFlag = 3, direction: Direction = 0, orientation: Orientation = 0) const
	draw_string_outline(ThemeDB.fallback_font, rangetextpos, rangetext, HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size ,4, Color.BLACK )
	draw_string(ThemeDB.fallback_font, rangetextpos, rangetext, HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size , rangecolor )


func get_tiles_affected_by_aoe_targeted_at_pos(aoe : Array[Vector2i], pos : Vector2i) -> Array[Vector2i] :
	var returned_aoe : Array[Vector2i] = []
	for p : Vector2i in aoe :
		returned_aoe.append(p+pos)
	return returned_aoe

func merge_aoes(aoe_1:Array[Vector2i], aoe_2:Array[Vector2i] ) -> Array[Vector2i] :
	var returned_aoe : Array[Vector2i] = []
	for t1 : Vector2i in aoe_1 :
		if not aoe_2.has(t1) :
			returned_aoe.append(t1)
	return returned_aoe


func start_targ(
	tspell: Spell,
	tspellpower: int,
	tcaster: CombatCreaButton,
	_used_item: Variant,
) -> void:
	print("TargetingLayer start_targ ", tspell.name)
	picked_targets.clear()
	picked_tiles.clear()
	built_aoe.clear()
	spell = tspell
	caster = tcaster #is a CombatCreaButton
	power = tspellpower
	spell_max_range = spell.get_range(power, caster.creature)
	spell_targettile = spell.targettile
	spell_aoe_los = spell.los
	spell_aoe_ray = spell.ray
	spell_allow_rotation = spell.rot
	spell_autotarget_type = spell.autotarget_type
	spell_max_targets = spell.get_target_number(power, caster.creature)
	spell_aoe = spell.get_aoe(power, caster.creature)
	aoe_color = spell.get_spell_dominant_color()
	show()
	set_process(true)
#	var mousepos : Vector2 = map.get_local_mouse_position()





static func bresenham_line(startpt : Vector2, endpt : Vector2, min_range : int, p_max_range : int) -> Array :
	# returns an array of all the tiles on the line between startpt and endpt, starting from startpt.
	var returned : Array = []
	
	if abs(endpt.y-startpt.y) < abs(endpt.x-startpt.x) :
		# if  |slope| < 1
		if startpt.x > endpt.x :
			returned = plotLineLow(endpt, startpt, true)
#			print("gauche !")
		else :
			returned = plotLineLow(startpt, endpt, false)
#			print("droite !")
	else :
		# if  |slope| > 1
		if startpt.y > endpt.y :
			returned = plotLineHigh(endpt, startpt, true)
#			print("haut !")
		else :
			returned = plotLineHigh(startpt, endpt, false)

#	returned = [startpt, endpt]
	if min_range>0 :
		returned.pop_front()  # remove the tile where the user is !
		returned.resize(min(returned.size(),p_max_range))
	else :
		returned.resize(min(returned.size(),p_max_range+1))
	if returned.is_empty() :
		print("RETUNRED EMPTY !")
	return returned


static func plotLineLow(startpt : Vector2, endpt : Vector2, reverseorder : bool) -> Array :
	# bresenham for  |slope| <1
	var returned : Array = []
	var dx : int = int(endpt.x - startpt.x)
	var dy : int = int(endpt.y - startpt.y)
	var yi : int = 1
	if dy < 0 :
		yi = -1
		dy = -dy
	var D : int = (2 * dy) - dx
	var y = startpt.y
	for x in range(startpt.x, endpt.x+1) :
		returned.append(Vector2(x,y))
		if D > 0 :
			y = y + yi
			D = D + 2* (dy - dx)
		else :
			D = D + 2*dy
	if reverseorder :
		returned.reverse()
#	print("returning ", returned)
	return returned


static func plotLineHigh(startpt : Vector2, endpt : Vector2, reverseorder : bool) -> Array :
	# bresenham for  |slope| >1
	var returned : Array = []
	var dx : int = int(endpt.x - startpt.x)
	var dy : int = int(endpt.y - startpt.y)
	var xi : int = 1
	if dx < 0 :
		xi = -1
		dx = -dx
	var D : int = (2 * dx) - dy
	var x = startpt.x
	for y in range(startpt.y, endpt.y+1) :
		returned.append(Vector2(x,y))
		if D > 0 :
			x = x + xi
			D = D + 2* (dx - dy)
		else :
			D = D + 2*dx
	if reverseorder :
		returned.reverse()
	return returned

func get_tiles_under_cb(cb : CombatCreaButton) -> Array[Vector2i] :
	var returned_array : Array = []
	var crea = cb.creature
	for x in range(crea.size.x) :
		for y in range(crea.size.y) :
			returned_array.append(Vector2i(crea.position)+Vector2i(x,y))
	return returned_array

func get_affected_tiles(s_spell : Spell, s_power : int, s_caster : CombatCreaButton, s_targeted_pos : Vector2, _s_aoe_override = []) ->Array :
	#FOR USE BY CbAnimationState !
	
	var s_max_range : int = s_spell.get_range(s_power, s_caster.creature)
	var s_aoe_los = s_spell.los
	var s_aoe_ray : bool = s_spell.ray
	var tiles_line_array : Array = []
	if s_aoe_ray or s_aoe_los :
		tiles_line_array = bresenham_line(s_caster.creature.position,s_targeted_pos, 0, s_max_range)
		tiles_line_array.erase(s_caster.creature.position)
	if s_aoe_los :
		#print("   get_spell_affected_creas   caster : ", s_caster)
		for ts_pos in tiles_line_array :
			var tilestack : Array = map.mapdata[ts_pos.x][ts_pos.y]
			for tiledict in tilestack :
#				print(tiledict)
				if tiledict["blkproj"]==1 :
					return []
	var s_spell_aoe : Array[Vector2i] = s_spell.get_aoe(s_power, s_caster.creature)
	#if rotation >= 0 and s_spell.rot :		#TODO  doesn't rotate walls for AI casts yet
		#s_spell_aoe_name = ["wh", "wl", "wv", "wj"][rotation]
	#var s_aoe_type : int = 9999 #0=no targeting 1=ballb1etc 2=ray 3=wall


	var returned_array : Array[Vector2i] = []

	if s_spell.skip_targeting :
		if s_spell.autotarget_type == Spell.AUTOTARGET_TYPE.SELF : #self
			return get_tiles_under_cb(s_caster)
	
	var s_spell_autotarget_type = s_spell.autotarget_type
	
	if s_spell_autotarget_type==Spell.AUTOTARGET_TYPE.ALL_ALLIES or s_spell_autotarget_type==Spell.AUTOTARGET_TYPE.ALL_ENEMIES or s_spell_autotarget_type==Spell.AUTOTARGET_TYPE.EVERYONE:
		var caster_faction : int = s_caster.creature.curFaction
		var targ_faction_picked_tileposes : Array[Vector2i] = []
		match spell_autotarget_type :
			Spell.AUTOTARGET_TYPE.EVERYONE :
				for cb in StateMachine.combat_state.all_battle_creatures_btns :
					targ_faction_picked_tileposes.append(cb.creature.position)
			Spell.AUTOTARGET_TYPE.ALL_ALLIES :
				for cb in StateMachine.combat_state.all_battle_creatures_btns :
					if cb.creature.curFaction == caster_faction : targ_faction_picked_tileposes.append(cb.creature.position)
			Spell.AUTOTARGET_TYPE.ALL_ENEMIES :
				for cb in StateMachine.combat_state.all_battle_creatures_btns :
					if cb.creature.curFaction != caster_faction : targ_faction_picked_tileposes.append(cb.creature.position)

		for t:Vector2i in targ_faction_picked_tileposes :
			returned_array = merge_aoes(get_tiles_affected_by_aoe_targeted_at_pos(s_spell_aoe, t), returned_array)
		return returned_array
	
	else :
	#if s_aoe_type==1 :
		if s_aoe_ray :
			for c in tiles_line_array :
				returned_array.append(c)
	
		for c in s_spell_aoe :
			var pos : Vector2 = s_targeted_pos+Vector2(c)
			if not returned_array.has(pos) :
				returned_array.append(pos)
	return returned_array
	
#must be used for each target. Used by AI for testing !
# returns an array of all the affected creatures
#ROTATION SHULD BE -1 IF NOT A ROTATABLE SPELL
func get_cbs_touching_tiles(effected_tiles : Array) -> Array:
	var returned_array : Array= []
	#print(" TGLAYER get_cbs_touching_tiles effected_tiles ", effected_tiles)
	for pos in effected_tiles :
		
		var cb = GameGlobal.who_is_at_tile(pos)
		if is_instance_valid(cb) :
			if not returned_array.has(cb) :
				returned_array.append(cb)
	return returned_array


#old gameglobal execute : (caster : CombatCreaButton,spell,power : int ,clickedtile : Vector2i, aoe_shape : Array, picked_targets : Dictionary, picked_tiles:Dictionary, chain_start : bool, must_add_terrain : bool) :
#msg frmat : {"type" : "Spell", "caster" : Crea, "Effected Tiles" : [], "Effected creas" : [], "targeted_tiles" : [], "spell":GDScript, "s_plvl" : 1, "used_item" : null , "add_terrain" : true}

func execute_spell(
	_caster: CombatCreaButton,
	s_spell,
	s_power: int,
	trgt_tiles: Array,
	spell_used_item: Variant,
	must_add_terrain: bool,
	override_aoe: Array,
) -> void:
	#"Override AoE is for wall rotations
	#print("TargetingLayer execute_spell : "+s_spell.name+" trgt_tiles : ", trgt_tiles)
	#print("TargetingLayer aoe_shape ", aoe_shape)
	var msg : Dictionary = {"type" : "Spell", "spell" : s_spell, "s_plvl" : s_power, "targeted_tiles" : trgt_tiles, "used_item" : spell_used_item , "must_add_terrain" : must_add_terrain, "override_aoe" : override_aoe }
	StateMachine.state.on_spellcast_confirmed(msg)
