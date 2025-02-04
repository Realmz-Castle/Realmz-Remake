"""
Author: Francisco de Biaso Neto
email: kikinhobiaso@gmail.com

#####################
### Pathjs Module ###
#####################

This module contains constantes to all important paths used into this project.
"""
extends Node

const MYFILENAME = "Realmz Remake/"
var profilesfolderpath : String = ''
var realmzfolderpath : String = ''
var campaignsfolderpath : String = ''
var datafolderpath : String = ''

var thingtypes : Dictionary = {}
var tiles_stuffbook : Dictionary = {}

var currentProfileFolderName : String = "Default Profile"

func _ready():
	if OS.has_feature("editor"):
		realmzfolderpath = ProjectSettings.globalize_path("res://").trim_suffix(MYFILENAME)
	else:
		realmzfolderpath = OS.get_executable_path().get_base_dir()
		if OS.get_name() == "macOS":
			realmzfolderpath = realmzfolderpath.replace("/Realmz.app/Contents/MacOS", "/")

	print(" realmzfolderpath : ", realmzfolderpath)

	profilesfolderpath = realmzfolderpath + "Profiles/"
	campaignsfolderpath = realmzfolderpath + "Campaigns/"
	datafolderpath = realmzfolderpath + "Data/"
	currentProfileFolderName = Utils.FileHandler.get_cfg_setting(Paths.realmzfolderpath+"settings.cfg","SETTINGS","current_profile", "Default Profile")
