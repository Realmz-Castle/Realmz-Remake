const allow_items : bool = true
const allow_action : bool = true
const allow_skill : bool = true
const allow_speak : bool = true
const allow_stop : bool = true

signal encounter_over

#static var control = null

#func set_control(c : Control) :
#	control = c

func _ready() :
	pass

func _on_spell_used(spell, character) :
	await generic_outcome()
	emit_signal("encounter_over")


func _on_item_used(item, character) :
	await generic_outcome()
	emit_signal("encounter_over")

func _on_ActionButton_pressed() :
	var textRect = UI.ow_hud.textRect
	var action1 : String = "Wait around"
	var action2 : String = "Whistle a merry tune"
	var action3 : String = "Enjoy tea and biscuits"
	textRect.display_multiple_choices(["What do  you want to do?",action1, action2, action3, "STOP"], ["TEXT","idc", "idc", "idc","STOP"])
	var answer = await textRect.choice_pressed
	await generic_outcome()
	emit_signal("encounter_over")

func _on_speaking(spoken : String) :
	var textRect = UI.ow_hud.textRect
	textRect.set_text('You say : "'+spoken+'".', true)
	if spoken == "home" :
		print("You speak home")
	else :
		await generic_outcome()
	emit_signal("encounter_over")

func generic_outcome() :
	var random_text_1 : String = "You are unable to see any result"
	var random_text_2 : String = "Nothing special seems to happen"
	var random_text_3 : String = "You notice nothing different"
	var randomtext : String = [random_text_1, random_text_2, random_text_3].pick_random()
	await ScriptHelperFuncsClass.display_text_wait_noise(randomtext,'message nod.wav')
