extends NinePatchRect

@onready var campaignsItemList : ItemList = $VBoxContainer/HBoxContainertT/ScenarioListVBox/CampaignsItemList
@onready var selectedCampaignNameLabel : Label = $VBoxContainer/HBoxContainertT/ScenDescrVBox/SelectedCampaignNameLabel
@onready var selectedCampaignDescrLabel: Label = $VBoxContainer/HBoxContainertT/ScenDescrVBox/SelectedCampaignDescrLabel

var selectedcampaign_onselect

@onready var startButton : Button = $VBoxContainer/HBoxContainerB/StartControl/StartButton

@onready var charPickRect : Control = $VBoxContainer/HBoxContainertT/PartyControl/CharPickRect


var campaignslist : Array = [] # array of Strings
var characterfoldernameslist : Array = [] # array of String
var characterslist : Array = [] # array of Character.gd objects
var charactersdict : Dictionary = {}  #  name : characterGD


var selectedCampaign : String = ''

var pickedparty : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	charPickRect.my_menu = self
	var _err_connnectcampaign = campaignsItemList.connect("item_selected",Callable(self,"_on_campaign_selected"))
#	campaignsItemList.connect("nothing_selected",Callable(self,"_on_campaign_unselected"))
	var _err_connectstartbutton = startButton.connect("pressed",Callable(self,"_on_StartButton_pressed"))
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_CancelButton_pressed() -> void :
	self.hide()
#	self.get_parent().get_parent().newCharacterButton.show()

func _on_campaign_selected(idx : int) -> void :
	set_ready(false, [])
	var metadata: Variant = campaignsItemList.get_item_metadata(idx)
	if not (metadata is Dictionary):
		return
	selectedCampaign = str(metadata.get("campaignName", ""))
	selectedcampaign_onselect = metadata.get("selectionRules")
	if bool(metadata.get("busy", false)):
		selectedCampaignDescrLabel.text = (
			selectedCampaign
			+ "\nThis campaign is already in use by another party.\nDelete that game first."
		)
		return

	if selectedcampaign_onselect is Dictionary:
		selectedCampaignNameLabel.text = str(
			selectedcampaign_onselect.get("title", selectedCampaign)
		)
		selectedCampaignDescrLabel.text = _classic_campaign_description(
			selectedcampaign_onselect
		)
	else:
		selectedCampaignNameLabel.text = selectedCampaign
		selectedCampaignDescrLabel.text = GameGlobal.get_campaign_description(selectedCampaign)
	#reset the character picking panel
	charPickRect.fill()

func _on_StartButton_pressed() -> void :
	if selectedcampaign_onselect is Dictionary and not bool(
		selectedcampaign_onselect.get("valid", false)
	):
		return
	GameGlobal.set_current_campaign(selectedCampaign)
	var data_dict : Dictionary = {
		"fatigue" = 0.0,
		"position" = Vector2.ZERO,
		"time" = 0,
		"money_pool" = [0,0,0],
		"money_banked" = [0,0,0],
		"light_time" = 0,
		"light_power" = 0,
		"camping" = 0,
		"allow_char_swap" = 0,
		"curr_temple" = [],
		"curr_shop" = '',
		"stuff_done" = {},
		"native_encounters" = {},
		"map_boats_dict" = {},
		"is_sailing_boat" = 0,
		"boat_image" = 'no boat_image',
		"save_name" = "",
		"save_descr" = '',
		"campaign" = selectedCampaign,
		"currentmap_name" = "Default Map",
		"shops_dict" = {},
		"minimaps" = [],
		"GlobalEffects" = {
			"WaterBreath" : {"Duration" : 0},
			"FeatherFall" : {"Duration" : 0},
			"Awareness" : {"Duration" : 0},
			"Scrying" : {"Duration" : 0},
			"Shielded" : {"Duration" : 0},
			"Sentry" : {"Duration" : 0},
			"CharmProt" : {"Duration" : 0}
		}
	}
	for pc in pickedparty :
		pc.cur_campaign = GameGlobal.currentcampaign
	GameGlobal.player_characters = pickedparty
	GameGlobal.init_globals_before_game_start(data_dict)
	
	#minimaps from on_campaign_start.gd  :
	var onstartscript: Variant = GameGlobal.get_native_campaign_start_script(selectedCampaign)
	if onstartscript != null:
		onstartscript.set_minimaps_in_gameglobal()
	#GameGlobal.currentcampaign_onload_script
	
	
	
	StateMachine.transition_to("Exploration", {"campaign_start" : true})
	#GameState._state = GameGlobal.eGameStates.startGame
	#transition here ?
#	GameGlobal.startCampaign(selectedCampaign)
	#get_tree().get_root().remove_child(get_parent().get_parent().get_parent())
#
#	print("STARTCAMPAIGN playerchat0 item0 ", pickedparty[0].inventory[0])
	return
		




func fill() -> void :
	selectedCampaign = ""
	selectedcampaign_onselect = null
	selectedCampaignNameLabel.text = ""
	selectedCampaignDescrLabel.text = ""
	set_ready(false, [])

	campaignslist = Utils.FileHandler.list_dirs_in_directory(Paths.campaignsfolderpath)
	campaignsItemList.clear()
	for campaign_value: Variant in campaignslist:
		var campaign_name := str(campaign_value)
		var selection_rules: Variant = GameGlobal.get_campaign_selection_rules(campaign_name)
		var display_name := campaign_name
		if selection_rules is Dictionary:
			display_name = "%s — %s" % [
				selection_rules.get("title", campaign_name),
				selection_rules.get("readinessState", "Invalid"),
			]
		var busy := false
		if GameGlobal.honest_mode :
			var savepath : String = (
				Paths.profilesfolderpath
				+ GameGlobal.currentprofile
				+ "/Saves/"
				+ campaign_name
				+ "/"
			)
			if DirAccess.dir_exists_absolute(savepath) :
				if Utils.FileHandler.list_dirs_in_directory(savepath).size()>0 :
					busy = true
					display_name += " (busy)"
		var item_index := campaignsItemList.item_count
		campaignsItemList.add_item(display_name)
		campaignsItemList.set_item_metadata(item_index, {
			"campaignName": campaign_name,
			"selectionRules": selection_rules,
			"busy": busy,
		})

	return


func _classic_campaign_description(selection_rules: Dictionary) -> String:
	var lines: Array[String] = [
		str(selection_rules.get("description", "")),
		str(selection_rules.get("versionLabel", "")),
		"Status: %s" % selection_rules.get("readinessState", "Invalid"),
		str(selection_rules.get("readinessSummary", "")),
	]
	var diagnostic := str(selection_rules.get("diagnostic", "")).strip_edges()
	if not diagnostic.is_empty():
		lines.append("Cannot start: %s" % diagnostic)
	var visible_lines: Array[String] = []
	for line: String in lines:
		if not line.is_empty():
			visible_lines.append(line)
	return "\n".join(visible_lines)

func set_ready(rdy : bool, party : Array) :
	startButton.disabled = not rdy
	if rdy :
		pickedparty = party#GameGlobal.player_characters = party
	else :
		pickedparty = []
#	print("characters : ",characterlist)
