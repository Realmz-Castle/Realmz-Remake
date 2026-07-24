const allow_spells : bool = true
const allow_items : bool = true
const allow_action : bool = true
const allow_skill : bool = true
const allow_speak : bool = false
const allow_stop : bool = true

var detected_trap_flag_stuff_done : String = 'ce9_detect'
var detected_trap_success_flag_stuff_done : String = 'ce9_detect_success'
var disabled_trap_flag_stuff_done : String = 'ce9_disable'
var disabled_trap_success_flag_stuff_done : String = 'ce9_disable_success'
var picked_trap_flag_stuff_done : String = 'ce9_picked'
var acro_difficulty : float = -5
var disa_difficulty : float = 0

signal encounter_over

func _ready() :
	pass

func _on_spell_used(character, spell, power) :
	var result : String = "0"
	var spell_names = ["Fantastic Wings", "Leap", "Superfly", "Limited Phase", "Phase"]
	if spell_names.has(spell.name) :
		result = "1"
	if result == "1":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(0)
	else:
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func _on_item_used(item, character) :
	var result : String = "0"
	var definition := NodeAccess.__Resources().get_item_definition(item)
	var item_name := definition.display_name if definition != null else ""
	var classic_ids := definition.classic_item_ids() if definition != null else []
	if item_name == "Rope" :
		result = "1"
	if classic_ids.has(813) :
		result = "1"
	if classic_ids.has(819) :
		result = "1"
	if classic_ids.has(811) :
		result = "4"
	if classic_ids.has(816) :
		result = "4"
	if result == "1":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(0)
	elif result == "4":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	else:
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func _on_ActionButton_pressed() :
	var textRect = UI.ow_hud.textRect
	var action1 : String = "Summon the town guard"
	textRect.display_multiple_choices(["What do  you want to do?",action1, "STOP"], ["TEXT","3","STOP"])
	var answer = await textRect.choice_pressed
	if answer != "STOP":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(2)
		emit_signal("encounter_over")

func _on_speaking(spoken : String) :
	await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func result1() :
	var text : String = "You have been successful and have retrieved the mutt.  The boy looks at you with misty eyes as he thanks you.  Somewhere a passionate deity looks down and smiles.   You are invited to come play in the old cave.  \"What cave?\" you ask."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	text = "\"Why, the old cave that leads into the castle courtyard.\"  He draws you a map on a piece of parchment.  You kindly turn down the chance to play with him, and he skips off with his happy, but muddy friend."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	#award 1500 victory points
	StateMachine.enter_ex_menu_state({"menu_name" : "LootMenu", "treasure" : [] ,"money" : [0,0,0] ,"exp" : 1500 })
	await UI.ow_hud.treasureControl.done_looting
	ScriptHelperFuncsClass.give_minimap(1)
	#New function
	await enable_area_point(0, 13, -1, 0, 0)

func result2() :
	var text : String = "Your attempt at climbing down the well has failed.  You lose your grip and fall to the bottom.  Now you need to be rescued as well.  The boy bursts out in tears all over again.  What have you gotten into?"
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	text = "At the bottom of the well, you find an old rope ladder.  It is very old but usable.  You throw one end up and climb out.   As you exit the well, the dog jumps out of your arms and runs off.  A screaming boy is right behind."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	#New function
	await enable_area_point(0, 13, -1, 0, 0)

func result3() :
	var text : String = "As you are bumbling about at trying to rescue the dog, the town guard shows up.  After much laughter at your expense, they produce a rope and complete the rescue.  This does not do much to raise your status as a hero."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	#New function
	await enable_area_point(0, 13, -1, 0, 0)

func result4() :
	pass

func _on_acro_used(stat : float, character) :
	var chance : float = GameGlobal.get_rogue_skill_success(stat, acro_difficulty)
	if randf() > chance :
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(1)
	else :
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(0)
		emit_signal("encounter_over")

func _on_disa_used(stat : float, character) :
	var chance : float = GameGlobal.get_rogue_skill_success(stat, disa_difficulty)
	if randf() > chance :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" failed Disable Trap.",'bleeding.wav')
		GameGlobal.stuff_done[disabled_trap_success_flag_stuff_done] = 0
	else :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" succeeds Disable Trap.",'level up.wav')
		GameGlobal.stuff_done[disabled_trap_success_flag_stuff_done] = 1
	GameGlobal.stuff_done[disabled_trap_flag_stuff_done] = 1

#New function
func enable_area_point(level : int, id : int, percent_chance : int, low : int, high : int) :
	pass
