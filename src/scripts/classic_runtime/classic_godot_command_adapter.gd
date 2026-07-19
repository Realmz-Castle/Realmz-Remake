class_name ClassicGodotCommandAdapter
extends RefCounted

const RogueResolverScript = preload("res://scripts/classic_runtime/classic_rogue_encounter_resolver.gd")
const InventoryRulesScript = preload("res://scripts/classic_runtime/classic_inventory_rules.gd")
const CHOICE_MENU_WIDTH := 380.0
const CHOICE_MENU_MARGIN := 20.0
const COMPLEX_ACTION_TEXT_COUNT := 8
const COMPLEX_WORD_TEXT_INDEX := 8
const COMPLEX_WORD_TEXT_LIMIT := 40
# Classic stores five contiguous 200-slot inventory categories.
const SHOP_CATEGORY_SIZE := 200
const SHOP_CATEGORIES := ["Weapons", "Armor", "Limbs", "Magic", "Supplies"]
# These duplicate shared definitions are stocked by Classic shops but omitted
# from Remake's Divinity ID table in favor of their equivalent item records.
const CLASSIC_SHARED_ITEM_ALIASES := {
	98: "Quarter Staff",
	610: "Waterworld",
	611: "Heal Small Wounds",
}
# Opcode 32 scales these temple.c base prices by its authored percentage.
const CLASSIC_TEMPLE_SERVICES := [
	["Heal Small Wounds", 1, 250],
	["Heal Medium Wounds", 1, 350],
	["Heal Large Wounds", 1, 850],
	["Heal Disease", 1, 200],
	["Flesh", 1, 750],
	["Heal Poison", 1, 200],
	["Heal Blindness", 1, 350],
	["Remove Items", 1, 550],
	["Revive Dead", 1, 1500],
]
const MAP_GAINED_MESSAGE := \
	"You gain a map, to view the map use Maps/Notes in the Menu."
const CLASSIC_ATTRIBUTE_STATS := {
	0: "Strength",
	1: "Intellect",
	2: "Wisdom",
	3: "Dexterity",
	4: "Vitality",
	6: "Luck",
}
# CoB's rockfall uses attribute value 5 for a quickness save, although Classic
# omits that case from savevsattr. Keep it meaningful without changing opcode 30.
const CLASSIC_MISC_ATTRIBUTE_STATS := {
	0: "Strength",
	1: "Intellect",
	2: "Wisdom",
	3: "Dexterity",
	4: "Vitality",
	5: "Dexterity",
	6: "Luck",
}
const CLASSIC_SPELL_SAVE_STATS := {
	0: ["MultiplierMental", "ResistanceMental"],
	1: ["MultiplierFire", "ResistanceFire"],
	2: ["MultiplierIce", "ResistanceIce"],
	3: ["MultiplierElect", "ResistanceElect"],
	4: ["MultiplierChemical", "ResistanceChemical"],
	5: ["MultiplierMental", "ResistanceMental"],
	6: ["MultiplierMagic", "ResistanceMagic"],
	7: ["MultiplierHealing", "ResistanceHealing"],
}
const CLASSIC_SPECIAL_STATS := {
	0: "Melee_Crit_Mult",
	3: "Melee_Crit_Rate",
	4: "Detect_Secret",
	5: "Acrobatics",
	6: "Detect_Trap",
	7: "Disable_Trap",
	9: "Force_Lock",
	11: "Pick_Lock",
	13: "Turn_Undead",
}

var classic_selected_characters: Array = []
var stored_party_equipment: Dictionary = {}


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
		"give_experience":
			return await _give_experience(payload)
		"pick_characters":
			return await _pick_characters(payload)
		"filter_selected_characters":
			return _filter_selected_characters(payload)
		"select_characters_by_misc":
			return _select_characters_by_misc(payload)
		"change_selected_health":
			return await _change_selected_health(payload)
		"change_party_health":
			return await _change_party_health(payload)
		"cast_classic_spell":
			return await _cast_classic_spell(payload)
		"give_map":
			return await _give_player_map(payload)
		"load_shop":
			return await _load_shop(payload)
		"offer_temple":
			return _offer_temple(payload)
		"enable_banking":
			return _enable_banking(payload)
		"check_party_item":
			return _check_party_item(payload)
		"alter_party_items":
			return _alter_party_items(payload)
		"store_party_equipment":
			return await _store_party_equipment(payload)
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
			_append_complex_word_choice(encounter, choices, choice_tokens)
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
			if selected == "word":
				var word_result := await _select_complex_word(encounter)
				if str(word_result.get("status", "")) == "cancelled":
					continue
				return word_result
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
		_append_complex_word_choice(encounter, choices, choice_tokens)
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
		if selected == "word":
			var word_result := await _select_complex_word(encounter)
			if str(word_result.get("status", "")) == "cancelled":
				continue
			word_result["thiefEncounter"] = resolver.rogue_encounter.duplicate(true)
			return word_result
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


func resolve_complex_word_result(encounter: Dictionary, entered_text: String) -> int:
	var outcome := int(encounter.get("wordResult", 0))
	if outcome == 0 or entered_text.is_empty():
		return 4
	var texts: Variant = encounter.get("texts", [])
	var expected := str(texts[COMPLEX_WORD_TEXT_INDEX]) \
		if texts is Array and texts.size() > COMPLEX_WORD_TEXT_INDEX else ""
	expected = expected.left(COMPLEX_WORD_TEXT_LIMIT)
	var first_space := expected.find(" ")
	if first_space >= 0:
		expected = expected.left(first_space)
	# Classic lowercases entered text, stops at the stored word's first space,
	# and never requires the entered text to end after the matching prefix.
	return outcome if entered_text.to_lower().begins_with(expected) else 4


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


func spell_effect_targets(target_mode: String, party: Array, selected: Array) -> Array:
	if target_mode == "party":
		return party.duplicate()
	if target_mode == "selected":
		return selected.duplicate()
	return []


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


func _append_complex_word_choice(
	encounter: Dictionary,
	choices: Array,
	tokens: Array
) -> void:
	if int(encounter.get("wordResult", 0)) == 0:
		return
	choices.append("Speak")
	tokens.append("word")


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


func _select_complex_word(encounter: Dictionary) -> Dictionary:
	var ui: Object = _autoload("UI")
	if ui == null or ui.ow_hud == null:
		return _error("Realmz HUD is unavailable for Classic spoken-word selection")
	var encounter_control: Object = ui.ow_hud.encounterControl
	if encounter_control == null \
			or not encounter_control.has_method("initialize_phrase_for_encounter"):
		return _error("Realmz encounter speech panel does not support compatibility selection")
	encounter_control.initialize_phrase_for_encounter()
	await encounter_control.encounter_phrase_submitted
	encounter_control.hide()
	var entered_text := str(encounter_control.encounter_phrase)
	if entered_text.is_empty():
		return {"status": "cancelled"}
	return {
		"outcome": resolve_complex_word_result(encounter, entered_text),
		"spokenText": entered_text,
	}


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
	var alias_name := str(CLASSIC_SHARED_ITEM_ALIASES.get(item_id, ""))
	if not alias_name.is_empty() and not names.has(alias_name):
		names.append(alias_name)
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


func _refresh_party_panels(party: Array) -> void:
	for character_value: Variant in party:
		_refresh_character_panel(character_value)


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
	if bool(encounter.get("canBackOut", false)):
		choices.append("Back out")
		choice_tokens.append("0")
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


func build_shop_inventory(
	payload: Dictionary,
	item_id_mapping: Dictionary,
	available_items: Dictionary
) -> Dictionary:
	var shop_value: Variant = payload.get("shop", {})
	if not (shop_value is Dictionary):
		return _error("Classic shop payload is missing its record")
	var shop: Dictionary = shop_value
	var item_ids: Variant = shop.get("itemIds", [])
	var quantities: Variant = shop.get("quantities", [])
	if not (item_ids is Array) or not (quantities is Array):
		return _error("Classic shop stock must use item and quantity arrays")
	if item_ids.size() != quantities.size():
		return _error("Classic shop item and quantity arrays have different lengths")

	var item_texts_value: Variant = payload.get("itemTexts", [])
	var item_texts: Array = item_texts_value if item_texts_value is Array else []
	var accept_ranges_value: Variant = payload.get("acceptRanges", [0, 0, 0, 0])
	if not (accept_ranges_value is Array) or accept_ranges_value.size() != 4:
		return _error("Classic shop acceptance ranges must contain four values")
	var accept_ranges: Array[int] = []
	for range_value: Variant in accept_ranges_value:
		accept_ranges.append(int(range_value))
	var categories := {
		"Weapons": [],
		"Armor": [],
		"Limbs": [],
		"Magic": [],
		"Supplies": [],
		"BuyBack": [],
	}
	var item_count := 0
	for slot: int in item_ids.size():
		var item_id: int = abs(int(item_ids[slot]))
		var quantity := int(quantities[slot])
		if item_id == 0 and quantity == 0:
			continue
		if item_id == 0 or quantity < 1:
			return _error("Classic shop has invalid stock in slot %d" % slot)
		var category_index := slot / SHOP_CATEGORY_SIZE
		if category_index >= SHOP_CATEGORIES.size():
			return _error("Classic shop stock slot %d is outside its fixed categories" % slot)
		var item_name := ""
		for candidate: String in _classic_item_names(item_id, item_id_mapping, item_texts):
			if available_items.has(candidate):
				item_name = candidate
				break
		if item_name.is_empty():
			return _error("Classic shop item %d has no loaded Remake item mapping" % item_id)
		categories[SHOP_CATEGORIES[category_index]].append([item_name, quantity, -1])
		item_count += quantity

	var inflation := int(shop.get("inflation", 100))
	if inflation < 0:
		return _error("Classic shop inflation cannot be negative")
	var native_shop := {
		"buy_rate": minf(float(inflation), 100.0) / 100.0,
		"sell_rate": float(inflation) / 100.0,
		"Weapons": categories["Weapons"],
		"Armor": categories["Armor"],
		"Limbs": categories["Limbs"],
		"Magic": categories["Magic"],
		"Supplies": categories["Supplies"],
		"BuyBack": categories["BuyBack"],
	}
	if accept_ranges[0] != 0 or accept_ranges[2] != 0:
		native_shop["classic_accept_ranges"] = accept_ranges
	if _classic_shop_restriction_is_effective(accept_ranges):
		native_shop["accepted_item_names"] = _accepted_classic_shop_item_names(
			accept_ranges,
			item_id_mapping,
			item_texts,
			available_items
		)
	return {
		"shop": native_shop,
		"itemCount": item_count,
	}


func _classic_shop_restriction_is_effective(accept_ranges: Array[int]) -> bool:
	# Classic rejects an item only after it misses both configured ranges. A
	# single populated range therefore retains the original unrestricted result.
	return accept_ranges[0] != 0 and accept_ranges[2] != 0


func classic_shop_accepts_item_id(item_id: int, accept_ranges: Array[int]) -> bool:
	var rejected_ranges := 0
	for range_index: int in [0, 2]:
		var low := accept_ranges[range_index]
		if low == 0:
			continue
		var high := accept_ranges[range_index + 1]
		if item_id < low or item_id > high:
			rejected_ranges += 1
	return rejected_ranges != 2


func _accepted_classic_shop_item_names(
	accept_ranges: Array[int],
	item_id_mapping: Dictionary,
	item_texts: Array,
	available_items: Dictionary
) -> Dictionary:
	var candidate_ids: Dictionary = {}
	for item_id_value: Variant in item_id_mapping.keys():
		candidate_ids[abs(int(item_id_value))] = true
	for item_id_value: Variant in CLASSIC_SHARED_ITEM_ALIASES.keys():
		candidate_ids[abs(int(item_id_value))] = true
	for item_text_value: Variant in item_texts:
		if item_text_value is Dictionary:
			candidate_ids[abs(int(item_text_value.get("itemId", 0)))] = true

	var accepted_names: Dictionary = {}
	for item_id_value: Variant in candidate_ids.keys():
		var item_id := int(item_id_value)
		if item_id == 0 or not classic_shop_accepts_item_id(item_id, accept_ranges):
			continue
		for item_name: String in _classic_item_names(item_id, item_id_mapping, item_texts):
			if available_items.has(item_name):
				accepted_names[item_name] = true
	return accepted_names


func build_temple_services(cost_percent: int) -> Dictionary:
	if cost_percent < 0:
		return _error("Classic temple cost percentage cannot be negative")
	var services: Array = []
	for service: Array in CLASSIC_TEMPLE_SERVICES:
		services.append([
			service[0],
			service[1],
			int(float(int(service[2]) * cost_percent) / 100.0),
		])
	return {"services": services}


func _offer_temple(payload: Dictionary) -> Dictionary:
	var built := build_temple_services(int(payload.get("costPercent", 100)))
	if str(built.get("status", "")) == "error":
		return built
	var game_global: Object = _autoload("GameGlobal")
	if game_global == null:
		return _error("Realmz game state is unavailable")
	game_global.currentTemple = built["services"]
	game_global.allow_temple(true)
	_play_sound(payload)
	return {
		"costPercent": int(payload.get("costPercent", 100)),
		"serviceCount": built["services"].size(),
	}


func _enable_banking(payload: Dictionary) -> Dictionary:
	var game_global: Object = _autoload("GameGlobal")
	if game_global == null:
		return _error("Realmz game state is unavailable")
	game_global.allow_banking(true)
	_play_sound(payload)
	return {"warningId": int(payload.get("warningId", 0))}


func _check_party_item(payload: Dictionary) -> Dictionary:
	var item_names := _mapped_item_names(payload)
	if item_names.is_empty():
		return _error(
			"Classic item %d has no Remake item mapping" % int(payload.get("itemId", 0))
		)
	return {
		"possessed": InventoryRulesScript.party_has_named_item(
			_party_characters(),
			item_names
		),
	}


func _alter_party_items(payload: Dictionary) -> Dictionary:
	var item_names := _mapped_item_names(payload)
	if item_names.is_empty():
		return _error(
			"Classic item %d has no Remake item mapping" % int(payload.get("itemId", 0))
		)
	var replacement_item: Dictionary = {}
	if int(payload.get("operation", 0)) == 3:
		var replacement_payload := {
			"itemId": int(payload.get("replacementItemId", 0)),
			"itemTexts": payload.get("itemTexts", []),
		}
		var replacement_names := _mapped_item_names(replacement_payload)
		if replacement_names.is_empty():
			return _error(
				"Classic replacement item %d has no Remake item mapping" \
				% int(payload.get("replacementItemId", 0))
			)
		var node_access: Object = _autoload("NodeAccess")
		var resources: Object = node_access.__Resources() if node_access != null else null
		var game_global: Object = _autoload("GameGlobal")
		if resources == null or game_global == null:
			return _error("Realmz item resources are unavailable")
		var replacement_name := ""
		for candidate_name: String in replacement_names:
			if resources.items_book.has(candidate_name):
				replacement_name = candidate_name
				break
		if replacement_name.is_empty():
			return _error(
				"Classic replacement item %d is not loaded" \
				% int(payload.get("replacementItemId", 0))
			)
		replacement_item = game_global.generate_item(replacement_name)

	var party := _party_characters()
	if party.is_empty():
		return _error("Classic item mutation has no party members")
	var result: Dictionary = InventoryRulesScript.alter_named_items(
		party,
		item_names,
		int(payload.get("maxMatches", 0)),
		int(payload.get("operation", 0)),
		int(payload.get("chargeDelta", 0)),
		replacement_item
	)
	if str(result.get("status", "")) == "error":
		return result
	_refresh_party_panels(party)
	return result


func _store_party_equipment(payload: Dictionary) -> Dictionary:
	var game_global: Object = _autoload("GameGlobal")
	if game_global == null:
		return _error("Realmz game state is unavailable")
	var party := _party_characters()
	if party.is_empty():
		return _error("Classic equipment storage has no party members")
	var pooled_money: Variant = game_global.money_pool
	if not (pooled_money is Array):
		return _error("Realmz pooled wealth is unavailable")

	if bool(payload.get("capture", false)):
		if bool(stored_party_equipment.get("active", false)):
			return {"captured": false, "active": true}
		var captured: Dictionary = InventoryRulesScript.capture_party_equipment(
			party,
			pooled_money
		)
		if str(captured.get("status", "")) == "error":
			return captured
		stored_party_equipment = captured
		_refresh_party_panels(party)
		return {
			"captured": true,
			"active": true,
			"itemCount": int(captured.get("itemCount", 0)),
		}

	if not bool(stored_party_equipment.get("active", false)):
		return {"restored": false, "active": false}
	var restored: Dictionary = InventoryRulesScript.restore_party_equipment(
		party,
		pooled_money,
		stored_party_equipment
	)
	if str(restored.get("status", "")) == "error":
		return restored
	stored_party_equipment = {}
	_refresh_party_panels(party)
	var extra_items: Array = restored.get("extraItems", [])
	if not extra_items.is_empty():
		await game_global.show_loot_menu(extra_items, [0, 0, 0], 0)
	return {
		"restored": true,
		"active": false,
		"restoredCount": int(restored.get("restoredCount", 0)),
		"extraItemCount": extra_items.size(),
		"reequipFailures": int(restored.get("reequipFailures", 0)),
	}


func _mapped_item_names(payload: Dictionary) -> Array[String]:
	var item_ids: Object = _autoload("ItemIdDivinity")
	var item_mapping: Dictionary = item_ids.mapping \
		if item_ids != null and item_ids.mapping is Dictionary else {}
	var item_texts: Variant = payload.get("itemTexts", [])
	return _classic_item_names(
		abs(int(payload.get("itemId", 0))),
		item_mapping,
		item_texts if item_texts is Array else []
	)


func _load_shop(payload: Dictionary) -> Dictionary:
	var node_access: Object = _autoload("NodeAccess")
	var resources: Object = node_access.__Resources() if node_access != null else null
	if resources == null:
		return _error("Realmz item resources are unavailable")
	var item_ids: Object = _autoload("ItemIdDivinity")
	var item_mapping: Dictionary = item_ids.mapping if item_ids != null else {}
	var built := build_shop_inventory(payload, item_mapping, resources.items_book)
	if str(built.get("status", "")) == "error":
		return built
	var game_global: Object = _autoload("GameGlobal")
	if game_global == null:
		return _error("Realmz game state is unavailable")
	var shop_name := "classic_shop_%d" % int(payload.get("shopId", 0))
	if not game_global.shops_dict.has(shop_name):
		game_global.shops_dict[shop_name] = built["shop"]
	else:
		var loaded_shop: Dictionary = game_global.shops_dict[shop_name]
		loaded_shop.erase("classic_accept_ranges")
		loaded_shop.erase("accepted_item_names")
		for rule_name: String in ["classic_accept_ranges", "accepted_item_names"]:
			if built["shop"].has(rule_name):
				loaded_shop[rule_name] = built["shop"][rule_name]
	game_global.currentShop = shop_name
	game_global.allow_banking(true)
	game_global.allow_money_change(true)

	if bool(payload.get("openImmediately", false)):
		var ui: Object = _autoload("UI")
		if ui == null or ui.ow_hud == null or ui.ow_hud.inventoryRect == null:
			return _error("Realmz shop UI is unavailable")
		if _selected_character() == null:
			return _error("Classic shop has no selected party member")
		ui.ow_hud._on_InventoryButton_pressed()
		var main_loop := Engine.get_main_loop()
		if main_loop is SceneTree:
			await main_loop.process_frame
		var inventory_rect: Object = ui.ow_hud.inventoryRect
		if not inventory_rect.visible:
			return _error("Realmz inventory did not open for the Classic shop")
		inventory_rect._on_ButtonShop_pressed()
		if not inventory_rect.shopRect.visible:
			return _error("Realmz shop did not open")
		await inventory_rect.shopRect.visibility_changed
	return {
		"shopName": shop_name,
		"itemCount": int(built.get("itemCount", 0)),
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


func _give_experience(payload: Dictionary) -> Dictionary:
	var game_global: Object = _autoload("GameGlobal")
	if game_global == null:
		return _error("Realmz game state is unavailable")
	await game_global.show_loot_menu(
		[],
		[0, 0, 0],
		int(payload.get("experience", 0))
	)
	return {}


func _pick_characters(payload: Dictionary) -> Dictionary:
	var party := _party_characters()
	if party.is_empty():
		return _error("Classic character pick has no party members")
	var allow_dead := bool(payload.get("allowDead", false))
	var eligible: Array = []
	for character_value: Variant in party:
		if allow_dead or _is_living_character(character_value):
			eligible.append(character_value)
	if eligible.is_empty():
		return _error("Classic character pick has no eligible party members")
	var count: int = min(int(payload.get("count", 0)), eligible.size())
	if count < 1:
		return _error("Classic character pick requests no characters")
	var ui: Object = _autoload("UI")
	if ui == null or ui.ow_hud == null:
		return _error("Realmz character picker is unavailable")
	ui.ow_hud.request_pc_pick(count)
	var picked_value: Variant = await ui.ow_hud.pc_picked
	if not (picked_value is Array):
		return _error("Realmz character picker returned an invalid selection")
	for character_value: Variant in picked_value:
		if not party.has(character_value) \
			or (not allow_dead and not _is_living_character(character_value)):
			return _error("Realmz character picker returned an ineligible party member")
	var selected := select_characters_after_pick(
		picked_value,
		party,
		bool(payload.get("invert", false))
	)
	_store_selected_characters(selected)
	return {"selectedCount": selected.size()}


func select_characters_after_pick(picked: Array, party: Array, invert: bool) -> Array:
	var selected: Array = []
	for character_value: Variant in party:
		var was_picked := picked.has(character_value)
		if was_picked != invert:
			selected.append(character_value)
	return selected


func _filter_selected_characters(payload: Dictionary) -> Dictionary:
	var result := filter_characters_by_check(
		payload,
		_party_characters(),
		_current_selected_characters()
	)
	if str(result.get("status", "")) == "error":
		return result
	var selected: Array = result.get("selected", [])
	_store_selected_characters(selected)
	return {
		"selectedCount": selected.size(),
		"checks": result.get("checks", []),
	}


func _select_characters_by_misc(payload: Dictionary) -> Dictionary:
	var resolved_payload := payload.duplicate(true)
	var selector := str(payload.get("selector", ""))
	if selector == "has_item" or selector == "wearing_item":
		var item_ids: Object = _autoload("ItemIdDivinity")
		var item_mapping: Dictionary = item_ids.mapping if item_ids != null else {}
		var item_texts: Variant = payload.get("itemTexts", [])
		var names := _classic_item_names(
			abs(int(payload.get("value", 0))),
			item_mapping,
			item_texts if item_texts is Array else []
		)
		if names.is_empty():
			return _error(
				"Classic item selector %d has no Remake item mapping" \
				% abs(int(payload.get("value", 0)))
			)
		resolved_payload["itemNames"] = names
	var result := select_characters_by_misc(
		resolved_payload,
		_party_characters(),
		_current_selected_characters(),
		_selected_character()
	)
	if str(result.get("status", "")) == "error":
		return result
	var selected: Array = result.get("selected", [])
	_store_selected_characters(selected)
	return {
		"selectedCount": selected.size(),
		"checks": result.get("checks", []),
	}


func select_characters_by_misc(
	payload: Dictionary,
	party: Array,
	previously_selected: Array,
	focused_character: Variant
) -> Dictionary:
	var selector := str(payload.get("selector", ""))
	var supported_selectors := [
		"movement_below",
		"position_before",
		"has_item",
		"percent",
		"attribute_save_failure",
		"spell_save_failure",
		"focused_character",
		"wearing_item",
		"exact_position",
	]
	if not supported_selectors.has(selector):
		return _error("Classic miscellaneous character selector is invalid")
	var candidate_mode := str(payload.get("candidateMode", "party"))
	if not ["selected", "party", "alive"].has(candidate_mode):
		return _error("Classic miscellaneous character selector has an invalid source set")
	var candidates := _selection_candidates(candidate_mode, party, previously_selected)
	var value := int(payload.get("value", 0))
	var item_names: Array = payload.get("itemNames", [])
	if (selector == "has_item" or selector == "wearing_item") and item_names.is_empty():
		return _error("Classic item selector has no item names")
	if selector == "attribute_save_failure" and not CLASSIC_MISC_ATTRIBUTE_STATS.has(value):
		return _error("Classic attribute save %d has no Remake stat mapping" % value)
	if selector == "spell_save_failure" and not CLASSIC_SPELL_SAVE_STATS.has(value):
		return _error("Classic spell save %d has no Remake stat mapping" % value)

	var selected: Array = []
	var checks: Array = []
	for character_value: Variant in candidates:
		if not (character_value is Object):
			return _error("Classic miscellaneous selector target is not a character")
		var party_position := party.find(character_value) + 1
		var matched := false
		var roll := 0
		match selector:
			"movement_below":
				if not character_value.has_method("get_stat"):
					return _error("Classic movement selector target has no readable stats")
				matched = float(character_value.get_stat("MaxMovement")) < value
			"position_before":
				matched = party_position > 0 and party_position < value
			"has_item":
				matched = _character_has_named_item(character_value, item_names, false)
			"percent":
				roll = randi_range(1, 100)
				matched = roll <= value
			"attribute_save_failure":
				if not character_value.has_method("get_stat"):
					return _error("Classic attribute-save target has no readable stats")
				roll = randi_range(1, 100)
				matched = roll >= 4.0 * float(
					character_value.get_stat(CLASSIC_MISC_ATTRIBUTE_STATS[value])
				)
			"spell_save_failure":
				if not character_value.has_method("get_stat"):
					return _error("Classic spell-save target has no readable stats")
				roll = randi_range(1, 100)
				matched = roll > _classic_spell_save_chance(character_value, value)
			"focused_character":
				matched = character_value == focused_character
			"wearing_item":
				matched = _character_has_named_item(character_value, item_names, true)
			"exact_position":
				matched = party_position == value
		if matched:
			selected.append(character_value)
		checks.append({
			"character": character_value,
			"name": str(character_value.get("name")),
			"roll": roll,
			"matched": matched,
		})
	return {
		"selected": selected,
		"checks": checks,
	}


func filter_characters_by_check(
	payload: Dictionary,
	party: Array,
	previously_selected: Array
) -> Dictionary:
	var check_type := str(payload.get("checkType", ""))
	var check_index := int(payload.get("checkIndex", -1))
	var stat_mapping: Dictionary
	var roll_high: int
	if check_type == "attribute":
		stat_mapping = CLASSIC_ATTRIBUTE_STATS
		roll_high = 25
	elif check_type == "special":
		stat_mapping = CLASSIC_SPECIAL_STATS
		roll_high = 100
	else:
		return _error("Classic character check has an invalid check type")
	if not stat_mapping.has(check_index):
		return _error(
			"Classic %s check %d has no Remake stat mapping" % [check_type, check_index]
		)

	var candidate_mode := str(payload.get("candidateMode", "selected"))
	if not ["selected", "party", "alive"].has(candidate_mode):
		return _error("Classic character check has an invalid candidate mode")
	var candidates := _selection_candidates(candidate_mode, party, previously_selected)

	var modifier := int(payload.get("modifier", 0))
	var select_on_failure := bool(payload.get("selectOnFailure", false))
	var stat_name := str(stat_mapping[check_index])
	var selected: Array = []
	var checks: Array = []
	for character_value: Variant in candidates:
		if not (character_value is Object) or not character_value.has_method("get_stat"):
			return _error("Classic character check target has no readable stats")
		var stat_value := float(character_value.get_stat(stat_name))
		var roll := randi_range(1, roll_high)
		# Classic's attribute comparison is strict; its percentage check is inclusive.
		var passed := roll - modifier < stat_value if check_type == "attribute" \
			else roll <= stat_value + modifier
		if passed != select_on_failure:
			selected.append(character_value)
		checks.append({
			"character": character_value,
			"name": str(character_value.get("name")),
			"roll": roll,
			"passed": passed,
		})
	return {
		"selected": selected,
		"checks": checks,
	}


func _selection_candidates(mode: String, party: Array, previously_selected: Array) -> Array:
	var candidates: Array = []
	for character_value: Variant in party:
		if mode == "party" \
		or (mode == "alive" and _is_living_character(character_value)) \
		or (mode == "selected" and previously_selected.has(character_value)):
			candidates.append(character_value)
	return candidates


func _character_has_named_item(
	character: Object,
	item_names: Array,
	equipped_only: bool
) -> bool:
	var inventory: Variant = character.get("inventory")
	if not (inventory is Array):
		return false
	var normalized_names: Array[String] = []
	for item_name_value: Variant in item_names:
		normalized_names.append(_normalized_item_name(str(item_name_value)))
	for item_value: Variant in inventory:
		if not (item_value is Dictionary):
			continue
		if not normalized_names.has(_normalized_item_name(str(item_value.get("name", "")))):
			continue
		if not equipped_only or int(item_value.get("equipped", 0)) == 1:
			return true
	return false


func _classic_spell_save_chance(character: Object, save_index: int) -> float:
	var stat_names: Array = CLASSIC_SPELL_SAVE_STATS[save_index]
	var multiplier := float(character.get_stat(stat_names[0]))
	var resistance := float(character.get_stat(stat_names[1]))
	# Remake stores elemental defense as damage modifiers rather than Classic DRVs.
	return clampf((2.0 * (1.0 - multiplier) + 0.1 * resistance) * 100.0, 0.0, 100.0)


func _change_selected_health(payload: Dictionary) -> Dictionary:
	var result := apply_selected_health_effect(payload, _current_selected_characters())
	return await _finish_health_effect(payload, result)


func _change_party_health(payload: Dictionary) -> Dictionary:
	var result := apply_party_health_effect(payload, _party_characters())
	return await _finish_health_effect(payload, result)


func _cast_classic_spell(payload: Dictionary) -> Dictionary:
	var target_mode := str(payload.get("targetMode", ""))
	if target_mode != "party" and target_mode != "selected":
		return _error("Classic spell command has an invalid target mode")
	var targets := spell_effect_targets(
		target_mode,
		_party_characters(),
		_current_selected_characters()
	)
	if target_mode == "party":
		# Opcode 18 replaces Classic's transient picked set with the whole party.
		_store_selected_characters(targets)
	if targets.is_empty():
		if target_mode == "selected":
			return {"targetCount": 0}
		return _error("Classic party spell command has no party members")

	var spell_ids: Object = _autoload("SpellsIdDivinity")
	var spell_id_mapping: Dictionary = spell_ids.mappings \
		if spell_ids != null and spell_ids.mappings is Dictionary else {}
	var spell_id := int(payload.get("spellId", 0))
	var spell_name := _mapped_spell_name(spell_id, spell_id_mapping)
	if spell_name.is_empty():
		return _error("Classic spell %d has no Remake mapping" % spell_id)
	var node_access: Object = _autoload("NodeAccess")
	var resources: Object = node_access.__Resources() if node_access != null else null
	if resources == null or not resources.spells_book.has(spell_name):
		return _error("Mapped spell '%s' is not loaded" % spell_name)
	var spell_entry: Variant = resources.spells_book[spell_name]
	if spell_entry is Dictionary and (
			not spell_entry.has("script") or spell_entry.get("script") == null
	):
		return _error("Mapped spell '%s' has no executable resource" % spell_name)

	var script_helper: Object = _autoload("ScriptHelperFuncs")
	if script_helper == null:
		return _error("Realmz spell helper is unavailable")
	await script_helper.CastSpellOnPickedCharacters(
		targets,
		spell_name,
		int(payload.get("power", 0))
	)
	for target: Variant in targets:
		_refresh_character_panel(target)
	return {
		"spellName": spell_name,
		"targetCount": targets.size(),
	}


func _finish_health_effect(payload: Dictionary, result: Dictionary) -> Dictionary:
	if str(result.get("status", "")) == "error":
		return result
	_play_sound({"soundId": int(payload.get("soundId", 0))})
	for hit_value: Variant in result.get("hits", []):
		if hit_value is Dictionary:
			_refresh_character_panel(hit_value.get("character"))
	var message: Variant = payload.get("message", {})
	if message is Dictionary and not message.is_empty():
		var text_result := await _show_text({"message": message})
		if str(text_result.get("status", "")) == "error":
			return text_result
	return {}


func apply_party_health_effect(payload: Dictionary, party: Array) -> Dictionary:
	return _apply_health_effect(payload, party, false)


func apply_selected_health_effect(payload: Dictionary, selected: Array) -> Dictionary:
	return _apply_health_effect(payload, selected, true)


func _apply_health_effect(
	payload: Dictionary,
	targets: Array,
	allow_empty: bool
) -> Dictionary:
	var roll_range: Variant = payload.get("rollRange", [])
	if not (roll_range is Array) or roll_range.size() < 2:
		return _error("Classic health command is missing its roll range")
	var low_roll := int(roll_range[0])
	var high_roll := int(roll_range[1])
	if high_roll < low_roll:
		return _error("Classic health command has an invalid roll range")
	if targets.is_empty() and not allow_empty:
		return _error("Classic party health command has no party members")
	for character_value: Variant in targets:
		if not (character_value is Object) \
			or not character_value.has_method("change_cur_hp"):
			return _error("Classic health target cannot receive a health change")

	var multiplier := int(payload.get("multiplier", 0))
	var hits: Array = []
	for character_value: Variant in targets:
		var roll := randi_range(low_roll, high_roll)
		var health_change := multiplier * roll
		character_value.change_cur_hp(health_change)
		hits.append({
			"character": character_value,
			"name": str(character_value.get("name")),
			"roll": roll,
			"change": health_change,
		})
	return {"hits": hits}


func _current_selected_characters() -> Array:
	var game_global: Object = _autoload("GameGlobal")
	if game_global != null and game_global.last_picked_characters is Array:
		return game_global.last_picked_characters.duplicate()
	return classic_selected_characters.duplicate()


func _store_selected_characters(characters: Array) -> void:
	classic_selected_characters = characters.duplicate()
	var game_global: Object = _autoload("GameGlobal")
	if game_global != null:
		game_global.last_picked_characters = characters.duplicate()


func _is_living_character(character: Variant) -> bool:
	return character is Object \
		and character.has_method("get_stat") \
		and float(character.get_stat("curHP")) > 0.0


func _give_player_map(payload: Dictionary) -> Dictionary:
	var map_id := int(payload.get("mapId", -1))
	if map_id < 0:
		return _error("Classic map command is missing its map ID")
	var game_global: Object = _autoload("GameGlobal")
	var native_map: Array = []
	if game_global != null and game_global.minimaps is Array \
			and map_id < game_global.minimaps.size():
		var map_value: Variant = game_global.minimaps[map_id]
		if map_value is Array and map_value.size() >= 7:
			native_map = map_value
			native_map[6] = 1

	_play_sound({"soundId": 30005})
	if bool(payload.get("display", false)) and _can_display_native_map(native_map):
		var ui: Object = _autoload("UI")
		if ui == null or ui.ow_hud == null or ui.ow_hud.minimapRect == null:
			return _error("Realmz minimap UI is unavailable")
		var minimap_rect: Object = ui.ow_hud.minimapRect
		minimap_rect.cur_map = native_map
		minimap_rect.show()
		minimap_rect.on_display()
		var state_machine: Object = _autoload("StateMachine")
		if state_machine != null:
			state_machine.enter_ex_menu_state({"menu_name": "MiniMapsMenu"})
		await minimap_rect.visibility_changed
		return {}

	var text_rect: Object = _text_rect()
	if text_rect == null:
		return _error("Realmz HUD TextRect is unavailable for the Classic map notice")
	var message := MAP_GAINED_MESSAGE
	if bool(payload.get("display", false)):
		var map_record: Variant = payload.get("mapRecord", {})
		if map_record is Dictionary:
			var map_note := str(map_record.get("note", "")).strip_edges()
			if not map_note.is_empty():
				message = map_note
	await text_rect.set_text(message, true)
	return {}


func _can_display_native_map(native_map: Array) -> bool:
	return native_map.size() >= 7 and native_map[2] is String


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
