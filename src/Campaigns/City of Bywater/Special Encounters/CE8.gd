const allow_spells : bool = true
const allow_items : bool = true
const allow_action : bool = true
const allow_skill : bool = false
const allow_speak : bool = false
const allow_stop : bool = true

var disa_difficulty : float = 10

signal encounter_over

func _ready() :
	pass

func _on_spell_used(character, spell, power) :
	var result : String = "0"
	if spell.name == "Waterworld" :
		result = "1"
	if spell.name == "Watergate" :
		result = "1"
	if result == "1":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(0)
	else:
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func _on_item_used(item, character) :
	var result : String = "0"
	var definition := NodeAccess.__Resources().get_item_definition(item)
	if definition != null and definition.display_name == "Waterworld" :
		result = "1"
	if result == "1":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(0)
	else:
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func _on_ActionButton_pressed() :
	var textRect = UI.ow_hud.textRect
	var action1 : String = "Hold breath and dive in."
	var action2 : String = "Drink some of the water"
	var action3 : String = "Throw something in"
	textRect.display_multiple_choices(["What do  you want to do?",action1, action2, action3, "STOP"], ["TEXT","2", "2", "2","STOP"])
	var answer = await textRect.choice_pressed
	if answer != "STOP":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(1)
		emit_signal("encounter_over")

func _on_speaking(spoken : String) :
	await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func result1() :
	await ScriptHelperFuncsClass.play_sound_divinity(667)
	#New function
	await teleport_to_location(3, 6, 50, 666)

func result2() :
	var text : String = "About forty feet down, you see a short tunnel that radiates light.  It obviously surfaces somewhere, but you cannot hold your breath long enough to reach it.  You must turn back."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')

func result4() :
	var text : String = "Nothing happens."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')

#New function
func teleport_to_location(level : int, x : int, y : int, sound : int) :
	pass
