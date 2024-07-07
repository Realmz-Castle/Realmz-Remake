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

func _on_item_used(item, character) :
	var textRect = UI.ow_hud.textRect
	textRect.set_text(character.name+' used '+item["name"]+' !')

func _on_ActionButton_pressed() :
	var textRect = UI.ow_hud.textRect
	textRect.display_multiple_choices(["First choice","Second Choice", "STOP"], ["1","2","STOP"])
	var answer = await textRect.choice_pressed
	if answer == "1" :
		emit_signal("encounter_over")
		print("Good Encounter  Answer !!!")
	else :
		print("bad answer, it was  the first")

func _on_speaking(spoken : String) :
	var textRect = UI.ow_hud.textRect
	textRect.set_text('You say : "'+spoken+'".', true)
	if spoken == "home" :
		print("You speak home")