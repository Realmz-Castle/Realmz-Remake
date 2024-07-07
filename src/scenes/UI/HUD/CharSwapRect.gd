extends NinePatchRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var pickedparty : Array = []


@onready var charPickRect = $CharPickRect
@onready var okButton : Button = $OKButton

# Called when the node enters the scene tree for the first time.
func _ready():
	charPickRect.my_menu = self
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func on_viewport_size_changed(screensize) :
	set_size(screensize)

func show_charswaprect() :
	pickedparty = GameGlobal.player_characters
	charPickRect.fill()
	super.show()

func fill() -> void :
	okButton.text = "Select and Quicksave" if GameGlobal.honest_mode else "OK"
	charPickRect.fill()


func set_ready(rdy : bool, party : Array) :
	okButton.disabled = not rdy
	if rdy :
		pickedparty = party#GameGlobal.player_characters = party
	else :
		pickedparty.clear()


func _on_CancelButton_pressed():
	StateMachine.transition_to("Exploration/ExWalking")
	hide()




func _on_OKButton_pressed():
	# find the characters that were swapped out and save them to profile
	var swapped_out_pcs : Array = []
	for pc in GameGlobal.player_characters :
		if not pickedparty.has(pc) :
			swapped_out_pcs.append(pc)
	print("CharSwaprect  save swapped out PCs to profile save " + str(swapped_out_pcs.size()))
	for pc in  swapped_out_pcs :
		var path = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/Characters/'+pc.name
		pc.cur_campaign = "Free"
		Utils.FileHandler.save_character(path, pc)
	StateMachine.transition_to("Exploration/ExWalking")
	for pc in pickedparty :
		pc.cur_campaign = GameGlobal.currentcampaign
	GameGlobal.player_characters = pickedparty
	get_parent().fillCharactersRect() # ask OWHUDNode2D
	GameGlobal.refresh_OW_HUD()
	hide()
	MusicStreamPlayer.play_music_map()
	var map = NodeAccess.__Map()
	map.set_ow_character_icon(GameGlobal.player_characters[0].icon)
	if GameGlobal.honest_mode :
		UI.ow_hud._on_q_save_button_pressed()
