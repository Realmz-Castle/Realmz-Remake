const allow_spells : bool = true
const allow_items : bool = false
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
	if ["Dig Hole", "Shape Earth"].has(spell.name) :
		result = "1"
	if spell.name == "Hands to Clay" :
		result = "4"
	if spell.name == "Flesh" :
		result = "2"
	if result == "1":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(0)
	elif result == "2":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(1)
	elif result == "4":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	else:
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func _on_item_used(item, character) :
	await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func _on_ActionButton_pressed() :
	var textRect = UI.ow_hud.textRect
	var action1 : String = "Dig"
	var action2 : String = "Throw stones at mountain"
	var action3 : String = "Attempt to climb slope"
	textRect.display_multiple_choices(["What do  you want to do?",action1, action2, action3, "STOP"], ["TEXT","1", "1", "1","STOP"])
	var answer = await textRect.choice_pressed
	if answer != "STOP":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(0)
		emit_signal("encounter_over")

func _on_speaking(spoken : String) :
	await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func result1() :
	var text : String = "You have succeeded in uncovering the passage behind the cave-in.  It is now  possible to traverse the passage to wherever it may take you."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	text = "The tunnel continues west.  You smell decaying flesh.  The odor is almost overwhelming."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	GameGlobal.stuff_done["caved_in_cavern_solved"] = 1

func result2() :
	var text : String = "It is a sickly sight to see living flesh growing out of the very rock.  However, your spell is far too feeble to move such large quantities of earth."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')

func result3() :
	var text : String = "As you stand pondering the situation, you here a deep rumble.  You look skyward and see the whole slope begin to slide towards you.  You manage to get away from the area with only slight damage.  However, the old site is hopelessly buried."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	ScriptHelperFuncsClass.heal_party(-1, 1, 4, "earth shake.wav")
	ScriptHelperFuncsClass.teleport_to_map_and_pos("map_0", Vector2(5,48), "monster shout.wav")
	GameGlobal.stuff_done["caved_in_cavern_solved"] = 2

func result4() :
	var text : String = "You have only managed to bring fresh debris down around you."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	ScriptHelperFuncsClass.heal_party(-1, 1, 4, "earth shake.wav")
