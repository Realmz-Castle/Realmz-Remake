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

# Called when the node enters the scene tree for the first time.
func _ready():	
	newprofileVBox.my_menu = self
	build_profiles_list()
	var profilefromcfg = Utils.FileHandler.get_cfg_setting(Paths.realmzfolderpath+"settings.cfg","SETTINGS","current_profile", "Default Profile")
	var hd_mode_from_config = Utils.FileHandler.get_cfg_setting(Paths.realmzfolderpath+"settings.cfg","SETTINGS","hd_mode", GameGlobal.hd_mode)
	GameGlobal.set_hd_mode(hd_mode_from_config)
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
	newCharacterPanel.set_clean_character()
	newCharacterPanel.fill()
	newCharacterPanel.show()
#	newCampaignButton.hide()

func _on_new_campaign_button_pressed():
	newCampaignPanel.fill()
	newCampaignPanel.show()
#	newCharacterButton.hide()


func _on_load_button_pressed():
	loadgameCtrl.fill('',false)
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
