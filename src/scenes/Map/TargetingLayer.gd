extends Node2D
class_name TargetingLayer


var targetTexture = preload("res://scenes/Map/MapTarget.png")

var map

var is_obstructed : bool = false

var spell
#var spell_chain : Array = []
var power : int = 0
var caster : CombatCreaButton
var used_item : Dictionary = {}

var max_targets : int = 0

var picked_targets : Dictionary = {}  #dict of  CombatCreaBUttons : number
var picked_tiles : Dictionary = {}  # dict of  vector2i : number
var spell_aoe_name : String = 'b1'
var b1 : Array = [Vector2i(0,0)]
var b2 : Array = b1 + [Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0)]
var b3 : Array = b2 + [Vector2i(1,-1),Vector2i(1,1),Vector2i(-1,1),Vector2i(-1,-1)]
var b4 : Array = b3 + [Vector2i(0,-2),Vector2i(2,0),Vector2i(0,2),Vector2i(-2,0)]
var b5 : Array = b4 + [Vector2i(1,-2),Vector2i(2,-1),Vector2i(2,1),Vector2i(1,2), Vector2i(-1,2),Vector2i(-2,1),Vector2i(-2,-1),Vector2i(-1,-2)]
var b6 : Array = b5 + [Vector2i(0,-3),Vector2i(3,0),Vector2i(0,3),Vector2i(-3,0)]
var b7 : Array = b6 + [Vector2i(1,-3),Vector2i(2,-2),Vector2i(3,-1), Vector2i(3,1),Vector2i(2,2),Vector2i(1,3), Vector2i(-1,3),Vector2(-2,2),Vector2(-3,1), Vector2(-3,-1),Vector2(-2,-2),Vector2(-1,-3)]
var wh : Array = [Vector2i(0,0),Vector2i(-1,0),Vector2i(1,0),Vector2i(-2,0),Vector2i(2,0),Vector2i(-3,0),Vector2i(3,0),
				Vector2i(0,-1),Vector2i(-1,-1),Vector2i(1,-1),Vector2i(-2,-1),Vector2i(2,-1),Vector2i(-3,-1),Vector2i(3,-1)]
var wv : Array = [Vector2i(0,0),Vector2i(0,-1),Vector2i(0,1),Vector2i(0,-2),Vector2i(0,2),Vector2i(0,-3),Vector2i(0,3),
				Vector2i(1,0),Vector2i(1,-1),Vector2i(1,1),Vector2i(1,-2),Vector2i(1,2),Vector2i(1,-3),Vector2i(1,3) ]
var wj : Array = [Vector2i(0,0),Vector2i(-1,-1),Vector2i(1,1),Vector2i(-2,-2),Vector2i(2,2),Vector2i(-3,-3),Vector2i(3,3),
					Vector2i(0,1),Vector2i(-1,-0),Vector2i(1,2),Vector2i(-2,-1),Vector2i(2,3),Vector2i(-3,-2)]
var wl : Array = [Vector2i(0,0),Vector2i(1,-1),Vector2i(-1,1),Vector2i(2,-2),Vector2i(-2,2),Vector2i(3,-3),Vector2i(-3,3),
					Vector2i(0,1),Vector2i(1,-0),Vector2i(-1,2),Vector2i(2,-1),Vector2i(-2,3),Vector2i(3,-2)]
var cr : Array = b3+b4
var bdict : Dictionary = {"b1":b1, "b2":b2,"b3":b3,"b4":b4,"b5":b5,"b6":b6,"b7":b7,"wh":wh,"wv":wv,"wj":wj,"wl":wl , 'cr':cr}

var attrColorDict : Dictionary = {"Fire" : Color.ORANGE, "Ice" : Color.CYAN, "Electric" : Color.MEDIUM_SLATE_BLUE,
	"Poison" : Color.FOREST_GREEN, "Chemical" : Color.GREEN_YELLOW, "Disease" : Color.YELLOW, "Healing" : Color.WHITE, "Mental" : Color.DEEP_PINK, 
	"Physical" : Color.LIGHT_CYAN, "Magical" : Color.CORNFLOWER_BLUE}

var aoe_color : Color = Color.LIGHT_GRAY
var aoe_type : int = 0  #0=no targeting 1=ballb1etc 2=ray 3=wall
var aoe_shape : Array = [] # for bi shapes
var aoe_los : bool = false
var aoe_ray : bool = false # if true, add spell's ray to the aoe
var allow_rotation : bool = false

var max_range : int = 0

const OBSTRUCTEDTEXT : String = "Obstructed !"

signal player_spell_confirmed


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

func is_aoe_empty(pos : Vector2i, aoe : Array) :	#checks walls
#	print("Targeting is_aoe_empty : ", pos,' ',aoe)
	for a in aoe :
		if not is_tile_empty(pos+a) :
			return false
	return true

#called every frame by targeting cb state
func update_targeting()->void:
	
	#print("TargetingLayer _process, gamestate is ", StateMachine._state_name)
	
#	if GameState._combat_state == GameGlobal.eCombatStates.unchecked :
#		set_process(false)
#		return
	if aoe_type==0 : #skip targeting 
		print("TargetIng Layer aoe_type 0 , skip targeting")
		if spell_aoe_name == "sf" : #self
			#GameGlobal.execute_spell(caster,spell,power,caster.creature.position, b1, {caster : 0}, {}, true, true)
			var msg : Dictionary = {"type" : "Spell", "caster" : caster, "Effected Tiles" : [], "Effected Creas" : [caster], "targeted_tiles" : [], "spell": spell, "s_plvl" : power, "used_item" : used_item , "add_terrain" : true}
			execute_spell(caster,spell,power,[caster.creature.position], used_item, true, [])
			return
		if spell_aoe_name=="af" or spell_aoe_name=="ae" or spell_aoe_name=="eo":
			aoe_shape=get_aoe_from_name('b1')
			var  targ_factions = []
			if spell_aoe_name=="af" or spell_aoe_name=="eo":
				targ_factions.append(0)
			if spell_aoe_name=="ae" or spell_aoe_name=="eo":
				targ_factions.append(1)
			var picked_tiles : Array = []
			for cb in StateMachine.combat_state.all_battle_creatures_btns :
				if targ_factions.has(cb.creature.curFaction) :
					picked_tiles.append(cb.creature.position)
			print("TargetingLayer  calls execute_spell !")
			#execute_spell(caster : CombatCreaButton,spell,power : int, trgt_tiles : Array, used_item : Dictionary, must_add_terrain : bool)
			execute_spell(caster,spell,power,picked_tiles, used_item, true, [])
			return
		
	if StateMachine.state == StateMachine.cb_decide_state :
		if StateMachine.cb_decide_state.is_spell_targeting :
			queue_redraw()
	var targettile_type : int = 0
	if spell.get("targettile")  : #0=anywhere 1=creature 2=empty 3=nowall 
		targettile_type = spell.targettile
	
	if Input.is_action_just_pressed("escape") :
		aoe_type = 0
		StateMachine.cb_decide_state.set_spell_targeting_mode(false, {})
		hide()
		return
	
	if allow_rotation :
		if Input.is_action_just_pressed("RotateAoE") :
			if aoe_shape==wh :
				aoe_shape=wl
			elif aoe_shape==wl :
				aoe_shape=wv
			elif aoe_shape==wv :
				aoe_shape=wj
			elif aoe_shape==wj :
				aoe_shape=wh
	
	if Input.is_action_just_pressed("LeftClick") :
		var mousepos : Vector2i = get_world_mousepos()
		var who = GameGlobal.who_is_at_tile(mousepos)
		var range : int = GameGlobal.calculate_range_vi( mousepos - Vector2i(caster.creature.position) )
#		var mousepos : Vector2i = Vector2i(map.get_local_mouse_position() )
		# targettile_type #0=anywhere 1=creature 2=empty 3=nowall
		print("Targeting mousepos ",mousepos )
		if range>max_range or (aoe_los and is_obstructed) or ((targettile_type==2 or targettile_type==3) and is_aoe_empty(mousepos, aoe_shape)==false):
			SfxPlayer.stream = NodeAccess.__Resources().sounds_book["target error.wav"]
			SfxPlayer.play()
			return
		if targettile_type==2 and who!=null :
			SfxPlayer.stream = NodeAccess.__Resources().sounds_book["target error.wav"]
			SfxPlayer.play()
			return
		#pick a target !
		if max_targets > 0 :
			
			
			
			if who != null and targettile_type!=2 :
				print("TargetingLayer target ? ",who.creature.name)
				if picked_targets.has(who) :
					picked_targets.erase(who)
					SfxPlayer.stream = NodeAccess.__Resources().sounds_book["Target Off.wav"]
					SfxPlayer.play()
				else :
					if picked_targets.keys().size() < max_targets :
						picked_targets[who] = picked_targets.keys().size()
						SfxPlayer.stream = NodeAccess.__Resources().sounds_book["Target On.wav"]
						SfxPlayer.play()
					else :
						SfxPlayer.stream = NodeAccess.__Resources().sounds_book["target error.wav"]
						SfxPlayer.play()
			else :
				if targettile_type!=1 :  #can target unoccipied tiles
					if picked_tiles.has(mousepos) :
						picked_tiles.erase(mousepos)
						SfxPlayer.stream = NodeAccess.__Resources().sounds_book["Target Off.wav"]
						SfxPlayer.play()
					else :
						if picked_tiles.keys().size()+picked_targets.keys().size() + StateMachine.cb_decide_state.picked_charas.size() < max_targets :
							picked_tiles[mousepos] = picked_tiles.keys().size()
						else :
							SfxPlayer.stream = GameGlobal.cmp_resources.sounds_book["target error.wav"]
							SfxPlayer.play()
#		if max_targets==0  or false :
#			pass
	
	if ( StateMachine.cb_decide_state.pleaseconfirmspell or (Input.is_action_just_pressed("LeftClick") and max_targets==0) or (Input.is_action_just_pressed("ValidateTargeting") ) and picked_targets.keys().size()+picked_tiles.keys().size()+ StateMachine.cb_decide_state.picked_charas.size() >0 ) :
		StateMachine.cb_decide_state.pleaseconfirmspell = false
#		print("targetibng blah")
#		if aoe_los and is_obstructed :
#			SfxPlayer.stream = NodeAccess.__Resources().sounds_book["target error.wav"]
#			SfxPlayer.play()
#			return 0
		var clickedtile : Vector2i = get_world_mousepos()
		hide()
		print("TargetingLayer picked_targets : ", picked_targets, " and picked_tiles", picked_tiles)
		
		#execute_spell(caster : CombatCreaButton,spell,power : int, trgt_tiles : Array, used_item : Dictionary, must_add_terrain : bool)
		var all_picked_tiles : Array = []
		for cb in picked_targets :
			all_picked_tiles.append(cb.creature.position)
		for t in picked_tiles :
			all_picked_tiles.append(t)
		#all_picked_tiles.append(clickedtile)
		var aoe_override : Array = aoe_shape if allow_rotation else []
		execute_spell(caster,spell,power,all_picked_tiles, used_item, true, aoe_override)
		return
	return

#	print(mousepos,', ',caster.creature.position )

func get_world_mousepos()->Vector2i :
#	return map.get_local_mouse_position()/32
#	+ map.get_local_mouse_position()
	var chara =  map.focuscharacter
	var chara_g_pos = chara.global_position
	var chara_l_pos = 32*Vector2(chara.tile_position_x, chara.tile_position_y)
	return ( -(chara_g_pos - chara_l_pos)   + map.get_local_mouse_position() )/32
	return ( -(caster.global_position - caster.creature.position*32)   + map.get_local_mouse_position() )/32 #+  (map.get_local_mouse_position() - caster.position )


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
	
	
	var mousepos : Vector2i = Vector2i(map.get_local_mouse_position() ) #+ map.focuscharacter.get_pixel_position()
#	var screensize : Vector2 = get_window().get_size()
#	mousepos = mousepos -screensize/2 +Vector2(160,90)#- Vector2(320,180)
	mousepos = mousepos/32
#	mousepos = Vector2i(mousepos)
#	var aoecolor : Color

			
	
	var temp_is_obstructed : bool = false
	var obstructed_at : Vector2 = Vector2.ZERO
	
	var tiles_line_array : Array = []
	if aoe_los or aoe_ray :
		tiles_line_array = bresenham_line(caster.creature.position, get_world_mousepos(), 0, max_range)

	if aoe_type==1 or aoe_type==3:
		var tilev : Vector2 = Vector2(32,32)
		var aoe_modified_shape = aoe_shape.duplicate()
		#print("tiles_line_array", tiles_line_array, ", caster at : ", caster.creature.position)
		if aoe_ray :
			for t in tiles_line_array :
				
				#aoe_modified_shape = GameGlobal.add_ray_to_spell_aoe(aoe_modified_shape, caster, )
				
				var c = Vector2i(t)  - get_world_mousepos()
				var overlaps_caster : bool = false
				for x in range(caster.creature.size.x) :
					for y in range(caster.creature.size.y) :
						if t+Vector2(x,y)== caster.creature.position :
							overlaps_caster = true
				if not aoe_modified_shape.has(c) and (not overlaps_caster ) :
					aoe_modified_shape.append(c)
					#print('added c : ' , c)
		for t in aoe_modified_shape :
			var posv : Vector2 = mousepos + t
			draw_rect(Rect2(32*posv,tilev), aoe_color ,false, 2)


	if aoe_los :
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
		draw_line(caster.global_position+0.5*caster.size, mousepos*32+Vector2i(16,16), line_color, 1, true )

	else :
		var targettile_type : int = 0
		var wmousepos = get_world_mousepos()
		if spell.get("targettile")  : #0=anywhere 1=creature 2=empty 3=nowall 
			targettile_type = spell.targettile
		if ((targettile_type==2 or targettile_type==3) and is_aoe_empty(wmousepos, aoe_shape)==false) :
			is_obstructed = true
			obstructed_at = wmousepos
#			get_parent().debuglabel.text+=str(obstructed_at)
		else :
			is_obstructed = false
	
	if is_obstructed :
		
		var obstextpos : Vector2 = (caster.global_position - caster.creature.position*32)+(obstructed_at*32)
#			print(obstructed_at, obstextpos)
		
		draw_rect(Rect2(obstextpos,Vector2(32,32)), Color.DARK_RED ,false, 2)
#			draw_line(obstextpos+Vector2(16,16),mousepos*32+Vector2i(16,16) , Color.RED, 3, true )
		draw_string_outline(ThemeDB.fallback_font, obstextpos-Vector2(16,0), OBSTRUCTEDTEXT, HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size ,4, Color.BLACK )
		draw_string(ThemeDB.fallback_font, obstextpos-Vector2(16,0), OBSTRUCTEDTEXT, HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size , Color.RED )
		
		
	
	var range : int = GameGlobal.calculate_range_vi( get_world_mousepos() - Vector2i(caster.creature.position) )
	var rangetext : String = str(range)+'/'+str(max_range)
	var rangecolor = Color.WHITE if range<=max_range else Color.RED
	var rangetextpos : Vector2 = 32*mousepos - Vector2i(8,0)
#	draw_string(font: Font, pos: Vector2, text: String, alignment: HorizontalAlignment = 0, width: float = -1, font_size: int = 16, modulate: Color = Color(1, 1, 1, 1), jst_flags: JustificationFlag = 3, direction: Direction = 0, orientation: Orientation = 0) const
	#draw_string_outline(font: Font, pos: Vector2, text: String, alignment: HorizontalAlignment = 0, width: float = -1, font_size: int = 16, size: int = 1, modulate: Color = Color(1, 1, 1, 1), jst_flags: JustificationFlag = 3, direction: Direction = 0, orientation: Orientation = 0) const
	draw_string_outline(ThemeDB.fallback_font, rangetextpos, rangetext, HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size ,4, Color.BLACK )
	draw_string(ThemeDB.fallback_font, rangetextpos, rangetext, HORIZONTAL_ALIGNMENT_CENTER, -1, ThemeDB.fallback_font_size , rangecolor )

func get_aoe_from_name(aoename) -> Array :
	if typeof(aoename) == TYPE_ARRAY:
		return aoename
	match aoename :
		"b1","b2","b3","b4","b5","b6","b7","wh","wl","wv","wj" :
			return bdict[aoename]
	return [aoename]

func start_targ(tspell, tspellpower : int, tcaster : CombatCreaButton, used_item : Dictionary) :
	print("TargetingLayer start_targ ", tspell.name)
	picked_targets.clear()
	picked_tiles.clear()
	spell = tspell
	caster = tcaster #is a CombatCreaButton
	power = tspellpower
	max_range = spell.get_range(power, caster.creature)
	aoe_los = spell.los
	aoe_ray = spell.ray
	allow_rotation = spell.rot
	max_targets = spell.get_target_number(power, caster.creature)
	spell_aoe_name = spell.get_aoe(power, caster.creature)
	print("TARGETINGLAYER spell_aoe_name :",spell_aoe_name)
	aoe_shape = get_aoe_from_name(spell_aoe_name)
	print("AoEshape : ", aoe_shape, "max range : ", max_range)
	match spell_aoe_name :
		"b1","b2","b3","b4","b5","b6","b7", "r" :
			aoe_type = 1
		"wh","wv","wj","wl" :
			aoe_type = 3
		"pt","sf","af","ae", "eo" :
			aoe_type = 0
			print("TargetingLayer : spellwith aoe_name "+spell_aoe_name+" is aoe_type 0 and should skip targeting")
	var foundcolor : bool = false
	for attr in spell.attributes :
		if attrColorDict.has(attr) :
			aoe_color = attrColorDict[attr]
			foundcolor = true
			break
	if not foundcolor :
		aoe_color = Color.GRAY
	show()
	set_process(true)
#	var mousepos : Vector2 = map.get_local_mouse_position()





static func bresenham_line(startpt : Vector2, endpt : Vector2, min_range : int, max_range : int) -> Array :
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
		# warning-ignore:narrowing_conversion
		returned.resize(min(returned.size(),max_range))
	else :
		returned.resize(min(returned.size(),max_range+1))
	if returned.is_empty() :
		print("RETUNRED EMPTY !")
	return returned


static func plotLineLow(startpt : Vector2, endpt : Vector2, reverseorder : bool) -> Array :
	# bresenham for  |slope| <1
	var returned : Array = []
	# warning-ignore:narrowing_conversion
	var dx : int = endpt.x - startpt.x
	# warning-ignore:narrowing_conversion
	var dy : int = endpt.y - startpt.y
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
	# warning-ignore:narrowing_conversion
	var dx : int = endpt.x - startpt.x
	# warning-ignore:narrowing_conversion
	var dy : int = endpt.y - startpt.y
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

func get_tiles_under_cb(cb : CombatCreaButton) -> Array :
	var returned_array : Array = []
	var crea = cb.creature
	for x in range(crea.size.x) :
		for y in range(crea.size.y) :
			returned_array.append(Vector2i(crea.position)+Vector2i(x,y))
	return returned_array

func get_affected_tiles(s_spell, s_power : int, s_caster : CombatCreaButton, s_targeted_pos : Vector2, s_aoe_override = []) :
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
	var s_spell_aoe_name = s_spell.get_aoe(s_power, s_caster.creature)
	if rotation >= 0 and s_spell.rot :
		s_spell_aoe_name = ["wh", "wl", "wv", "wj"][rotation]
	var s_aoe_type : int = 9999 #0=no targeting 1=ballb1etc 2=ray 3=wall
	match s_spell_aoe_name :
		"b1","b2","b3","b4","b5","b6","b7" :
			s_aoe_type = 1
		"wh","wv","wj","wl" :
			s_aoe_type = 1
		"pt","sf","af","ae", "eo" :
			s_aoe_type = 0

	var returned_array : Array = []

	if s_aoe_type==0 :
		if spell_aoe_name == "sf" : #self
			return get_tiles_under_cb(s_caster)
	if spell_aoe_name=="af" or spell_aoe_name=="ae" or spell_aoe_name=="eo":
		var  targ_factions = [] #[0,1,2,3]
		if spell_aoe_name=="eo":
			targ_factions = [0,1,2,3]
		if spell_aoe_name=="af" :
			targ_factions = [s_caster.creature.curFaction]
		if spell_aoe_name=="ae" :
			targ_factions = [0,1,2,3]
			targ_factions.erase(s_caster.creature.curFaction)
		for cb in StateMachine.combat_state.all_battle_creatures_btns :
			if targ_factions.has(cb.creature.curFaction):
				returned_array.append(get_tiles_under_cb(cb))
		return returned_array
	
	if s_aoe_type==1 :
		var s_aoe_shape=get_aoe_from_name(s_spell_aoe_name)  #single tile

		if s_aoe_ray :
			for c in tiles_line_array :
				returned_array.append(c)
	
		for c in s_aoe_shape :
			var pos : Vector2 = s_targeted_pos+Vector2(c)
			if not returned_array.has(pos) :
				returned_array.append(pos)
	return returned_array
	
#must be used for each target. Used by AI for testing !
# returns an array of all the affected creatures
#ROTATION SHULD BE -1 IF NOT A ROTATABLE SPELL
func get_cbs_touching_tiles(effected_tiles : Array) -> Array:
	var returned_array : Array= []
	for pos in effected_tiles :
		var cb = GameGlobal.who_is_at_tile(pos)
		if is_instance_valid(cb) :
			if not returned_array.has(cb) :
				returned_array.append(cb)
	return returned_array


#old gameglobal execute : (caster : CombatCreaButton,spell,power : int ,clickedtile : Vector2i, aoe_shape : Array, picked_targets : Dictionary, picked_tiles:Dictionary, chain_start : bool, must_add_terrain : bool) :
#msg frmat : {"type" : "Spell", "caster" : Crea, "Effected Tiles" : [], "Effected creas" : [], "targeted_tiles" : [], "spell":GDScript, "s_plvl" : 1, "used_item" : null , "add_terrain" : true}

func execute_spell(caster : CombatCreaButton,spell,power : int, trgt_tiles : Array, used_item : Dictionary, must_add_terrain : bool, override_aoe : Array) :
	#print("TargetingLayer execute_spell : "+spell.name+" trgt_tiles : ", trgt_tiles)
	var msg : Dictionary = {"type" : "Spell", "spell" : spell, "s_plvl" : power, "targeted_tiles" : trgt_tiles, "used_item" : used_item , "must_add_terrain" : must_add_terrain, "override_aoe" : override_aoe }
	StateMachine.state.on_spellcast_confirmed(msg)
