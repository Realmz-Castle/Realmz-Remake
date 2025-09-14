const allow_spells : bool = true
const allow_items : bool = true
const allow_action : bool = true
const allow_skill : bool = true
const allow_speak : bool = true
const allow_stop : bool = true


var detected_trap_flag_stuff_done : String = 'default_enc_detect'
var detected_trap_success_flag_stuff_done : String = 'default_enc_detect_success'
var disabled_trap_flag_stuff_done : String = 'default_enc_disable'
var disabled_trap_success_flag_stuff_done : String = 'default_enc_disable_success'
var picked_trap_flag_stuff_done : String = 'default_enc_picked'
var acro_difficulty : float = 10
var dete_difficulty : float = 10
var disa_difficulty : float = 10
var pick_difficulty : float = 10


signal encounter_over

#static var control = null

#func set_control(c : Control) :
#	control = c

func _ready() :
	pass

func _on_spell_used(character, spell, power) :
	await ScriptHelperFuncsClass.display_text_wait_noise("You cast "+spell.name+" at thin air.",spell.sounds[1])
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
	emit_signal("encounter_over", spoken)

func generic_outcome() :
	var random_text_1 : String = "You are unable to see any result"
	var random_text_2 : String = "Nothing special seems to happen"
	var random_text_3 : String = "You notice nothing different"
	var randomtext : String = [random_text_1, random_text_2, random_text_3].pick_random()
	await ScriptHelperFuncsClass.display_text_wait_noise(randomtext,'message nod.wav')
	
func _on_acro_used(stat : float, character) :
	var chance : float =  clampf(0.01*(stat-acro_difficulty),0.0,1.0)
	if randf()>chance :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" failed Acrobatics.",'bleeding.wav')
	else :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" succeeds Acrobatics.",'level up.wav')

func _on_dete_used(stat : float, character) :
	var chance : float =  clampf(0.01*(stat-dete_difficulty),0.0,1.0)
	if randf()>chance :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" failed Detect Traps.",'bleeding.wav')
		GameGlobal.stuff_done[detected_trap_success_flag_stuff_done] = 0
	else :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" succeeds Detect Traps !.",'level up.wav')
		GameGlobal.stuff_done[detected_trap_success_flag_stuff_done] = 1
	GameGlobal.stuff_done[detected_trap_flag_stuff_done] = 1
	

func _on_disa_used(stat : float, character) :
	var chance : float =  clampf(0.01*(stat-disa_difficulty),0.0,1.0)
	if randf()>chance :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" failed Disable Trap.",'bleeding.wav')
		GameGlobal.stuff_done[disabled_trap_success_flag_stuff_done] = 0
	else :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" succeeds Disable.",'level up.wav')
		GameGlobal.stuff_done[disabled_trap_success_flag_stuff_done] = 1
	GameGlobal.stuff_done[disabled_trap_flag_stuff_done] = 1



func _on_pick_used(stat : float, character) :
	if not GameGlobal.stuff_done.has(disabled_trap_success_flag_stuff_done) :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" tried to picka  lock and triggered a trap ! Fortunately it can only  trigger once, it's now safe.",'bleeding.wav')
		GameGlobal.stuff_done[disabled_trap_success_flag_stuff_done] = 1
		return
	var chance : float =  clampf(0.01*(stat-pick_difficulty),0.0,1.0)
	if randf()>chance :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" failed Pick Lock. The lock is now stuck...",'bleeding.wav')
	else :
		await ScriptHelperFuncsClass.display_text_wait_noise(character.name+" succeeds Pick Lock.",'level up.wav')
	GameGlobal.stuff_done[picked_trap_flag_stuff_done] = 1

func _on_forc_used(stat : float, character) :
	pass
