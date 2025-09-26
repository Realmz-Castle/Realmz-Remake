"""
Author: Francisco de Biaso Neto
email: kikinhobiaso@gmail.com

#####################
### Pathjs Module ###
#####################

This module contains constantes to all important paths used into this project.
"""
extends Node

var profilesfolderpath : String = ''
var realmzfolderpath : String = ''
var campaignsfolderpath : String = ''
var datafolderpath : String = ''
var settingspath : String = ''

var currentProfileFolderName : String = "Default Profile"

func _ready():
	print("Paths._ready() :")
	if OS.has_feature("editor"):
		realmzfolderpath = ProjectSettings.globalize_path("res://")
	else:
		realmzfolderpath = OS.get_executable_path().get_base_dir()
		if OS.get_name() == "macOS":
			realmzfolderpath = "/Applications/Realmz-Remake/"
	realmzfolderpath = realmzfolderpath.rstrip("/") + "/"
	print("   realmzfolderpath : ", realmzfolderpath)

	profilesfolderpath = realmzfolderpath + "Profiles/"
	print("   profilesfolderpath : ", profilesfolderpath)
	
	campaignsfolderpath = realmzfolderpath + "Campaigns/"
	print("   campaignsfolderpath : ", campaignsfolderpath)
	
	datafolderpath = realmzfolderpath + "Data/"
	print("   datafolderpath : ", datafolderpath)
	
	settingspath =  realmzfolderpath + "override.cfg"
	print("   settingspath : ", settingspath)
	
	currentProfileFolderName = Utils.FileHandler.get_cfg_setting(settingspath,"SETTINGS","current_profile", "Default Profile")
