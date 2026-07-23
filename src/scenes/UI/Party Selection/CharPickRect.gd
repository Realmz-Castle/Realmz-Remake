extends NinePatchRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var charpickbuttonTSCN : PackedScene = preload("res://scenes/UI/Party Selection/CharPickButton.tscn")

var my_menu # the menu this rect is part of, handles results

@export var pick_party_label : Label

@onready var eligiblerect = $VBoxContainer/HBoxContainer/EligibleVBox/EligibleListRect
@onready var teamrect = $VBoxContainer/HBoxContainer/SelectedVBox/TeamListRect
@onready var eligibleContainer : VBoxContainer = $VBoxContainer/HBoxContainer/EligibleVBox/EligibleListRect/EligibleScrollContainer/EligibleVBoxContainer
@onready var teamContainer : VBoxContainer = $VBoxContainer/HBoxContainer/SelectedVBox/TeamListRect/TeamScrollContainer/TeamVBoxContainer

var selectedcharbutton = null
var restrictions_summary := ""

var characterfoldernameslist : Array = [] # array of String
#var characterslist : Array = [] # array of Character.gd objects
#var charactersdict : Dictionary = {}  #  name : characterGD


# Called when the node enters the scene tree for the first time.
func _ready():
	eligiblerect.my_menu = self
	teamrect.my_menu = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func fill() :
	pick_party_label.text = "Pick a party for "+GameGlobal.currentcampaign
	restrictions_summary = GameGlobal.get_campaign_restrictions_description(
		my_menu.selectedCampaign,
		my_menu.selectedcampaign_onselect
	)
	_show_restriction_feedback()
#	print("charpickretct fill()  :")
#	characterslist = []
#	charactersdict = {}
	characterfoldernameslist = Utils.FileHandler.list_dirs_in_directory(Paths.profilesfolderpath+"/"+Paths.currentProfileFolderName+"/Characters/")
#	print("CharPickRect characterfoldernameslist :  ", characterfoldernameslist)
#	print ("CharPickRect GameGlobal.profile_characters_list ", GameGlobal.profile_characters_list)
	#load all the characters
#	for c in characterfoldernameslist :
#		var path = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/Characters/'+c
#		print("charpick rect charpath : ",path)
#		var newchar = Utils.FileHandler.load_character(path)
#		print("loaded char ", newchar.name)
#		characterslist.append(newchar)
##		charactersdict[newchar.name] = newchar
	
	# clean the scroll containers
	for child in eligibleContainer.get_children() :
		eligibleContainer.remove_child(child)
		child.queue_free()
	for child in teamContainer.get_children() :
		teamContainer.remove_child(child)
		child.queue_free()
	
	for c in GameGlobal.profile_characters_list :
#		print("charîckrect  adding panel for ", c.name)
		var charpickpanel = charpickbuttonTSCN.instantiate()
#		charpickpanel.set_text(c.name)
		var admission := GameGlobal.get_character_campaign_admission(
			c,
			my_menu.selectedCampaign,
			my_menu.selectedcampaign_onselect
		)
		charpickpanel.set_character(
			c,
			bool(admission.get("allowed", false)),
			str(admission.get("reason", ""))
		)
		charpickpanel.my_menu = self
		charpickpanel.connect("pressed",Callable(self,"_on_char_button_pressed").bind(charpickpanel))
#		if GameGlobal.player_characters.has(c) :
		var samename : bool = false
		for ggpc in GameGlobal.player_characters :
			if ggpc.name==c.name :
				samename=true
				break
		if samename :
			teamContainer.add_child(charpickpanel)
		else :
			eligibleContainer.add_child(charpickpanel)
	check_party_ok()
	
func _on_char_button_pressed(bp) :
#	print("_on_char_button_pressed ", bp.character.name)
	for b in eligibleContainer.get_children() :
		b.set_highlighted(b==bp)
	for b in teamContainer.get_children() :
		b.set_highlighted(b==bp)
	selectedcharbutton = bp


func _on_AddButton_pressed():
	print("CharPickrect _on_AddButton_pressed")

	if selectedcharbutton == null :
		print("CharPickRect : selectedcharbutton == null ",selectedcharbutton == null)
		return
	if selectedcharbutton.get_parent()!=eligibleContainer :
		print("CharPickRect : ",selectedcharbutton == null, ',', selectedcharbutton.get_parent()!=eligibleContainer )
		return
	if selectedcharbutton.disabled :
		print("CharPickRect : seklectedcharbvutton dsabled")
		return
	var party := _selected_party()
	party.append(selectedcharbutton.character)
	var admission := GameGlobal.validate_campaign_party(
		party,
		my_menu.selectedCampaign,
		my_menu.selectedcampaign_onselect
	)
	if not bool(admission.get("allowed", false)):
		_show_restriction_feedback(str(admission.get("reason", "")))
		return
#	selectedcharbutton.character.cur_campaign = GameGlobal.currentcampaign
	eligibleContainer.remove_child(selectedcharbutton)
	teamContainer.add_child(selectedcharbutton)
	_on_char_button_pressed(selectedcharbutton)
	
	check_party_ok()

func _on_DropButton_pressed():
	print("CharPickrect _on_DropButton_pressed")
	if selectedcharbutton == null  or selectedcharbutton.get_parent()!=teamContainer :
		return
#	selectedcharbutton.character.cur_campaign = "Free"
	teamContainer.remove_child(selectedcharbutton)
	eligibleContainer.add_child(selectedcharbutton)
	_on_char_button_pressed(selectedcharbutton)
	
	check_party_ok()


func check_party_ok() :
	var party := _selected_party()
	var admission := GameGlobal.validate_campaign_party(
		party,
		my_menu.selectedCampaign,
		my_menu.selectedcampaign_onselect
	)
	var allowed := bool(admission.get("allowed", false))
	my_menu.set_ready(allowed, party)
	var reason := str(admission.get("reason", ""))
	_show_restriction_feedback("" if party.is_empty() else reason)


func _selected_party() -> Array:
	var party: Array = []
	for character_panel in teamContainer.get_children():
		party.append(character_panel.character)
	return party


func _show_restriction_feedback(reason := "") -> void:
	var message := restrictions_summary
	if not reason.is_empty():
		message += " — %s" % reason
	$RestrictionsLabel.text = message
	$RestrictionsLabel.tooltip_text = message
