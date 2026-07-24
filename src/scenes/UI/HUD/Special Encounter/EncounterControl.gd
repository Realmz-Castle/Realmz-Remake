extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var encounter_script = null  #GDScript instanced, so justa  RefCounted
var encounter_name := ""
var encounter_phrase_selection_mode := false
var encounter_phrase := ""

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
signal encounter_phrase_submitted

# Called when the node enters the scene tree for the first time.
func _ready():
	on_viewport_size_changed(ScreenUtils.get_logical_window_size(self))
	useitemRect.connect("item_picked",Callable(self,"_on_item_used"))
	useSkillRect.connect("skill_picked", Callable(self,"_on_skill_used"))

func initialize(scriptname : String) :
	if not transition_to(scriptname):
		close()
		return
	await self.encounter_over
	close()


func transition_to(scriptname: String) -> bool:
	print("encountercontrol initialize : "+scriptname)
	encounter_phrase_selection_mode = false
	encounter_phrase = ""
	var resources = NodeAccess.__Resources()
	var encounter_name := scriptname
	if not resources.special_encounters_book.has(encounter_name):
		encounter_name = encounter_name.trim_suffix(".gd")
	if not resources.special_encounters_book.has(encounter_name):
		push_error("Special encounter %s was not found" % scriptname)
		return false
	self.encounter_name = encounter_name
	if encounter_script != null:
		if encounter_script.is_connected("encounter_over", _on_encounter_script_over):
			encounter_script.disconnect("encounter_over", _on_encounter_script_over)
		if encounter_script.has_signal("encounter_changed") \
				and encounter_script.is_connected("encounter_changed", _configure_encounter_buttons):
			encounter_script.disconnect("encounter_changed", _configure_encounter_buttons)
	encounter_script = resources.special_encounters_book[encounter_name]
	if encounter_script.has_method("begin"):
		encounter_script.begin()
	encounter_script.connect("encounter_over", _on_encounter_script_over)
	if encounter_script.has_signal("encounter_changed"):
		encounter_script.connect("encounter_changed", _configure_encounter_buttons)
	_configure_encounter_buttons()
	show()
	return true


func run_result(result_index: int) -> Variant:
	var replacement := ScriptHelperFuncsClass.get_complex_result_replacement_Divinity(
		encounter_name,
		result_index
	)
	if not replacement.is_empty():
		return await ScriptHelperFuncsClass.run_replacement_action_point_Divinity(replacement)
	var method_name := "result%d" % (result_index + 1)
	if encounter_script == null or not encounter_script.has_method(method_name):
		push_error("Special encounter has no result row %d" % result_index)
		return false
	await encounter_script.call(method_name)
	return true


func _configure_encounter_buttons() -> void:
	for b in boxContainer.get_children():
		b.hide()
	speakField.set_text('')
	speakButton.get_child(0).hide()
	useitemRect.hide()
	useSkillRect.hide()

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
	or encounter_script.get("pick_difficulty")!=null
	or encounter_script.get("force_difficulty")!=null) :
		skillbutton.show()


func _on_encounter_script_over(_result: Variant = null) -> void:
	encounter_over.emit()


func initialize_phrase_for_encounter() -> void:
	encounter_phrase_selection_mode = true
	encounter_phrase = ""
	close_spell_menu()
	choiceContainer.hide()
	useitemRect.hide()
	for button: Node in boxContainer.get_children():
		button.hide()
	speakButton.show()
	speakField.set_text("")
	speakButton.get_child(0).show()
	show()
	speakField.grab_focus()

func close(returnedbyencounter=null) :
	#GameState.set_paused(false)
#	Input.set_custom_mouse_cursor(GameState.cursor_sword)
#	disablerButton.hide()
	print("EncounterControl returnedbyencounter : ", returnedbyencounter)
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

func _on_item_used(item: ItemInstance, character: Creature) -> void:
	useitemRect.hide()
	await encounter_script._on_item_used(item, character)

func _on_skill_used(skillname : String, character) :
	if skillname == "abort":
		useSkillRect.hide()
		return
	print("EncounterControl _on_skill_used : "+skillname+" by "+character.name)
	var stat : float = character.get_stat(skillname)
	match skillname :
		"Acrobatics" :
			await encounter_script._on_acro_used(stat, character)
		"Detect_Trap" :
			await encounter_script._on_dete_used(stat, character)
		"Disable_Trap" :
			await encounter_script._on_disa_used(stat, character)
		"Pick_Lock" :
			await encounter_script._on_pick_used(stat, character)
		"Force_Lock" :
			await encounter_script._on_forc_used(stat, character)
	if visible:
		useSkillRect.display_character_skills(encounter_script)


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
	var entered_text := speakField.get_text()
	if encounter_phrase_selection_mode:
		encounter_phrase_selection_mode = false
		encounter_phrase = entered_text
		speakField.set_text('')
		encounter_phrase_submitted.emit()
		return
	await encounter_script._on_speaking(entered_text)
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
	if (picked_spell == null) :
		print("EncounterControl spell_picked : null. abort.")
		return
	print("EncounterControl spell_picked : ",picked_spell.name,' lv'+str(picked_power)+" by ", picked_character.name)
	await encounter_script._on_spell_used(picked_character, picked_spell, picked_power)
	
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
