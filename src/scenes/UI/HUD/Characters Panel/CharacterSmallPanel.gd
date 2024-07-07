extends Panel
class_name CharaSmallPanel

@export var dropItemEntryTSCN : PackedScene
@onready var inventoryrect = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().inventoryRect

var character = null#: GDScript = null
var type : int = 0  #type :  0:map 1:loot 2:combat

var paneltype : int = 0  #0=player character 1= NPC

@onready var nameLabel : Label = $CharnameLabel
@onready var faceButton : Button = $PortraitButton
@onready var curHPLabel : Label= $"HPLabel/CurHPLabel"
@onready var maxHPLabel : Label= $"HPLabel/MaxHPLabel"
@onready var SPLabel : Label= $SPLabel
@onready var curSPLabel : Label= $"SPLabel/CurSPLabel"
@onready var maxSPLabel : Label= $"SPLabel/MaxSPLabel"

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
var effect_sprite_frame_counter : int = 0
@onready var effect_sprite_timer : Timer = $"PortraitButton/EffectSprite/Timer"

@onready var bandead_sprite : Sprite2D = $PortraitButton/BanDeadSprite

signal chara_small_panel_selected

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
	SPLabel.text = chara.used_resource 
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
			itemsnumberLabel.text = str(character.inventory.size())
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
	curHPLabel.text = str(character.get_stat("curHP"))
	maxHPLabel.text = str(character.get_stat("maxHP"))
	match character.used_resource :
		"SP" :
			curSPLabel.text = str( character.get_stat("curSP") )
			maxSPLabel.text = str( character.get_stat("maxSP") )
		"TP" :
			curSPLabel.text = str( character.get_stat("curTP") )
			maxSPLabel.text = str( character.get_stat("maxTP") )
		"FP" :
			curSPLabel.text = str( character.get_stat("curFP") )
			maxSPLabel.text = str( character.get_stat("maxFP") )
		"RP" :
			curSPLabel.text = str( character.get_stat("curRP") )
			maxSPLabel.text = str( character.get_stat("maxRP") )
	itemsnumberLabel.text = str(character.inventory.size())
	curWeightLabel.text = str(character.get_inventory_weight())
	maxWeightLabel.text = str(character.get_stat("Weight_Limit"))
	
	bandead_sprite.frame = character.life_status
	
	mvnLabel.text = str(character.get_movement() - character.used_movepoints)
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
	# good enough to prove it's an item !
	return ( data[1]!=character and ( typeof(data[0]) == TYPE_DICTIONARY and data[0].has("imgdata") ))

func _drop_data(_pos, data):
	var item = data[0]
	var characteritemcamefrom = data[1]
	if characteritemcamefrom == character :
		return
	else :
		print(" smallpanels character is ", character.name)
#		print(inventoryrect.inventoryBoxLeft.get_parent().get_inventory_owner())  #was nil
#		print(inventoryrect.inventoryBoxRight.get_parent().get_inventory_owner()) #  was not nil
		characteritemcamefrom.inventory.erase(item)
		character.inventory.append(item)
		inventoryrect.fill_inventory_Vbox(inventoryrect.inventoryBoxLeft, inventoryrect.inventoryBoxLeft.get_parent().get_inventory_owner())
		inventoryrect.fill_inventory_Vbox(inventoryrect.inventoryBoxRight, inventoryrect.inventoryBoxRight.get_parent().get_inventory_owner())




func _on_DropItemButton_pressed():
	print("_on_DropItemButton_pressed")
	for child in dropVBox.get_children() :
		dropVBox.remove_child(child)
		child.queue_free()
	var char_inventory = character.inventory
	var prev_ib = null
	var n = 0
	for i in char_inventory :
		var ibutton = dropItemEntryTSCN.instantiate()
#		ibutton.set_text_alignment(Button.ALIGN_LEFT)
#		ibutton.set_flat(true)
		var text : String = i["name"]
		if i.has("charges_max") :
			if i["charges_max"]>0 :
				text = text + ' X' + str(i["charges"])
		ibutton.text = text
		if i["equipped"]==1 :
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
	

func _on_dropentry_pressed(i : Dictionary) :
#	print("_on_dropentry_pressed")
	character.drop_inventory_item(i)
	update_display()
	dropPopup.hide()

func show_spell_effect(effect_texture_frame) :
	effect_sprite.show()
	effect_sprite_frame_counter = 0
	effect_sprite.frame = effect_texture_frame
	effect_sprite_timer.start(0.1)


func _on_EffectSprite_Timer_timeout():
	effect_sprite_frame_counter+=1
	if effect_sprite_frame_counter >7 :
		effect_sprite_frame_counter = 0
		effect_sprite_timer.stop()
		effect_sprite.hide()
	else :
		effect_sprite_timer.start(0.1)
	effect_sprite.frame+=1
	pass # Replace with function body.
#func _on_dropentry_focused(pos, n ) :
#	print(pos,n)

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
	UI.ow_hud._on_bestiary_button_pressed()
	if UI.ow_hud.visible :
		var cdata : Dictionary = {"data": {}, "stats":{},"tools":{"spells" : []}}
		cdata["data"]["name"] = character.name
		var descrString : String = ''
		match character.is_npc_ally :
			true :
				descrString = "One of you allies. "
			false :
				match character.is_summoned :
					true :
						descrString = "A creature summoned by "+character.summoner_name+". "
					false :
						descrString = "One of your characters. A "+ character.racegd.classrace_name+" "+character.classgd.classrace_name+". "
		
		var spelcialString :String = ''
		var specialskillsPercent : Array = ["Melee_Crit_Rate","Melee_Crit_Mult","Ranged_Crit_Rate","Ranged_Crit_Mult"]
		var specialskillsAbsolute : Array = ["Detect_Secret","Acrobatics","Detect_Trap","Disable_Trap","Force_Lock","Pick_Lock","Turn_Undead"]
		for s in specialskillsPercent :
			var stat : float = character.get_stat(s)
			#print("CharacterSmallPanel specialskillsPercent base_stat: ",s,' ',character.base_stats[s], ", cur stat : ",character.get_stat(s))
			if stat != 0.0 :
				spelcialString += s.replace("_"," ") + ' : ' + str(100*stat) + "%, "
		for s in specialskillsAbsolute :
			var stat : float = character.get_stat(s)
			if stat != 0.0 :
				spelcialString += s.replace("_"," ") + ' : ' + str(stat) + ", "
		if not spelcialString.is_empty() :
			descrString += '\n'+spelcialString.trim_suffix(", ")
		
		if character.get("selection_pts") :
			descrString += '\nThis Character has '+ str(character.selection_pts) + ' unused Ability Selection Points.'
		if character.get("exp_tnl") :
			descrString += '\nExperience required to level up : '+str(character.exp_tnl)
		
		cdata["data"]["description"] = descrString
		cdata["data"]["level"] = character.level
		if character.get("icon") :
			cdata["data"]["image"] = character.icon
		else :
			cdata["data"]["image"] = character.textureL
		cdata["data"]["tags"] = character.tags
		for s in character.stats :
			cdata["stats"][s] = character.get_stat(s)
		UI.ow_hud.bestiaryRect._on_entry_pressed(cdata)
