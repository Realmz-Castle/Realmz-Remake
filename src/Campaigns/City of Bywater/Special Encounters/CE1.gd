const allow_spells : bool = true
const allow_items : bool = true
const allow_action : bool = true
const allow_skill : bool = false
const allow_speak : bool = true
const allow_stop : bool = true

var disa_difficulty : float = 10

signal encounter_over

func _ready() :
	pass

func _on_spell_used(character, spell, power) :
	var result : String = "0"
	if spell.name == "Charm Foe" :
		result = "1"
	if spell.name == "Major Charm Foe" :
		result = "1"
	if result == "1":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(0)
	else:
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func _on_item_used(item, character) :
	var result : String = "0"
	var definition := NodeAccess.__Resources().get_item_definition(item)
	if definition != null and definition.display_name == "Helm of True Sight +3" :
		result = "3"
	if result == "3":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(2)
	else:
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func _on_ActionButton_pressed() :
	var textRect = UI.ow_hud.textRect
	var action1 : String = "Examine some books."
	var action2 : String = "Study quietly at a table."
	textRect.display_multiple_choices(["What do  you want to do?",action1, action2, "STOP"], ["TEXT","2", "2","STOP"])
	var answer = await textRect.choice_pressed
	if answer != "STOP":
		var transitioned: bool = await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(1)
		if not transitioned:
			emit_signal("encounter_over")

func _on_speaking(spoken : String) :
	if spoken == "waterford" :
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(0)
	else:
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func result1() :
	var text : String = "\"Waterford was supposed to be but a legend.  I have discovered in my days of research through volumes of forgotten lore that it did exist.  In fact, it lies through a secret cave in the mountains east of here.  Only the best of wines were made there.\""
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	text = "\"I sought it out many years ago and brought some wine back, but I have not been there in many years.  The exact location of the city is lost to me.  I only recall the way into the Grimwall mountains.\""
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	ScriptHelperFuncsClass.give_minimap(2)

func result2() -> bool:
	var text : String = "You browse through many volumes of text.  If nothing else, you feel more enlightened."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	if randf() < 0.25:
		return jump_to_complex_encounter(2)
	return false

func result3() :
	pass

func result4() :
	var text : String = "Nothing happens."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')

func jump_to_complex_encounter(target: int) -> bool:
	return ScriptHelperFuncsClass.transition_complex_encounter_Divinity(target)
