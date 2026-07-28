extends Panel
class_name CharaSmallPanel

@export var dropItemEntryTSCN : PackedScene
@onready var inventoryrect = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().inventoryRect

var character = null#: GDScript = null
var type : int = 0  #type :  0:map 1:loot 2:combat

var paneltype : int = 0  #0=player character 1= NPC

@onready var nameLabel : Label = $CharnameLabel
@onready var faceButton : Button = $PortraitButton
@onready var HPLabel : Label = $HPLabel
@onready var HPValueLabel : Label = $HPValueLabel
@onready var SPLabel : Label = $SPLabel
@onready var SPValueLabel : Label = $SPValueLabel

@onready var selectButton : Button = $"SelectButton"
@onready var selectedOffIcon : Texture2D = load("res://scenes/UI/HUD/Characters Panel/CharPanelSelectOff.png")
@onready var selectedOnIcon : Texture2D = load("res://scenes/UI/HUD/Characters Panel/CharPanelSelectOn.png")
@onready var select_several_counter_label : Label = $PortraitButton/NumberLabel

@onready var hpLabel = $HPLabel
@onready var spLabel = $SPLabel
@onready var lootRect = $lootRect
@onready var dropbutton=$lootRect/DropItemButton
@onready var dropPopup : PopupPanel = $lootRect/DropItemButton/DropPopup
#onready var dropRect = $lootRect/DropItemButton/DropRect
@onready var dropVBox : VBoxContainer = $lootRect/DropItemButton/DropPopup/DropScroll/DropVBox
@onready var dropScroll : ScrollContainer = $lootRect/DropItemButton/DropPopup/DropScroll
#onready var dropPopup =$lootRect/DropItemButton/PopupMenu
#onready var dropPupupMenu = $lootRect/DropItemButton/PopupMenu
@onready var itemsnumberLabel : Label = $lootRect/lootRect2/ItemsNLabel
@onready var curWeightLabel : Label = $"lootRect/LoadCNLabel"
@onready var maxWeightLabel : Label = $"lootRect/LoadMNLabel"

@onready var combatctrl : Control = $combatControl
@onready var mvnLabel : Label = $combatControl/MvnLabel
@onready var aprnLabel : Label = $combatControl/APRnLabel

@onready var effect_sprite : Sprite2D = $"PortraitButton/EffectSprite"

#@onready var effect_sprite_timer : Timer = $"PortraitButton/EffectSprite/Timer"

@onready var bandead_sprite : Sprite2D = $PortraitButton/BanDeadSprite

var effect_sprite_base_frame : int = 0
@export var effect_sprite_frame_counter : int = 0 :
	set(_new_effect_frame) :
		effect_sprite_frame_counter = _new_effect_frame
		effect_sprite.frame = effect_sprite_base_frame+_new_effect_frame
		print("CharaSmallPanel show_spell_effect : frame:", effect_sprite.frame)

@export var effect_sprite_animationplayer : AnimationPlayer

signal chara_small_panel_selected

#signal spell_effect_over

func _ready():
	pass

func set_character(chara : Creature) -> void :
#	print("charname : ", chara.charname)
	character = chara
	nameLabel.text = chara.name
	if paneltype== 0 :
		faceButton.icon = chara.portrait
	else :
		faceButton.icon = chara.textureR
	bandead_sprite.frame = chara.life_status

func set_type(t : int, showdropmenu : bool = true) :
	#type :  0:map 1:loot 2:combat
	if type != t :
		type = t
		if t==0 :
			hpLabel.show()
			spLabel.show()
		else :
			hpLabel.hide()
			spLabel.hide()
			if showdropmenu :
				dropbutton.show()
			else :
				dropbutton.hide()
		if t==1 :
			lootRect.show()
			itemsnumberLabel.text = str(character.inventory_instances().size())
			curWeightLabel.text = str(character.get_inventory_weight())
			maxWeightLabel.text = str(character.get_stat("Weight_Limit"))
		else :
			lootRect.hide()
		if t==2 :
			hpLabel.show()
			spLabel.show()
			combatctrl.show()
			mvnLabel.text = str(character.get_movement_left())
			aprnLabel.text = str(character.get_stat("MaxActions"))
		else :
			combatctrl.hide()
#		update_display()

func update_display() ->void :
	#type :  0:map 1:loot 2:combat
	nameLabel.text = character.name
	if paneltype==0 :
		faceButton.icon = character.portrait
	else :
		faceButton.icon = character.textureR
	HPValueLabel.text = "%d/%d" % [character.get_stat("curHP"), character.get_stat("maxHP")]
	var resource_key : String = character.used_resource
	var cur_key : String = "cur" + resource_key
	var max_key : String = "max" + resource_key
	if resource_key.is_empty() or not character.stats.has(cur_key) :
		SPLabel.text = ""
		SPValueLabel.text = ""
	else :
		SPLabel.text = resource_key
		SPValueLabel.text = "%d/%d" % [character.get_stat(cur_key), character.get_stat(max_key)]
	itemsnumberLabel.text = str(character.inventory_instances().size())
	curWeightLabel.text = str(character.get_inventory_weight())
	maxWeightLabel.text = str(character.get_stat("Weight_Limit"))
	
	bandead_sprite.frame = character.life_status
	
	mvnLabel.text = str(character.get_movement_left())
	aprnLabel.text = str(character.get_stat("MaxActions") - character.used_apr)


func _on_SelectButton_pressed():
	emit_signal("chara_small_panel_selected")

func toggle_SelectButton_Icon(s : bool) :
	if s :
		selectButton.set_button_icon(selectedOnIcon)
	else :
		selectButton.set_button_icon(selectedOffIcon)
		


func set_targeted_number(n : int) :
	select_several_counter_label.set_text( str(n) )
	if n == 0 :
		select_several_counter_label.set_text('')

func _can_drop_data(_pos, data):
	return (
		data is Array
		and data.size() >= 2
		and data[0] is ItemInstance
		and data[1] is Creature
		and data[1] != character
		and character.can_add_inventory_item(data[0])
	)

func _drop_data(_pos, data):
	var item = data[0]
	var characteritemcamefrom = data[1]
	if characteritemcamefrom == character :
		return
	else :
		print(" smallpanels character is ", character.name)
#		print(inventoryrect.inventoryBoxLeft.get_parent().get_inventory_owner())  #was nil
#		print(inventoryrect.inventoryBoxRight.get_parent().get_inventory_owner()) #  was not nil
		characteritemcamefrom.transfer_inventory_item_to(character, item)
		inventoryrect.fill_inventory_Vbox(inventoryrect.inventoryBoxLeft, inventoryrect.inventoryBoxLeft.get_parent().get_inventory_owner())
		inventoryrect.fill_inventory_Vbox(inventoryrect.inventoryBoxRight, inventoryrect.inventoryBoxRight.get_parent().get_inventory_owner())




func _on_DropItemButton_pressed():
	print("_on_DropItemButton_pressed")
	for child in dropVBox.get_children() :
		dropVBox.remove_child(child)
		child.queue_free()
	var char_inventory: Array[ItemInstance] = character.inventory_instances()
	var prev_ib = null
	var n = 0
	for i: ItemInstance in char_inventory:
		var ibutton = dropItemEntryTSCN.instantiate()
#		ibutton.set_text_alignment(Button.ALIGN_LEFT)
#		ibutton.set_flat(true)
		var definition := NodeAccess.__Resources().get_item_definition(i)
		if definition == null:
			continue
		var text: String = definition.display_name_for(i)
		if definition.maximum_charges > 0:
			text += " X" + str(i.charges)
		ibutton.text = text
		if i.equipped:
			ibutton.set_disabled(true)
		if prev_ib!=null :
			ibutton.set_focus_neighbor(offset_top,prev_ib.get_path())
			prev_ib.set_focus_neighbor(offset_bottom,ibutton.get_path())
		#connect(signal: String,Callable(target: Object,method: String).bind(binds: Array = [  ),flags: int = 0)
		ibutton.connect("pressed",Callable(self,"_on_dropentry_pressed").bind(i))
#		ibutton.connect("focus_entered",Callable(self,"_on_dropentry_focused").bind(ibutton.get_position().y,n))
#		ibutton.connect("gui_input",Callable(self,"_on_dropentry_gui_input"))
		dropVBox.add_child(ibutton)
		prev_ib = ibutton
		n +=1
#	dropRect.show()
	# calculate availlable height for the popup
	var globalpos = get_global_position()
	var screeny = UI.ow_hud.get_mofified_screensize().y
	var ysize = screeny-globalpos.y-60
	var itemysize = 20+14*n
	ysize = min(ysize, itemysize)
#	ysize = max(ysize, 200)
	dropPopup.popup(Rect2(globalpos+Vector2(60,50), Vector2(150,ysize)))

	#focus_neighbor_top(value)
	#focus_neighbor_bottom(value)
	#set_focus_neighbor
	

func _on_dropentry_pressed(i: ItemInstance) -> void:
#	print("_on_dropentry_pressed")
	character.drop_inventory_item(i)
	update_display()
	dropPopup.hide()

func show_spell_effect(effect_texture_frame) :
	print("CharaSmallPanel show_spell_effect : frame:", effect_texture_frame)
	effect_sprite.show()
	effect_sprite_base_frame = effect_texture_frame
	effect_sprite_animationplayer.play(&'effect', -1, 2.0, false)
	await effect_sprite_animationplayer.animation_finished
	effect_sprite.hide()
#
#func _on_EffectSprite_Timer_timeout():
	#effect_sprite_frame_counter+=1
	#if effect_sprite_frame_counter >7 :
		#effect_sprite_frame_counter = 0
		#effect_sprite_timer.stop()
		#effect_sprite.hide()
	#else :
		#effect_sprite_timer.start(0.1)
	#effect_sprite.frame+=1
	#pass # Replace with function body.
##func _on_dropentry_focused(pos, n ) :
##	print(pos,n)

#func _on_dropentry_gui_input(event : InputEvent):
##	print("_on_dropentry_gui_input")
#	print(event)
#	if event is InputEventKey and not event.echo:
##		print("inouteventkeey")
#		#if and ev.scancode == KEY_K
#		if InputMap.event_is_action ( event, "ui_up" ) :
#			dropScroll.set_v_scroll(dropScroll.get_v_scroll()-7)
#		if InputMap.event_is_action ( event, "ui_down" ) :
#			dropScroll.set_v_scroll(dropScroll.get_v_scroll()+7)
#		#event_is_action ( InputEvent event, String action ) const
	





func _on_portrait_button_pressed():
	var cdata : Dictionary = {"data": {}, "stats":{},"tools":{"spells" : []}}
	cdata["data"]["name"] = character.name
	cdata["data"]["level"] = character.level
	cdata["data"]["tags"] = character.tags
	if character.get("icon") :
		cdata["data"]["image"] = character.icon
	else :
		cdata["data"]["image"] = character.textureL

	# Subtitle: "Race · Class" for player chars; allies/summons get a descriptor
	if character.is_npc_ally :
		cdata["data"]["subtitle"] = "Ally"
	elif character.is_summoned :
		cdata["data"]["subtitle"] = "Summoned by " + character.summoner_name
	elif character.classgd != null and character.racegd != null :
		var race_name: String = (
			str(character.get_display_race_name())
			if character.has_method("get_display_race_name")
			else str(character.racegd.classrace_name)
		)
		var caste_name: String = (
			str(character.get_display_caste_name())
			if character.has_method("get_display_caste_name")
			else str(character.classgd.classrace_name)
		)
		cdata["data"]["subtitle"] = race_name + " · " + caste_name

	# Description: short flavor + progression info. The special-skill stats live
	# in their own panel via cdata["special_skills"], not here.
	var descr_parts : Array = []
	if character.is_npc_ally :
		descr_parts.append("One of your allies.")
	elif character.is_summoned :
		descr_parts.append("A creature summoned by " + character.summoner_name + ".")
	else :
		descr_parts.append("One of your characters.")
	if character.has_method("get_ability_selection_points"):
		var selection_points := int(character.get_ability_selection_points())
		if selection_points != 0:
			descr_parts.append(
				"%d unused %s."
				% [
					selection_points,
					character.get_ability_selection_points_label(),
				]
			)
	if character.get("exp_tnl") :
		descr_parts.append("Experience to next level: %d" % character.exp_tnl)
	cdata["data"]["description"] = "\n".join(descr_parts)

	# Special skills as [name, formatted_value] pairs — only non-zero entries.
	var special_skills : Array = []
	var skills_pct : Array = ["Melee_Crit_Rate", "Melee_Crit_Mult", "Ranged_Crit_Rate", "Ranged_Crit_Mult"]
	var skills_abs : Array = ["Detect_Secret", "Acrobatics", "Detect_Trap", "Disable_Trap", "Force_Lock", "Pick_Lock", "Turn_Undead"]
	for s in skills_pct :
		var v : float = character.get_stat(s)
		if v != 0.0 :
			special_skills.append([s.replace("_", " "), "%+.1f%%" % (100.0 * v)])
	for s in skills_abs :
		var v : float = character.get_stat(s)
		if v != 0.0 :
			special_skills.append([s.replace("_", " "), str(v)])
	cdata["special_skills"] = special_skills

	for s in character.stats :
		cdata["stats"][s] = character.get_stat(s)
	# Mutually exclusive with the bestiary — never overlap.
	if UI.ow_hud.bestiaryRect.visible :
		UI.ow_hud.bestiaryRect.hide()
	if StateMachine._state_name == "Exploration" :
		StateMachine.enter_ex_menu_state({"menu_name": "CharacterInfoMenu"})
	elif StateMachine._state_name == "CbDecideAction" :
		StateMachine.enter_cb_menu_state({"menu_name": "CharacterInfoMenu"})
	UI.ow_hud.characterStatRect.show_for_character(cdata)
