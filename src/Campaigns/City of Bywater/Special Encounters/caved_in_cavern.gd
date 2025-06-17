const allow_items : bool = false
const allow_action : bool = true
const allow_skill : bool = false
const allow_spell : bool = true
const allow_speak : bool = false
const allow_stop : bool = true

signal encounter_over

#static var control = null

#func set_control(c : Control) :
#	control = c

func _ready() :
	pass

func _on_spell_used(spell, character) :
	var result : String = "0"
	if ["Dig Hole", "Shape Earth"].has(spell.name) :
		result ="1"
	if spell.name == "Hands to Clay" :
		result ="4"
	if "Flesh" == spell.name :
		result = "2"
	await generic_outcome(result)
	emit_signal("encounter_over")


func _on_item_used(item, character) :
	#NO ITEMS.. MAYBE ADD SCROLLS LATER
	await generic_outcome("0")
	emit_signal("encounter_over")

func _on_ActionButton_pressed() :
	var textRect = UI.ow_hud.textRect
	var action1 : String = "Dig"
	var action2 : String = "Throw stones at mountain"
	var action3 : String = "Attempt to climb slope"
	textRect.display_multiple_choices(["What do  you want to do?",action1, action2, action3, "STOP"], ["TEXT","1", "0", "0","STOP"])
	var answer = await textRect.choice_pressed
	await generic_outcome(answer)
	emit_signal("encounter_over")

func _on_speaking(spoken : String) :
	#NOT USED HERE
	emit_signal("encounter_over")

func generic_outcome(result : String) :
	var text : String = ""
	if result == "1" :
		text = "You have succeeded in uncovering the passage behind the cave-in.  It is now  possible to traverse the passage to wherever it may take you."
		await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
		text = "The tunnel continues west.  You smell decaying flesh.  The odor is almost overwhelming."
		await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
		GameGlobal.stuff_done["caved_in_cavern_solved"] = 1
		print("caved_in_cavern generic_outcome 1")
	if result ==  "2" :
		text = "It is a sickly sight to see living flesh growing out of the very rock.  However, your spell is far too feeble to move such large quantities of earth."
		await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
		print("caved_in_cavern generic_outcome 2")
	if result == "3" :
		ScriptHelperFuncsClass.heal_party(-1, 1, 4, "earth shake.wav")
		text = "As you stand pondering the situation, you here a deep rumble.  You look skyward and see the whole slope begin to slide towards you.  You manage to get away from the area with only slight damage.  However, the old site is hopelessly buried."
		await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
		ScriptHelperFuncsClass.teleport_to_map_and_pos("map_0", Vector2(5,48), "monster shout.wav")
		GameGlobal.stuff_done["caved_in_cavern_solved"] = 2 #BLOCKED
		print("caved_in_cavern generic_outcome 3")
	if result == "4" :
		ScriptHelperFuncsClass.heal_party(-1, 1, 4, "earth shake.wav")
		text = "You have only managed to bring fresh debris down around you."
		await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
		print("caved_in_cavern generic_outcome 4")
		
