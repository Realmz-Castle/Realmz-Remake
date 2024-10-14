extends NinePatchRect

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@export var cancelButton : Button# = $CancelButton
@export var okButton : Button# = $OKButton
@export var lineEdit : LineEdit# = $LineEdit
@export var nameLabel : Label# = $NameLabel
@export var portraitContainer : GridContainer# = $"PortraitScrollContainer/PortraitContainer"
@export var iconContainer : GridContainer# = $"IconScrollContainer/IconContainer"
@export var portraitScroll : ScrollContainer# = $"PortraitScrollContainer"
@export var iconScroll : ScrollContainer# = $"IconScrollContainer"
@export var toggleButton : Button# = $"ToggleIcoPortButton"
@export var classitemlist : ItemList #= $"ClassItemList"
@export var raceitemlist : ItemList #= $"RaceItemList"
@export var characterstatrect : NewCharStatsRect #= $"CharacterStatsRect"
@export var levelMenuButton : MenuButton #= $"LevelMenuButton"


var iconsImages : Array = []
var portraitsTextures: Array = []
var iconsTextures : Array = []

var classesgd : Array = []
var racesgd : Array = []
var newchar_level = 1
#var onlyportrait : Texture2D = preload("res://Main Menu/onlyportrait.png")

var new_char_name = "[NO NAME]"
@onready var new_char_portrait : Texture2D = load("res://scenes/UI/Main Menu/DefaultPortrait.png")
@onready var new_char_icon : Texture2D = load("res://scenes/UI/Main Menu/DefaultIcon.png")
var new_char_class : GDScript = null
var new_char_race : GDScript = null

var new_character = null

@export var portraitRect : TextureRect# = $"PortraitRect"
@export var iconRect : TextureRect# = $"IconRect"

@onready var default_icon : Texture2D = preload("res://scenes/UI/Main Menu/DefaultIcon.png")
@onready var default_portrait : Texture2D = preload("res://scenes/UI/Main Menu/DefaultPortrait.png")

#var dir = Directory.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var _err_on_CancelButton_pressed = cancelButton.connect("pressed",Callable(self,"_on_CancelButton_pressed"))
	var _err_on_OKButton_pressed = okButton.connect("pressed",Callable(self,"_on_OKButton_pressed"))
	var _err_on_LineEdit_changed = lineEdit.connect("text_changed",Callable(self,"_on_LineEdit_changed"))
	fillIconsPortraitsChoices()
	loadClassesRaces()
	fillClassesRacesMenus()
	fillLevelMenuButton([1,3,5,10,15,20,30])


func set_clean_character() :
	new_character = null
	
	new_char_portrait = default_portrait
	portraitRect.texture = default_portrait
	characterstatrect.display_portrait(portraitRect.texture )
	new_char_icon = default_icon
	iconRect.texture = default_icon
	
#	new_character = GameGlobal.playerCharacterGD.new({"name":"ENTER NAME"}, default_icon, default_portrait, null, null)
	#GameGlobal.playerCharacterGD.new(jsonresult, newicon, newportrait, classgd, racegd)

func try_create_character() :
#	print("try_create_character : ", new_char_name)
	if not (new_char_class and  new_char_race) :
		return
	new_character = GameGlobal.playerCharacterGD.new({"level":newchar_level}, new_char_icon, new_char_portrait, new_char_class, new_char_race)
	new_character.portrait = new_char_portrait
	new_character.icon = new_char_icon
	new_character.name = new_char_name
#	new_character.apply_raceclass_base_stats()
#	for l in range(newchar_level) : done in  playerCharacterGD _init now
#		new_character.level_up()
#	new_character.recalculate_stats()
	characterstatrect.display_data(new_character)

func fillLevelMenuButton(levels : Array) :
	var popup : PopupMenu = levelMenuButton.get_popup()
	for l in levels :
		popup.add_item(str(l), l)
	popup.connect("id_pressed",Callable(self,"_on_level_picked"))

func _on_level_picked(ID):
	newchar_level = ID
	levelMenuButton.set_text(String(ID))
	characterstatrect.set_character_level(newchar_level)
	if new_character :
		try_create_character()


func fillIconsPortraitsChoices():
	var portraitspath = Paths.datafolderpath+"Character Portraits/"
	var portraitfilenames : Array = Utils.FileHandler.list_files_in_directory(portraitspath)
#	print("NewCharacter portraitfilenames : ",portraitfilenames )
	portraitfilenames.sort()
	for pfn in portraitfilenames :
		var portraittex = Utils.FileHandler.load_img_texture(portraitspath+pfn)
		portraitsTextures.append(portraittex)
	var iconspath = Paths.datafolderpath+"Character Icons/"
	print('newcharacterpanel iconspath : ', iconspath)
	var iconfilenames : Array = Utils.FileHandler.list_files_in_directory(iconspath)
	iconfilenames.sort()
	for ifn in iconfilenames :
		var icontex = Utils.FileHandler.load_img_texture(iconspath+ifn)
		iconsTextures.append(icontex)
	
	for p in range(portraitsTextures.size()) :
		var b = Button.new()
		b.flat = true
		b.icon = portraitsTextures[p]
		b.connect("pressed",Callable(self,"_on_portrait_button_pressed").bind(p))
		portraitContainer.add_child(b)
	for i in range(iconsTextures.size()) :
		var b = Button.new()
		b.flat = true
		b.icon = iconsTextures[i]
		b.connect("pressed",Callable(self,"_on_icon_button_pressed").bind(i))
		iconContainer.add_child(b)


func loadClassesRaces() :
	classesgd = []
	racesgd = []
	var classespath = Paths.datafolderpath+"Character Classes/"
	var classesfilenames : Array = Utils.FileHandler.list_files_in_directory(classespath)
	classesfilenames.sort()
	for cf in classesfilenames :
		var classgd : GDScript = load(classespath + cf)
		classesgd.append(classgd)
	var racespath = Paths.datafolderpath+"Character Races/"
	var racesfilenames : Array = Utils.FileHandler.list_files_in_directory(racespath)
	racesfilenames.sort()
	for rf in racesfilenames :
		var racegd : GDScript = load(racespath + rf)
		racesgd.append(racegd)


func fillClassesRacesMenus() :
	var i=0
	for c  in classesgd :
		classitemlist.add_item(c.classrace_name)
		classitemlist.set_item_tooltip(i,c.classrace_definition)
		i=i+1
	i=0
	for r in racesgd :
		raceitemlist.add_item(r.classrace_name)
		raceitemlist.set_item_tooltip(i,r.classrace_definition)
		i=i+1


func _on_classrace_select(i : int, isclass : bool) :
	if isclass :
		new_char_class = classesgd[i]
	else :
		new_char_race = racesgd[i]
	if new_char_name != "[NO NAME]" and new_char_name == "" and new_char_class!=null and new_char_race!=null :
		okButton.disabled = false
	_on_LineEdit_changed(lineEdit.text)
#	characterstatrect.display_raceclass(new_char_race,new_char_class)
	try_create_character()

	

func _on_portrait_button_pressed(i : int) :
	new_char_portrait = portraitsTextures[i]
	if new_character :
		new_character.portrait = portraitsTextures[i]
	portraitRect.texture = portraitsTextures[i]
	characterstatrect.display_portrait( portraitsTextures[i])


func _on_icon_button_pressed(i : int) :
	new_char_icon = iconsTextures[i]
	iconRect.texture = iconsTextures[i]
	if new_character :
		new_character.icon = iconsTextures[i]

func _on_CancelButton_pressed() -> void :
	self.hide()
#	self.get_parent().get_parent().newCampaignButton.show()

func _on_OKButton_pressed() -> void :
	if new_character==null or new_char_name == "[NO NAME]" or new_char_name == "" or new_char_class==null or new_char_race==null :
		okButton.disabled = true
		return
	new_character.name = new_char_name
	new_character.exp_tnl = PlayerCharacter.get_exp_req_for_lvl(new_character.level +1)
	new_character.level = newchar_level
	var path = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/Characters/'+new_char_name
	print("new char path : ", path)
	DirAccess.make_dir_recursive_absolute(path)
	

	
	#let the character  get their free stuff
	new_character.racegd._character_creation_gifts(new_character)
	new_character.classgd._character_creation_gifts(new_character)
#
	# generate the stats modification  trait script source

	var statsmodsdict : Dictionary = characterstatrect.stat_mods_dict
	print("NewCharacterPanel ADDING custom_stats.gd ? ", statsmodsdict.size() >0)
	if statsmodsdict.size() >0 :
		print("NewCharacterPanel ADDING custom_stats.gd")
		var traitscript = load('res://shared_assets/traits/custom_stats.gd')
#		var ntraitscript = traitscript.new([statsmodsdict])
		new_character.add_trait(traitscript, [statsmodsdict])
#	var stats_mod_source : String = "var name : String = 'character_creation_stats_mod'\n"
#	for stat in statsmodsdict.keys() :
#		stats_mod_source += "\nvar "+"_on_calculate_"+stat+" : int = "+String(statsmodsdict[stat])
#	var traitscript : GDScript = GDScript.new()
#	traitscript.set_source_code(stats_mod_source)
#	var _err_traitscript_reload = traitscript.reload()
#	if _err_traitscript_reload != OK :
#		print("ERROR LOADING CHARACTER CREATION STATS MOD TRAIT SCRIPT, error code : "+_err_traitscript_reload)
#	var  traitscriptinstance = traitscript.new()
#	new_character.add_trait(traitscriptinstance)

#
#	path = "D:/Programming/Godot 4/Godot 4 Projects/Realmz Remake Folder/Profiles/Samuel/Saves/City of Bywater/toto/Characters/test"
	

	new_character.stats["curHP"] = new_character.get_stat("maxHP")
	match new_character.used_resource :
		"SP" : 
			new_character.stats["curSP"] = new_character.get_stat("maxSP")
	
	
	Utils.FileHandler.save_character(path, new_character)

	
	GameGlobal.load_character_to_profile(new_character.name)
	
#	save_char.open(path+'/data.json', File.WRITE)
#	save_char.store_line('{"name":"'+new_char_name+'", "free":1}')
#	save_char.close()
#
#
#	var classsource : String = new_char_class.get_source_code()
#	save_char.open(path+'/class.gd', File.WRITE)
#	save_char.store_string(classsource)
#	save_char.close()
#	var racesource : String = new_char_race.get_source_code()
#	save_char.open(path+'/race.gd', File.WRITE)
#	save_char.store_string(racesource)
#	save_char.close()
#
#	var _err_savepng_portrait = new_char_portrait.get_data().save_png(path+"/portrait.png")
#	var _err_savepng_icon = new_char_icon.get_data().save_png(path+"/icon.png")

	_on_CancelButton_pressed()

func _on_LineEdit_changed(newtext : String) -> void :
	new_char_name = newtext
	nameLabel.text = new_char_name
#	print(Autoloaded.profilesfolderpath+"/"+Autoloaded.currentProfileFolderName+"/Characters/"+new_char_name)
#	if dir.dir_exists(Paths.profilesfolderpath+"/"+Paths.currentProfileFolderName+"/Characters/"+new_char_name) :
	var is_valid_filename : Array = Utils.FileHandler.is_valid_file_name(new_char_name)
	if is_valid_filename[0]!=1 :
		nameLabel.set('custom_colors/font_color' , Color(1,0,0,1) )
		okButton.disabled = true
		characterstatrect.display_name(is_valid_filename[1])
		return
	print("NEWCAMPAIGNPANEL.GD CHECK")
	print(Paths.profilesfolderpath+Paths.currentProfileFolderName+"/Characters/"+new_char_name)
	print("DirAccess.dir_exists_absolute ? ", DirAccess.dir_exists_absolute(Paths.profilesfolderpath+Paths.currentProfileFolderName+"/Characters/"+new_char_name))
	if DirAccess.dir_exists_absolute(Paths.profilesfolderpath+Paths.currentProfileFolderName+"/Characters/"+new_char_name) :
		nameLabel.set('custom_colors/font_color' , Color(1,0,0,1) )
		okButton.disabled = true
		characterstatrect.display_name("NAME ALREADY USED")
	else :
		nameLabel.set('custom_colors/font_color' , Color(0,1,0,1) )
		okButton.disabled = false
		characterstatrect.display_name(new_char_name)

func fill() -> void :
	lineEdit.text = "[NO NAME]"
	new_char_name = "[NO NAME]"
	classitemlist.deselect_all()
	raceitemlist.deselect_all()
	new_char_race = null
	new_char_class = null
	characterstatrect.display_name(new_char_name)
	newchar_level = 1
	levelMenuButton.set_text('1')
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ToggleIcoPortButton_pressed():
	portraitScroll.visible = not portraitScroll.visible
	iconScroll.visible = not iconScroll.visible
	if portraitScroll.visible :
		toggleButton.text = "Show Icons"
		if iconsTextures.size() == portraitsTextures.size() :
			portraitScroll.set_v_scroll(iconScroll.get_v_scroll())
	else :
		toggleButton.text = "Show Portraits"
		if iconsTextures.size() == portraitsTextures.size() :
			iconScroll.set_v_scroll(portraitScroll.get_v_scroll())
		
