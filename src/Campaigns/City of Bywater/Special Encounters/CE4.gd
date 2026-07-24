const allow_spells : bool = true
const allow_items : bool = true
const allow_action : bool = true
const allow_skill : bool = true
const allow_speak : bool = false
const allow_stop : bool = true

var detected_trap_flag_stuff_done : String = 'ce4_detect'
var detected_trap_success_flag_stuff_done : String = 'ce4_detect_success'
var disabled_trap_flag_stuff_done : String = 'ce4_disable'
var disabled_trap_success_flag_stuff_done : String = 'ce4_disable_success'
var picked_trap_flag_stuff_done : String = 'ce4_picked'
var dete_difficulty : float = 20
var disa_difficulty : float = 0
var pick_difficulty : float = 10

signal encounter_over

func _ready() :
	pass

func _on_spell_used(character, spell, power) :
	var result : String = "0"
	if spell.name == "Open Lock" :
		result = "1"
	if spell.name == "Destroy Trap" :
		result = "1"
	if result == "1":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(0)
	else:
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func _on_item_used(item, character) :
	var result : String = "0"
	var definition := NodeAccess.__Resources().get_item_definition(item)
	if definition != null and definition.display_name == "Necklace of Keys" :
		result = "1"
	if result == "1":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(0)
	else:
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func _on_ActionButton_pressed() :
	var textRect = UI.ow_hud.textRect
	var action1 : String = "Bang on the door."
	var action2 : String = "Try and force the door."
	textRect.display_multiple_choices(["What do  you want to do?",action1, action2, "STOP"], ["TEXT","3", "3","STOP"])
	var answer = await textRect.choice_pressed
	if answer != "STOP":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(2)
		emit_signal("encounter_over")

func _on_speaking(spoken : String) :
	await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func result1() :
	await ScriptHelperFuncsClass.play_sound_divinity(141)
	var text : String = "The lock is now open."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')

func result2() :
	await ScriptHelperFuncsClass.play_sound_divinity(654)
	var text : String = "As the echoes fade from your pounding, you hear a faint shuffling.  It would seem you have gained the attention of some of the denizens of this crypt."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	#New function
	await start_battle("BTL24", "BTL0")

func result3() :
	pass

func result4() :
	var text : String = "After making a hell of a lot of noise nothing happens."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	if randf() < 0.20:
		#New function
		await jump_to_simple_encounter(1)

func _on_dete_used(stat : float, character) :
	var chance : float = GameGlobal.get_rogue_skill_success(stat, dete_difficulty)
	if randf() > chance :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" detect no signs of a trap.",'bleeding.wav')
		GameGlobal.stuff_done[detected_trap_success_flag_stuff_done] = 0
	else :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" have checked the lock and are sure that it is not trapped.",'level up.wav')
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
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" have failed to pick the lock.",'bleeding.wav')
		GameGlobal.stuff_done[picked_trap_flag_stuff_done] = 0
	else :
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(0)
		GameGlobal.stuff_done[picked_trap_flag_stuff_done] = 1
		emit_signal("encounter_over")

func _on_forc_used(stat : float, character) :
	var chance : float = GameGlobal.get_rogue_skill_success(stat, 0)
	if randf() > chance :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" failed to force the lock.",'bleeding.wav')
	else :
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(0)
		emit_signal("encounter_over")

#New function
func start_battle(low_btl : String, high_btl : String) :
	pass

#New function
func jump_to_simple_encounter(target : int) :
	pass
