extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var encounter_script = null  #GDScript instanced, so justa  RefCounted

@onready var disablerButton : Button = get_parent().find_child("DisablerButton")
@onready var boxContainer : HBoxContainer = $HBoxContainer
@onready var spellButton = $HBoxContainer/SpellButton
@onready var itemButton = $HBoxContainer/InventoryButton
@onready var useitemRect = $HBoxContainer/InventoryButton/UseItemRect
@onready var itempreview =$HBoxContainer/InventoryButton/UseItemRect/ItemPreview
@onready var actionButton = $HBoxContainer/ActionButton
@onready var skillbutton = $HBoxContainer/SkillsButton
@onready var useSkillRect = $HBoxContainer/SkillsButton/UseSkillRect
@onready var speakButton = $HBoxContainer/SpeakButton
@onready var speakField : TextEdit = $"HBoxContainer/SpeakButton/NinePatchRect/TextEdit"
@onready var stopButton = $HBoxContainer/StopButton

@onready var choiceContainer = $"../VBoxScreen/HBoxTop/MapArea/ChoicesVBoxContainer"

signal encounter_over

# Called when the node enters the scene tree for the first time.
func _ready():
	on_viewport_size_changed(ScreenUtils.get_logical_window_size(self))
	useitemRect.connect("item_picked",Callable(self,"_on_item_used"))


func initialize(scriptname : String) :
	print("encountercontrol initialize : "+scriptname)
	#GameGlobal.currentSpecialEncounterName = scriptname
#	for b in boxContainer.get_children() :
#		b.show()
#	return
	var resources = NodeAccess.__Resources()
	for b in boxContainer.get_children() :
		b.hide()
	speakField.set_text('')
	speakButton.get_child(0).hide()
	useitemRect.hide()
	useSkillRect.hide()
	
	encounter_script = resources.special_encounters_book[scriptname]
	if not encounter_script.is_connected("encounter_over",Callable(self,"close")) :
		encounter_script.connect("encounter_over",Callable(self,"close"))
#	print("encounter_script", encounter_script, encounter_script.allow_items)
#	encounter_script.control = self
	if encounter_script.allow_spells :
		spellButton.show()
	if encounter_script.allow_items :
		itemButton.show()
	if encounter_script.allow_action :
		actionButton.show()
	if encounter_script.allow_speak :
		speakButton.show()
	if encounter_script.allow_stop :
		stopButton.show()
	
	if (encounter_script.get("acro_difficulty")!=null
	or encounter_script.get("dete_difficulty")!=null
	or encounter_script.get("disa_difficulty")!=null
	or encounter_script.get("pick_difficulty")!=null) :
		skillbutton.show()

	
	show()
#	disablerButton.show()
	#GameState.set_paused(true)
#	Input.set_custom_mouse_cursor(GameState.cursor_click)
	#GDScriptFunctionState await object: Object = null.signal:String=
	await self.encounter_over
	print('encounter_over')
	close()

func close() :
	#GameState.set_paused(false)
#	Input.set_custom_mouse_cursor(GameState.cursor_sword)
#	disablerButton.hide()
	hide()
	close_spell_menu()
	UI.ow_hud.close_special_encounter(true)


func on_viewport_size_changed(screensize:Vector2) :
	_set_position(Vector2(0, screensize.y-250))
	# map zone size = x-360  y-200
	useitemRect._set_size( Vector2((screensize.x-360)*0.6666-1, (screensize.y-200)-120 ) )
	useitemRect._set_global_position(Vector2((screensize.x-360)*0.16666, 60))

	itempreview.chargesLabel._set_position( Vector2(floor((screensize.x-360)*0.6666) - 85 -10, 4) )
	itempreview.statsLabel._set_position( Vector2(floor((screensize.x-360)*0.6666) - 205 -10, 20) )
	#itempreview.colorRect._set_size(Vector2(floor((screensize.x-360)*0.6666)-10, 40))
	itempreview.set_deferred("size",  Vector2(floor((screensize.x-360)*0.6666)-10, 40)   )
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_InventoryButton_pressed():
	close_spell_menu()
	choiceContainer.hide()
	speakButton.get_child(0).hide()
	if UI.ow_hud.selected_character == null :
		useitemRect.character = GameGlobal.player_characters[0]
	else :
		useitemRect.character = UI.ow_hud.selected_character
	useitemRect.display_character_inventory()
	useitemRect.show()

func _on_item_used(item : Dictionary, character) :
#	print(character.name+' used '+item["name"]+' !')
	useitemRect.hide()
	await encounter_script._on_item_used(item, character)

func _on_ActionButton_pressed():
	close_spell_menu()
	choiceContainer.hide()
	speakButton.get_child(0).hide()
	useitemRect.hide()
	await encounter_script._on_ActionButton_pressed()

func _on_SpeakButton_pressed():
	close_spell_menu()
	choiceContainer.hide()
	useitemRect.hide()
	speakField.set_text('')
	speakButton.get_child(0).show()

func _on_SpeakDoneButton_pressed():
	close_spell_menu()
	choiceContainer.hide()
	speakButton.get_child(0).hide()
	await encounter_script._on_speaking(speakField.get_text())
	speakField.set_text('')

func _on_StopButton_pressed():
	close_spell_menu()
	choiceContainer.hide()
	useitemRect.hide()
	UI.ow_hud.spellcastMenu.hide()
	if UI.ow_hud.textRect.choicesContainer.visible :
		return
	emit_signal("encounter_over")

func close_spell_menu() :
	UI.ow_hud.spellcastMenu.hide()
	#UI.ow_hud.spellcastMenu.emit_signal("abort", null, null, 0, {} )

func _on_spell_button_pressed() -> void:
	choiceContainer.hide()
	useitemRect.hide()
	speakButton.get_child(0).hide()
	var spells_menu : SpellsMenu = UI.ow_hud.spellcastMenu
	spells_menu.initialize(GameGlobal.player_characters[0])
	spells_menu.show()
	await spells_menu.hidden
	#var spell_picked = await UI.ow_hud.spellcastMenu.spell_picked
	var picked_character = spells_menu.picked_character
	var picked_spell = spells_menu.picked_spell
	var picked_power : int = spells_menu.picked_power
	if typeof(picked_spell) == TYPE_STRING :
		print("EncounterControl spell_picked : STRING. abort.")
		return
	print("EncounterControl spell_picked : ",picked_spell.name,' lv'+str(picked_power)+" by ", picked_character.name)
	encounter_script._on_spell_used(picked_character, picked_spell, picked_power)
	
	#var picked_character = null
#var picked_level = 1
#var picked_spell = null
#var picked_power : int = 1


func _on_skills_button_pressed() -> void:
	close_spell_menu()
	choiceContainer.hide()
	useitemRect.hide()
	speakButton.get_child(0).hide()
	
	if UI.ow_hud.selected_character == null :
		useSkillRect.character = GameGlobal.player_characters[0]
	else :
		useSkillRect.character = UI.ow_hud.selected_character
	useSkillRect.display_character_skills(encounter_script)
	useSkillRect.show()
