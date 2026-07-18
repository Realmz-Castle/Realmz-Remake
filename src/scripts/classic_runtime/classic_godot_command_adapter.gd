class_name ClassicGodotCommandAdapter
extends RefCounted

const RogueResolverScript = preload("res://scripts/classic_runtime/classic_rogue_encounter_resolver.gd")
const CHOICE_MENU_WIDTH := 380.0
const CHOICE_MENU_MARGIN := 20.0
const COMPLEX_ACTION_TEXT_COUNT := 8


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
		"give_treasure":
			return await _give_treasure(payload)
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
	if not (encounter is Dictionary):
		return _error("Classic complex encounter payload is missing its record")
	var text_rect: Object = _text_rect()
	if text_rect == null:
		return _error("Realmz HUD TextRect is unavailable")
	if not bool(encounter.get("thief", false)):
		while true:
			_show_encounter_prompt(text_rect, payload)
			var choice_model := build_complex_action_choices(
				encounter,
				false
			)
			var choices: Array = choice_model["choices"]
			var choice_tokens: Array = choice_model["tokens"]
			_append_complex_spell_choice(encounter, choices, choice_tokens)
			_append_complex_item_choice(encounter, choices, choice_tokens)
			if bool(encounter.get("canBackOut", false)):
				choices.append("Back out")
				choice_tokens.append("back")
			if choices.is_empty():
				return _error("Classic complex encounter has no available actions")
			var selected: String = str(await _show_choices(
				text_rect,
				choices,
				choice_tokens
			))
			if selected == "back":
				return {"outcome": 0}
			if selected == "spell":
				var spell_result := await _select_complex_spell(encounter)
				if str(spell_result.get("status", "")) == "cancelled":
					continue
				return spell_result
			if selected == "item":
				var item_result := await _select_complex_item(
					encounter,
					payload.get("itemTexts", [])
				)
				if str(item_result.get("status", "")) == "cancelled":
					continue
				return item_result
			var token_parts: PackedStringArray = selected.split(":", false, 1)
			if token_parts.size() != 2 or token_parts[0] != "action":
				return _error("Classic complex encounter returned an invalid action")
			return {"outcome": int(token_parts[1])}

	var thief_encounter: Variant = payload.get("thiefEncounter", {})
	if not (thief_encounter is Dictionary) or thief_encounter.is_empty():
		return _error("Classic rogue encounter payload is missing its Data TD2 record")
	var resolver: Object = RogueResolverScript.new()
	if not resolver.configure(encounter, thief_encounter):
		return _error(resolver.last_error)
	var character: Object = _selected_character()
	if character == null or not character.has_method("get_stat"):
		return _error("Classic rogue encounters require a selected party member")

	while true:
		character = _living_rogue_character(character)
		if character == null:
			return _error("Classic rogue encounter has no conscious party member")
		_show_encounter_prompt(text_rect, payload)
		var choice_model := build_rogue_encounter_choices(
			resolver,
			character,
			false
		)
		var choices: Array = choice_model["choices"]
		var choice_tokens: Array = choice_model["tokens"]
		var action_choices := build_complex_action_choices(encounter, false)
		choices.append_array(action_choices["choices"])
		choice_tokens.append_array(action_choices["tokens"])
		_append_complex_spell_choice(encounter, choices, choice_tokens)
		_append_complex_item_choice(encounter, choices, choice_tokens)
		if bool(encounter.get("canBackOut", false)):
			choices.append("Back out")
			choice_tokens.append("back")
		if choices.is_empty():
			return _error("Classic complex encounter has no available actions")
		var selected: String = str(await _show_choices(text_rect, choices, choice_tokens))
		if selected == "back":
			return {
				"outcome": 0,
				"thiefEncounter": resolver.rogue_encounter.duplicate(true),
			}
		if selected == "spell":
			var spell_result := await _select_complex_spell(encounter)
			if str(spell_result.get("status", "")) == "cancelled":
				continue
			spell_result["thiefEncounter"] = resolver.rogue_encounter.duplicate(true)
			return spell_result
		if selected == "item":
			var item_result := await _select_complex_item(
				encounter,
				payload.get("itemTexts", [])
			)
			if str(item_result.get("status", "")) == "cancelled":
				continue
			item_result["thiefEncounter"] = resolver.rogue_encounter.duplicate(true)
			return item_result
		var token_parts: PackedStringArray = selected.split(":", false, 1)
		if token_parts.size() == 2 and token_parts[0] == "action":
			return {
				"outcome": int(token_parts[1]),
				"thiefEncounter": resolver.rogue_encounter.duplicate(true),
			}
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
				var trap_result := await _show_rogue_trap(resolution, character)
				if str(trap_result.get("status", "")) == "error":
					return trap_result
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


func build_complex_action_choices(encounter: Dictionary, can_back_out: bool) -> Dictionary:
	var choices: Array = []
	var tokens: Array = []
	var texts: Variant = encounter.get("texts", [])
	var outcome := int(encounter.get("actionResult", 0))
	if texts is Array and outcome > 0:
		for index: int in range(min(texts.size(), COMPLEX_ACTION_TEXT_COUNT)):
			var choice_text := str(texts[index]).strip_edges()
			if choice_text.is_empty() or choice_text == "*":
				continue
			choices.append(choice_text)
			tokens.append("action:%d" % outcome)
	if can_back_out:
		choices.append("Back out")
		tokens.append("back")
	return {"choices": choices, "tokens": tokens}


func resolve_complex_spell_result(
	encounter: Dictionary,
	spell_name: String,
	spell_class: int,
	spell_id_mapping: Dictionary
) -> int:
	var spell_ids: Variant = encounter.get("spellIds", [])
	var spell_results: Variant = encounter.get("spellResults", [])
	if not (spell_ids is Array) or not (spell_results is Array):
		return 4
	for index: int in range(min(spell_ids.size(), spell_results.size())):
		var spell_id := int(spell_ids[index])
		if spell_id > 0 and spell_id < 7 and spell_class == spell_id:
			return int(spell_results[index])
		if spell_id >= 1101:
			var mapped_name := _mapped_spell_name(spell_id, spell_id_mapping)
			# Remake shares a spell resource by name across Classic caster schools.
			if _normalized_spell_name(mapped_name) == _normalized_spell_name(spell_name):
				return int(spell_results[index])
	return 4


func classic_spell_mapping_key(spell_id: int) -> String:
	if spell_id < 1101:
		return ""
	# Classic packs zero-based caster class, level, and slot above the 1101 base.
	# Remake's existing table uses those same parts as a concatenated string key.
	var packed := spell_id - 1101
	var caster_class := int(packed / 1000) + 1
	var remainder := packed % 1000
	var spell_level := int(remainder / 100)
	var spell_slot := remainder % 100
	return "%d%d%d" % [caster_class * 100, spell_level, spell_slot]


func resolve_complex_item_result(
	encounter: Dictionary,
	item_name: String,
	item_id_mapping: Dictionary,
	item_texts: Array
) -> int:
	var item_ids: Variant = encounter.get("itemIds", [])
	var item_results: Variant = encounter.get("itemResults", [])
	if not (item_ids is Array) or not (item_results is Array):
		return 4
	var normalized_item_name := _normalized_item_name(item_name)
	for index: int in range(min(item_ids.size(), item_results.size())):
		var item_id: int = abs(int(item_ids[index]))
		if item_id == 0:
			continue
		for candidate_name: String in _classic_item_names(
			item_id,
			item_id_mapping,
			item_texts
		):
			if _normalized_item_name(candidate_name) == normalized_item_name:
				return int(item_results[index])
	return 4


func _append_complex_spell_choice(
	encounter: Dictionary,
	choices: Array,
	tokens: Array
) -> void:
	if _first_spellcaster() == null or not _has_complex_spell_responses(encounter):
		return
	choices.append("Cast a spell")
	tokens.append("spell")


func _has_complex_spell_responses(encounter: Dictionary) -> bool:
	var spell_ids: Variant = encounter.get("spellIds", [])
	return spell_ids is Array and not spell_ids.is_empty() and int(spell_ids[0]) != 0


func _append_complex_item_choice(
	encounter: Dictionary,
	choices: Array,
	tokens: Array
) -> void:
	if _first_item_holder() == null or not _has_complex_item_responses(encounter):
		return
	choices.append("Use an item")
	tokens.append("item")


func _has_complex_item_responses(encounter: Dictionary) -> bool:
	var item_ids: Variant = encounter.get("itemIds", [])
	return item_ids is Array and not item_ids.is_empty() and int(item_ids[0]) != 0


func _select_complex_spell(encounter: Dictionary) -> Dictionary:
	var caster := _first_spellcaster()
	if caster == null:
		return _error("Classic complex encounter has no conscious spellcaster")
	var ui: Object = _autoload("UI")
	if ui == null or ui.ow_hud == null:
		return _error("Realmz HUD is unavailable for Classic spell selection")
	var spell_menu: Object = ui.ow_hud.spellcastMenu
	if spell_menu == null or not spell_menu.has_method("initialize_for_encounter"):
		return _error("Realmz spell menu does not support encounter selection")
	spell_menu.initialize_for_encounter(caster)
	spell_menu.show()
	await spell_menu.encounter_spell_picked
	var spell: Variant = spell_menu.picked_spell
	if spell == null:
		return {"status": "cancelled"}
	var picked_character: Variant = spell_menu.picked_character
	var power := int(spell_menu.picked_power)
	if picked_character is Object and picked_character.has_method("on_ability_use"):
		picked_character.on_ability_use(spell, power)
	var spell_ids: Object = _autoload("SpellsIdDivinity")
	var spell_mapping: Dictionary = spell_ids.mappings if spell_ids != null else {}
	var spell_class := int(spell.get("classic_spell_class")) \
		if spell.get("classic_spell_class") != null else 0
	return {
		"outcome": resolve_complex_spell_result(
			encounter,
			str(spell.get("name")),
			spell_class,
			spell_mapping
		),
		"spellName": str(spell.get("name")),
		"spellPower": power,
	}


func _select_complex_item(encounter: Dictionary, item_texts: Variant) -> Dictionary:
	var holder := _first_item_holder()
	if holder == null:
		return _error("Classic complex encounter has no conscious item holder")
	var ui: Object = _autoload("UI")
	if ui == null or ui.ow_hud == null:
		return _error("Realmz HUD is unavailable for Classic item selection")
	var encounter_control: Object = ui.ow_hud.encounterControl
	var item_menu: Object = encounter_control.useitemRect if encounter_control != null else null
	if item_menu == null or not item_menu.has_method("initialize_for_encounter"):
		return _error("Realmz encounter item picker does not support compatibility selection")
	for button: Node in encounter_control.boxContainer.get_children():
		button.hide()
	encounter_control.itemButton.show()
	encounter_control.show()
	item_menu.initialize_for_encounter(holder)
	item_menu.show()
	await item_menu.encounter_item_picked
	encounter_control.hide()
	var item: Variant = item_menu.picked_item
	if not (item is Dictionary) or item.is_empty():
		return {"status": "cancelled"}
	var item_ids: Object = _autoload("ItemIdDivinity")
	var item_mapping: Dictionary = item_ids.mapping if item_ids != null else {}
	var response_item_texts: Array = item_texts if item_texts is Array else []
	# Classic's encounter path selects ordinary items without consuming them.
	return {
		"outcome": resolve_complex_item_result(
			encounter,
			str(item.get("name", "")),
			item_mapping,
			response_item_texts
		),
		"itemName": str(item.get("name", "")),
	}


func _first_spellcaster() -> Object:
	var preferred := _selected_character()
	if _can_select_spell(preferred):
		return preferred
	for character_value: Variant in _party_characters():
		if _can_select_spell(character_value):
			return character_value
	return null


func _first_item_holder() -> Object:
	var preferred := _selected_character()
	if _can_select_item(preferred):
		return preferred
	for character_value: Variant in _party_characters():
		if _can_select_item(character_value):
			return character_value
	return null


func _can_select_spell(character: Variant) -> bool:
	if not (character is Object) or not character.has_method("get_stat"):
		return false
	if float(character.get_stat("curHP")) <= 0.0:
		return false
	var spell_levels: Variant = character.get("spells")
	if not (spell_levels is Array):
		return false
	for level_value: Variant in spell_levels:
		if level_value is Array and not level_value.is_empty():
			return true
	return false


func _can_select_item(character: Variant) -> bool:
	if not (character is Object) or not character.has_method("get_stat"):
		return false
	if float(character.get_stat("curHP")) <= 0.0:
		return false
	var inventory: Variant = character.get("inventory")
	return inventory is Array and not inventory.is_empty()


func _mapped_spell_name(spell_id: int, spell_id_mapping: Dictionary) -> String:
	var key := classic_spell_mapping_key(spell_id)
	return str(spell_id_mapping.get(key, spell_id_mapping.get(spell_id, "")))


func _normalized_spell_name(spell_name: String) -> String:
	var normalized := spell_name.strip_edges().to_lower()
	if normalized == "discover magic i":
		return "discover magic"
	return normalized


func _classic_item_names(
	item_id: int,
	item_id_mapping: Dictionary,
	item_texts: Array
) -> Array[String]:
	var names: Array[String] = []
	var mapped_name := str(item_id_mapping.get(
		item_id,
		item_id_mapping.get(str(item_id), "")
	))
	if not mapped_name.is_empty():
		names.append(mapped_name)
	for item_text_value: Variant in item_texts:
		if not (item_text_value is Dictionary):
			continue
		if abs(int(item_text_value.get("itemId", 0))) != item_id:
			continue
		for field_name: String in ["identifiedName", "unidentifiedName"]:
			var item_text_name := str(item_text_value.get(field_name, "")).strip_edges()
			if not item_text_name.is_empty() and not names.has(item_text_name):
				names.append(item_text_name)
	return names


func _normalized_item_name(item_name: String) -> String:
	return item_name.strip_edges().to_lower()


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


func _show_rogue_trap(resolution: Dictionary, character: Object) -> Dictionary:
	var trap_value: Variant = resolution.get("trap", {})
	if not (trap_value is Dictionary):
		return _error("Classic rogue trap payload is missing")
	var trap: Dictionary = trap_value
	if int(trap.get("spellId", 0)) != 0:
		return _error("Classic trap spell effects are not implemented yet")
	var damage_result := apply_rogue_trap_damage(
		trap,
		character,
		_party_characters()
	)
	if str(damage_result.get("status", "")) == "error":
		return damage_result
	_play_sound({"soundId": int(trap.get("soundId", 0))})
	var feedback: Array[String] = ["A trap is sprung!"]
	for hit_value: Variant in damage_result.get("hits", []):
		if not (hit_value is Dictionary):
			continue
		feedback.append("%s takes %d damage." % [
			str(hit_value.get("name", "Party member")),
			int(hit_value.get("damage", 0)),
		])
		_refresh_character_panel(hit_value.get("character"))
	await _show_text({"message": {"text": "\n".join(feedback)}})
	return {}


func apply_rogue_trap_damage(
	trap: Dictionary,
	selected_character: Object,
	party: Array
) -> Dictionary:
	var low_damage := int(trap.get("damageLow", 0))
	var high_damage := int(trap.get("damageHigh", 0))
	if low_damage < 0 or high_damage < low_damage:
		return _error("Classic rogue trap has an invalid damage range")
	# Classic treats a zero lower bound as a trap without direct HP damage.
	if low_damage == 0:
		return {"hits": []}

	var targets: Array = [selected_character] if bool(trap.get("rogueOnly", false)) \
		else party.duplicate()
	if targets.is_empty():
		return _error("Classic rogue trap has no damage target")
	for target_value: Variant in targets:
		if not (target_value is Object) or not target_value.has_method("change_cur_hp"):
			return _error("Classic rogue trap target cannot receive damage")

	var hits: Array = []
	for target_value: Variant in targets:
		var damage := randi_range(low_damage, high_damage)
		target_value.change_cur_hp(-damage)
		hits.append({
			"character": target_value,
			"name": str(target_value.get("name")),
			"damage": damage,
		})
	return {"hits": hits}


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


func _living_rogue_character(preferred: Object) -> Object:
	if preferred != null and preferred.has_method("get_stat") \
		and float(preferred.get_stat("curHP")) > 0.0:
		return preferred
	for character_value: Variant in _party_characters():
		if character_value is Object and character_value.has_method("get_stat") \
			and float(character_value.get_stat("curHP")) > 0.0:
			return character_value
	return null


func _party_characters() -> Array:
	var game_global: Object = _autoload("GameGlobal")
	if game_global == null:
		return []
	var party: Variant = game_global.player_characters
	return party if party is Array else []


func _refresh_character_panel(character: Variant) -> void:
	var ui: Object = _autoload("UI")
	if ui == null or ui.ow_hud == null:
		return
	for panel: Node in ui.ow_hud.charsVContainer.get_children():
		if panel.get("character") == character and panel.has_method("update_display"):
			panel.update_display()
			return


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


func build_treasure_delivery(
	payload: Dictionary,
	item_id_mapping: Dictionary,
	available_items: Dictionary
) -> Dictionary:
	var treasure_value: Variant = payload.get("treasure", {})
	if not (treasure_value is Dictionary):
		return _error("Classic treasure payload is missing its record")
	var treasure: Dictionary = treasure_value
	var item_ids: Variant = treasure.get("itemIds", [])
	if not (item_ids is Array):
		return _error("Classic treasure item IDs must be an array")

	var item_texts_by_id: Dictionary = {}
	var item_texts: Variant = payload.get("itemTexts", [])
	if item_texts is Array:
		for item_text_value: Variant in item_texts:
			if item_text_value is Dictionary:
				var item_id: int = abs(int(item_text_value.get("itemId", 0)))
				if item_id != 0:
					item_texts_by_id[item_id] = item_text_value

	var item_names: Array[String] = []
	for item_id_value: Variant in item_ids:
		var item_id: int = abs(int(item_id_value))
		if item_id == 0:
			continue
		var item_name := str(item_id_mapping.get(item_id, ""))
		if item_name.is_empty() or not available_items.has(item_name):
			var item_text: Variant = item_texts_by_id.get(item_id, {})
			if item_text is Dictionary:
				for key: String in ["identifiedName", "unidentifiedName"]:
					var candidate := str(item_text.get(key, "")).strip_edges()
					if available_items.has(candidate):
						item_name = candidate
						break
		if item_name.is_empty() or not available_items.has(item_name):
			return _error("Classic item %d has no loaded Remake item mapping" % item_id)
		item_names.append(item_name)

	return {
		"itemNames": item_names,
		"money": [
			int(treasure.get("gold", 0)),
			int(treasure.get("gems", 0)),
			int(treasure.get("jewelry", 0)),
		],
		"experience": int(treasure.get("exp", 0)),
	}


func _give_treasure(payload: Dictionary) -> Dictionary:
	var node_access: Object = _autoload("NodeAccess")
	var resources: Object = node_access.__Resources() if node_access != null else null
	if resources == null:
		return _error("Realmz item resources are unavailable")
	var item_ids: Object = _autoload("ItemIdDivinity")
	var item_mapping: Dictionary = item_ids.mapping if item_ids != null else {}
	var delivery := build_treasure_delivery(payload, item_mapping, resources.items_book)
	if str(delivery.get("status", "")) == "error":
		return delivery
	var game_global: Object = _autoload("GameGlobal")
	if game_global == null:
		return _error("Realmz game state is unavailable")
	var items: Array = []
	for item_name: String in delivery.get("itemNames", []):
		items.append(game_global.generate_item(item_name))
	await game_global.show_loot_menu(
		items,
		delivery.get("money", [0, 0, 0]),
		int(delivery.get("experience", 0))
	)
	return {}


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
