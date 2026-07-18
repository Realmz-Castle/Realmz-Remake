class_name ClassicGodotCommandAdapter
extends RefCounted

const RogueResolverScript = preload("res://scripts/classic_runtime/classic_rogue_encounter_resolver.gd")
const CHOICE_MENU_WIDTH := 380.0
const CHOICE_MENU_MARGIN := 20.0


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
	if str(payload.get("encounterKind", "")) == "complex":
		return await _show_complex_encounter(payload)
	if str(payload.get("encounterKind", "")) != "simple":
		return _error("Classic encounter kind is not supported")
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


func _show_complex_encounter(payload: Dictionary) -> Dictionary:
	var encounter: Variant = payload.get("encounter", {})
	var thief_encounter: Variant = payload.get("thiefEncounter", {})
	if not (encounter is Dictionary) or not (thief_encounter is Dictionary):
		return _error("The first complex encounter slice requires a Data TD2 rogue branch")
	var resolver: Object = RogueResolverScript.new()
	if not resolver.configure(encounter, thief_encounter):
		return _error(resolver.last_error)
	var text_rect: Object = _text_rect()
	if text_rect == null:
		return _error("Realmz HUD TextRect is unavailable")
	var character: Object = _selected_character()
	if character == null or not character.has_method("get_stat"):
		return _error("Classic rogue encounters require a selected party member")

	while true:
		_show_encounter_prompt(text_rect, payload)
		var choice_model := build_rogue_encounter_choices(
			resolver,
			character,
			bool(encounter.get("canBackOut", false))
		)
		var choices: Array = choice_model["choices"]
		var choice_tokens: Array = choice_model["tokens"]
		if choices.is_empty():
			return _error("Classic rogue encounter has no available actions")
		var selected: String = str(await _show_choices(text_rect, choices, choice_tokens))
		if selected == "back":
			return {
				"outcome": 0,
				"thiefEncounter": resolver.rogue_encounter.duplicate(true),
			}
		var token_parts: PackedStringArray = selected.split(":", false, 1)
		if token_parts.size() != 2 or token_parts[0] != "rogue":
			return _error("Classic complex encounter returned an invalid action")
		var action_index: int = int(token_parts[1])
		var chance: int = resolver.success_percent(
			action_index,
			float(character.get_stat(resolver.stat_name(action_index)))
		)
		var resolution: Dictionary = resolver.resolve_action(
			action_index,
			chance > 0 and randi_range(1, 100) <= chance
		)
		match str(resolution.get("status", "")):
			"error":
				return _error(str(resolution.get("message", "Classic rogue action failed")))
			"trap":
				return _error("Classic armed-trap effects are not implemented yet")
			"resolved":
				await _show_rogue_feedback(payload, resolution)
				var outcome := int(resolution.get("outcome", 0))
				if outcome != 0:
					return {
						"outcome": outcome,
						"thiefEncounter": resolution["thiefEncounter"],
					}
			_:
				return _error("Classic rogue action returned an invalid result")
	return _error("Classic rogue encounter ended unexpectedly")


func build_rogue_encounter_choices(
	resolver: Object,
	character: Object,
	can_back_out: bool
) -> Dictionary:
	var choices: Array = []
	var tokens: Array = []
	var character_name: String = str(character.get("name"))
	for action_value: Variant in resolver.available_actions():
		if not (action_value is Dictionary):
			continue
		var stat_name := str(action_value.get("stat", ""))
		if stat_name.is_empty():
			continue
		var action_index := int(action_value.get("index", -1))
		var stat_value := float(character.get_stat(stat_name))
		if stat_value <= 0.0:
			continue
		var chance: int = resolver.success_percent(
			action_index,
			stat_value
		)
		choices.append("%s — %s (%d%%)" % [
			str(action_value.get("label", "Rogue action")),
			character_name,
			chance,
		])
		tokens.append("rogue:%d" % action_index)
	if can_back_out:
		choices.append("Back out")
		tokens.append("back")
	return {"choices": choices, "tokens": tokens}


func _show_encounter_prompt(text_rect: Object, payload: Dictionary) -> void:
	var prompt_message: Variant = payload.get("promptMessage", {})
	if prompt_message is Dictionary:
		text_rect.set_text(str(prompt_message.get("text", "")), false)


func _show_rogue_feedback(payload: Dictionary, resolution: Dictionary) -> void:
	_play_sound({"soundId": int(resolution.get("soundId", 0))})
	var message_id: int = abs(int(resolution.get("messageId", 0)))
	if message_id == 0:
		return
	var message: Dictionary = _find_message(payload.get("thiefMessages", []), message_id)
	if not message.is_empty():
		await _show_text({"message": message})


func _find_message(messages_value: Variant, message_id: int) -> Dictionary:
	if not (messages_value is Array):
		return {}
	for message_value: Variant in messages_value:
		if message_value is Dictionary and int(message_value.get("id", -1)) == message_id:
			return message_value
	return {}


func _selected_character() -> Object:
	var ui: Object = _autoload("UI")
	if ui != null and ui.ow_hud != null and ui.ow_hud.selected_character != null:
		return ui.ow_hud.selected_character
	var game_global: Object = _autoload("GameGlobal")
	if game_global != null:
		var party: Variant = game_global.player_characters
		if party is Array and not party.is_empty():
			return party[0]
	return null


func _show_choices(text_rect: Object, choices: Array, choice_tokens: Array) -> Variant:
	# TextRect's legacy helper transitions to a removed `MultipleChoices` state.
	# Drive its existing choice container directly until Remake has a native
	# state-machine path for modal choices again.
	var choices_container: Object = text_rect.choicesContainer
	choices_container.show()
	choices_container.display_multiple_choices(choices, choice_tokens)
	var main_loop := Engine.get_main_loop()
	if main_loop is SceneTree:
		await main_loop.process_frame
	_layout_choice_menu(choices_container)
	var selected: Variant = await choices_container.choice_pressed
	choices_container.hide()
	return selected


func _layout_choice_menu(choices_container: Control) -> void:
	var map_area := choices_container.get_parent() as Control
	if map_area == null:
		return
	var available_size := map_area.size
	var menu_width := minf(CHOICE_MENU_WIDTH, available_size.x - CHOICE_MENU_MARGIN * 2.0)
	var menu_height := minf(
		float(choices_container.get("height")),
		available_size.y - CHOICE_MENU_MARGIN * 2.0
	)
	choices_container.size = Vector2(menu_width, menu_height)
	var actual_size := choices_container.size
	choices_container.position = Vector2(
		(available_size.x - actual_size.x) / 2.0,
		(available_size.y - actual_size.y) / 2.0
	)


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
