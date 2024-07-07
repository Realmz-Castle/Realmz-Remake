"""
Author: Francisco de Biaso Neto
email: kikinhobiaso@gmail.com

####################
### Utils Module ###
####################

This module contains auxiliary functions and constantes.
"""
extends Node

# Constant #
const GRID_SIZE := 32


func load_texture_as_string(imgstring : String, imgdatasize : int) -> Texture:
	var imgdataraw : PackedByteArray = Marshalls.base64_to_raw(imgstring)
	var imgdatadecmprsd : PackedByteArray = imgdataraw.decompress(imgdatasize, FileAccess.COMPRESSION_GZIP)

	var image : Image = Image.new()
	image.load_png_from_buffer(imgdatadecmprsd)
	var texture : ImageTexture = ImageTexture.new()
	texture.create_from_image(image) #,0 # no flags, no fil
	return ImageTexture.create_from_image(image)



# File manipulator #
class FileHandler:	
	
	const forbidden_windows_file_names :  Array = ['CON', 'PRN', 'AUX', 'NUL', 'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9', 'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9' ]
	
	static func is_valid_file_name(new_text : String)->Array :
#		print("is_valid_file_name : "+new_text)
		if new_text.is_empty() :
			return [-1, "Empty !"]
		if new_text.begins_with(' ') :
			return [-1, "Begins with a space !"]
		if new_text.ends_with(' ') :
			return [-1, "Ends with a space !"]
		if new_text.begins_with('\t') :
			return [-1, "Begins with a tab !"]
		if new_text.ends_with('\t') :
			return [-1, "Ends with a tab !"]
		var found : Array = []
		for c in ['/','\\','|',':','?','*','<','>',"\""] :
			if new_text.find(c)>=0 :
				found.append(c)
		if not found.is_empty() :
			var text : String = "Found illegal characters :  "
			for c in found :
				text = text+c
			return [-2, text]
		
		var textbeforedot : String = new_text
		var dotsplit : PackedStringArray = new_text.split('.')
		if not dotsplit.is_empty() :
			textbeforedot = dotsplit[0]
			
		for fn in forbidden_windows_file_names :
			var capfn = fn.to_upper()
			if capfn == textbeforedot.to_upper() :
				return [-3, "Forbidden File Name in Windows"]
		
		if new_text.ends_with(' ') or new_text.ends_with('\t') :
			return [-4, "File Name ends with WiteSpace"]
		
		if new_text.begins_with(' ') or new_text.begins_with('\t') :
			return [-5, "File Name begins with WiteSpace"]
		
		return [1, "Valid Name"]
	
	
	
	static func read_json_array_from_txt(txt) -> Array:
		var test_json_conv = JSON.new()
		test_json_conv.parse(txt)
		var data_parse = test_json_conv.get_data()
		if data_parse.error != OK:
			return []
		return data_parse.result	
	
	static func read_json_dic_from_file(path) -> Dictionary:
		return read_json_dictionary_from_txt(read_txt_from_file(path))

	static func read_json_dictionary_from_txt(txt) -> Dictionary:
#		print(txt)
		var test_json_conv = JSON.new()
		var err = test_json_conv.parse(txt)
		var data_parsed : Dictionary = test_json_conv.data
		if err != OK:
				print("GLOBAL : read_json_dictionary_from_txt parse text ERROR "+ str(err) )
				return {}
		return data_parsed#.result

	static func read_txt_from_file(path) -> String:
#		var data_file = File.new()
#		if data_file.open(path, File.READ) != OK:
#			return ""
#		print("Utils read_txt_from_file : ", path)
		var file : FileAccess = FileAccess.open(path, FileAccess.ModeFlags.READ)
		
		var data_text = file.get_as_text()
		file = null #fileaccess is closed when it's  freed, no close() since godot4
		return data_text
		
	static func list_files_in_directory(path) -> Array :  #copied from profileslist.gd
		var dir = DirAccess.open(path)
		return dir.get_files()

	static func list_dirs_in_directory(path) :
		var dir = DirAccess.open(path)
		return dir.get_directories()

	static func get_cfg_setting(path, section, key, default) :
		var config = ConfigFile.new()
#		print(Paths.realmzfolderpath+"settings.cfg")
		var err = config.load(path)
		if err == OK: # if not, something went wrong with the file loading
			return config.get_value(section, key, default)	
	#	if not config.has_section_key(section, key):
	#			print(section, key)
		else :
			print("err",err)
				
	static func set_cfg_setting(path, section, key, value) :
		var config = ConfigFile.new()
		var err = config.load(path)
		if err == OK: # if not, something went wrong with the file loading
			# Look for the display/width pair, and default to 1024 if missing
	#		var screen_width = config.get_value("display", "width", 1024)
			# Store a variable if and only if it hasn't been defined yet
	#		if not config.has_section_key("audio", "mute"):
			config.set_value(section, key, value)
			print('    ',key, value)
		else :
			print("ERROR",err, " set_cfg_setting ",path)
		# Save the changes by overwriting the previous file
		config.save(path)
	
	static func load_character(path)-> PlayerCharacter :		
		
		var newicon = Utils.FileHandler.load_img_texture(path+"/icon.png")

		var newportrait = Utils.FileHandler.load_img_texture(path+"/portrait.png")
		var jsonresult = read_json_dic_from_file(path+'/data.json')		

		var classgd : GDScript = load(path + "/class.gd")
		var racegd : GDScript = load(path + "/race.gd")
		
		#if not jsonresult.has("base_stats") :
			#print("UTILS load_character "+jsonresult["name"]+": NO BASE STATS YET")
		#else :
			#print("UTILS load_character "+jsonresult["name"]+": Melee_Crit_Rate ? "+str(jsonresult["base_stats"]["Melee_Crit_Rate"]))

		var newchar = GameGlobal.playerCharacterGD.new(jsonresult, newicon, newportrait, classgd, racegd)

		return newchar
	
	
	static func save_character(path : String, chara) :
		print("Utils : saving character "+chara.name)
#		var save_char = File.new()
#		save_char.open(path+'/data.json', File.WRITE)
		print("Utils save : ",path+'/data.json')
		var save_char_file : FileAccess = FileAccess.open(path+'/data.json', FileAccess.ModeFlags.WRITE)
		if save_char_file==null :
			print("ERROR save_character save_char_file get_open_error() : ", FileAccess.get_open_error() )
#		var data_text : String = save_char_file.get_as_text()
#		file = null #fileaccess is closed when it's  freed, no close() since godot4

		#save simple stuff
		save_char_file.store_line(chara.get_save_string())

		save_char_file = null #fileaccess is closed when it's  freed, no close() since godot4

		
		
		var classsource : String = chara.classgd.get_source_code()
		save_char_file = FileAccess.open(path+'/class.gd', FileAccess.ModeFlags.WRITE)
#		save_char_file.open(path+'/class.gd', FileAccess.ModeFlags.WRITE)
		save_char_file.store_string(classsource)
		save_char_file = null
		
		var racesource : String = chara.racegd.get_source_code()
		save_char_file = FileAccess.open(path+'/race.gd', FileAccess.ModeFlags.WRITE)
		save_char_file.store_string(racesource)
		save_char_file = null

		var _err_savepng_portrait = chara.portrait.get_image().save_png(path+"/portrait.png")
		var _err_savepng_icon = chara.icon.get_image().save_png(path+"/icon.png")
	
		print("Utils : DONE saving character "+chara.name)
	
	static func load_img_texture(path) ->ImageTexture :
		var img = Image.new()
		var err = img.load(path)
		if (err!=0) :
			print("error ",err," loading img at "+ path)
			return ImageTexture.new()
		else :
			var tex = ImageTexture.create_from_image(img)
			return tex
	
	
class Render:
	static func setAllChildrenLayers(nodeFather):
		if nodeFather == null:
			return
		for N in nodeFather.get_children():
			if N.get_child_count() > 0:  
				setAllChildrenLayers(N)
			else:			
				N.z_index = N.z_index + definition.Render.get_layer_space()		
				print(N.z_index)

func _ready() :
	pass
