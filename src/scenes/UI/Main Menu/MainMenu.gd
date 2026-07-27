extends Control

@export var newprofileVBox : VBoxContainer
@export var honest_mode_label : Label

@export var profilebutton : Button
@export var profilespopup : PopupMenu
@onready var newCampaignButton : Button = $NewCampaignButton
@onready var newCampaignPanel : NinePatchRect = $NewCampaignPanel
@onready var newCharacterButton : Button = $NewCharacterButton
@onready var loadgameButton : Button = $LoadButton
@onready var loadgameWindow : Window = $LoadWindow
@onready var loadgameCtrl : SaveLoadCtrl = $LoadWindow/SaveLoadRect
@onready var newCharacterPanel : NinePatchRect = $NewCharacterPanel
@onready var hdModeCheckButton : CheckButton = $HDButton
var profileslist : Array =  []
var initial_profile_ready := false

signal initial_profile_loaded

# Called when the node enters the scene tree for the first time.
func _ready():
	newprofileVBox.my_menu = self
	build_profiles_list()
	#var config = FileAccess.open(Paths.realmzfolderpath+"settings.cfg", FileAccess.ModeFlags.WRITE_READ)
	#if config:
		#config.close()

	var profilefromcfg = Utils.FileHandler.get_cfg_setting(Paths.settingspath,"SETTINGS","current_profile", "Default Profile")
	pass
	var hd_mode_from_config = Utils.FileHandler.get_cfg_setting(Paths.settingspath,"SETTINGS","hd_mode", false)
	var game_speed_from_config := float(
		Utils.FileHandler.get_cfg_setting(
			Paths.settingspath,
			"SETTINGS",
			"game_speed_percent",
			GameGlobal.DEFAULT_GAME_SPEED_PERCENT
		)
	)
	var map_debug_overlays_from_config := bool(
		Utils.FileHandler.get_cfg_setting(
			Paths.settingspath,
			"SETTINGS",
			"show_map_debug_overlays",
			true
		)
	)
	
	GameGlobal.set_hd_mode(hd_mode_from_config)
	GameGlobal.set_game_speed_percent(game_speed_from_config)
	GameGlobal.set_map_debug_overlays_enabled(map_debug_overlays_from_config)
	_load_initial_profile_after_first_frame(profilefromcfg, hd_mode_from_config)


func _load_initial_profile_after_first_frame(
	profilefromcfg: String,
	hd_mode_from_config: bool
) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_inside_tree():
		return
#	var dir = Directory.new()
	if DirAccess.dir_exists_absolute(Paths.profilesfolderpath+"/" + profilefromcfg) :
#	if dir.dir_exists(Paths.profilesfolderpath+"/" + profilefromcfg) :
		GameGlobal.set_current_profile(profilefromcfg)
		honest_mode_label.visible = GameGlobal.honest_mode
		profilebutton.text = profilefromcfg
		newCampaignButton.disabled = false
		newCharacterButton.disabled = false
		loadgameButton.disabled = false
		hdModeCheckButton.button_pressed = GameGlobal.hd_mode
		if GameGlobal.hd_mode:
			ScreenUtils.set_window_scale(self, 2.0)
	initial_profile_ready = true
	initial_profile_loaded.emit()

	#print("Mainmenu _ready over")





func build_profiles_list() -> void :
	profilespopup.clear()
#	for child in profilespopup.get_children() :
#		profilespopup.remove_child(child)
#		child.queue_free()
	profileslist = Utils.FileHandler.list_dirs_in_directory(Paths.profilesfolderpath)
	print("profileslist : ", Paths.profilesfolderpath)
	for i in range(profileslist.size()) :
		#add_item(label: String, id: int = -1, accel: int = 0)
		profilespopup.add_item(profileslist[i])






func _on_profile_button_pressed():
	profilespopup.set_position ( self.get_position() )
	profilespopup.popup()
	profilespopup.show()


func _on_profile_popup_menu_id_pressed(id):
	newCampaignButton.disabled = false
	newCharacterButton.disabled = false
	loadgameButton.disabled = false
	profilebutton.text = profileslist[id]
	GameGlobal.set_current_profile(profileslist[id])
	honest_mode_label.visible = GameGlobal.honest_mode


func _on_new_character_button_pressed():
	newCharacterPanel.clear_classic_campaign_context()
	newCharacterPanel.set_clean_character()
	newCharacterPanel.fill()
	newCharacterPanel.loadClassesRaces()
	newCharacterPanel.fillClassesRacesMenus()
	newCharacterPanel.show()
#	newCampaignButton.hide()

func _on_new_campaign_button_pressed():
	newCampaignPanel.fill()
	newCampaignPanel.show()
#	newCharacterButton.hide()


func _on_load_button_pressed():
	loadgameCtrl.fill('',false)
	loadgameCtrl.show()
	loadgameWindow.show()


func _on_hd_button_pressed():
	var hd_mode_chosen = hdModeCheckButton.button_pressed

	if hd_mode_chosen:
		# Switch to HD
		ScreenUtils.set_window_scale(self, 2.0)
	else:
				ScreenUtils.set_window_scale(self, 1.0)
		# Switch to SD


	GameGlobal.set_hd_mode(hd_mode_chosen)

	# Save the setting on change, otherwise smart defaults will be used every time
	# for the screen you start the game on
	GameGlobal.save_hd_mode(hd_mode_chosen)
