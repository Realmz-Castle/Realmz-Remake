extends RefCounted


signal encounter_over
signal encounter_changed

var allow_spells := false
var allow_items := false
var allow_action := false
var allow_speak := false
var allow_stop := true

var acro_difficulty: Variant = null
var dete_difficulty: Variant = null
var disa_difficulty: Variant = null
var pick_difficulty: Variant = null
var force_difficulty: Variant = null

var detected_trap_flag_stuff_done := ""
var detected_trap_success_flag_stuff_done := ""
var disabled_trap_flag_stuff_done := ""
var disabled_trap_success_flag_stuff_done := ""
var picked_trap_flag_stuff_done := ""

var _runtime: RefCounted
var _entry_encounter_id := ""


func configure(runtime: RefCounted) -> void:
	_runtime = runtime
	_entry_encounter_id = _runtime.get_current_encounter_id()
	_refresh_configuration()


func begin() -> void:
	var entered: Dictionary = _runtime.enter_encounter(_entry_encounter_id)
	if entered.get("status") != "ok":
		push_error(str(entered.get("message", "Unable to enter native encounter")))
		return
	_refresh_configuration()


func _on_ActionButton_pressed() -> void:
	var choices: Array = _runtime.get_action_choices()
	if choices.is_empty():
		await _finish_response(_runtime.respond("action", "", _context()))
		return
	var labels: Array = ["What do you want to do?"]
	var values: Array = ["TEXT"]
	for choice: Dictionary in choices:
		labels.append(str(choice.get("label", choice.get("id", ""))))
		values.append(str(choice.get("id", "")))
	labels.append("STOP")
	values.append("STOP")
	var answer: Variant = await _show_action_choices(labels, values)
	if str(answer) == "STOP":
		return
	await _finish_response(_runtime.respond("action", answer, _context()))


func _show_action_choices(labels: Array, values: Array) -> Variant:
	# The legacy TextRect helper still targets the removed MultipleChoices state.
	var choices = UI.ow_hud.textRect.choicesContainer
	choices.show()
	choices.display_multiple_choices(labels, values)
	var answer: Variant = await choices.choice_pressed
	choices.hide()
	return answer


func _on_speaking(spoken: String) -> void:
	await _finish_response(_runtime.respond("spokenWord", spoken, _context()))


func _on_spell_used(character, spell, power: int) -> void:
	var context := _context()
	context["character"] = character
	context["spell"] = spell
	context["power"] = power
	await _finish_response(_runtime.respond("spell", spell.name, context))


func _on_item_used(item: ItemInstance, character) -> void:
	var context := _context()
	context["character"] = character
	context["item"] = item
	var definition := NodeAccess.__Resources().get_item_definition(item)
	await _finish_response(_runtime.respond(
		"item",
		definition.display_name_for(item) if definition != null else "",
		context,
	))


func _on_acro_used(stat: float, character) -> void:
	await _use_skill("Acrobatics", stat, character)


func _on_dete_used(stat: float, character) -> void:
	await _use_skill("Detect_Trap", stat, character)


func _on_disa_used(stat: float, character) -> void:
	await _use_skill("Disable_Trap", stat, character)


func _on_pick_used(stat: float, character) -> void:
	await _use_skill("Pick_Lock", stat, character)


func _on_forc_used(stat: float, character) -> void:
	await _use_skill("Force_Lock", stat, character)


func _use_skill(skill_name: String, stat: float, character) -> void:
	var context := _context()
	context["character"] = character
	context["stat"] = stat
	context["roll"] = randf() * 100.0
	await _finish_response(_runtime.respond("rogueSkill", skill_name, context))


func _finish_response(outcome: Dictionary) -> void:
	if outcome.get("status") != "ok":
		push_error(str(outcome.get("message", "Native encounter response failed")))
		return
	await _apply_effects(outcome.get("effects", []), outcome.get("context", {}))
	if not str(outcome.get("nextEncounter", "")).is_empty():
		_refresh_configuration()
		encounter_changed.emit()
	if bool(outcome.get("close", true)):
		encounter_over.emit()


func _apply_effects(effects: Array, context: Dictionary) -> void:
	for effect_value: Variant in effects:
		if not effect_value is Dictionary:
			continue
		var effect: Dictionary = effect_value
		match str(effect.get("type", "")):
			"message":
				await ScriptHelperFuncsClass.display_text_wait_noise(
					str(effect.get("text", "")),
					str(effect.get("sound", "message nod.wav"))
				)
			"setFlag":
				var flag_name := str(effect.get("id", ""))
				if not flag_name.is_empty():
					GameGlobal.stuff_done[flag_name] = effect.get("value", true)
			"setState":
				# The runtime records this effect before the adapter presents it.
				pass
			"mapMutation":
				_apply_map_mutation(effect)
			"actionPointMutation":
				_apply_action_point_mutation(effect)
			"giveMinimap":
				ScriptHelperFuncsClass.give_minimap(int(effect.get("id", 0)))
			"teleport":
				GameGlobal.change_map(
					str(effect.get("map", GameGlobal.currentmap_name)),
					int(effect.get("x", 0)),
					int(effect.get("y", 0))
				)
			"extension":
				_call_campaign_extension(effect, context)
			_:
				push_warning("Unknown native encounter effect: %s" % str(effect.get("type", "")))


func _apply_map_mutation(effect: Dictionary) -> void:
	var mutation_id := str(effect.get("id", ""))
	if mutation_id.is_empty():
		return
	var map_name := str(effect.get("map", GameGlobal.currentmap_name))
	GameGlobal.stuff_done["%s.mutation.%s" % [map_name, mutation_id]] = effect.get("value", true)


func _apply_action_point_mutation(effect: Dictionary) -> void:
	var script_name := str(effect.get("script", ""))
	if script_name.is_empty():
		return
	var map_name := str(effect.get("map", GameGlobal.currentmap_name))
	var flag_prefix := "%s.script_%s" % [map_name, script_name]
	if effect.has("chance"):
		GameGlobal.stuff_done[flag_prefix + ".chance"] = float(effect["chance"])
	if effect.has("replacement"):
		GameGlobal.stuff_done[flag_prefix + ".replaced"] = str(effect["replacement"])


func _call_campaign_extension(effect: Dictionary, context: Dictionary) -> void:
	var method_name := str(effect.get("method", ""))
	var handler: Variant = GameGlobal.campaign_global_script
	if method_name.is_empty() or handler == null or not handler.has_method(method_name):
		push_warning("Native encounter extension %s is unavailable" % method_name)
		return
	var arguments_value: Variant = effect.get("arguments", [])
	var arguments: Array = arguments_value.duplicate(true) if arguments_value is Array else []
	arguments.append(context)
	handler.callv(method_name, arguments)


func _refresh_configuration() -> void:
	var allowed: Dictionary = _runtime.get_allowed_responses()
	allow_action = bool(allowed.get("action", false))
	allow_speak = bool(allowed.get("spokenWord", false))
	allow_spells = bool(allowed.get("spell", false))
	allow_items = bool(allowed.get("item", false))
	allow_stop = bool(allowed.get("stop", true))

	acro_difficulty = _skill_difficulty("Acrobatics")
	dete_difficulty = _skill_difficulty("Detect_Trap")
	disa_difficulty = _skill_difficulty("Disable_Trap")
	pick_difficulty = _skill_difficulty("Pick_Lock")
	force_difficulty = _skill_difficulty("Force_Lock")

	var encounter_key := "native.%s" % _runtime.get_current_encounter_id()
	detected_trap_flag_stuff_done = encounter_key + ".detect"
	detected_trap_success_flag_stuff_done = encounter_key + ".detect.success"
	disabled_trap_flag_stuff_done = encounter_key + ".disable"
	disabled_trap_success_flag_stuff_done = encounter_key + ".disable.success"
	picked_trap_flag_stuff_done = encounter_key + ".pick"


func _skill_difficulty(skill_name: String) -> Variant:
	var configured: Dictionary = _runtime.get_skill_configuration(skill_name)
	return float(configured["difficulty"]) if configured.has("difficulty") else null


func _context() -> Dictionary:
	return {"flags": GameGlobal.stuff_done}
