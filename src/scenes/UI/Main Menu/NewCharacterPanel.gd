extends NinePatchRect

const ClassicCampaignInstallScript = preload(
	"res://scripts/classic_runtime/classic_campaign_install.gd"
)
const ClassicCharacterRulesScript = preload(
	"res://scripts/classic_runtime/classic_character_rules.gd"
)
const ClassicItemMaterializerScript = preload(
	"res://scripts/classic_runtime/classic_item_materializer.gd"
)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@export var cancelButton : Button# = $CancelButton
@export var okButton : Button# = $OKButton
@export var lineEdit : LineEdit# = $LineEdit
@export var portraitContainer : GridContainer# = $"PortraitScrollContainer/PortraitContainer"
@export var iconContainer : GridContainer# = $"IconScrollContainer/IconContainer"
@export var portraitScroll : ScrollContainer# = $"PortraitScrollContainer"
@export var iconScroll : ScrollContainer# = $"IconScrollContainer"
@export var toggleButton : Button# = $"ToggleIcoPortButton"
@export var classitemlist : ItemList #= $"ClassItemList"
@export var raceitemlist : ItemList #= $"RaceItemList"
@export var characterstatrect : NewCharStatsRect #= $"CharacterStatsRect"
@export var levelMenuButton : MenuButton #= $"LevelMenuButton"
@export var classicContextLabel : Label
@export var genderOptionButton : OptionButton


@export var abilities_rect : AbilitiesManagementRect

var iconsImages : Array = []
var portraitsTextures: Array = []
var iconsTextures : Array = []

var classesgd : Array = []
var racesgd : Array = []
var newchar_level = 1
#var onlyportrait : Texture2D = preload("res://Main Menu/onlyportrait.png")

var new_char_name = ""
@onready var new_char_portrait : Texture2D = load("res://scenes/UI/Main Menu/DefaultPortrait.png")
@onready var new_char_icon : Texture2D = load("res://scenes/UI/Main Menu/DefaultIcon.png")
var new_char_class : GDScript = null
var new_char_race : GDScript = null

var new_character = null
var previous_music_info = null  # Store info about music playing before character creation
var classic_campaign_name := ""
var classic_install: Object
var classic_race_options: Array[Dictionary] = []
var classic_caste_options: Array[Dictionary] = []
var classic_race_id := 0
var classic_caste_id := 0
var classic_gender := 1
var return_to_campaign_panel: Control
var classic_creation_active := false

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
	genderOptionButton.item_selected.connect(_on_gender_selected)
	genderOptionButton.visible = false
	classicContextLabel.visible = false

	# Connect to visibility changed signal to handle music
	connect("visibility_changed", Callable(self, "_on_visibility_changed"))


func configure_classic_campaign(
	campaign_name: String,
	campaign_panel: Control
) -> Dictionary:
	var install = ClassicCampaignInstallScript.new()
	if not install.load_from_campaigns_directory(
		Paths.campaignsfolderpath,
		campaign_name
	):
		return {"status": "error", "message": install.last_error}
	classic_campaign_name = campaign_name
	classic_install = install
	return_to_campaign_panel = campaign_panel
	classicContextLabel.text = (
		"Creating for %s — scenario race and caste rules apply."
		% str(install.bundle.manifest.get("name", campaign_name))
	)
	classicContextLabel.visible = true
	genderOptionButton.visible = true
	classic_gender = 1
	classic_creation_active = false
	genderOptionButton.select(0)
	fill()
	loadClassesRaces()
	fillClassesRacesMenus()
	return {"status": "ok"}


func clear_classic_campaign_context() -> void:
	classic_campaign_name = ""
	classic_install = null
	classic_race_options.clear()
	classic_caste_options.clear()
	classic_race_id = 0
	classic_caste_id = 0
	classic_gender = 1
	classic_creation_active = false
	classicContextLabel.visible = false
	genderOptionButton.visible = false
	return_to_campaign_panel = null


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
	print("try create", new_char_class, new_char_race)
	if not (new_char_class and  new_char_race) :
		return
	var construction_level: int = 1 if classic_install != null else newchar_level
	new_character = GameGlobal.playerCharacterGD.new(
		{"level": construction_level},
		new_char_icon,
		new_char_portrait,
		new_char_class,
		new_char_race
	)
	if classic_install != null:
		new_character.classic_race_id = classic_race_id
		new_character.classic_caste_id = classic_caste_id
		var classic_result := (
			ClassicCharacterRulesScript.initialize_character_creation(
				classic_install.bundle,
				new_character,
				classic_gender,
				newchar_level
			)
		)
		var classic_status := str(classic_result.get("status", ""))
		if classic_status == "native":
			new_character = GameGlobal.playerCharacterGD.new(
				{"level": newchar_level},
				new_char_icon,
				new_char_portrait,
				new_char_class,
				new_char_race
			)
			new_character.classic_race_id = classic_race_id
			new_character.classic_caste_id = classic_caste_id
			classic_creation_active = false
		elif classic_status == "ok":
			classic_creation_active = true
		else:
			classicContextLabel.text = str(classic_result.get(
				"message",
				"The selected Classic race and caste cannot create a character."
			))
			new_character = null
			classic_creation_active = false
			okButton.disabled = true
			return
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
	levelMenuButton.set_text(str(ID))
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
	if classic_install != null:
		classic_race_options = _classic_identity_options(
			"race",
			racesgd
		)
		classic_caste_options = _classic_identity_options(
			"caste",
			classesgd
		)


func fillClassesRacesMenus() :
	classitemlist.clear()
	raceitemlist.clear()
	if classic_install != null:
		for option_index: int in range(classic_caste_options.size()):
			var caste_option: Dictionary = classic_caste_options[option_index]
			classitemlist.add_item(str(caste_option.get("name", "")))
			classitemlist.set_item_tooltip(
				option_index,
				str(caste_option.get("tooltip", ""))
			)
			classitemlist.set_item_disabled(
				option_index,
				not bool(caste_option.get("allowed", true))
			)
		for option_index: int in range(classic_race_options.size()):
			var race_option: Dictionary = classic_race_options[option_index]
			raceitemlist.add_item(str(race_option.get("name", "")))
			raceitemlist.set_item_tooltip(
				option_index,
				str(race_option.get("tooltip", ""))
			)
			raceitemlist.set_item_disabled(
				option_index,
				not bool(race_option.get("allowed", true))
			)
		return
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


func _classic_identity_options(
	identity_kind: String,
	native_definitions: Array
) -> Array[Dictionary]:
	var rules: Dictionary = classic_install.bundle.documents.get("rules", {})
	var rule_names: Dictionary = rules.get("ruleNames", {})
	var names_value: Variant = rule_names.get(
		"raceNames" if identity_kind == "race" else "casteNames",
		[]
	)
	var names: Array = names_value if names_value is Array else []
	if names.is_empty():
		names = (
			ClassicItemMaterializerScript.STANDARD_RACE_NAMES.duplicate()
			if identity_kind == "race"
			else ClassicItemMaterializerScript.STANDARD_CASTE_NAMES.duplicate()
		)
	var native_by_name: Dictionary = {}
	for definition_value: Variant in native_definitions:
		if not (definition_value is GDScript):
			continue
		var definition: GDScript = definition_value
		var definition_name := str(
			definition.get_script_constant_map().get("classrace_name", "")
		)
		native_by_name[definition_name.to_lower()] = definition
	var fallback_name := "Human" if identity_kind == "race" else "Fighter"
	var fallback: GDScript = native_by_name.get(fallback_name.to_lower())
	if fallback == null and not native_definitions.is_empty():
		fallback = native_definitions[0]

	var option_ids: Array[int] = []
	for definition_name_value: Variant in native_by_name.keys():
		var definition_name := str(definition_name_value)
		for name_index: int in range(names.size()):
			if str(names[name_index]).to_lower() == definition_name:
				option_ids.append(name_index + 1)
				break
	var table_selection: Dictionary = rules.get("tableSelection", {})
	var selected_table: Dictionary = table_selection.get(
		"races" if identity_kind == "race" else "castes",
		{}
	)
	if str(selected_table.get("source", "")) == "scenario-local":
		for record_id_value: Variant in selected_table.get(
			"changedRecordIds",
			[]
		):
			var identity_id := int(record_id_value) + 1
			if identity_id > 0 and identity_id not in option_ids:
				option_ids.append(identity_id)
	option_ids.sort()

	var selection_rules: Dictionary = classic_install.selection_rules()
	var banned_ids: Variant = selection_rules.get(
		"bannedRaceIds" if identity_kind == "race" else "bannedCasteIds",
		[]
	)
	var options: Array[Dictionary] = []
	for identity_id: int in option_ids:
		if identity_id < 1 or identity_id > names.size():
			continue
		var display_name := str(names[identity_id - 1]).strip_edges()
		if display_name.is_empty():
			continue
		var native_definition: GDScript = native_by_name.get(
			display_name.to_lower(),
			fallback
		)
		var allowed: bool = not (
			banned_ids is Array and identity_id in banned_ids
		)
		options.append({
			"id": identity_id,
			"name": display_name,
			"nativeDefinition": native_definition,
			"allowed": allowed,
			"tooltip": (
				"Not allowed by this scenario."
				if not allowed
				else "Uses this scenario's active Classic rules."
			),
		})
	return options


func _on_class_select(i : int) :
	if classic_install != null:
		var option: Dictionary = classic_caste_options[i]
		new_char_class = option.get("nativeDefinition") as GDScript
		classic_caste_id = int(option.get("id", 0))
	else:
		new_char_class = classesgd[i]
	_on_LineEdit_changed(lineEdit.text)
	characterstatrect.display_partial_selection(new_char_race, new_char_class)
	try_create_character()

func _on_race_select(i : int) :
	if classic_install != null:
		var option: Dictionary = classic_race_options[i]
		new_char_race = option.get("nativeDefinition") as GDScript
		classic_race_id = int(option.get("id", 0))
	else:
		new_char_race = racesgd[i]
	_on_LineEdit_changed(lineEdit.text)
	characterstatrect.display_partial_selection(new_char_race, new_char_class)
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
	var campaign_panel := return_to_campaign_panel
	var campaign_name := classic_campaign_name
	fill()
	clear_classic_campaign_context()
	self.hide()
	if campaign_panel != null \
			and campaign_panel.has_method("resume_after_character_creation"):
		campaign_panel.call(
			"resume_after_character_creation",
			campaign_name
		)
#	self.get_parent().get_parent().newCampaignButton.show()

func _on_OKButton_pressed() -> void :
	if new_character==null or new_char_name == "" or new_char_class==null or new_char_race==null :
		okButton.disabled = true
		return
	new_character.name = new_char_name
	if not classic_creation_active:
		new_character.exp_tnl = PlayerCharacter.get_exp_req_for_lvl(
			new_character.level + 1
		)
		new_character.level = newchar_level
	if classic_install != null:
		new_character.cur_campaign = classic_campaign_name
	
	NodeAccess.__Resources().load_spell_resources("res://shared_assets/spells/")
	


	#var max_spell_level = new_character.classgd.max_spell_lvl
	#new_character.spells.clear()
	#for i  in  range(max_spell_level) :
		#new_character.spells.append([])

	# Let native identities get their ordinary gifts. Active Classic profiles
	# receive their source-ordered resources after spell selection below.
	if not classic_creation_active:
		await new_character.racegd._character_creation_gifts(new_character)
		await new_character.classgd._character_creation_gifts(new_character)
	
	
	printerr("Newcharpanel before adding spells ;", new_character.spells)
	abilities_rect.set_displayed_character(new_character, true, [])
	abilities_rect.show()
	await abilities_rect.on_closed

	if classic_creation_active:
		var resources: Object = NodeAccess.__Resources()
		var campaign_items_path: String = (
			classic_install.campaign_directory.path_join("Items") + "/"
		)
		if resources != null \
				and FileAccess.file_exists(
					campaign_items_path.path_join("stuff_book.json")
				):
			resources.load_item_resources(campaign_items_path)
		var item_book: Dictionary = (
			resources.items_book
			if resources != null and resources.items_book is Dictionary
			else {}
		)
		var item_ids: Object = ItemIdDivinity
		var item_mapping: Dictionary = (
			item_ids.mapping
			if item_ids != null and item_ids.mapping is Dictionary
			else {}
		)
		var resource_result := (
			ClassicCharacterRulesScript.apply_character_creation_resources(
				new_character,
				item_book,
				item_mapping
			)
		)
		if str(resource_result.get("status", "")) != "ok":
			classicContextLabel.text = str(resource_result.get(
				"message",
				"Classic starting resources could not be applied."
			))
			okButton.disabled = true
			return
	
	
#
	# generate the stats modification  trait script source

	var statsmodsdict : Dictionary = (
		{}
		if classic_creation_active
		else characterstatrect.stat_mods_dict
	)
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


	var path = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/Characters/'+new_char_name
	print("new char path : ", path)
	DirAccess.make_dir_recursive_absolute(path)

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
	if new_char_name == "" :
		okButton.disabled = true
		characterstatrect.display_name("")
		return
	var is_valid_filename : Array = Utils.FileHandler.is_valid_file_name(new_char_name)
	if is_valid_filename[0]!=1 :
		okButton.disabled = true
		characterstatrect.display_name(is_valid_filename[1])
		return
	if DirAccess.dir_exists_absolute(Paths.profilesfolderpath+Paths.currentProfileFolderName+"/Characters/"+new_char_name) :
		okButton.disabled = true
		characterstatrect.display_name("NAME ALREADY USED")
	else :
		okButton.disabled = false
		characterstatrect.display_name(new_char_name)

func fill() -> void :
	lineEdit.text = ""
	new_char_name = ""
	classitemlist.deselect_all()
	raceitemlist.deselect_all()
	new_char_race = null
	new_char_class = null
	new_char_portrait = default_portrait
	new_char_icon = default_icon
	portraitRect.texture = default_portrait
	iconRect.texture = default_icon
	new_character = null
	classic_creation_active = false
	classic_race_id = 0
	classic_caste_id = 0
	newchar_level = 1
	levelMenuButton.set_text('1')
	okButton.disabled = true
	characterstatrect.clear()
	characterstatrect.display_portrait(default_portrait)


func _on_gender_selected(index: int) -> void:
	classic_gender = index + 1
	if classic_install != null and new_char_class != null and new_char_race != null:
		try_create_character()
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

func _on_visibility_changed():
	if visible:
		# Panel is being shown - play character creation music
		print("Starting character creation music")
		# Store current music info so we can restore it later
		previous_music_info = MusicStreamPlayer.currently_playing.duplicate()
		MusicStreamPlayer.play_music_type("Create")
	else:
		# Panel is being hidden - restore previous music
		print("Stopping character creation music")
		if previous_music_info != null and previous_music_info.has("path") and previous_music_info["path"] != '':
			# Restore the previous music
			MusicStreamPlayer.play_music(previous_music_info)
		else:
			# No previous music was playing, so stop music
			MusicStreamPlayer.stop()
		previous_music_info = null
