"""
Author: Francisco de Biaso Neto
email: kikinhobiaso@gmail.com

##################
### Map Module ###
##################

Loads Things and add them into this Node.
"""

extends Control
class_name Map

const ClassicQueuedSpellRuntimeScript = preload(
	"res://scripts/classic_runtime/classic_queued_spell_runtime.gd"
)
const ClassicLightScript = preload(
	"res://scripts/classic_runtime/classic_light.gd"
)
const ClassicDungeonBattleTerrainScript = preload(
	"res://scripts/classic_runtime/classic_dungeon_battle_terrain.gd"
)
const BattleOccupancyRulesScript = preload("res://scripts/battle_occupancy_rules.gd")

# Get Thing Scene By default #
#@export (PackedScene) var _thing


var secret_texture : Texture2D
var path_texture : Texture2D
var display_explored_only : bool = false
var explored_tiles : Array = []  #array of array  of boold, true=explored
var extra_images : Dictionary = {}
var show_scripts : bool = true
@export var show_pathfinding_debug : bool = false
var mapdata : Array = []
var map_size : Vector2 = Vector2.ONE
var mapscriptareas : Dictionary = {}
var mapsecretpaths : Dictionary= {}
var mapsecrets : Dictionary= {}
var mapboats : Dictionary = {}
var mapscripts : GDScript = null
var maptype : String = ""
var mapmusictype : String = ""
var outdoor_riding : bool = false
var cam_x : int = 0
var cam_y : int = 0
var widthtiles : int = 32
var heighttiles : int = 18
const RIGHTPANELWIDTH : int = 320
const BOTTOMPANELHEIGHT : int = 200
var mouseinside : bool = false # true iff the mouse is inside teh map area / button
var pressed : bool = false # true iff the map (and not a character) is being clicked, used for movements.

@onready var debuglabel : Label = $DebugLabel

@onready var aStar11 = preload("res://scenes/MyAstar2D.gd").new()  #1 wide 1 high
@onready var aStar12 = preload("res://scenes/MyAstar2D.gd").new()  #1 wide 2 high
@onready var aStar21 = preload("res://scenes/MyAstar2D.gd").new()  #2 wide 1 high
@onready var aStar22 = preload("res://scenes/MyAstar2D.gd").new()  #2 wide 2 high

#@onready var aStarExtra = preload("res://scenes/MyAstar2D.gd").new()


var last_generated_path : Array = []

@onready var focuscharacter = get_node("Characters/OWPlayer")
@onready var owcharacter : OW_Player = focuscharacter
@onready var charactersnode = get_node("Characters")
@onready var blacktexture : Texture2D = preload("res://shared_assets/Map Symbols/tileBlack.png")
@onready var darktexture : Texture2D = preload("res://shared_assets/Map Symbols/tileDark.png")
@onready var mapbutton : Button = $MapMouseControlButton

@onready var images_node : Node2D = $ExtraImages
@onready var creatures_node : Node2D = $CombatCreatures
@onready var targetingLayer : Node2D = $TargetingLayer
@onready var gfx_node : Node2D =  $Gfx

var tiles_book : Dictionary = {}

var darkness_level : int = 0  #how dark is the map with no extra light from GameGlobals.light_time
const darkness_offset : int = 156
@onready var darkness_00 : Texture2D= preload("res://scenes/Map/Darkness/darkness_00.png")
@onready var darkness_01 : Texture2D= preload("res://scenes/Map/Darkness/darkness_01.png")
@onready var darkness_02 : Texture2D= preload("res://scenes/Map/Darkness/darkness_02.png")
@onready var darkness_03 : Texture2D= preload("res://scenes/Map/Darkness/darkness_03.png")
@onready var darkness_04 : Texture2D= preload("res://scenes/Map/Darkness/darkness_04.png")
@onready var darkness_05 : Texture2D= preload("res://scenes/Map/Darkness/darkness_05.png")
@onready var darkness_06 : Texture2D= preload("res://scenes/Map/Darkness/darkness_06.png")
@onready var darkness_array : Array = [darkness_00,darkness_01,darkness_02,darkness_03,darkness_04,darkness_05,darkness_06]

@onready var riding_character : Texture2D = preload( "res://shared_assets/Map Symbols/Riding.png" )
@onready var camping_character: Texture2D = preload( "res://shared_assets/Map Symbols/Camp.png" )

var  exploration_sight_dirs : Array = []

#var exampleTerrainEffect : Dictionary = {"caster" : "somecreature", "Tiles" : [Vector2.ZERO], "timeleft" : 3, "spell" : somescript, "texture" : Texture}

var terrainEffects : Array = []
var _next_terrain_effect_id := 1
#var terrainTexAtlas : ImageTexture = preload("res://shared_assets/BattleEffects/BattleEffects.png")
var terrains_tex_pos_dict : Dictionary = {
	"Bnd" : Vector2i(2,1),	"Web" : Vector2i(3,1),	"Trg" : Vector2i(4,1),"Yfr" : Vector2i(5,1),
	"Gcl" : Vector2i(6,1),	"Bcl" : Vector2i(7,1),	"Spn" : Vector2i(8,1),"Slm" : Vector2i(9,1),
	"Spr" : Vector2i(10,1),	"Bal" : Vector2i(11,1),	"Orb" : Vector2i(12,1),"Thn" : Vector2i(13,1),
	"Spk" : Vector2i(14,1),	"Str" : Vector2i(0,2),	"Dts" : Vector2i(1,2) ,"Ice" : Vector2i(5,2),
	# Exact PICT 302 frames used by Classic queue icons 9 and 10.
	"ClassicQueue9" : Vector2i(4,6), "ClassicQueue10" : Vector2i(12,6) }
var tex_name_tex_dict : Dictionary = {}

func add_terrain_effect_from_spell(
	spell,
	power: int,
	aoe: Array,
	targ_pos: Vector2i,
	caster: Creature
) -> bool:
	var t_aoe : Array = []
	for i in range(aoe.size()) :
		t_aoe.append(Vector2i(aoe[i])+targ_pos)
	var is_classic: bool = spell.has_method("is_classic_queued_spell") \
		and spell.is_classic_queued_spell()
	if is_classic and ClassicQueuedSpellRuntimeScript.classic_effect_count(terrainEffects) \
			>= ClassicQueuedSpellRuntimeScript.MAX_EFFECTS:
		push_warning("Classic queued spell limit reached; the new field was not retained")
		return false
	if spell.terrain_tex.is_empty() or not tex_name_tex_dict.has(spell.terrain_tex):
		push_warning("Spell %s has no battlefield terrain texture" % spell.name)
		return false
	var duration := int(spell.get_duration_roll(power, caster))
	if duration <= 0 or t_aoe.is_empty():
		return false
	terrainEffects.append({
		"id": _next_terrain_effect_id,
		"time": duration,
		"tiles": t_aoe,
		"caster": caster,
		"phase_owner": caster,
		"spell": spell,
		"power": power,
		"texture": tex_name_tex_dict[spell.terrain_tex],
		"classic": is_classic,
	})
	_next_terrain_effect_id += 1
	queue_redraw()
	return true

func remove_terrain_effect(terrain : Dictionary) :
	terrainEffects.erase(terrain)
#	var newarray : Array = []
#	for t in terrainEffects :
#		if t!=terrain :
#			newarray.append(t)
#	terrainEffects = newarray

func get_terrain_effects_at_pos(tpos : Vector2) -> Array :
#	print("MAP get_terrain_effects_at_pos ", tpos)
	var returned : Array = []
	for t in terrainEffects :
#		print("MAP t[tiles] ", t["tiles"])
		for p in t["tiles"] :
			if Vector2(p)==tpos :
				returned.append(t)
				continue
	return returned


func get_terrain_effects_touching_creature(creature: Creature) -> Array:
	return ClassicQueuedSpellRuntimeScript.effects_touching_creature(
		terrainEffects, creature
	)

func add_extra_image(key : String, img_key : String, coords : Vector2) :
	print("MAp add_extra_image : "+ key+ ', '+img_key,', ',coords)
	var imgbook = NodeAccess.__Resources().images_book
	var newtex : ImageTexture = imgbook[img_key]["tex"]
#	var newsprite : Sprite2D = Sprite2D.new()
#	newsprite.texture = newtex
#	newsprite.position = coords
#	extra_images[key] = newtextrect
#	images_node.add_child(newtextrect)

	var newtextrect : TextureRect = TextureRect.new()
	newtextrect.texture = newtex
	newtextrect.position = coords*32
	newtextrect.size = newtex.get_size()
	extra_images[key] = newtextrect
	images_node.add_child(newtextrect)

func remove_extra_image(key : String) :
	if not extra_images.has(key) :
		return
	extra_images[key].queue_free()
	extra_images.erase(key)

func _on_new_round(combat_buttons: Array = []) -> Array:
	var stationary_actions := ClassicQueuedSpellRuntimeScript.stationary_actions(
		terrainEffects, combat_buttons
	)
	for terrain: Dictionary in terrainEffects:
		if not bool(terrain.get("classic", false)):
			terrain["time"] = int(terrain.get("time", 0)) - 1
	terrainEffects = terrainEffects.filter(
		func(terrain: Dictionary) -> bool: return int(terrain.get("time", 0)) > 0
	)
	queue_redraw()
	return stationary_actions


func advance_classic_terrain_phase(phase_owner: Creature) -> void:
	terrainEffects = ClassicQueuedSpellRuntimeScript.advance_phase(
		terrainEffects, phase_owner
	)
	queue_redraw()


func advance_missing_classic_terrain_phases(combat_buttons: Array) -> void:
	var live_creatures: Array = []
	for button: Variant in combat_buttons:
		if is_instance_valid(button) and is_instance_valid(button.creature):
			live_creatures.append(button.creature)
	terrainEffects = ClassicQueuedSpellRuntimeScript.advance_missing_phases(
		terrainEffects, live_creatures
	)
	queue_redraw()

# Call functions to load the map #
func _ready():
	set_debug_overlays_enabled(GameGlobal.map_debug_overlays_enabled)
	aStar11.crea_size = Vector2.ONE
	#aStarExtra.crea_size = Vector2(2,2)#Vector2.ONE*2
	aStar12.crea_size = Vector2(1,2)
	aStar21.crea_size = Vector2(2,1)
	aStar22.crea_size = Vector2(2,2)
	var terrainTexAtlas: Image = load("res://shared_assets/BattleEffects/BattleEffects.png")

	for n in terrains_tex_pos_dict :
		var new_tex : ImageTexture = ImageTexture.new()
		var pos : Vector2i = terrains_tex_pos_dict[n]
		var rect = Rect2i( 32*pos, Vector2i(32,32))
		var image = terrainTexAtlas.get_region(rect)
		# Loads texture from texture atlas #
		new_tex = ImageTexture.create_from_image(image) #,0
		tex_name_tex_dict[n] = new_tex
	var map_symbols_atlas : Image = load("res://scenes/Map/map_symbols.png")

	var path_image : Image = map_symbols_atlas.get_region(Rect2i( Vector2i.ZERO, Vector2i(32,32)))
	path_texture = ImageTexture.create_from_image(path_image)
	var secret_image : Image = map_symbols_atlas.get_region(Rect2i( Vector2i(32,0), Vector2i(32,32)))
	secret_texture = ImageTexture.create_from_image(secret_image)

	var raysperside : int = 16
	var halfray : int = floor(raysperside/2)
	for x in range(0,raysperside) : #[0,1,2,3,4,5,6,7]
		exploration_sight_dirs.append(Vector2(-halfray+x,-halfray))
		exploration_sight_dirs.append(Vector2(halfray,-halfray+x))
		exploration_sight_dirs.append(Vector2(halfray-x,halfray))
		exploration_sight_dirs.append(Vector2(-halfray,halfray-x))
#	load_map()

func set_debug_overlays_enabled(enabled: bool) -> void:
	show_scripts = enabled
	if not is_instance_valid(debuglabel):
		return
	debuglabel.visible = enabled
	if not enabled:
		debuglabel.text = ""
	queue_redraw()

func set_ow_character_icon(icon : Texture2D) :
	if GameGlobal.camping :
		owcharacter.set_icon(camping_character)
		return
	elif GameGlobal.is_sailing_boat :
		var tex : Texture = NodeAccess.__Resources().images_book[GameGlobal.boat_sailed_image_name]["tex"]
		owcharacter.set_icon(tex)
		return
	elif outdoor_riding :
		owcharacter.set_icon(riding_character)
		return

	owcharacter.set_icon(icon)

# Load the game map #
func load_map( _campaign : String, mapname : String) -> void:
	print("Map load_map ", _campaign, ' ',mapname)
	var resources = NodeAccess.__Resources()
	mapdata = resources.maps_book[mapname][0]
	mapscriptareas = resources.maps_book[mapname][1]["ScriptRects"]
	mapsecretpaths.clear()
	for p in resources.maps_book[mapname][1]["Paths"] :
		mapsecretpaths[Vector2i(p[0],p[1])] = p[2]
	mapsecrets.clear()
	for p in resources.maps_book[mapname][1]["Secrets"] :
		mapsecrets[Vector2i(p[0],p[1])] = [ p[2], p[3] , p[4] ]  #seen, fucntionname,  failchance
	mapscripts = resources.maps_book[mapname][2]

	mapboats.clear()
	extra_images.clear()
	for c in images_node.get_children() :
		c.queue_free()

	for c in creatures_node.get_children() :
		c.queue_free()

	if mapscripts != null:
		mapscripts._on_map_load(self)

	map_size = Vector2( mapdata.size(), mapdata[0].size())

	#generate_graph(mapdata : Array, swimmer : bool, flyer : bool, big : bool)
	aStar11.generate_graph(mapdata, true, false, false) #swimmer flyer big
	aStar12.generate_graph(mapdata, true, false, true) #swimmer flyer big
	aStar21.generate_graph(mapdata, true, false, true) #swimmer flyer big
	aStar22.generate_graph(mapdata, true, false, true) #swimmer flyer big

	tiles_book = NodeAccess.__Resources().tiles_book
	maptype = resources.maps_book[mapname][3]
	mapmusictype = resources.maps_book[mapname][4]
	outdoor_riding = resources.maps_book[mapname][5]
	darkness_level = resources.maps_book[mapname][6]
	display_explored_only = resources.maps_book[mapname][7]
	explored_tiles = resources.maps_book[mapname][8]

	if GameGlobal.map_boats_dict.has(mapname) :
		for b : String in GameGlobal.map_boats_dict[mapname] :
			#print("MAP: print images_book")
			#print(NodeAccess.__Resources().images_book.keys())
			#get_tree().quit()
			var imgname : String = GameGlobal.map_boats_dict[mapname][b]
			print("MAP IMGNAME : ", imgname)
			var boatimage =  NodeAccess.__Resources().images_book[imgname]
			var s : Array = b.split(',')
			mapboats[Vector2i(int(s[0]), int(s[1]))] = [boatimage, imgname ]
	else :
		mapboats.clear()
	#TEST
	#GameGlobal.stuff_done['TileSwaps.'+mapname] = {}
	#GameGlobal.stuff_done['TileSwaps.'+mapname]["x4y4l0"] = [4, 4, 0, "ForestDay", 55]
	#apply tile swap changes  marked by  flags :
	if GameGlobal.stuff_done.has('TileSwaps.'+mapname) :
		var tswapdict : Dictionary = GameGlobal.stuff_done['TileSwaps.'+mapname]
		for tswapkey : String in tswapdict : #eg x4y4l0
			var tsd : Array = tswapdict[tswapkey] #eg [4, 4, 0, "ForestDay", 55]
			ScriptHelperFuncsClass.change_currmap_tile(tsd[0],tsd[1],tsd[2],tsd[3], tsd[4])
	load_simple_encounter_data(mapname)

func _on_viewport_size_changed() :
	var screensize : Vector2 = ScreenUtils.get_logical_window_size(self)
	mapbutton.size = screensize-Vector2(320,201)
	var vscale =Vector2.ONE
	if screensize.x<512 :
		vscale.x = screensize.x/512
	if screensize.y<400 :
		vscale.y = screensize.y/400

	widthtiles = ceil(screensize.x/32)-(vscale.x*RIGHTPANELWIDTH/32)+3
	heighttiles = ceil(screensize.y/32)-(vscale.y*BOTTOMPANELHEIGHT/32)+1
	queue_redraw()

func _draw() :  #map cells are  [ [used_tileset_name,t_id,true],
#	return
#	if mapdata.is_empty() :
#		return

	cam_x = focuscharacter.tile_position_x - int((widthtiles)/2) +1
	cam_y = focuscharacter.tile_position_y - int((heighttiles)/2)
	charactersnode.position = Vector2(-cam_x*32,-cam_y*32)
	creatures_node.position = charactersnode.position
	images_node.position = charactersnode.position
	gfx_node.position = charactersnode.position
#	print("Map mapdata , ", mapdata)


	for x in range(widthtiles) :
		for y in range(heighttiles) :
#			print("Map 116: ", cam_x, ' ',x,' , ', cam_y, ' ',y)
			if cam_x+x<0 or cam_y+y<0 or cam_x+x>=map_size.x or cam_y+y>=map_size.y :
				draw_texture_rect(blacktexture, Rect2(32*x,32*y,32,32), true)
				continue
			#print("Map 340 : ",cam_x+x,'<=',map_size.x, ',  ', cam_y+y,'<=',map_size.y, ", explored_tules size : ", explored_tiles.size(), "explored_tiles[0] size  : ", explored_tiles[0].size())
			# mapsizeX is 30  mapsizeY is 20 , all good
			#explosize is 20  explsize(0) is 30... width is y and height is x
			if display_explored_only and (not explored_tiles[cam_y+y][cam_x+x]==1) :
				draw_texture_rect(blacktexture, Rect2(32*x,32*y,32,32), true)
				continue

			for xtra in extra_images.keys() :
				var xtpos : Vector2 = (extra_images[xtra].position/32).round()
#				print("xtra ", xtra, ' xtpos ',xtpos)
				if xtpos.x<=mapdata.size() and xtpos.x>=0  and xtpos.y<=mapdata.size() and xtpos.y>=0 :
#					print(explored_tiles[xtpos.x][xtpos.y])
					extra_images[xtra].visible = explored_tiles[xtpos.x][xtpos.y]==1

			var tile = mapdata[cam_x+x][cam_y+y]
#			print(tile)
			if tile.is_empty()  : #or tile[0]["items"].is_empty()
				draw_texture_rect(blacktexture, Rect2(32*x,32*y,32,32), true)
			else :
				if false : #!tile[0]["light"] :
					draw_texture_rect(darktexture, Rect2(32*x,32*y,32,32), true)
				else :
					for i in tile :  #  dicts... no,array now
#						print(i)
#						print(stuffbook[i]){image:[Image:1191], type:ground}
#						print("draw map, ",i)
						draw_texture_rect(i["texture"], Rect2(32*x,32*y,32,32), true)
					if show_pathfinding_debug \
							and last_generated_path.has(Vector2(cam_x+x,cam_y+y)):
						draw_texture_rect(darktexture, Rect2(32*x,32*y,32,32), true)

			##PATHFINDING DEBUG
			#if aStar11.is_point_solid(Vector2i(cam_x+x, cam_y+y)) :
				###draw_texture_rect(path_texture, Rect2(32*x,32*y,32,32), true)
				#draw_texture_rect(secret_texture, Rect2(32*x,32*y,32,32), true)


			# draw terrain effects :
			for t in terrainEffects :
#				print("Map : There sia terrain effect, does it ", t["tiles"])
				if t["tiles"].has(Vector2i(cam_x+x,cam_y+y)) : #t["texture"]
#					print("map : it contains tile ", Vector2i(x,y))
					draw_texture_rect(t["texture"], Rect2(32*x,32*y,32,32), true, Color(1,1,1,0.5))

			#draw secret paths etc
			var tpos : Vector2i = Vector2i(cam_x+x,cam_y+y)
			if mapsecretpaths.has(tpos) :
				if mapsecretpaths[tpos] == 1 :
					draw_texture_rect(path_texture, Rect2(32*x,32*y,32,32), true, Color(1,1,1,1))
			if mapsecrets.has(tpos) :
#				print(mapsecrets)
#				print("Map  Draw : mapsecrets[tpos]",mapsecrets[tpos])
				if mapsecrets[tpos][0] == 1 :
					draw_texture_rect(secret_texture, Rect2(32*x,32*y,32,32), true, Color(1,1,1,1))
			if mapboats.has(tpos) :
				#print("MAP mapboats[tpos] : ", mapboats[tpos])
				var btimg : Texture = mapboats[tpos][0]["tex"]
				draw_texture_rect(btimg, Rect2(32*x,32*y,32,32), true, Color(1,1,1,1))

	if ClassicLightScript.should_draw_darkness(
		darkness_level,
		StateMachine.is_combat_state(),
		is_instance_valid(GameGlobal.classic_campaign_session)
	):
		var light_level : int = darkness_level + GameGlobal.light_power
		light_level = int(clamp(light_level, 0, 6))
		if light_level <= 6 and light_level >=0:
			var focuschar_pos : Vector2 = focuscharacter.get_global_position()
			draw_texture_rect( darkness_array[light_level], Rect2( focuschar_pos-Vector2(darkness_offset,darkness_offset),Vector2(352,352)) , false )
			draw_rect(Rect2(Vector2(0,0),Vector2(widthtiles*16-darkness_offset,heighttiles*32) ), Color.BLACK, true)
			draw_rect(Rect2(Vector2(widthtiles*16+darkness_offset-8,0),Vector2(widthtiles*16-darkness_offset,heighttiles*32) ), Color.BLACK, true)
			draw_rect(Rect2(Vector2(0,0),Vector2(widthtiles*32,heighttiles*16-darkness_offset) ), Color.BLACK, true)
			draw_rect(Rect2(Vector2(0,heighttiles*16+darkness_offset),Vector2(widthtiles*32,heighttiles*16-darkness_offset) ), Color.BLACK, true)

	if show_scripts :
		for s in mapscriptareas :
#			print (s)
			var sp = mapscriptareas[s]
			var tl : Vector2 = Vector2( 32*sp["scriptRectangle"][0][0] , 32*sp["scriptRectangle"][0][1] )
			var sz : Vector2 = Vector2( 32*(sp["scriptRectangle"][1][0]+1) , 32*(sp["scriptRectangle"][1][1]+1) ) - tl
			var camoffset : Vector2 = Vector2(32*cam_x, 32*cam_y)
			var rect : Rect2 = Rect2(tl-camoffset, sz)
			draw_rect(rect,Color(1,0,0.8, 1),false,2.0)# false) TODOGODOT4 Antialiasing argument is missing
			#draw_string(font: Font, rect.position, s, Color( 1, 0, 0.8, 1 ), -1)
			#Draws text using the specified font at the pos (bottom-left corner using the baseline of the font). The text will have its color multiplied by modulate. If width is greater than or equal to 0, the text will be clipped if it exceeds the specified width.

			#var default_font = ThemeDB.fallback_font
			#var default_font_size = ThemeDB.fallback_font_size
			#draw_string(default_font, Vector2(64, 64), "Hello world", HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size)

			draw_string(ThemeDB.fallback_font, tl-camoffset, s, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(pow(randf(), 4), pow(randf(), 4), pow(randf(), 4)))
	return


# for some reason it didnt trigger
#func _on_MapMouseControlButton_toggled(button_pressed):
#	pressed = button_pressed
#	print('lol')


func _on_MapMouseControlButton_button_down():
	pressed = true
	#print(" map burp down")

func _on_MapMouseControlButton_button_up():
	pressed = false
	#print(" map burp up ")

func _on_MapMouseControlButton_mouse_entered():
	mouseinside = true
	#print(" map burp entered")

func _on_MapMouseControlButton_mouse_exited():
	mouseinside = false
	#print(" map burp exited")

func _process(_delta):
	if not visible:
		return
	if not show_scripts:
		return
	var combat_animation_timer: Variant = "unloaded"
	if (
		is_instance_valid(StateMachine.combat_state)
		and is_instance_valid(StateMachine.combat_state.cbanimstate)
	):
		combat_animation_timer = StateMachine.combat_state.cbanimstate.timer
	var newtext : String = "Map Debug Label : GameState : "+str(StateMachine._state_name)+", combat : "+str(StateMachine.is_combat_state())+", cbanim timer:"+str(combat_animation_timer)+'\n'
	debuglabel.text = newtext + '\n teamsize : '+str(GameGlobal.player_characters.size())+ "\n TectRectChoiceContainer visible ?"+str(UI.ow_hud.textRect.choicesContainer.visible)
	debuglabel.text +=  "\nGameGlobal.currentmap_name : "+GameGlobal.currentmap_name

func set_secret_seen(pos : Vector2i) :
	if mapsecrets.has(pos) :
		mapsecrets[pos][0] = 1
		var resources = NodeAccess.__Resources()
		for s in resources.maps_book[GameGlobal.currentmap_name][1]["Secrets"] :
			if s[0] == pos.x  and s[1] == pos.y :
				s[2] = 1
				return

func set_secretpath_seen(pos : Vector2i) :
	if mapsecretpaths.has(pos) :
		mapsecretpaths[pos] = 1
		var resources = NodeAccess.__Resources()
		for s in resources.maps_book[GameGlobal.currentmap_name][1]["Paths"] :
			if s[0] == pos.x  and s[1] == pos.y :
				s[2] = 1
				return

func get_secret_fail_chance(pos : Vector2i) -> float :
	if mapsecrets.has(pos) :
		print("Map get_secret_fail_chance ",mapsecrets[pos][2])
		return mapsecrets[pos][2]
	else :
		return  1.0

func on_step_on_boat(pos : Vector2i) :
	var a : Array = [ [1,2],[3,4]]
	a.erase([3,4])
	print('a: ', a)
	GameGlobal.boat_sailed_image_name = mapboats[pos][1] #this is the String
	GameGlobal.is_sailing_boat = true
	set_ow_character_icon(GameGlobal.player_characters[0].icon)
	mapboats.erase(pos)
	#print("MAP b4on_step_on_boat : ", GameGlobal.map_boats_dict)
	#print("what i try to rase : ", [pos.x, pos.y] )
	var mapboatsdict : Dictionary = GameGlobal.map_boats_dict[GameGlobal.currentmap_name]
	#print("mapboatsdict : ", mapboatsdict)
	mapboatsdict.erase( str(pos.x)+','+str(pos.y) )
	#print("mapboatsdict after erase : ", mapboatsdict)
	#print("MAP afon_step_on_boat : ", GameGlobal.map_boats_dict)
	queue_redraw()

func dock_boat_at(pos : Vector2i) :
	#GameGlobal.boat_sailed_image_name = mapboats[pos][1] #this is the String
	GameGlobal.is_sailing_boat = false
	GameGlobal.map_boats_dict[GameGlobal.currentmap_name][str(pos.x)+','+str(pos.y)] = GameGlobal.boat_sailed_image_name
	print("MAP dock_boat : ", GameGlobal.map_boats_dict)
	#for b in GameGlobal.map_boats_dict[mapname] :
	#var boatimage =  NodeAccess.__Resources().images_book[b[2]]
	#mapboats[Vector2i(b[0], b[1])] = [boatimage, b[2] ]   in  loader, b2 is  name

	var tex : Texture = NodeAccess.__Resources().images_book[GameGlobal.boat_sailed_image_name]["tex"]
	mapboats[pos] = [{"tex":tex, "img" : null},GameGlobal.boat_sailed_image_name]
	#var btimg : Texture = mapboats[tpos][0]["tex"] in the _draw
	#mapboats[Vector2i(b[0], b[1])] = [boatimage, b[2] ]
	set_ow_character_icon(GameGlobal.player_characters[0].icon)

func explore_tiles_from_tilepos(tpos : Vector2) -> void :
	#print("explore_tiles_from_tilepos ", tpos)
	explored_tiles[tpos.y][tpos.x] = 1
	# do bresentham is neveral directions
	#bresenham_line(startpt : Vector2, endpt : Vector2, min_range : int, max_range : int) -> Array :
	var explored_tiles_x_size = explored_tiles[0].size()
	var explored_tiles_y_size = explored_tiles.size()
	var ignore_blocking_sight := GameGlobal.exploration_sight_ignores_blocking_tiles()
	for endpt in exploration_sight_dirs :
		#continue
		#print("explored_tiles_x_size : ",explored_tiles_x_size, ", explored_tiles_y_size : ", explored_tiles_y_size)
		var line : Array = targetingLayer.bresenham_line(tpos, tpos+5*endpt,1,20) #Array of vector2
		for t in line :
			if t.x<0 or t.y<0 or t.x>=explored_tiles_x_size or t.y>=explored_tiles_y_size : break
			explored_tiles[t.y][t.x] = 1
#			print(mapdata[t.x][t.y])
			var tile_stack: Array = mapdata[t.x][t.y]
			if tile_stack.is_empty():
				continue
			if bool(tile_stack[0]["blkview"]) and not ignore_blocking_sight:
				break

func generate_zoomed_map(mapname : String) -> void:
	printerr("Map.generate_zoomed_map ", mapname)
	var resources = NodeAccess.__Resources()
	if not resources.maps_book.has(mapname):
		print("Map not found: ", mapname)
		return

	# Get original map data (assume [0] is the tile array)
	var original_map = resources.maps_book[mapname]
	var original_tilemap = original_map[0]
	var orig_cols = original_tilemap.size()
	var orig_rows = original_tilemap[0].size()
	# Prepare expanded map
	var expanded_cols = orig_cols * 3
	var expanded_rows = orig_rows * 3
	var expanded_tilemap = []
	var classic_dungeon_battle_tiles: Array = []
	for i in range(expanded_cols):
		expanded_tilemap.append([])
		for j in range(expanded_rows):
			expanded_tilemap[i].append([]) # will be array of one tile dict
	# Expand each tile using only the ground layer, keep cell as array of one dict
	for col in range(orig_cols):
		for row in range(orig_rows):
			var cell = original_tilemap[col][row]
			var ground_tile = null
			if cell.size() > 0:
				ground_tile = cell[0] # Only use ground layer
			else:
				push_warning("No tilesets loaded for fallback tile!")
				continue
			var is_classic_dungeon := (
				ClassicDungeonBattleTerrainScript.is_classic_dungeon_tile(ground_tile)
			)
			if is_classic_dungeon and classic_dungeon_battle_tiles.is_empty():
				classic_dungeon_battle_tiles = (
					ClassicDungeonBattleTerrainScript.ensure_tileset(resources.tiles_book)
				)

			var expansion = []
			if is_classic_dungeon:
				expansion.resize(9)
				expansion.fill(0)
			elif ground_tile.has("expansion") and ground_tile["expansion"].size() == 9:
				expansion = ground_tile["expansion"]
			else:
				for k in range(9):
					expansion.append(ground_tile["id"])
			# LOGGING for debugging
			#print("Expanding cell [", col, ",", row, "] with expansion: ", expansion, " from tileset: ", ground_tile["tileset_name"])

			for i in range(3):
				for j in range(3):
					var expanded_col = col * 3 + j
					var expanded_row = row * 3 + i
					var exp_index = i * 3 + j
					var expanded_tile_dict = null
					if is_classic_dungeon:
						expanded_tile_dict = (
							ClassicDungeonBattleTerrainScript.battle_tile_for_field(
								classic_dungeon_battle_tiles,
								int(ground_tile["classicDungeonField"])
							)
						)
						if expanded_tile_dict.is_empty():
							expanded_tile_dict = ground_tile
					else:
						var tileset_key = ground_tile["tileset_name"] + ".json"
						if resources.tiles_book.has(tileset_key) and expansion[exp_index] < resources.tiles_book[tileset_key].size() and expansion[exp_index] >= 0:
							expanded_tile_dict = resources.tiles_book[tileset_key][expansion[exp_index]]
						else:
							push_warning("Invalid expansion index %s for tileset %s, using ground_tile" % [str(expansion[exp_index]), tileset_key])
							expanded_tile_dict = ground_tile # fallback to ground_tile
					expanded_tilemap[expanded_col][expanded_row] = [expanded_tile_dict] # array of one dict

	# Duplicate original map structure, but replace tilemap with expanded_tilemap
	var zoomed_map = original_map.duplicate(true)
	zoomed_map[0] = expanded_tilemap
	zoomed_map[1] = {
		"ScriptRects": {},
		"Paths": [],
		"Secrets": []
	} # ScriptRects, Paths, and Secrets are present but empty
	zoomed_map[2] = null # Clear map scripts
	zoomed_map[4] = "Battle" # Set mapmusictype to "Battle"
	# Exploration masks use row/column dimensions from the source map. They cannot
	# be reused by the three-times-larger battlefield, and combat terrain should
	# remain visible regardless of how much of the source map was explored.
	zoomed_map[7] = false
	zoomed_map[8] = []
	for row in range(expanded_rows):
		var explored_row: Array = []
		explored_row.resize(expanded_cols)
		explored_row.fill(1)
		zoomed_map[8].append(explored_row)
	resources.maps_book["temporary_zoomed_map"] = zoomed_map
	print("MAP Generated temporary zoomed map from: ", mapname, " with music type set to Battle and expanded tiles")
	load_map(GameGlobal.currentcampaign, "temporary_zoomed_map" )
	print("MAP loaded  temporary_zoomed_map")

func find_path(from : Vector2i, to : Vector2i, swimmer : bool, flying : bool, big : bool, crea : Creature, melee_enemies_on_the_way : bool) -> Array :
	#var right_astar : SpecificAstar2D = aStar11 #get_right_graph_for_crea(crea)
	var right_astar : SpecificAstar2D = get_right_graph_for_crea(crea)
	print("MAP ASTAR CREA  SIZE : ", right_astar.crea_size)
	var temporarily_cleared: Dictionary = {}

	# Melee AI paths into an occupied target; its final attempted step becomes
	# an attack. Temporarily clear only that overlap from the active size graph.
	var who = GameGlobal.who_is_at_tile(to)
	if who :
		for anchor: Vector2i in BattleOccupancyRulesScript.blocked_anchors_for(
			who.creature.position,
			who.creature.size,
			right_astar.crea_size,
			right_astar.region
		):
			if right_astar.blocked_tiles.has(anchor):
				right_astar.clear_pos(anchor)
				temporarily_cleared[anchor] = true
	if melee_enemies_on_the_way :
		for cb : CombatCreaButton in StateMachine.combat_state.all_battle_creatures_btns :
			var c : Creature = cb.creature
			if c.curFaction != crea.curFaction :
				for anchor: Vector2i in BattleOccupancyRulesScript.blocked_anchors_for(
					c.position,
					c.size,
					right_astar.crea_size,
					right_astar.region
				):
					if right_astar.blocked_tiles.has(anchor):
						right_astar.clear_pos(anchor)
						temporarily_cleared[anchor] = true

	last_generated_path = right_astar.get_point_path(from, to)
	for anchor: Vector2i in temporarily_cleared:
		right_astar.block_pos(anchor)
	return last_generated_path

func get_right_graph_for_crea(crea : Creature) -> SpecificAstar2D :
	#return aStar11  #TODO FIX THIS
	#return aStarExtra
	pass
	match crea.size :
		Vector2.ONE :
			return aStar11
		Vector2(1,2) :
			return aStar12
		Vector2(2,1) :
			return aStar21
		Vector2(2,2) :
			return aStar22
		_ :
			return aStar22

#called at GameState.end_active_creature_turn and GameGlobal.start_new_round
func pathfinder_update_characters(charlist : Array, active_crea) :
	#print("MAP pathfinder_update_characters, active crea : " +active_crea.name + ' ', +active_crea.size)
	var spec_astar = get_right_graph_for_crea(active_crea)
	#print("MAP pathfinder_update_characters, astar creasize : ", spec_astar.crea_size)
	spec_astar.update_blocked_by_creas(charlist, active_crea)
	#aStar12.update_blocked_by_creas(charlist)
	#aStar21.update_blocked_by_creas(charlist)
	#aStar22.update_blocked_by_creas(charlist)

func pathfinder_clear_pos(pos : Vector2i) :
	aStar11.clear_pos(pos)
	aStar12.clear_pos(pos)
	aStar21.clear_pos(pos)
	aStar22.clear_pos(pos)
	#aStarExtra.clear_pos(pos)

func pathfinder_block_pos(pos : Vector2) :
	aStar11.block_pos(pos)
	aStar12.block_pos(pos)
	aStar21.block_pos(pos)
	aStar22.block_pos(pos)
	#aStarExtra.block_pos(pos)


func load_simple_encounter_data(mapname : String) :
	if mapname=="temporary_zoomed_map" :
		return
	print("MAP load_simple_encounter_data")
	#check if GameGlobal.load_simple_encounter_data has data for this map, else  load from campaign
	if not GameGlobal.stuff_done.has(mapname+'.SEdata') :
		var mapspath : String =  Paths.campaignsfolderpath + GameGlobal.currentcampaign + "/Maps/"+mapname+"/map_SimpleEncounters.json"
		print(mapspath)
		var map_se_data : Dictionary = Utils.FileHandler.read_json_dic_from_file(mapspath)
		#if map_se_data.is_empty() :
		GameGlobal.stuff_done[mapname+'.SEdata']=map_se_data
			#return
		#printerr("MAP load_simple_encounter_data "+mapname+" data : ", GameGlobal.stuff_done[mapname+'.SEdata'])
