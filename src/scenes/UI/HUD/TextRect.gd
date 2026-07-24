extends NinePatchRect
class_name TextRect

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

func set_item_info(item: ItemInstance) -> void:
	if item == null:
		return
	var resources = NodeAccess.__Resources()
	var definition := resources.get_item_definition(item)
	if definition == null:
		return
	aoetex.hide()
	itemtex.show()
	itemtex.texture = resources.item_texture(item)
	var text := "          %s : %s" % [
		definition.display_name_for(item),
		definition.display_type,
	]
	var slots := definition.slots()
	if not slots.is_empty():
		text += "\t\t( %s )" % " ".join(slots)
	text += "\n          Price : %d\tWeight : %d" % [
		definition.price,
		definition.total_weight(item),
	]
	if item.identified and definition.maximum_charges > 0:
		text += "\tCharges : %d/%d" % [
			item.charges,
			definition.maximum_charges,
		]
	text += "\n" + definition.description_for(item)
	if item.identified:
		var weapon_damage := definition.weapon_damage()
		if not weapon_damage.is_empty():
			text += "\nWeapon Damage :\t"
			for damage_type: Variant in weapon_damage:
				var damage: Variant = weapon_damage[damage_type]
				if damage is Array and damage.size() >= 2:
					text += "%s : %s-%s \t" % [
						damage_type,
						damage[0],
						damage[1],
					]
		var stats := definition.stats()
		if not stats.is_empty():
			text += "\nStats :\t"
			for stat_name: Variant in stats:
				text += "%s : %s \t" % [stat_name, stats[stat_name]]
		var trait_names := resources.item_trait_display_names(item)
		if not trait_names.is_empty():
			text += "\nStatus Effects :\t%s" % " \t".join(trait_names)
	if definition.equippable:
		var can_equip: Array[String] = []
		for pc: PlayerCharacter in GameGlobal.player_characters:
			if int(pc.equippable_types.get(definition.item_type, 0)) > 0:
				can_equip.append(pc.name)
		text += "\nCan be equipped by : %s" % " ".join(can_equip)
			
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
		disablerButton.grab_focus()
		#StateMachine.transition_to("WaitForClick", {"prev_state" : StateMachine._state_name})
		Input.set_custom_mouse_cursor(UI.cursor_click)
#		pause = true
#		while(pause) :
#			pass

		#GDScriptFunctionState await object: Object = null.signal:String=
		await disablerButton.pressed
		print('""TextRect disablerButton, "pressed"', text)

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

func display_multiple_choices(choices : Array, scripts : Array = []) :
	aoetex.hide()
	itemtex.hide()
	var opened_menu := false
	if StateMachine._state_name == "Exploration" :
		StateMachine.enter_ex_menu_state({"menu_name": "MultipleChoices"})
		opened_menu = true
	elif StateMachine._state_name == "CbDecideAction" :
		StateMachine.enter_cb_menu_state({"menu_name": "MultipleChoices"})
		opened_menu = true
	Input.set_custom_mouse_cursor(UI.cursor_click)
	
	if scripts.is_empty() : scripts = range(choices.size())
	
	choicesContainer.show()
	choicesContainer.display_multiple_choices(choices, scripts)
	var choice = await choicesContainer.choice_pressed
	print("TextRect textrect choice "+str(choice))
	choicesContainer.hide()
	if opened_menu :
		if (
			StateMachine._state_name == "ExMenus"
			and StateMachine.ex_menu_state.cur_menu_name == "MultipleChoices"
		) :
			StateMachine.exit_ex_menu_state({})
		elif (
			StateMachine._state_name == "CbMenus"
			and StateMachine.cb_menu_state.cur_menu_name == "MultipleChoices"
		) :
			StateMachine.exit_cb_menu_state({})
	emit_signal("choice_pressed", choice)

	
	#GameState.set_paused(false)
	#Input.set_custom_mouse_cursor(GameState.cursor_sword)
#	print(picked_choice_script)
	

#TODO  remove this once not needed
const attrColorDict : Dictionary = {"Fire" : Color.ORANGE, "Ice" : Color.CYAN, "Electric" : Color.MEDIUM_SLATE_BLUE,
	"Poison" : Color.FOREST_GREEN, "Chemical" : Color.GREEN_YELLOW, "Disease" : Color.YELLOW, "Healing" : Color.WHITE, "Mental" : Color.DEEP_PINK, 
	"Physical" : Color.LIGHT_CYAN, "Magical" : Color.CORNFLOWER_BLUE}




func set_spell_info(spelldict : Dictionary, crea : Creature, plvl : int) :
	itemtex.hide()
	var spellscript = spelldict["script"]
	var spell_info_txt : String = spelldict["name"]+", level "+ str(spellscript.schools) +" ability.\nAttributes : "
	
	for attr in spellscript.elements :
		var colorcode : String = '#'+spellscript.get_element_color(attr).to_html()
		
		print("TextRect set_spell_info : elem attr ", attr, " for GameGlobal.get_element_name")
		spell_info_txt += "[color="+colorcode+"]"+GameGlobal.get_element_name(attr)+"[/color] "
		
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

	aoetex.texture = UI.ow_hud.spellcastMenu.get_aoe_image(spellscript, crea , plvl)
	aoetex.show()


#TODO delete this once not needed
func get_attribute_color(attr : String)->Color :
	push_error("TextRect get_attribute_color should be DEPRECATED soon ! change use to get_attribute_color_Global")
	if attrColorDict.has(attr) :
		return attrColorDict[attr]
	return Color.GRAY
#OTHER GLOBAL ONE FOR SPELLS MOVED TO Spells CLASS

#func _on_ChoicesVBoxContainer_choice_pressed(script):
#	picked_choice_script = script
#	print("pciked script : ", script)
#	pass # Replace with function body.
