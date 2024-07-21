"""
Author: Francisco de Biaso Neto
email: kikinhobiaso@gmail.com

#######################
### Resource Module ###
#######################

All resources are loaded and accessed through this module.
"""
extends Node
class_name CampaignResources

# Global resource variables #
#var g_thing_types = {}
#var g_stuff_book = {}
#var g_img_pack = {}
#var g_map_things = {}
var g_scripts = {}
#var g_texture_atlas = Image.new()

var images_book : Dictionary = {}
var tiles_book : Dictionary = {}	#contains data about the tiles used in maps
var items_book : Dictionary = {}	# contains models of standard items.
var crea_book: Dictionary = {}	# contains dicts defining creatures for combat.
var battles_book : Dictionary = {}	# contains dicts defining battles.
var creascripts_book : Dictionary = {}	#a  dict of  scriptname:creature ai gdscript


var maps_book : Dictionary = {}	#contains maps
var thingtypes : Dictionary = {"ground" : 0, "ground_level" : 1, "furnitures" : 2, "creatures" : 3, "structures" : 4}

var sounds_book : Dictionary = {}

var spells_book : Dictionary = {}

var musics_book : Dictionary = {}
var musics_types_book : Dictionary = {}

var special_encounters_book : Dictionary = {}

#var shopsGD = null

# Initialize resources #
func _ready():
	pass
	load_music_resources(Paths.datafolderpath+'Music/')
#	load_shared_ressources()
#	load_map_resources()
#	load_audios()

# Load data that any campaign can access
#func load_shared_ressources() ->void:
#	var path : String = "shared_assets/tiles/"
#	g_img_pack = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path + "img_pack.json"))
#	g_stuff_book = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path +"stuff_book.json"))
#	g_texture_atlas.load(path+"textureAtlas.png")
#	pass


# dict must have a SCRIPT_source  key with the script source as the value
func _add_script_to_dict_from_source(dict : Dictionary,scriptname : String , argsstring : String) :
		print("_add_script_to_dict_from_source : adding script "+scriptname+" to dict")#+dict["name"])
		var newscript : GDScript = GDScript.new()
		var source : String = "static func "+scriptname+argsstring + "  :\n" + dict[scriptname+"_source"]
#		print("_add_script_to_dict_from_source : script source : "+ source)
		print(source)
		newscript.set_source_code(source)
		var _err_newscript_reload = newscript.reload()
		dict[scriptname] = newscript
		print("done adding script")

#func_add_script_to_bbatlle_dict(battle_dict : Dictionary,,scriptname : String , argsstring : String) :
	


func clear_ressources() -> void:
	tiles_book.clear()
	battles_book.clear()
	crea_book.clear()
	maps_book.clear()
	items_book.clear()
	sounds_book.clear()
	musics_book.clear()
	musics_types_book.clear()
	special_encounters_book.clear()
	spells_book.clear()
	creascripts_book.clear()
#	shopsGD = null
	load_music_resources(Paths.datafolderpath+'Music/')


func load_campaign_ressources( campaign : String = "") ->void :
	print("RESOURCES load_campaign_ressources")
	
	
	
	clear_ressources()
	load_tile_resources("shared_assets/tiles/")
	var tilesetspath : String = Paths.campaignsfolderpath + campaign + "/Tilesets/"
	if DirAccess.dir_exists_absolute(tilesetspath) :
		#var tilesets : Array = Utils.FileHandler.list_dirs_in_directory(tilesetspath)
		#for ts in tilesets :
		load_tile_resources(tilesetspath)# + ts + '/')
	
	load_item_resources("shared_assets/items/")
	var itemsetpath : String = Paths.campaignsfolderpath + campaign + "/Items/"
	if DirAccess.dir_exists_absolute(itemsetpath) :
		load_item_resources(itemsetpath)
	
	load_sound_ressources("shared_assets/sounds/")
	var soundsspath : String = Paths.campaignsfolderpath + campaign + "/Sounds/"
	if DirAccess.dir_exists_absolute(soundsspath) :
		load_sound_ressources(soundsspath)
	
#	print(sounds_book)
	load_music_resources(Paths.datafolderpath+'Music/')
	var musicspath = Paths.campaignsfolderpath + campaign + "/Music/"
	if DirAccess.dir_exists_absolute(musicspath) :
		load_music_resources(musicspath)
	
	print("Resources B4load spells")
	
	load_spell_resources( "res://shared_assets/spells/" )
	var spellspath = Paths.campaignsfolderpath + campaign + "/Spells/"
	if DirAccess.dir_exists_absolute(spellspath) :
		load_spell_resources(spellspath)
#	print("\n\n", "spell resources : \n", spells_book.keys() ,"\n\n")
	
	load_creature_ai_resources("res://shared_assets/CreatureScripts/")
	var creascriptspath : String = Paths.campaignsfolderpath + campaign + "/CreatureScripts/"
	if DirAccess.dir_exists_absolute(creascriptspath) :
		load_creature_ai_resources(creascriptspath)
	
	load_bestiary_resources("res://shared_assets/Bestiary/")
	var bestiarypath = Paths.campaignsfolderpath + campaign + "/Bestiary/"
	if DirAccess.dir_exists_absolute(bestiarypath) :
		load_bestiary_resources(bestiarypath)
	
	load_battle_resources(campaign)
	
#	print(" ")
#	print("crea_book : ")
#	print(crea_book)
#	print(" ")
	
	load_special_encounter_resources(campaign)
	# only done once checked starting the campaign !
#	load_shops_resources(campaign, items_book)
	
	var mapspath : String =  Paths.campaignsfolderpath + campaign + "/Maps/"
	var mapnames : Array = Utils.FileHandler.list_dirs_in_directory(mapspath)
	for mn in mapnames :
		load_map_ressources(mapspath + mn + '/', mn)

#	print(maps_book.keys())
#	print (tiles_book["BYWATER_extrafloor"])

# Load tiles data, added to the tiles_book ressource dictionary #
func load_tile_resources( path : String ) -> void:		
	# load the tile data at the "path" location
	
	
	#make a list of the folders inside the directory at paths
	var tileset_folder_names : Array = Utils.FileHandler.list_dirs_in_directory(path)
#	print("resources load_tile_resources tileset_folder_names : ", tileset_folder_names)
	
	for ts_name in tileset_folder_names : 
		print("resource load tiles : ", ts_name)
		var n_tileset : Array = []
		var n_ts_json_data : Dictionary = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path +'/'+ ts_name + "/"+ts_name+".json"))
		
		var atlas_width : int = n_ts_json_data["columns"]
		
		var texture_atlas : Image = Image.new()
		var _err_textureatlasload = texture_atlas.load(path +'/'+ ts_name + '/'+ts_name+".png")
		var tileset_name : String = n_ts_json_data["name"]
		var json_tiles_array : Array = n_ts_json_data["tiles"]
		
		var templates_dict : Dictionary = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path +'/'+ ts_name + "/tile_templates.json"))
		#print(json_tiles_array.size())
		for id in range(n_ts_json_data["tilecount"]) :
			
			var t_dict : Dictionary =  json_tiles_array[id]
#			print("resource load tiles : ", tileset_name, ' : ', t_dict["properties"][0]["value"])
			var n_tile_dict = {}
			
			#find the position of the tile's image based on id and the exture atlas 's size
			var x_pos : int = id % atlas_width
			var y_pos : int = floor(float(id)/float(atlas_width))
			var rect = Rect2i(x_pos * Utils.GRID_SIZE, y_pos * Utils.GRID_SIZE, Utils.GRID_SIZE, Utils.GRID_SIZE)
			# Create a new texture for this thing #
			var texture = ImageTexture.new()
			var image = texture_atlas.get_region(rect)
			# Loads texture from texture atlas #
			texture = ImageTexture.create_from_image(image) #,0
			var imgbk_key : String = tileset_name+str(id)
			#print("Resource tiles : "+imgbk_key)
			images_book[imgbk_key] = {}
			images_book[imgbk_key]["img"] = image
			images_book[imgbk_key]["tex"] = texture
			
			n_tile_dict["texture"] = texture
			#set tiles  data from its template
			var tile_name : String = t_dict["properties"][0]["value"]
			var tile_template_name : String = t_dict["properties"][1]["value"]
			#print("resource tile_template_name :  "+tile_template_name+ " for "+tile_name+" id "+str(id))
			#print("Resources var template_dict ", tile_template_name,' ', templates_dict.has(tile_template_name))
			var template_dict : Dictionary = templates_dict[tile_template_name]
			for property in template_dict.keys() :
				n_tile_dict[property] = template_dict[property]
			n_tile_dict["name"] = tile_name
			n_tile_dict["tileset_name"] = ts_name
			n_tile_dict["id"]= id
			n_tileset.append(n_tile_dict)
		tiles_book[ts_name+'.json'] = n_tileset
#	print(tiles_book)
	##########
#	opk so  to load tilesets :
#upon loading the scenario
#array : allTilesetsUsedInScenario  #just load the tileset as dictionaries as  normal but keep them separated, identified  by  an index i  this array
#
#to load a map :
#for  each tile, convert  their  global id  to  [id in their tileset, pointer to tileset]  , using the  "tilesets"  array i just copypasted to calculate it
#Then build the map  ([x][y][layer]), again as a 3d  array of tile datas  ( = ref to  image  and  template name ) 
#only  the first step  requires  extra work
#should be good enough
#
#
#	var n_tile_img_pack = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path + "img_pack.json"))
#
#
#
#	var texture_atlas : Image = Image.new()
#	var _err_textureatlasload = texture_atlas.load(path+"textureAtlas.png")
#
#	for i in n_tile_img_pack :
#		# Get position inside  texture atlas #
#		var rect = Rect2i(n_tile_img_pack[i]["0_ref_x"] * Utils.GRID_SIZE, n_tile_img_pack[i]["0_ref_y"] * Utils.GRID_SIZE, Utils.GRID_SIZE, Utils.GRID_SIZE)
#		# Create a new texture for this thing #
#		var texture = ImageTexture.new()
#		var image = texture_atlas.get_region(rect)
#		# Loads texture from texture atlas #
#		texture = ImageTexture.create_from_image(image) #,0
#		images_book[i] = {}
#		images_book[i]["img"] = image
#		images_book[i]["tex"] = texture
#
#
#
#	var n_tile_stuff_book : Dictionary = {}
#	n_tile_stuff_book = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path +"stuff_book.json"))
#
#	var n_tile_templates : Dictionary = {}
#	n_tile_templates = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path +"tile_templates.json"))
#	var n_tile_defs : Dictionary = {}
#	n_tile_defs = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path +"tile_defs.json"))
#
#
#	for thing_name in n_tile_stuff_book :
#		# Iterate through each tile name, load image data for it #
#		# Get img ref #
#		var img_ref = n_tile_stuff_book[thing_name]["img_ptr"]
#		# find texture in images_book :
#		var texture = images_book[img_ref]["tex"]
#		# assign texture
#		n_tile_stuff_book[thing_name]["texture"] = texture
#
#		for item in n_tile_templates[n_tile_defs[thing_name]].keys() :
#			n_tile_stuff_book[thing_name][item] = n_tile_templates[n_tile_defs[thing_name]][item]
#
#	for thing_name in n_tile_stuff_book :
#		tiles_book[thing_name] = n_tile_stuff_book[thing_name]
##	var folderpath : String = Paths.realmzfolderpath + "Campaigns"
	print("Don loading tiles from : ", path)
	return

func load_item_resources( path : String ) -> void:		
	# load the item data at the "path" location
	var n_item_img_pack : Dictionary = {}
	n_item_img_pack = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path + "img_pack.json"))
	var texture_atlas : Image = Image.new()
	var _err_textureatlasload = texture_atlas.load(path+"textureAtlas.png")

	for i in n_item_img_pack :
		# Get position inside  texture atlas #
		var rect = Rect2(n_item_img_pack[i]["0_ref_x"] * 32, n_item_img_pack[i]["0_ref_y"] * 32, 32, 32)
		# Create a new texture for this thing #
		var image = texture_atlas.get_region(rect)
		# Loads texture from texture atlas #
		var texture = ImageTexture.create_from_image(image) #,0
		images_book[i] = {}
		images_book[i]["img"] = image
		images_book[i]["tex"] = texture

	var n_item_stuff_book : Dictionary = {}
	n_item_stuff_book = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path +"stuff_book.json"))
#	print("\nloaded n_item_stuff_book ?\n")
#	print(n_item_stuff_book)

	for item_name in n_item_stuff_book :
		var new_item = generate_item_from_json_dict(n_item_stuff_book[item_name])
		n_item_stuff_book[item_name] = new_item

#		print("done loading item "+new_item["name"]  )

	for item_name in n_item_stuff_book :
		items_book[item_name] = n_item_stuff_book[item_name]
#	var folderpath : String = Paths.realmzfolderpath + "Campaigns"


func load_bestiary_resources( path : String ) -> void:
	
	var creatureGD : GDScript = preload("res://Creature/Creature.gd")
	var crea_template = creatureGD.new()
	
	var n_crea_img_pack : Dictionary = {}
	n_crea_img_pack = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path + "img_pack.json"))
	var texture_atlas : Image = Image.new()
	var _err_textureatlasload = texture_atlas.load(path+"textureAtlas.png")
	
	#load images to images_book
	for i in n_crea_img_pack :
		var size_txt : String = n_crea_img_pack[i]["size"]
		var size : Vector2 = Vector2.ZERO
		match size_txt :
			"32x32" :
				size = Vector2(32,32)
			"32x64" :
				size = Vector2(32,64)
			"64x32" :
				size = Vector2(64,32)
			"64x64" :
				size = Vector2(64,64)
		# Get position inside  texture atlas #
		var rect = Rect2(32*n_crea_img_pack[i]["0_ref_x"], 32*n_crea_img_pack[i]["0_ref_y"], size.x, size.y)
		# Create a new texture for this thing #
		
#		print(" RESOURCE RECT : ", rect)
		
		var image = texture_atlas.get_region(rect)
		# Loads texture from texture atlas #
		var texture = ImageTexture.create_from_image(image) #,0
		images_book[i] = {}
		images_book[i]["img"] = image
		images_book[i]["tex"] = texture

	var n_crea_stuff_book : Dictionary = {}
	n_crea_stuff_book = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path +"stuff_book.json"))
	#load creature data
	for crea_name in n_crea_stuff_book :
		var new_crea_data = { "stats" : crea_template.stats.duplicate() , "tools" : {} }
		var ncreastatmods = n_crea_stuff_book[crea_name]["stats"]
		for s in ncreastatmods :
			new_crea_data["stats"][s] = ncreastatmods[s]
		if n_crea_stuff_book[crea_name].has("traits") :
			#print("RESOURCELOADER n_crea_stuff_book[crea_name][traits] : "+crea_name+" : ", n_crea_stuff_book[crea_name]["traits"])
			new_crea_data["traits"] = n_crea_stuff_book[crea_name]["traits"]
		new_crea_data["data"] = n_crea_stuff_book[crea_name] ["data"]
		new_crea_data["data"]["image"] = images_book[ new_crea_data["data"]["image"] ]["tex"]
		new_crea_data["tools"] = n_crea_stuff_book[crea_name]["tools"]
		new_crea_data["ai"] = n_crea_stuff_book[crea_name]["ai"]
		new_crea_data["scripts"] = n_crea_stuff_book[crea_name]["scripts"]
		n_crea_stuff_book[crea_name] = new_crea_data
	#add to crea book
	for crea_name in n_crea_stuff_book :
		crea_book[crea_name] = n_crea_stuff_book[crea_name]

func generate_item_from_json_dict(json_dict : Dictionary) -> Dictionary :
	# sets  item's sound image etc from its dict data
	# need to load sounds first !

#	print("generate_item_from_json_dict, has imgdata ? ",json_dict["name"],' ',json_dict.has("imgdata"))

	var new_item : Dictionary = {}
	if not json_dict.has("imgdata"):
#		print("RESOURCE generate_item_from_json_dict ITEM HAS NO imgdata ! "+json_dict["name"])
		# item comes from a  stuffbook... get the image from imagebook
		# Get img ref #
		var img_ref = json_dict["img_ptr"]
		# find texture in images_book :
		var texture = images_book[img_ref]["tex"]
		# assign texture
		new_item["texture"] = texture
		var image : Image = images_book[img_ref]["img"]

		var imgdata : PackedByteArray = image.save_png_to_buffer()
		var imgdatasize : int = imgdata.size()
		var imgdatacompressed : PackedByteArray = imgdata.compress(FileAccess.COMPRESSION_GZIP)
		# use  imgdatacompressed.decompress(imgdatasize, File.COMPRESSION_GZIP)  to decompress
		# now i need to turn this into a string
		new_item["imgdatasize"] = imgdatasize
#		new_item["name"] = "lol"
		new_item["imgdata"]  = Marshalls.raw_to_base64(imgdatacompressed)
		# use Marshalls.base64_to_raw(new_item["imgdata"]) to recover  the compressed image data
		#</new>
	else :
		if json_dict["imgdatasize"] >0 :
			var texture = Utils.load_texture_as_string(json_dict["imgdata"], json_dict["imgdatasize"])
			new_item["texture"] = texture
			new_item["imgdata"] = json_dict["imgdata"]
			new_item["imgdatasize"] = json_dict["imgdatasize"]

	new_item["name"] = json_dict["name"]
	new_item["type"] = json_dict["type"]
	new_item["sound"] = json_dict["sound"]
	
	if json_dict.has("unique") :
		new_item["unique"] = json_dict["unique"]
	else :
		new_item["is_unique"] = 0
	
	if json_dict.has("is_magical") :
		new_item["is_magical"] = json_dict["is_magical"]
	else :
		new_item["is_magical"] = 0
	
	if json_dict.has("unidentified_name") :
		new_item["unidentified_name"] = json_dict["unidentified_name"]
		if not json_dict.has("is_identified") :
			new_item["is_identified"] = 0
	else :
		new_item["unidentified_name"] = json_dict["name"]
		new_item["is_identified"] = 1
	if json_dict.has("is_identified") :
		new_item["is_identified"] = json_dict["is_identified"]
	
	if json_dict.has("is_magical") :
		new_item["is_magical"] = json_dict["is_magical"]
	else :
		new_item["is_magical"] = 0
	
	if json_dict.has("hands") :
		new_item["hands"] = json_dict["hands"]
	else :
		new_item["hands"] = 0
	
	if json_dict.has("unique") :
		new_item["unique"] = json_dict["unique"]
	else :
		new_item["unique"] = 0
	
	if json_dict.has("description") :
		new_item["description"] = json_dict["description"]
	else :
		new_item["description"] = ''
	
	if json_dict.has("delete_on_empty") :
		new_item["delete_on_empty"] = json_dict["delete_on_empty"]
	else :
		new_item["delete_on_empty"] = 0
	
	if json_dict.has("slots") :
		new_item["slots"] = json_dict["slots"]
	else :
		new_item["slots"] = []
	
	if json_dict.has("equippable") :
		new_item["equippable"] = json_dict["equippable"]
	else :
		new_item["equippable"] = 0
	if json_dict.has("equipped") :
		new_item["equipped"] = json_dict["equipped"]
	else :
		new_item["equipped"] = 0
	
	if json_dict.has("only_usable_by_classes") :
		new_item["only_usable_by_classes"] = json_dict["only_usable_by_classes"]
	if json_dict.has("not_usable_by_classes") :
		new_item["not_usable_by_classes"] = json_dict["not_usable_by_classes"]
	if json_dict.has("only_usable_by_races") :
		new_item["only_usable_by_races"] = json_dict["only_usable_by_races"]
	if json_dict.has("not_usable_by_races") :
		new_item["not_usable_by_races"] = json_dict["not_usable_by_races"]
	
	if json_dict.has("stats") :
		new_item["stats"] = json_dict["stats"]
	else :
		if new_item.has('equippable') :
			new_item["stats"] = {}
	
	if json_dict.has("stats_mini") :
		new_item["stats_mini"] = json_dict["stats_mini"]
	else :
		new_item["stats_mini"] = ''
	
	if json_dict.has("charges") :
		new_item["charges_max"] = json_dict["charges_max"]
		new_item["charges"] = json_dict["charges"]
	else :
		new_item["charges_max"] = 0
		new_item["charges"] = 0
	
	
	
	if json_dict.has("tradeable") :
		new_item["tradeable"] = json_dict["tradeable"]
	else :
		new_item["tradeable"] = 1
	
	if json_dict.has("weight") :
		new_item["weight"] = json_dict["weight"]
	else :
		new_item["weight"] = 0
	
	if json_dict.has("price") :
		new_item["price"] = json_dict["price"]
	else :
		new_item["price"] = 0
	
	if json_dict.has("charges_weight") :
		new_item["charges_weight"] = json_dict["charges_weight"]
	else :
		new_item["charges_weight"] = 0
	
	if json_dict.has("splittable") :
		new_item["splittable"] = json_dict["splittable"]
	else :
		new_item["splittable"] = 0
	
	if json_dict.has("ammo_type") :
		new_item["ammo_type"] = json_dict["ammo_type"]
	else :
		new_item["ammo_type"] = 'cantuse'
	
	if json_dict.has("custom_spell_source") :
		var custom_spell_source : String = json_dict["custom_spell_source"]
		var custom_spellscript : GDScript = GDScript.new()
		custom_spellscript.set_source_code(custom_spell_source)
#		print("resources.gd DONE set source code for "+sn+" , before reload()")

		var _err_newscript_reload = custom_spellscript.reload()
#		print(_err_newscript_reload)
		var newscript = custom_spellscript.new()
		spells_book[custom_spellscript.name] = { "name" : custom_spellscript.name, "source" : custom_spell_source, "script" : custom_spellscript}

	if json_dict.has("weapon_dmg") :
		new_item["weapon_dmg"] = json_dict["weapon_dmg"]
		if json_dict.has("melee_atk_anim_icon") :
			new_item["melee_atk_anim_icon"] = json_dict["melee_atk_anim_icon"]
		else :
			new_item["melee_atk_anim_icon"] = "ATK_HTH"
			
		if json_dict.has("weapon_tag_bonus_dmg") :
			new_item["weapon_tag_bonus_dmg"] = json_dict["weapon_tag_bonus_dmg"]
	#Load Scripts !
#	print("checking for item scripts  in "+new_item["name"])

	if json_dict.has("_on_equipping_source") :
		new_item["_on_equipping_source"] = json_dict["_on_equipping_source"]
		_add_script_to_dict_from_source(new_item,"_on_equipping", "(_character, _item)")
		
	if json_dict.has("_on_unequipping_source") :
		new_item["_on_unequipping_source"] = json_dict["_on_unequipping_source"]
		_add_script_to_dict_from_source(new_item,"_on_unequipping", "(_character, _item)")
#	print("lol")
	if json_dict.has("_on_field_use_source") :
		new_item["_on_field_use_source"] = json_dict["_on_field_use_source"]
		_add_script_to_dict_from_source(new_item,"_on_field_use", "(_character, _item)")
	if json_dict.has("_on_combat_use_source") :
		new_item["_on_combat_use_source"] = json_dict["_on_combat_use_source"]
		_add_script_to_dict_from_source(new_item,"_on_combat_use", "(_character, _item)")

	if json_dict.has("_on_field_use_spell") :
		new_item["_on_field_use_spell"] = json_dict["_on_field_use_spell"]
	if json_dict.has("_on_combat_use_spell") :
		new_item["_on_combat_use_spell"] = json_dict["_on_combat_use_spell"]


	if json_dict.has("_on_drop_source") :
		new_item["_on_drop_source"] = json_dict["_on_drop_source"]
		_add_script_to_dict_from_source(new_item,"_on_drop", "(_character, _item)")
	
	if json_dict.has("_calculate_melee_attack_source") :
		new_item["_calculate_melee_attack_source"] = json_dict["_calculate_melee_attack_source"]
		_add_script_to_dict_from_source(new_item,"_calculate_melee_attack", "(_attacker, _defender, _weapon,  _is_crit, _crit_mult)")
	
	if json_dict.has("_calculate_melee_accuracy_source") :
		new_item["_calculate_melee_accuracy_source"] = json_dict["_calculate_melee_accuracy_source"]
		_add_script_to_dict_from_source(new_item,"_calculate_melee_accuracy", "(_attacker, _defender, _weapon)")
	
	if json_dict.has("extra_data") :
		new_item["extra_data"] = json_dict["extra_data"].duplicate(true)
	
	# load traits !
	if json_dict.has("traits") :
		new_item["traits"] = json_dict["traits"]
		for traitarray in json_dict["traits"] :
			print("item traitarray ",traitarray)
			var traitname = traitarray[0]
			var traitinit = traitarray[1]
			var newscript : GDScript = GDScript.new()

			if traitname.ends_with('.gd') :
				newscript = load("res://shared_assets/traits/"+traitname)
#				var args : Array = traitinit
				new_item[traitname] = [newscript,traitinit]#.new(args)
			else :
				new_item[traitname+"_source"] = json_dict[traitname+"_source"]
				newscript.set_source_code(new_item[traitname+"_source"])
				var _err_newscript_reload = newscript.reload()
				if _err_newscript_reload != OK :
					print("ERROR LOADING ITEM TRAIT SCRIPT "+new_item["name"] + " "+traitname+ " , error code : "+_err_newscript_reload)
#				var new_trait_script = newscript.new(traitinit)
#				new_trait_script.
				new_item[traitname] = [newscript,traitinit]#new_trait_script
	
	if json_dict.has("melee_inflicted_traits") :
		#print("RESOURCES : item "+new_item["name"]+"has melee_inflicted_traits")
		new_item["melee_inflicted_traits"] = json_dict["melee_inflicted_traits"]
		for traitarray in json_dict["melee_inflicted_traits"] :
			print("item traitarray ",traitarray)
			var traitname = traitarray[0]
			var traitinit = traitarray[1]
			var chance = traitarray[2]
			var newscript : GDScript = GDScript.new()

			if traitname.ends_with('.gd') :
				newscript = load("res://shared_assets/traits/"+traitname)
#				var args : Array = traitinit
				new_item[traitname] = [newscript,traitinit]#.new(args)
			else :
				new_item[traitname+"_source"] = json_dict[traitname+"_source"]
				newscript.set_source_code(new_item[traitname+"_source"])
				var _err_newscript_reload = newscript.reload()
				if _err_newscript_reload != OK :
					print("ERROR LOADING ITEM inflicetdTRAIT SCRIPT "+new_item["name"] + " "+traitname+ " , error code : "+_err_newscript_reload)
#				var new_trait_script = newscript.new(traitinit)
#				new_trait_script.
				new_item[traitname] = [newscript,traitinit]#new_trait_script
#				else :
#					print("NO ERROR LOADING ITEM TRAIT SCRIPT "+new_item["name"] + " "+traitname)
			
#				print("\n\n")
#				print("new_item "+new_item["name"]+ " "+traitname+" \n" , new_item[traitname] )
#				print("\n\n")
#	new_item["name"] = "lelele"
	return new_item
	

func load_sound_ressources( path : String ) -> void :
	var filenames : Array = Utils.FileHandler.list_files_in_directory(path)
	var soundnames : Array = []
	for s in filenames :
		if s.ends_with(".ogg") or s.ends_with(".wav") or s.ends_with(".mp3"):
			soundnames.append(s)
	print ("sounds in folder : ",soundnames)
	for s in soundnames :	
#		print("sound path : ", path+s)
		var loadedsound : AudioStream
		# DOESNT WORK IN  OUTSIDE FOLDERS !
		if path == "shared_assets/sounds/" :  #easy to load from inside res:// !
			loadedsound = load(path+s)
		else :
			var snd_file : FileAccess = FileAccess.open(path+s, FileAccess.ModeFlags.READ)
#			ogg_file.open(path+s, File.READ)
			var bytes = snd_file.get_buffer(snd_file.get_length())
			if s.ends_with("ogg") :
				loadedsound = AudioStreamOggVorbis.new()
				print("Resources OGG outside sharedassets is glitchy, "+s+" not loaded")
			elif s.ends_with("mp3") :
				loadedsound = AudioStreamMP3.new()
				loadedsound.data = bytes
			elif s.ends_with("wav") :
#				if assert(stream.format == AudioStreamSample.FORMAT_8_BITS) :
				print("Resources WAV outside sharedassets is glitchy, "+s+" not loaded")
#				bytes = convert_wav_pcm8(bytes)
#				loadedsound = AudioStreamWAV.new()
#				loadedsound.data = bytes
			elif s.ends_with("ogg") :
				print("RESOURCE L577 : FIX OGG LOADER WORKS ???")
				loadedsound = AudioStreamOggVorbis.load_from_file(path+s)
				
			snd_file.close()
		
		sounds_book[s] = loadedsound



func load_music_resources(path : String) :
	#path =  path to  a Music folder that may have subfolders
	print('Resources.gd load_music_resources ',path)
	#Paths.datafolderpath+"Music/"
	var subfoldernames = Utils.FileHandler.list_dirs_in_directory(path)
	#list all subfolders, this is just an array of Strings
	for sf in subfoldernames :
		if not musics_types_book.has(sf) :
			musics_types_book[sf] = {}
		var sfpath = path + sf #+ '/'
		var sfmusicnames = Utils.FileHandler.list_files_in_directory(sfpath)
		#again just an array of Strings
		for sfmn in sfmusicnames :
			var musicdict = {}
			if sfmn.ends_with("ogg") :
				print("RESOURCE L400 TODO : FIX OGG LOADER   SRSLY")
				musicdict["type"] = 'ogg'
				#just load .. NOTB ECAUSE IT S OUSTIDE res://
#				musicdict["sound"] = load(sfpath+'/'+sfmn)

#				var ogg_file : FileAccess = FileAccess.open(sfpath+'/'+sfmn, FileAccess.ModeFlags.READ)
#				var bytes = ogg_file.get_buffer(ogg_file.get_length())
#
				var loadedsound = AudioStreamOggVorbis.new()
				print("RESOURsE LOADER OGG MUSIC !!! "+sfmn, ", path is : "+sfpath+'/'+sfmn)
				#SOMEHOW THIS CRASHES var loadedsound : AudioStreamOggVorbis = AudioStreamOggVorbis.load_from_file(sfpath+'/'+sfmn)
				#loadedsound.load_from_file(sfpath+'/'+sfmn)
					
##				loadedsound.data = bytes
#				loadedsound.packet_sequence.packet_data = bytes
#				ogg_file.close()

				musicdict["sound"] = loadedsound
				
			elif sfmn.ends_with("mp3") :
				musicdict["type"] = 'mp3'
				var mp3_file = FileAccess.open(sfpath+'/'+sfmn, FileAccess.ModeFlags.READ)
#				mp3_file.open(sfpath+'/'+sfmn, File.READ)
				var bytes = mp3_file.get_buffer(mp3_file.get_length())
				var loadedsound = AudioStreamMP3.new()
				loadedsound.data = bytes
				mp3_file.close()
				musicdict["sound"] = loadedsound
			elif sfmn.ends_with(".mod") or sfmn.ends_with(".xm") :
				musicdict["type"] = 'mod'
			
			musicdict["path"] = sfpath+'/'+sfmn
				#the modplayer addon uses the path
			musics_types_book[sf][sfmn] = musicdict
			musics_book[sfmn]= musicdict
			
#			print("music resource loaded : "+sfmn,","+String(musicdict))
#	pass
#	print("MSUIC LOADED")
#	print(musics_book)

func load_spell_resources(path : String) :
#	print("resources.gd load_spell_resources "+path)
#	print("load_spell_resources : "+ path +"spells_book.json")
	var n_spells_book = Utils.FileHandler.read_json_dic_from_file(path +"spells_book.json")
#	print("n_spells_book : ", n_spells_book)
	for sn in n_spells_book :
#		print("adding " +sn)

		var spellscript : GDScript = GDScript.new()
		var spellsource = n_spells_book[sn]
#		print("resources.gd before setting spell source code for "+sn)
#		print(spellsource)
		spellscript.set_source_code(spellsource)
#		print("resources.gd DONE set source code for "+sn+" , before reload()")

		var _err_newscript_reload = spellscript.reload()
#		print(_err_newscript_reload)
		var newscript = spellscript.new()
		spells_book[sn] = { "name" : sn, "source" : spellsource, "script" : newscript}
#		print("resources.gd DONE reload() for "+sn)
		
#		print("LITTLE TEST, ", spells_book[sn]["script"].get_min_damage(7))

# load map data, convert to an array, added to the maps_book ressource dictionary
func load_map_ressources( path : String , _name : String) -> void :
	print("Resources load_map_ressources ", _name)
	var newmapdict : Dictionary = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path+"map_things.json"))
	var newmapinfo : Dictionary = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path+"map_info.json"))
	var newmapscriptareas : Dictionary = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(path+"map_scriptareas.json"))
	
	var newmapscripts : GDScript = load(path + "map_scripts.gd" )
	
	var sizey : int = newmapdict[ "height"]
	var sizex : int = newmapdict[ "width"]
	var mapname : String = newmapinfo[ "name"]
	var maptype : String = newmapinfo["map_type"]
	var mapmusictype : String = newmapinfo["music_type"]
	var outdoor_riding : bool = newmapinfo["outdoor_riding"]
	var darkness_level : int = newmapinfo["darkness_level"]
	var display_explored_only : bool = bool(newmapinfo["display_explored_only"])
	
	# get the ids occupied by each tileset used here
	var used_tilesets_array : Array = newmapdict["tilesets"] #{(}"source.json :string = first_id : int}
	var ts_first_id_dict : Dictionary = {}
	for uts in used_tilesets_array :
		ts_first_id_dict[uts["source"]] = uts["firstgid"]
#	print(used_tilesets_array)
	# build the array
	var newmapdata : Array = []
	for _y in range(sizey) :
		var newline : Array = []
		for _x in range(sizex) :
			newline.append([])
		newmapdata.append(newline)
	
	var explored_tiles : Array = []
	for _y in range(sizey) :
		var newline : Array = []
		for _x in range(sizex) :
			newline.append(0)
		explored_tiles.append(newline)
	
	
	# fill the array with the items found in the json
	for layer in newmapdict["layers"] :
		var t_number : int = 0
#		print('layer["chunks"][0]["data"] : \n', layer["chunks"][0]["data"])
		for tn in layer["chunks"][0]["data"] :

			if tn==0 :
				t_number+=1
				continue
#			print(tn)
			
			var used_tileset_name : String = used_tilesets_array[0]["source"]
			
			for uts in used_tilesets_array :
				if uts["firstgid"] > tn :
					break
				used_tileset_name = uts["source"]
			var t_id = tn - ts_first_id_dict[used_tileset_name] #id of the tile in its own tileset
			var y : int = floor(float(t_number)/float(sizex))
			var x : int = t_number%sizex
			var tile = tiles_book[used_tileset_name][t_id]
			newmapdata[x][y].append(tile)
#			print("newmapdata" , newmapdata)
#			return
			t_number+=1
	###
#	for t in newmapdict[ "map_units" ] :
#
#		var x = t["x"]
#		var y = t["y"]
##		var z = t["z"]
##		if z == 3 :
#		var light : bool = bool(t["has_light"])
#		var items : Array = Array(t["items"])
#		items.sort_custom(Callable(self,"sort_item_type"))
#		# items should be organized by layer
#		var newtiledata : Dictionary = {"items":items, "light":light}
#
#		newmapdata[x][y].append(newtiledata)
#	var secret_paths : Dictionary = {}
#	var secrets : Dictionary = {}
	maps_book[mapname] = [newmapdata, newmapscriptareas, newmapscripts, maptype,mapmusictype, outdoor_riding, darkness_level, display_explored_only, explored_tiles]
	print("Resources done load map resources : ", _name)
	return


func load_special_encounter_resources(campaign : String) :
#	print("RESOURCES load_special_encounter_resources")
	var encounters_folder_path = Paths.campaignsfolderpath+ campaign + "/Special Encounters/"
	var encounter_file_names : Array = Utils.FileHandler.list_files_in_directory(encounters_folder_path)
	for fn in encounter_file_names :
#		print("encounter : ", fn)
		var enc = load(encounters_folder_path+fn).new()
#		print("encounter enc : ", enc)
		special_encounters_book[fn] = enc
#	print("special encounters : ", special_encounters_book.keys())

func load_battle_resources(campaign : String) :
	print("Resources load_battle_resources :")
	var battles_folder_path = Paths.campaignsfolderpath+ campaign + "/Battles/"
	var n_battle_stuff_book : Dictionary = {}
	n_battle_stuff_book = Utils.FileHandler.read_json_dictionary_from_txt(Utils.FileHandler.read_txt_from_file(battles_folder_path +"battles.json"))
	for b in n_battle_stuff_book.keys() :
		print(n_battle_stuff_book[b])
		for s in ["start","turn","win","lose","flee"] :
			if n_battle_stuff_book[b]["Scripts"].has(s+"_source") :
				_add_script_to_dict_from_source(n_battle_stuff_book[b]["Scripts"],s,'()')
	for b in n_battle_stuff_book :
		battles_book[b] = n_battle_stuff_book[b] # { "Map" : b["Map"], "Creatures" : {}, "Scripts" : {} }

func sort_item_type(a : String, b : String):
	# comparator for sorting items by  layer as defined in  thing_types.json
	return thingtypes[tiles_book[a]["type"]] < thingtypes[tiles_book[b]["type"]]


func load_creature_ai_resources(path : String) :
	print("resources.gd load_creature_ai_resources "+path)
	var scriptfilenames : Array = Utils.FileHandler.list_files_in_directory(path)
#	var n_creascripts_book = Utils.FileHandler.read_json_dic_from_file(path +"spells_book.json")
#	print("n_spells_book : ", n_spells_book)
	for sn in scriptfilenames :
#		print("adding " +sn)
		var newcreascript = load(path+sn)
		creascripts_book[sn] = newcreascript


""" Accessible resources """

# Tiles Book :
func get_tiles_book() -> Dictionary:
	return tiles_book

func get_sounds_book() -> Dictionary:
	return sounds_book




# Img Pack
#func get_img_pack() -> Dictionary:
#	return g_img_pack

# Stuff Book
#func get_stuff_book() -> Dictionary:
#	return g_stuff_book

# Map things
#func get_map_things() -> Dictionary:
#	return g_map_things

# Thing types - Layers
#func get_thing_types() -> Array:
#	return g_thing_types
#
## Get texture Atlas #
#func get_texture_atlas() -> Image:
#	return g_texture_atlas


