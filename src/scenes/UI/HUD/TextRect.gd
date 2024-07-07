extends NinePatchRect
#TextRect

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

@onready var textLabel : RichTextLabel = $RichTextLabel
@onready var hud : Control = $"../../.."
@onready var disablerButton = $DisablerButton #cover whole screen with mouse filter STOP to disable UI
@onready var aoetex : TextureRect = $AoETextureRect
@onready var itemtex : TextureRect = $ItemRect

#@onready var choicesContainer = $ChoicesVBoxContainer
@export var choicesContainer : VBoxContainer

signal interruption_over
signal choice_pressed

#var picked_choice_script = null

#var pause : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var screensize : Vector2 = get_window().get_size()
	#disablerButton._set_size(screensize)
	disablerButton.set_deferred("size", screensize)
	disablerButton._set_position(Vector2(0,-screensize.y+200))
	choicesContainer.add_theme_constant_override ("separation",0)
#	choicesContainer.connect("choice_pressed",Callable(self,"_on_ChoicesVBoxContainer_choice_pressed").bind(scripts[i))
	choicesContainer._set_global_position(Vector2((screensize.x-320-380)/2,5))
	choicesContainer._set_size(Vector2(380,screensize.y-210))
	


func on_viewport_size_changed(screensize:Vector2) :
	pass
#	_set_size(Vector2(screensize.x-320, 200))
#	_set_position(Vector2(0, screensize.y-200))
#	textLabel._set_size(Vector2(screensize.x-320-15, 170))
	disablerButton._set_position(Vector2(0,-screensize.y+200))
	disablerButton._set_size(screensize)
#
#	choicesContainer.on_viewport_size_changed(screensize)

func set_item_info(item : Dictionary) :
	aoetex.hide()
	itemtex.show()
	itemtex.texture = item["texture"]
	var text = "          "+item["name"]+" : "+item["type"]#+' imgdatasize'+str(item["imgdatasize"])

	if item.has("slots") :
		if not item["slots"].is_empty() :
			text += "\t\t( "
			for s in item["slots"] :
				text += s+' '
			text += ")"
	text +="\n          Price : "+str(item["price"])+"\tWeight : "+str(item["weight"])
	if item.has("charges_max") :
		if item["charges_max"] >0 :
			text +="\tCharges : "+str(item["charges"])+'/'+str(item["charges_max"])
	text +="\n"+item["description"]
	if item.has("weapon_dmg") :
		text +="\nWeapon Damage :\t"
		for t in item["weapon_dmg"] :
			text += t+' : '+str(item["weapon_dmg"][t][0])+'-'+str(item["weapon_dmg"][t][1])+' \t'
	if item.has("stats") :
		if not item["stats"].is_empty() :
			text +="\nStats :\t"
			for s in item["stats"] :
				text += s+' : '+str(item["stats"][s])+' \t'
	if item.has("traits") :
		if not item["traits"].is_empty() :
			var traitsnameslist : Array = []
			for t in item["traits"] :
				print("t : ",t)
				var traitname = t[0]
#				print(item["name"]+"traitname : ",traitname)
				var traitscript = item[traitname][0]
#				print(item["name"]+" traitname : ",traitname," traitscript ",traitscript.get_source_code())
#				var traitinstance = traitscript.new()
				traitsnameslist.append(traitscript.menuname)
			text +="\nStatus Effects :\t"
			for tn in traitsnameslist :
				text +=tn+" \t"
	if item.has("equippable") :
		if item["equippable"]>0 :
			var canequiplist : Array = []
			for pc in GameGlobal.player_characters :
				if pc.equippable_types[item["type"]]>0 :
					canequiplist.append(pc.name)
			text += "\nCan be equipped by : "
			for n in canequiplist :
				text +=n+' '
			
#	if item.has("weapon_dmg") :
#		text +="\n"
	textLabel.parse_bbcode(text)

func set_text(text : String, _interrupt : bool = true, _sound : String = "") :
#	if GameState._state == GameGlobal.eCombatStates.inCombat :
#		if text.is_empty() :
#			hud.CreatureRect.show()
#			hide()
#	print("textRext set_text : "+text)
	aoetex.hide()
	itemtex.hide()
#	print("textrect hud : ",hud,' : ',hud.name)
	hud.creatureRect.hide()
	show()
#	textLabel.clear()
	if _sound != "" :
		SfxPlayer.stream = NodeAccess.__Resources().sounds_book[_sound]
		SfxPlayer.play()
	
#	var err = 
	textLabel.parse_bbcode(text)
#	if err != 0 :
#		print("Error displaying BBCode in TextRect : ", err)
#	else :
#		print("textLabel.parse_bbcode : ", text)
	if _interrupt :
#		hud.set_mouse_filter(MOUSE_FILTER_IGNORE)
		disablerButton.show()
		#StateMachine.transition_to("WaitForClick", {"prev_state" : StateMachine._state_name})
		Input.set_custom_mouse_cursor(UI.cursor_click)
#		pause = true
#		while(pause) :
#			pass

		#GDScriptFunctionState await object: Object = null.signal:String=
		await disablerButton.pressed
		print('""disablerButton, "pressed"', text)

		#GameState.set_paused(false)
		Input.set_custom_mouse_cursor(UI.cursor_sword)
		disablerButton.hide()
		textLabel.clear()

#		print("texRect l84 GameState._state :  ", GameState._state, ' ', GameState._state == GameGlobal.eCombatStates.inCombat)
		if StateMachine.is_combat_state() :
			hud.creatureRect.show()
			hide()
			

		emit_signal("interruption_over")




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



#func _on_DisablerButton_pressed():

#	pause = false

func display_multiple_choices(choices : Array, scripts : Array) :
	aoetex.hide()
	itemtex.hide()
	StateMachine.transition_to("MultipleChoices", {"prev_state" : StateMachine._state_name, "choicesContainer" : choicesContainer})
	Input.set_custom_mouse_cursor(UI.cursor_click)
	choicesContainer.display_multiple_choices(choices, scripts)
	
	choicesContainer.show()
	var choice = await choicesContainer.choice_pressed
	#print("textrect choice "+choice)
	emit_signal("choice_pressed", choice)
	choicesContainer.hide()
	
	#GameState.set_paused(false)
	#Input.set_custom_mouse_cursor(GameState.cursor_sword)
#	print(picked_choice_script)
	

var attrColorDict : Dictionary = {"Fire" : Color.ORANGE, "Ice" : Color.CYAN, "Electric" : Color.MEDIUM_SLATE_BLUE,
	"Poison" : Color.FOREST_GREEN, "Chemical" : Color.GREEN_YELLOW, "Disease" : Color.YELLOW, "Healing" : Color.WHITE, "Mental" : Color.DEEP_PINK, 
	"Physical" : Color.LIGHT_CYAN, "Magical" : Color.CORNFLOWER_BLUE}


func set_spell_info(spelldict : Dictionary, crea : Creature) :
	itemtex.hide()
	var spellscript = spelldict["script"]
	var spell_info_txt : String = spelldict["name"]+", level "+ str(spellscript.level) +" "+ spellscript.school +" ability.\nAttributes : "
	
	for attr in spellscript.attributes :
		var colorcode : String = '#'+get_attribute_color(attr).to_html()
		spell_info_txt += "[color="+colorcode+"]"+attr+"[/color] "
		
	if spellscript.in_field and  spellscript.in_combat :
		spell_info_txt += "\nCan be used both in and out of combat."
	if spellscript.in_field and  (not spellscript.in_combat) :
		spell_info_txt += "\nCan only be used out of combat."
	if (not spellscript.in_field) and  spellscript.in_combat :
		spell_info_txt += "\nCan only be used in combat."
	if not (spellscript.in_field or spellscript.in_combat) :
		spell_info_txt += "\nOnly used in Special Encounters."
	
	if spellscript.in_combat :
		if spellscript.los and  spellscript.rot :
			spell_info_txt += "Requires Line of Sight. Area of effect can be rotated.\n"
		if spellscript.los and  (not spellscript.rot) :
			spell_info_txt += "Requires Line of Sight.\n"
		if (not spellscript.los) and  spellscript.rot :
			spell_info_txt += "Does not require Line of Sight. Area of effect can be rotated.\n"
		if not (spellscript.los or spellscript.rot) :
			spell_info_txt += "Does not require Line of Sight.\n"
	else :
		spell_info_txt += "\n"
	
	spell_info_txt += spellscript.description +"\n"
	spell_info_txt += "Usage cost with changes from traits : " + str(crea.get_spell_resource_cost(spelldict["script"],1)) +" "+crea.used_resource+" at Power Level 1"
	set_text(spell_info_txt, false, "")
	
	var aoe_name : String = spellscript.get_aoe(3, crea)
	var aoenametotex_dict : Dictionary = UI.ow_hud.spellcastMenu.aoenametotex_dict
	if aoenametotex_dict.has(aoe_name):
		aoetex.texture = aoenametotex_dict[aoe_name]
	else :
		aoetex.texture = UI.ow_hud.spellcastMenu.aoe_sp_tex
	aoetex.show()


func get_attribute_color(attr : String)->Color :
	if attrColorDict.has(attr) :
		return attrColorDict[attr]
	return Color.GRAY
#func _on_ChoicesVBoxContainer_choice_pressed(script):
#	picked_choice_script = script
#	print("pciked script : ", script)
#	pass # Replace with function body.
