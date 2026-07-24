const allow_spells : bool = true
const allow_items : bool = true
const allow_action : bool = true
const allow_skill : bool = true
const allow_speak : bool = false
const allow_stop : bool = true

var detected_trap_flag_stuff_done : String = 'ce6_detect'
var detected_trap_success_flag_stuff_done : String = 'ce6_detect_success'
var disabled_trap_flag_stuff_done : String = 'ce6_disable'
var disabled_trap_success_flag_stuff_done : String = 'ce6_disable_success'
var picked_trap_flag_stuff_done : String = 'ce6_picked'
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
	if spell.id == 1 :
		result = "3"
	if result == "1":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(0)
	elif result == "3":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(2)
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
	var action1 : String = "Knock on the door"
	var action2 : String = "Set fire to the building"
	textRect.display_multiple_choices(["What do  you want to do?",action1, action2, "STOP"], ["TEXT","3", "3","STOP"])
	var answer = await textRect.choice_pressed
	if answer != "STOP":
		await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(2)
		emit_signal("encounter_over")

func _on_speaking(spoken : String) :
	await ScriptHelperFuncsClass.dispatch_complex_result_Divinity(3)
	emit_signal("encounter_over")

func result1() :
	var text : String = "Most of the shop's goods have fallen into total ruin.  However, some items did survive along with a tidy sum of gold."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	ScriptHelperFuncsClass.give_treasure_with_id(14)

func result3() :
	var text : String = "You have set the building on fire.  Something causes the old building to explode."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	#New function
	await cast_spell_on_party("Fireball", 2, -100, true)
	#New function
	await change_map_tile(2, 29, 6, 164, 0)

func result4() :
	var text : String = "Nothing happens."
	await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')

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
func cast_spell_on_party(spell_name : String, power : int, drv_modifier : int, can_drv : bool) :
	pass

#New function
func change_map_tile(level : int, x : int, y : int, new_tile : int, level_type : int) :
	pass
