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
	textRect.set_text("otherencounter "+character.name+' used '+item["name"]+' !')
	emit_signal("encounter_over")

func _on_ActionButton_pressed() :
	var textRect = UI.ow_hud.textRect
	textRect.display_multiple_choices(["Other First choice","Other Second Choice", "STOP"], ["1","2","STOP"])
	var answer = await textRect.choice_pressed
	if answer == "1" :
		textRect.set_text("You picked : Other First choice", true)
		await textRect.interruption_over
	else :
		textRect.set_text("You picked : Other Second choice", true)
		await textRect.interruption_over
	textRect.set_text("", false)
	emit_signal("encounter_over")

func _on_speaking(spoken : String) :
	var textRect = UI.ow_hud.textRect
	textRect.set_text('You say : "'+spoken+'".', true)
	if spoken == "home" :
		print("You speak home")
	emit_signal("encounter_over")