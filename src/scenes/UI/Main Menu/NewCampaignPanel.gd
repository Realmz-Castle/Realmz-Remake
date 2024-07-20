extends NinePatchRect

@onready var campaignsItemList : ItemList = $VBoxContainer/HBoxContainertT/ScenarioListVBox/CampaignsItemList
@onready var selectedCampaignNameLabel : Label = $VBoxContainer/HBoxContainertT/ScenDescrVBox/SelectedCampaignNameLabel
@onready var selectedCampaignDescrLabel: Label = $VBoxContainer/HBoxContainertT/ScenDescrVBox/SelectedCampaignDescrLabel

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
#	print(idx, campaignsItemList.get_item_text(idx))
	selectedCampaign = campaignsItemList.get_item_text(idx)
	if selectedCampaign.ends_with(" (busy)") :
		selectedCampaignDescrLabel.text = selectedCampaign+"\nThis campaign is already in use by another party.\nDelete that game first."
		return
	GameGlobal.set_current_campaign(selectedCampaign)
	selectedCampaignNameLabel.text = selectedCampaign
	selectedCampaignDescrLabel.text = GameGlobal.get_currentcampaign_description()
	#reset the character picking panel
	charPickRect.fill()

func _on_StartButton_pressed() -> void :
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
		"curr_shop" = '',
		"stuff_done" = {},
		"map_boats_dict" = {},
		"is_sailing_boat" = 0,
		"boat_image" = 'no boat_image',
		"save_name" = "",
		"save_descr" = '',
		"campaign" = selectedCampaign,
		"currentmap_name" = "Default Map",
		"shops_dict" = {},
		"GlobalEffects" = {
			"WaterBreath" : {"Duration" : 0},
			"FeatherFall" : {"Duration" : 0},
			"Awareness" : {"Duration" : 0},
			"Scrying" : {"Duration" : 0},
			"Shielded" : {"Duration" : 0},
			"Sentry" : {"Duration" : 0}
		}
	}
	for pc in pickedparty :
		pc.cur_campaign = GameGlobal.currentcampaign
	GameGlobal.player_characters = pickedparty
	GameGlobal.init_globals_before_game_start(data_dict)
	StateMachine.transition_to("Exploration", {"campaign_start" : true})
	#GameState._state = GameGlobal.eGameStates.startGame
	#transition here ?
#	GameGlobal.startCampaign(selectedCampaign)
	#get_tree().get_root().remove_child(get_parent().get_parent().get_parent())
#
#	print("STARTCAMPAIGN playerchat0 item0 ", pickedparty[0].inventory[0])
	return
		




func fill() -> void :
	charPickRect.fill()

	campaignslist = Utils.FileHandler.list_dirs_in_directory(Paths.campaignsfolderpath)
	campaignsItemList.clear()
	for c in campaignslist :
		var selectable : bool = true
		if GameGlobal.honest_mode :
			var savepath : String = Paths.profilesfolderpath + GameGlobal.currentprofile + "/Saves/"+ c + "/"
			if DirAccess.dir_exists_absolute(savepath) :
				if Utils.FileHandler.list_dirs_in_directory(savepath).size()>0 :
					selectable = false
					c = c+ " (busy)"
		campaignsItemList.add_item(c)#,null,selectable) BUG not selmectable still selectable...

	return

func set_ready(rdy : bool, party : Array) :
	startButton.disabled = not rdy
	if rdy :
		pickedparty = party#GameGlobal.player_characters = party
	else :
		pickedparty = []
#	print("characters : ",characterlist)
