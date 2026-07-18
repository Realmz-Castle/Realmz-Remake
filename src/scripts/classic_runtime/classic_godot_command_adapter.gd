class_name ClassicGodotCommandAdapter
extends RefCounted


func execute_command(command: String, payload: Dictionary) -> Dictionary:
	match command:
		"show_text":
			return await _show_text(payload)
		"choice":
			return await _show_yes_no_choice()
		"start_encounter":
			return await _show_encounter(payload)
		"play_sound":
			return _play_sound(payload)
		_:
			return _error("The Godot classic adapter does not yet handle '%s'" % command)


func _show_text(payload: Dictionary) -> Dictionary:
	var text_rect: Object = _text_rect()
	if text_rect == null:
		return _error("Realmz HUD TextRect is unavailable")
	var message: Variant = payload.get("message", {})
	var text := str(message.get("text", "")) if message is Dictionary else ""
	await text_rect.set_text(text, true)
	return {}


func _show_yes_no_choice() -> Dictionary:
	var text_rect: Object = _text_rect()
	if text_rect == null:
		return _error("Realmz HUD TextRect is unavailable")
	var answer: Variant = await _show_choices(text_rect, ["Yes", "No"], ["YES", "NO"])
	return {"accepted": str(answer) == "YES"}


func _show_encounter(payload: Dictionary) -> Dictionary:
	if str(payload.get("encounterKind", "")) != "simple":
		return _error("The first Godot vertical slice supports simple encounters only")
	var text_rect: Object = _text_rect()
	if text_rect == null:
		return _error("Realmz HUD TextRect is unavailable")
	var encounter: Variant = payload.get("encounter", {})
	if not (encounter is Dictionary):
		return _error("Classic encounter payload is missing its record")
	var prompt_message: Variant = payload.get("promptMessage", {})
	if prompt_message is Dictionary:
		text_rect.set_text(str(prompt_message.get("text", "")), false)
	var choice_model := build_simple_encounter_choices(encounter)
	var choices: Array = choice_model["choices"]
	var choice_tokens: Array = choice_model["outcomes"]
	if choices.is_empty():
		return _error("Classic simple encounter has no available choices")

	var selected_outcome: Variant = await _show_choices(text_rect, choices, choice_tokens)
	return {"outcome": int(selected_outcome)}


func _show_choices(text_rect: Object, choices: Array, choice_tokens: Array) -> Variant:
	# TextRect's legacy helper transitions to a removed `MultipleChoices` state.
	# Drive its existing choice container directly until Remake has a native
	# state-machine path for modal choices again.
	var choices_container: Object = text_rect.choicesContainer
	choices_container.show()
	choices_container.display_multiple_choices(choices, choice_tokens)
	var selected: Variant = await choices_container.choice_pressed
	choices_container.hide()
	return selected


func build_simple_encounter_choices(encounter: Dictionary) -> Dictionary:
	var texts: Variant = encounter.get("texts", [])
	var outcomes: Variant = encounter.get("choiceResults", [])
	var choices: Array = []
	var choice_tokens: Array = []
	if not (texts is Array) or not (outcomes is Array):
		return {"choices": choices, "outcomes": choice_tokens}
	for index: int in range(min(texts.size(), outcomes.size())):
		var outcome := int(outcomes[index])
		var choice_text := str(texts[index])
		if outcome <= 0 or choice_text.is_empty():
			continue
		choices.append(choice_text)
		choice_tokens.append(str(outcome))
	return {"choices": choices, "outcomes": choice_tokens}


func _play_sound(payload: Dictionary) -> Dictionary:
	var sound_id := int(payload.get("soundId", 0))
	if sound_id == 0:
		return {}
	var sound_ids: Object = _autoload("SfxIdDivinity")
	if sound_ids == null or not sound_ids.mapping.has(sound_id):
		return {"status": "skipped", "message": "Classic sound %d has no Remake mapping" % sound_id}
	var sound_name := str(sound_ids.mapping[sound_id])
	var node_access: Object = _autoload("NodeAccess")
	var resources: Object = node_access.__Resources() if node_access != null else null
	if resources == null or not resources.sounds_book.has(sound_name):
		return {"status": "skipped", "message": "Mapped sound '%s' is not loaded" % sound_name}
	var sfx_player: Object = _autoload("SfxPlayer")
	if sfx_player == null:
		return {"status": "skipped", "message": "Realmz SFX player is unavailable"}
	sfx_player.stream = resources.sounds_book[sound_name]
	sfx_player.play()
	return {}


func _text_rect() -> Object:
	var ui: Object = _autoload("UI")
	if ui == null or ui.ow_hud == null:
		return null
	return ui.ow_hud.textRect


func _autoload(autoload_name: String) -> Node:
	var main_loop: MainLoop = Engine.get_main_loop()
	if not (main_loop is SceneTree):
		return null
	return main_loop.root.get_node_or_null(autoload_name)


func _error(message: String) -> Dictionary:
	return {
		"status": "error",
		"message": message,
	}
