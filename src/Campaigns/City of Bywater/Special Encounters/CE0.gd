const allow_spells : bool = true
const allow_items : bool = true
const allow_action : bool = true
const allow_skill : bool = true
const allow_speak : bool = true
const allow_stop : bool = true

var detected_trap_flag_stuff_done : String = 'ce0_detect'
var detected_trap_success_flag_stuff_done : String = 'ce0_detect_success'
var disabled_trap_flag_stuff_done : String = 'ce0_disable'
var disabled_trap_success_flag_stuff_done : String = 'ce0_disable_success'
var picked_trap_flag_stuff_done : String = 'ce0_picked'
var acro_difficulty : float = 0
var dete_difficulty : float = 0
var disa_difficulty : float = 0
var pick_difficulty : float = 0

signal encounter_over

func _ready() :
	pass

func _on_spell_used(character, spell, power) :
	await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func _on_item_used(item, character) :
	await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func _on_ActionButton_pressed() :
	var textRect = UI.ow_hud.textRect
	var action1 : String = "Wait around"
	var action2 : String = "Whistle a merry tune"
	var action3 : String = "Enjoy tea and biscuits"
	textRect.display_multiple_choices(["What do  you want to do?",action1, action2, action3, "STOP"], ["TEXT","4", "4", "4","STOP"])
	var answer = await textRect.choice_pressed
	if answer != "STOP":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
		emit_signal("encounter_over")

func _on_speaking(spoken : String) :
	await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func result4() :
	var random_text_1 : String = "Nothing special seems to happen."
	var random_text_2 : String = "You notice nothing different."
	var random_text_3 : String = "You are unable to see any results."
	var random_text_4 : String = "Nothing happens."
	var randomtext : String = [random_text_1, random_text_2, random_text_3, random_text_4].pick_random()
	await ScriptHelperFuncsClass.display_text_wait_noise(randomtext,'message nod.wav')

func _on_acro_used(stat : float, character) :
	var chance : float = GameGlobal.get_rogue_skill_success(stat, acro_difficulty)
	if randf() > chance :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" failed Acrobatics.",'bleeding.wav')
	else :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" succeeds Acrobatics.",'level up.wav')

func _on_dete_used(stat : float, character) :
	var chance : float = GameGlobal.get_rogue_skill_success(stat, dete_difficulty)
	if randf() > chance :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" failed Detect Traps.",'bleeding.wav')
		GameGlobal.stuff_done[detected_trap_success_flag_stuff_done] = 0
	else :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" succeeds Detect Traps.",'level up.wav')
		GameGlobal.stuff_done[detected_trap_success_flag_stuff_done] = 1
	GameGlobal.stuff_done[detected_trap_flag_stuff_done] = 1

func _on_disa_used(stat : float, character) :
	var chance : float = GameGlobal.get_rogue_skill_success(stat, disa_difficulty)
	if randf() > chance :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" failed Disable Trap.",'bleeding.wav')
		GameGlobal.stuff_done[disabled_trap_success_flag_stuff_done] = 0
	else :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" succeeds Disable Trap.",'level up.wav')
		GameGlobal.stuff_done[disabled_trap_success_flag_stuff_done] = 1
	GameGlobal.stuff_done[disabled_trap_flag_stuff_done] = 1

func _on_pick_used(stat : float, character) :
	var chance : float = GameGlobal.get_rogue_skill_success(stat, pick_difficulty)
	if randf() > chance :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" failed Pick Lock.",'bleeding.wav')
		GameGlobal.stuff_done[picked_trap_flag_stuff_done] = 0
	else :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" succeeds Pick Lock.",'level up.wav')
		GameGlobal.stuff_done[picked_trap_flag_stuff_done] = 1
