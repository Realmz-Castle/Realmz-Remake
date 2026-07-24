const allow_spells : bool = true
const allow_items : bool = true
const allow_action : bool = true
const allow_skill : bool = true
const allow_speak : bool = false
const allow_stop : bool = true

var detected_trap_flag_stuff_done : String = 'ce5_detect'
var detected_trap_success_flag_stuff_done : String = 'ce5_detect_success'
var disabled_trap_flag_stuff_done : String = 'ce5_disable'
var disabled_trap_success_flag_stuff_done : String = 'ce5_disable_success'
var picked_trap_flag_stuff_done : String = 'ce5_picked'
var dete_difficulty : float = 0
var disa_difficulty : float = 0
var pick_difficulty : float = -10

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
	var item_name := definition.display_name if definition != null else ""
	if item_name == "Necklace of Keys" :
		result = "1"
	if item_name == "Iron Key" :
		result = "1"
	if result == "1":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(0)
	else:
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func _on_ActionButton_pressed() :
	var textRect = UI.ow_hud.textRect
	var action1 : String = "Try and smash the box open."
	textRect.display_multiple_choices(["What do  you want to do?",action1, "STOP"], ["TEXT","2","STOP"])
	var answer = await textRect.choice_pressed
	if answer != "STOP":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(1)
		emit_signal("encounter_over")

func _on_speaking(spoken : String) :
	await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func result1() :
	var text : String = "The chest pops open revealing several vials and a pair of scrolls."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	ScriptHelperFuncsClass.give_treasure_with_id(13)
	#New function
	await change_map_rect(5, 3, -1, "BTL0", "BTL0")
	await change_map_rect(5, 1, -1, "BTL0", "BTL0")

func result2() :
	await ScriptHelperFuncsClass.play_sound_divinity(10107)
	var text : String = "As you hit the box, you hear glass break.  Inside are several smashed vials and a pair of scrolls.  They are now soaked and worthless."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	#New function
	await change_map_rect(5, 3, -1, "BTL0", "BTL0")
	await change_map_rect(5, 1, -1, "BTL0", "BTL0")

func result3() :
	await ScriptHelperFuncsClass.play_sound_divinity(10107)
	var text : String = "Your fumbling around with the box has caused some vials of liquid to break inside.  Liquid oozes out of the box and seeps into the ground.  The smell is repugnant.  Most likely the vials contained magic potions.  What a pity!"
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	text = "With the glass already broken, you smash the box open.  There are several smashed vials and a pair of scrolls.  They are now soaked and worthless."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	#New function
	await change_map_rect(5, 3, -1, "BTL0", "BTL0")
	await change_map_rect(5, 1, -1, "BTL0", "BTL0")

func result4() :
	var text : String = "Nothing happens."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	#New function
	await change_map_rect(5, 3, -1, "BTL0", "BTL0")
	await change_map_rect(5, 1, -1, "BTL0", "BTL0")

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
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
		GameGlobal.stuff_done[picked_trap_flag_stuff_done] = 0
	else :
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(0)
		GameGlobal.stuff_done[picked_trap_flag_stuff_done] = 1
		emit_signal("encounter_over")

func _on_forc_used(stat : float, character) :
	var chance : float = GameGlobal.get_rogue_skill_success(stat, 20)
	if randf() > chance :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" failed to force the lock.",'bleeding.wav')
	else :
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(0)
		emit_signal("encounter_over")

#New function
func change_map_rect(level : int, id : int, times : int, low_btl : String, high_btl : String) :
	pass
