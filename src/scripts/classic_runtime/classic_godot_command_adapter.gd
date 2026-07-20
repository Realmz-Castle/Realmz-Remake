class_name ClassicGodotCommandAdapter
extends RefCounted

const RogueResolverScript = preload("res://scripts/classic_runtime/classic_rogue_encounter_resolver.gd")
const InventoryRulesScript = preload("res://scripts/classic_runtime/classic_inventory_rules.gd")
const CharacterConditionRulesScript = preload(
	"res://scripts/classic_runtime/classic_character_condition_rules.gd"
)
const SpellOverrideScript = preload(
	"res://scripts/classic_runtime/classic_spell_override.gd"
)
const MapBridgeScript = preload("res://scripts/classic_runtime/classic_map_bridge.gd")
const CombatRoutRulesScript = preload(
	"res://scripts/classic_runtime/classic_combat_rout_rules.gd"
)
const COMBATANT_SCENE_PATH := "res://scenes/Map/CombatCharacter.tscn"
# Classic's negative runs-away condition is permanent and maps to this native AI trait.
const PERMANENT_FLEEING_TRAIT_PATH := "res://shared_assets/traits/p_fleeing.gd"
const CLASSIC_MAX_MONSTERS := 100
const CLASSIC_BATTLE_GRID_SIZE := 13
const CLASSIC_BATTLE_GRID_CELLS := CLASSIC_BATTLE_GRID_SIZE * CLASSIC_BATTLE_GRID_SIZE
const CLASSIC_BATTLE_ORIGIN_OFFSET := 5
const CLASSIC_FIELD_SPELL_SAVE_MODES := ["none", "negate", "half_damage"]
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
# These are core STR# 3 warnings 118 and 124, not scenario messages. Their
# original spelling is preserved.
const CLASSIC_COWARD_RETREAT_MESSAGE := \
	"Having fled the battle, the enemy remains to challange you another time."
const CLASSIC_COWARD_EXPERIENCE_MESSAGE := \
	"You all loose victory points for this cowardly display."
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
# Classic's party-condition indexes use different names from Remake's saved
# global effects. Search and the unused final slot have no native state yet.
const CLASSIC_PARTY_EFFECTS := {
	1: "WaterBreath",
	2: "Shielded",
	3: "Awareness",
	4: "Scrying",
	6: "FeatherFall",
	7: "Sentry",
	8: "CharmProt",
}

var classic_selected_characters: Array = []
var stored_party_equipment: Dictionary = {}
var classic_bundle: Object
var classic_spell_overrides: Dictionary = {}
var classic_registered_spells: Dictionary = {}
var classic_map_bridge = MapBridgeScript.new()
# Opcode 100 runs in a nested host while start_battle waits on this adapter.
# This one-shot carries its slot-8 result back to the suspended outer command.
var _forced_battle_resume_slot := -1


func configure_classic_bundle(bundle: Object) -> void:
	_unregister_classic_spell_overrides()
	classic_bundle = bundle
	classic_map_bridge.configure(bundle)
	classic_spell_overrides.clear()
	_forced_battle_resume_slot = -1
	_register_classic_spell_overrides()


func classic_save_state() -> Dictionary:
	var saved_equipment := stored_party_equipment.duplicate(true)
	var inventories: Variant = saved_equipment.get("inventories", [])
	if inventories is Array:
		for inventory_value: Variant in inventories:
			if not (inventory_value is Array):
				continue
			for item_value: Variant in inventory_value:
				if item_value is Dictionary:
					item_value.erase("texture")
	return {"storedPartyEquipment": saved_equipment}


func restore_classic_save_state(saved_state: Dictionary) -> Dictionary:
	var equipment_value: Variant = saved_state.get("storedPartyEquipment", {})
	if not (equipment_value is Dictionary):
		return _error("Classic save contains invalid stored equipment")
	stored_party_equipment = equipment_value.duplicate(true)
	var inventories: Variant = stored_party_equipment.get("inventories", [])
	if not (inventories is Array):
		return _error("Classic save contains invalid stored inventories")
	var resources := _classic_campaign_resources()
	if resources == null or not resources.has_method("generate_item_from_json_dict"):
		return {"status": "ok"}
	for inventory_index: int in inventories.size():
		var inventory_value: Variant = inventories[inventory_index]
		if not (inventory_value is Array):
			return _error("Classic save contains an invalid stored inventory")
		var restored_inventory: Array = []
		for item_value: Variant in inventory_value:
			if not (item_value is Dictionary):
				return _error("Classic save contains an invalid stored item")
			restored_inventory.append(
				resources.call("generate_item_from_json_dict", item_value.duplicate(true))
			)
		inventories[inventory_index] = restored_inventory
	return {"status": "ok"}


func activate_classic_start(location: Dictionary) -> Dictionary:
	var transition_result := classic_map_bridge.transition(
		location,
		_autoload("GameGlobal"),
		_classic_campaign_resources()
	)
	if str(transition_result.get("status", "")) == "error":
		return transition_result
	var view_result := classic_map_bridge.redraw_view(
		location,
		_autoload("GameGlobal")
	)
	if str(view_result.get("status", "")) == "error":
		return view_result
	transition_result["view"] = view_result
	return transition_result


func reapply_classic_map_state(runtime_state: Object) -> Dictionary:
	return classic_map_bridge.reapply_persistent_state(
		runtime_state,
		_autoload("GameGlobal"),
		_classic_campaign_resources()
	)


func classic_spell_override(spell_id: int) -> Variant:
	if classic_spell_overrides.has(spell_id):
		return classic_spell_overrides[spell_id]
	if classic_bundle == null or not classic_bundle.has_method("get_spell_override"):
		return null
	var record: Variant = classic_bundle.get_spell_override(spell_id)
	if not (record is Dictionary) or record.is_empty():
		return null
	var spell = SpellOverrideScript.new()
	spell.configure(record)
	classic_spell_overrides[spell_id] = spell
	return spell


func _register_classic_spell_overrides() -> void:
	if classic_bundle == null:
		return
	var resources := _classic_campaign_resources()
	if resources == null:
		return
	var spells_book: Variant = resources.get("spells_book")
	var override_index: Variant = classic_bundle.get("spell_overrides_by_id")
	if not (spells_book is Dictionary) or not (override_index is Dictionary):
		return
	var spell_ids: Array = override_index.keys()
	spell_ids.sort()
	for spell_id_value: Variant in spell_ids:
		var spell: Variant = classic_spell_override(int(spell_id_value))
		if spell == null or not spell.is_generically_executable():
			continue
		var had_previous: bool = spells_book.has(spell.name)
		var previous_entry: Variant = spells_book.get(spell.name)
		spells_book[spell.name] = {
			"name": spell.name,
			"source": "",
			"script": spell,
			"classicSpellId": int(spell_id_value),
		}
		classic_registered_spells[spell.name] = {
			"spell": spell,
			"hadPrevious": had_previous,
			"previousEntry": previous_entry,
		}


func _unregister_classic_spell_overrides() -> void:
	var resources := _classic_campaign_resources()
	if resources != null:
		var spells_book: Variant = resources.get("spells_book")
		if spells_book is Dictionary:
			for spell_name: String in classic_registered_spells:
				var registration: Dictionary = classic_registered_spells[spell_name]
				var entry: Variant = spells_book.get(spell_name)
				var registered_spell: Variant = entry.get("script") \
					if entry is Dictionary else entry
				if registered_spell != registration.get("spell"):
					continue
				if bool(registration.get("hadPrevious", false)):
					spells_book[spell_name] = registration.get("previousEntry")
				else:
					spells_book.erase(spell_name)
	classic_registered_spells.clear()


func _classic_campaign_resources() -> Node:
	var main_loop: MainLoop = Engine.get_main_loop()
	if not (main_loop is SceneTree):
		return null
	return main_loop.root.get_node_or_null("Main/Resources")


func get_classic_execution_context() -> Dictionary:
	var game_global: Object = _autoload("GameGlobal")
	if game_global == null:
		return {}
	var current_time := int(game_global.get("time"))
	if current_time < 0:
		return {}
	return {"scenarioDay": floori(float(current_time) / 86400.0)}


func execute_command(command: String, payload: Dictionary) -> Dictionary:
	match command:
		"show_text":
			return await _show_text(payload)
		"choice":
			return await _show_yes_no_choice()
		"start_encounter":
			return await _show_encounter(payload)
		"start_battle":
			return await _start_classic_battle(payload)
		"play_sound":
			return _play_sound(payload)
		"wait_for_click":
			return await _wait_for_click(payload)
		"show_picture":
			return _show_classic_picture(payload)
		"redraw_map":
			return _redraw_map()
		"set_map_tile":
			return classic_map_bridge.set_tile(
				payload, _autoload("GameGlobal"), _classic_campaign_resources()
			)
		"set_trigger_percent":
			return classic_map_bridge.set_trigger_percent(
				payload, _autoload("GameGlobal"), _classic_campaign_resources()
			)
		"teleport":
			return await _teleport_classic_party(payload)
		"set_view_direction", "set_view_mode":
			return classic_map_bridge.redraw_view(payload, _autoload("GameGlobal"))
		"set_map_darkness":
			return classic_map_bridge.set_darkness(
				payload, _autoload("GameGlobal"), _classic_campaign_resources()
			)
		"set_random_encounter_rect":
			return classic_map_bridge.set_random_rectangle(
				payload, _autoload("GameGlobal"), _classic_campaign_resources()
			)
		"set_land_look":
			return classic_map_bridge.set_land_look(
				payload, _autoload("GameGlobal"), _classic_campaign_resources()
			)
		"check_party_condition":
			return _check_party_condition(payload)
		"check_party_ally":
			return _check_party_ally(payload)
		"check_combat_monster":
			return _check_combat_monster(payload)
		"destroy_combat_monsters":
			return _destroy_combat_monsters(payload)
		"deanimate_lower_undead":
			return _deanimate_lower_undead(payload)
		"rout_combat_monsters":
			return _rout_combat_monsters(payload)
		"spawn_combat_monsters":
			return _spawn_combat_monsters(payload)
		"activate_battle_round_macro":
			return _activate_battle_round_macro(payload)
		"end_classic_battle":
			return await _end_classic_battle(payload)
		"add_party_ally":
			return _add_classic_ally(payload)
		"present_random_branch":
			return await _present_random_branch(payload)
		"set_priest_turning":
			return await _present_priest_turning(payload)
		"give_treasure":
			return await _give_treasure(payload)
		"give_battle_loot":
			# Native battle cleanup has already presented defeated-enemy rewards.
			return {}
		"apply_coward_penalty":
			return await _apply_coward_penalty(payload)
		"give_experience":
			return await _give_experience(payload)
		"give_character_condition":
			return _give_character_condition(payload)
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
		"take_party_wealth":
			return _take_party_wealth(payload)
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


func _wait_for_click(payload: Dictionary) -> Dictionary:
	var text_rect: Object = _text_rect()
	if text_rect == null:
		return _error("Realmz HUD TextRect is unavailable")
	_play_sound(payload)
	await text_rect.set_text(str(payload.get("prompt", "Click Mouse")), true)
	return {}


func _show_classic_picture(payload: Dictionary) -> Dictionary:
	var picture_rect: Object = _picture_rect()
	if picture_rect == null:
		return {"status": "skipped", "message": "Realmz HUD PictureRect is unavailable"}
	var paths: Object = _autoload("Paths")
	var game_global: Object = _autoload("GameGlobal")
	if paths == null or game_global == null:
		return {"status": "skipped", "message": "Realmz campaign paths are unavailable"}
	var splash_directory := str(paths.campaignsfolderpath)
	splash_directory = splash_directory.path_join(str(game_global.currentcampaign))
	splash_directory = splash_directory.path_join("Splash Images")
	for file_name: String in picture_file_candidates(payload):
		if FileAccess.file_exists(splash_directory.path_join(file_name)):
			picture_rect.display_image(file_name)
			return {"fileName": file_name}
	return {
		"status": "skipped",
		"message": "Classic picture %d has no exported Remake image" \
			% int(payload.get("pictureId", 0)),
	}


func picture_file_candidates(payload: Dictionary) -> Array:
	var candidates: Array = []
	var picture: Variant = payload.get("picture", {})
	if picture is Dictionary:
		for field_name: String in ["fileName", "relativePath", "path", "name"]:
			var field_value: Variant = picture.get(field_name)
			if field_value is String:
				_append_picture_candidate(candidates, field_value)
	var picture_id := int(payload.get("pictureId", 0))
	if picture_id != 0:
		_append_picture_candidate(candidates, "%d.png" % abs(picture_id))
	return candidates


func _append_picture_candidate(candidates: Array, value: String) -> void:
	var file_name := value.strip_edges().replace("\\", "/")
	if file_name.begins_with("Splash Images/"):
		file_name = file_name.trim_prefix("Splash Images/")
	if file_name.is_empty() or file_name.is_absolute_path():
		return
	var path_parts := file_name.split("/", false)
	if path_parts.has("..") or candidates.has(file_name):
		return
	candidates.append(file_name)


func _redraw_map() -> Dictionary:
	var changed := false
	var picture_rect: Object = _picture_rect()
	if picture_rect != null:
		picture_rect.hide()
		changed = true
	var game_global: Object = _autoload("GameGlobal")
	var current_map: Variant = game_global.get("map") if game_global != null else null
	if current_map is Object and current_map.has_method("queue_redraw"):
		current_map.queue_redraw()
		changed = true
	if not changed:
		return {"status": "skipped", "message": "Realmz map display is unavailable"}
	return {}


func _teleport_classic_party(payload: Dictionary) -> Dictionary:
	_play_sound(payload)
	var message: Variant = payload.get("message", {})
	if message is Dictionary and not str(message.get("text", "")).strip_edges().is_empty():
		var message_result := await _show_text(payload)
		if str(message_result.get("status", "")) == "error":
			return message_result
	return classic_map_bridge.transition(
		payload,
		_autoload("GameGlobal"),
		_classic_campaign_resources()
	)


func _check_party_condition(payload: Dictionary) -> Dictionary:
	var game_global: Object = _autoload("GameGlobal")
	if game_global == null:
		return _error("Realmz party state is unavailable")
	var global_effects: Variant = game_global.get("global_effects")
	if not (global_effects is Dictionary):
		return _error("Realmz global-effect state is unavailable")
	var result := party_condition_status(
		int(payload.get("conditionIndex", -1)),
		global_effects,
		int(game_global.get("light_time"))
	)
	if not bool(result.get("supported", false)):
		return _error(
			"Classic party condition %d has no Remake state mapping" \
				% int(payload.get("conditionIndex", -1))
		)
	return {"active": bool(result.get("active", false))}


func party_condition_status(condition_index: int, global_effects: Dictionary, light_time: int) -> Dictionary:
	if condition_index == 0:
		return {"supported": true, "active": light_time > 0}
	if not CLASSIC_PARTY_EFFECTS.has(condition_index):
		return {"supported": false, "active": false}
	var effect: Variant = global_effects.get(CLASSIC_PARTY_EFFECTS[condition_index], {})
	var duration := int(effect.get("Duration", 0)) if effect is Dictionary else 0
	return {"supported": true, "active": duration > 0}


func _check_party_ally(payload: Dictionary) -> Dictionary:
	var game_global: Object = _autoload("GameGlobal")
	var player_allies: Variant = game_global.get("player_allies") if game_global != null else null
	if not (player_allies is Array):
		return _error("Realmz ally state is unavailable")
	return {"present": party_has_classic_ally(payload, player_allies)}


func party_has_classic_ally(payload: Dictionary, allies: Array) -> bool:
	var monster_id := int(payload.get("monsterId", -1))
	var monster_name_id := int(payload.get("monsterNameId", -1))
	var monster: Variant = payload.get("monster", {})
	var display_name := str(monster.get("displayName", "")) if monster is Dictionary else ""
	for ally_value: Variant in allies:
		var ally_id := -1
		var ally_name_id := -1
		var ally_name := ""
		if ally_value is Object:
			ally_id = _classic_monster_id(ally_value)
			ally_name_id = _classic_monster_name_id(ally_value)
			ally_name = str(ally_value.get("name"))
		elif ally_value is Dictionary:
			ally_id = _classic_monster_id(ally_value)
			ally_name_id = _classic_monster_name_id(ally_value)
			ally_name = str(ally_value.get("name", ""))
		if monster_name_id >= 0:
			if ally_name_id == monster_name_id:
				return true
			continue
		if ally_id == monster_id:
			return true
		if not display_name.is_empty() and ally_name.to_lower() == display_name.to_lower():
			return true
	return false


func _check_combat_monster(payload: Dictionary) -> Dictionary:
	var context := _combat_context()
	if context.has("error"):
		return _error(str(context["error"]))
	return {"present": combat_has_classic_monster(payload, context["combatants"])}


func combat_has_classic_monster(payload: Dictionary, combatants: Array) -> bool:
	var monster_name_id := int(payload.get("monsterNameId", -1))
	if monster_name_id < 0:
		return false
	monster_name_id = abs(monster_name_id)
	for combatant_value: Variant in combatants:
		var creature: Variant = _combatant_creature(combatant_value)
		if creature == null or not _is_living_combat_creature(creature):
			continue
		if _classic_monster_name_id(creature) == monster_name_id:
			return true
	return false


func _destroy_combat_monsters(payload: Dictionary) -> Dictionary:
	var context := _combat_context()
	if context.has("error"):
		return _error(str(context["error"]))
	var selected: Array = select_classic_combatants(payload, context["combatants"])
	var removed: int = remove_classic_combatants(context["state"], selected)
	if removed < 0:
		return _error("Realmz combat removal API is unavailable")
	return {"removed": removed}


func _deanimate_lower_undead(payload: Dictionary) -> Dictionary:
	var context := _combat_context()
	if context.has("error"):
		return _error(str(context["error"]))
	var monster_ids: Variant = payload.get("monsterIds", [])
	if not (monster_ids is Array):
		return _error("Classic lower-undead command has an invalid monster list")
	var selected: Array = select_classic_combatants_by_ids(monster_ids, context["combatants"])
	var removed: int = remove_classic_combatants(context["state"], selected)
	if removed < 0:
		return _error("Realmz combat removal API is unavailable")
	return {"removed": removed}


func _rout_combat_monsters(payload: Dictionary) -> Dictionary:
	var context := _combat_context()
	if context.has("error"):
		return _error(str(context["error"]))
	var actor_faction: Variant = payload.get("actorFaction")
	if actor_faction == null:
		actor_faction = _active_combat_faction(context["stateMachine"])
	if actor_faction == null:
		return _error("Realmz active combat actor is unavailable")
	var monster_ids: Variant = payload.get("monsterIds", [])
	if not (monster_ids is Array):
		return _error("Classic combat-rout command has an invalid monster list")
	var selected := select_classic_combatants_by_ids_and_faction(
		monster_ids,
		int(actor_faction),
		context["combatants"]
	)
	var fleeing_trait: Variant = load(PERMANENT_FLEEING_TRAIT_PATH)
	if not (fleeing_trait is Script):
		return _error("Realmz permanent fleeing trait is unavailable")
	var routed := apply_classic_rout(selected, fleeing_trait)
	if routed < 0:
		return _error("Realmz permanent fleeing trait is unavailable")
	return {"routed": routed}


func _spawn_combat_monsters(payload: Dictionary) -> Dictionary:
	var context := _combat_context()
	if context.has("error"):
		return _error(str(context["error"]))
	var game_global: Object = _autoload("GameGlobal")
	var node_access: Object = _autoload("NodeAccess")
	if game_global == null or node_access == null:
		return _error("Realmz combat spawn dependencies are unavailable")
	var resources: Object = node_access.__Resources()
	var map: Object = node_access.__Map()
	var creature_book: Variant = resources.get("crea_book") if resources != null else null
	var creature_script: Variant = game_global.get("combatCreatureGD")
	var combatant_scene: Variant = _combatant_scene_resource()
	if not (creature_book is Dictionary):
		return _error("Realmz bestiary resources are unavailable")
	var origin: Variant = _classic_spawn_origin(payload, context["stateMachine"])
	if not (origin is Vector2):
		return _error("Realmz combat spawn actor position is unavailable")
	var actor_faction: Variant = payload.get("actorFaction")
	if bool(payload.get("inheritActorFaction", false)) and actor_faction == null:
		actor_faction = _active_combat_faction(context["stateMachine"])
	if bool(payload.get("inheritActorFaction", false)) and actor_faction == null:
		return _error("Realmz combat spawn actor faction is unavailable")
	var result := spawn_classic_combatants(
		payload,
		context["state"],
		map,
		creature_book,
		creature_script,
		combatant_scene,
		origin,
		actor_faction
	)
	if str(result.get("status", "")) == "error":
		return result
	for _spawn_index: int in range(int(result.get("spawned", 0))):
		_play_sound({"soundId": int(payload.get("soundId", 0))})
	return result


func _combatant_scene_resource() -> Variant:
	return load(COMBATANT_SCENE_PATH)


func spawn_classic_combatants(
	payload: Dictionary,
	combat_state: Variant,
	map: Variant,
	creature_book: Dictionary,
	creature_script: Variant,
	combatant_scene: Variant,
	origin: Vector2,
	actor_faction: Variant = null
) -> Dictionary:
	if not (combat_state is Object) or not combat_state.has_method("find_pos_for_crea_on_battlefield"):
		return _error("Realmz combat placement API is unavailable")
	var combatants: Variant = combat_state.get("all_battle_creatures_btns")
	var initiative: Variant = combat_state.get("battle_creatures_yet_to_act_btns")
	var creatures_node: Variant = map.get("creatures_node") if map is Object else null
	if not (combatants is Array) or not (initiative is Array) or creatures_node == null:
		return _error("Realmz combat roster is unavailable")
	if creature_script == null or combatant_scene == null:
		return _error("Realmz combat creature resources are unavailable")
	var monster: Variant = payload.get("monster", {})
	if not (monster is Dictionary):
		return _error("Classic combat spawn is missing its monster record")
	var monster_id := int(payload.get("monsterId", -1))
	var bestiary_name := resolve_classic_monster_bestiary_name(
		monster_id,
		monster,
		creature_book
	)
	if bestiary_name.is_empty():
		return _error("Classic combat spawn %d (%s) has no matching Remake bestiary entry" % [
			monster_id,
			monster.get("displayName", "unnamed"),
		])
	var requested := maxi(0, int(payload.get("spawnCount", 0)))
	var slots_used := classic_combat_monster_slots_used(combat_state, combatants)
	var available := maxi(0, CLASSIC_MAX_MONSTERS - slots_used)
	var spawn_count := mini(requested, available)
	var faction_override := int(payload.get("factionOverride", 0))
	var inherit_faction := bool(payload.get("inheritActorFaction", false))
	if inherit_faction and actor_faction == null:
		return _error("Classic combat spawn requires its actor faction")
	var resolved_faction: Variant = null
	if faction_override != 0:
		resolved_faction = faction_override
	elif inherit_faction:
		resolved_faction = int(actor_faction)
	elif monster.has("traitor"):
		resolved_faction = int(monster["traitor"])
	var spawned: Array = []
	for _spawn_index: int in range(spawn_count):
		var creature: Variant = creature_script.new()
		if not (creature is Object) or not creature.has_method("initialize_from_bestiary_dict"):
			return _error("Realmz creature cannot load a bestiary entry")
		creature.initialize_from_bestiary_dict(bestiary_name)
		_set_classic_monster_identity(creature, monster_id, monster)
		if resolved_faction != null:
			creature.set("baseFaction", int(resolved_faction))
			creature.set("curFaction", int(resolved_faction))
		creature.position = combat_state.find_pos_for_crea_on_battlefield(
			creature,
			origin,
			true,
			15,
			10
		)
		var combatant: Variant = combatant_scene.instantiate()
		if not (combatant is Object) or not combatant.has_method("set_creature_represented"):
			return _error("Realmz combat creature scene is unavailable")
		creatures_node.add_child(combatant)
		combatant.set_creature_represented(creature)
		creature.set("combat_button", combatant)
		var background: Variant = combatant.get("bgsprite")
		if background is Object and background.has_method("hide"):
			background.hide()
		combatants.append(combatant)
		initiative.append(combatant)
		spawned.append(combatant)
		slots_used += 1
		_set_classic_combat_monster_slots_used(combat_state, slots_used)
	return {
		"requested": requested,
		"spawned": spawned.size(),
		"capacityLimited": spawn_count < requested,
		"slotsUsed": slots_used,
		"bestiaryName": bestiary_name,
		"combatants": spawned,
	}


func classic_combat_monster_count(combatants: Array) -> int:
	var count := 0
	for combatant_value: Variant in combatants:
		var creature: Variant = _combatant_creature(combatant_value)
		if creature is Object and not bool(creature.get("is_player_controlled")):
			count += 1
		elif creature is Dictionary and not bool(creature.get("isPlayerControlled", false)):
			count += 1
	return count


func classic_combat_monster_slots_used(combat_state: Variant, combatants: Array) -> int:
	var live_count := classic_combat_monster_count(combatants)
	if not (combat_state is Object):
		return live_count
	if _object_has_property(combat_state, "classic_monster_slots_used"):
		return maxi(live_count, int(combat_state.get("classic_monster_slots_used")))
	return live_count


func _set_classic_combat_monster_slots_used(combat_state: Variant, count: int) -> void:
	if not (combat_state is Object):
		return
	if _object_has_property(combat_state, "classic_monster_slots_used"):
		combat_state.set("classic_monster_slots_used", count)


func _activate_battle_round_macro(payload: Dictionary) -> Dictionary:
	var context := _combat_context()
	if context.has("error"):
		return _error(str(context["error"]))
	var battle_data: Variant = context["state"].get("cur_battle_data")
	if not apply_battle_round_macro_schedule(
		battle_data,
		bool(payload.get("disableSchedule", false))
	):
		return _error("Realmz battle-round schedule is unavailable")
	return {"targetMacroId": int(payload.get("targetMacroId", -1))}


func apply_battle_round_macro_schedule(battle_data: Variant, disable_schedule: bool) -> bool:
	if not (battle_data is Dictionary):
		return false
	if disable_schedule:
		battle_data["battleMacro"] = 0
	return true


func _end_classic_battle(payload: Dictionary) -> Dictionary:
	var context := _combat_context()
	if context.has("error"):
		return _error(str(context["error"]))
	var game_global: Object = _autoload("GameGlobal")
	if game_global == null or not game_global.has_method("end_battle"):
		return _error("Realmz battle completion API is unavailable")
	var resume_slot := int(payload.get("resumeSlot", -1))
	if not _record_forced_battle_resume_slot(resume_slot):
		return _error("Classic forced battle resume slot must be 8")
	var outcome := str(payload.get("outcome", "won"))
	var reward_mode := str(payload.get("rewardMode", "normal"))
	await game_global.call("end_battle", outcome, reward_mode)
	return {"outcome": outcome, "resumeSlot": resume_slot}


func _start_classic_battle(payload: Dictionary) -> Dictionary:
	_forced_battle_resume_slot = -1
	var node_access: Object = _autoload("NodeAccess")
	var resources: Object = node_access.__Resources() if node_access != null else null
	var game_global: Object = _autoload("GameGlobal")
	if resources == null or game_global == null:
		return _error("Realmz battle resources are unavailable")
	var battle_id_result := resolve_classic_battle_id(payload)
	if str(battle_id_result.get("status", "")) == "error":
		return battle_id_result
	var battle_id := int(battle_id_result["battleId"])
	var resource_result := ensure_classic_battle_resource(
		battle_id,
		resources.battles_book,
		resources.crea_book
	)
	if str(resource_result.get("status", "")) == "error":
		return resource_result
	var request := build_classic_battle_request(
		payload,
		resources.battles_book,
		_party_characters(),
		_current_selected_characters(),
		battle_id
	)
	if str(request.get("status", "")) == "error":
		return request

	_play_sound(payload)
	var message: Variant = payload.get("message", {})
	if message is Dictionary and not str(message.get("text", "")).is_empty():
		var text_result := await _show_text(payload)
		if str(text_result.get("status", "")) == "error":
			return text_result
	if bool(request.get("noBattle", false)):
		return {
			"battleId": int(request.get("battleId", 0)),
			"battleStarted": false,
			"outcome": "lost",
			"coward": true,
			"survivorCount": 0,
		}

	game_global.allow_next_battle_loot = bool(request["allowLoot"])
	var battle_overrides := build_existing_classic_battle_overrides(
		battle_id,
		resources.battles_book,
		resources.crea_book
	)
	battle_overrides["classicBattleId"] = battle_id
	battle_overrides["classicPriestTurningEnabled"] = bool(
		payload.get("priestTurningEnabled", true)
	)
	game_global.start_battle(
		str(request["battleName"]),
		"",
		true,
		bool(request["surprise"]),
		bool(request["allowLoss"]),
		true,
		true,
		request["participants"],
		battle_overrides
	)
	var outcome_value: Variant = await game_global.battle_end
	var outcome := str(outcome_value)
	var survivor_count := 0
	for character_value: Variant in request["participants"]:
		if _is_living_character(character_value):
			survivor_count += 1
	var response := {
		"battleId": int(request["battleId"]),
		"battleStarted": true,
		"outcome": outcome,
		"coward": outcome != "won",
		"survivorCount": survivor_count,
	}
	var forced_resume_slot := _take_forced_battle_resume_slot()
	if forced_resume_slot >= 0:
		response["forcedResumeSlot"] = forced_resume_slot
	return response


func _record_forced_battle_resume_slot(resume_slot: int) -> bool:
	if resume_slot != 8:
		return false
	_forced_battle_resume_slot = resume_slot
	return true


func _take_forced_battle_resume_slot() -> int:
	var resume_slot := _forced_battle_resume_slot
	_forced_battle_resume_slot = -1
	return resume_slot


func build_classic_battle_request(
	payload: Dictionary,
	battles_book: Dictionary,
	party: Array,
	selected: Array,
	resolved_battle_id := -1
) -> Dictionary:
	var battle_id_result := resolve_classic_battle_id(payload, resolved_battle_id)
	if str(battle_id_result.get("status", "")) == "error":
		return battle_id_result
	var battle_id := int(battle_id_result["battleId"])
	var battle_name := "Battle_%d" % battle_id
	if not battles_book.has(battle_name):
		return _error("Classic battle %d has no native Remake resource" % battle_id)

	var selective := str(payload.get("participantMode", "party")) == "selected"
	var participants: Array = []
	if selective:
		for character_value: Variant in selected:
			if not party.has(character_value):
				return _error("Classic battle selection contains a non-party character")
			if _is_living_character(character_value):
				participants.append(character_value)
	else:
		participants = party.duplicate()
		if participants.is_empty():
			return _error("Classic battle has no party members")

	return {
		"battleId": battle_id,
		"battleName": battle_name,
		"participants": participants,
		"noBattle": participants.is_empty(),
		"surprise": bool(payload.get("surprise", false)),
		"allowLoss": selective
			or bool(payload.get("outcomeBranch", false))
			or int(payload.get("lootMode", 0)) == 10,
		"allowLoot": int(payload.get("lootMode", 0)) != 5,
	}


func resolve_classic_battle_id(payload: Dictionary, resolved_battle_id := -1) -> Dictionary:
	var battle_range: Variant = payload.get("battleIdRange", [])
	if not (battle_range is Array) or battle_range.size() < 2:
		return _error("Classic battle command has no battle range")
	var first_battle_id := int(battle_range[0])
	var last_battle_id := int(battle_range[1])
	if first_battle_id < 1 or last_battle_id < first_battle_id:
		return _error("Classic battle command has an invalid battle range")
	var battle_id := int(resolved_battle_id)
	if battle_id < 0:
		battle_id = randi_range(first_battle_id, last_battle_id)
	if battle_id < first_battle_id or battle_id > last_battle_id:
		return _error("Resolved Classic battle is outside its authored range")
	return {"battleId": battle_id}


func ensure_classic_battle_resource(
	battle_id: int,
	battles_book: Dictionary,
	creature_book: Dictionary
) -> Dictionary:
	var battle_name := "Battle_%d" % battle_id
	if battles_book.has(battle_name):
		return {"battleName": battle_name, "created": false}
	if classic_bundle == null or not classic_bundle.has_method("get_battle"):
		return _error("Classic battle %d has no compiled battle record" % battle_id)
	var battle_record: Variant = classic_bundle.get_battle(battle_id)
	if not (battle_record is Dictionary) or battle_record.is_empty():
		return _error("Classic battle %d has no compiled battle record" % battle_id)
	var monsters: Variant = classic_bundle.get("monsters_by_id")
	if not (monsters is Dictionary):
		return _error("Classic campaign has no compiled monster index")
	var materialized := materialize_classic_battle(
		battle_record,
		monsters,
		creature_book
	)
	if str(materialized.get("status", "")) == "error":
		return materialized
	battles_book[battle_name] = materialized["battle"]
	return {
		"battleName": battle_name,
		"created": true,
		"creatureCount": int(materialized.get("creatureCount", 0)),
	}


func build_existing_classic_battle_overrides(
	battle_id: int,
	battles_book: Dictionary,
	creature_book: Dictionary
) -> Dictionary:
	if classic_bundle == null or not classic_bundle.has_method("get_monster"):
		return {}
	var battle_name := "Battle_%d" % battle_id
	var battle: Variant = battles_book.get(battle_name, {})
	if not (battle is Dictionary):
		return {}
	var source_creatures: Variant = battle.get("Creatures", [])
	if not (source_creatures is Array):
		return {}
	var creatures: Array = source_creatures.duplicate(true)
	var decorated := false
	for creature_index: int in range(creatures.size()):
		var creature_value: Variant = creatures[creature_index]
		if not (creature_value is Array) or creature_value.is_empty():
			continue
		var bestiary_name := str(creature_value[0])
		var compiled := _compiled_monster_for_bestiary_name(bestiary_name, creature_book)
		if compiled.is_empty():
			continue
		var metadata := _classic_battle_monster_metadata(
			int(compiled["monsterId"]),
			compiled["monster"],
			false
		)
		if creature_value.size() > 2 and creature_value[2] is Dictionary:
			var existing_metadata: Dictionary = creature_value[2].duplicate(true)
			for metadata_key: Variant in metadata:
				if not existing_metadata.has(metadata_key):
					existing_metadata[metadata_key] = metadata[metadata_key]
			creature_value[2] = existing_metadata
		else:
			creature_value.append(metadata)
		creatures[creature_index] = creature_value
		decorated = true
	return {"Creatures": creatures} if decorated else {}


func _compiled_monster_for_bestiary_name(
	bestiary_name: String,
	creature_book: Dictionary
) -> Dictionary:
	var bestiary: Variant = creature_book.get(bestiary_name, {})
	if not (bestiary is Dictionary):
		return {}
	var candidate_ids := _classic_resource_ids(
		bestiary,
		"classicMonsterId",
		"classicMonsterIds"
	)
	var data: Variant = bestiary.get("data", {})
	if data is Dictionary:
		candidate_ids.append_array(_classic_resource_ids(
			data,
			"classicMonsterId",
			"classicMonsterIds"
		))
		var native_id: Variant = data.get("id")
		if native_id is int or native_id is float:
			var normalized_id: int = abs(int(native_id))
			if not candidate_ids.has(normalized_id):
				candidate_ids.append(normalized_id)
	for monster_id: int in candidate_ids:
		var monster: Variant = classic_bundle.get_monster(monster_id)
		if monster is Dictionary and not monster.is_empty():
			return {"monsterId": monster_id, "monster": monster}
	return {}


func _classic_battle_monster_metadata(
	monster_id: int,
	monster: Dictionary,
	force_friend: bool
) -> Dictionary:
	return {
		"classicMonsterId": monster_id,
		"classicMonsterNameId": int(monster.get("nameId", -1)),
		"classicDeathMacro": int(monster.get("deathMacro", 0)),
		"classicTurnUndeadEligible": _classic_monster_can_be_turned(monster),
		"classicHitDice": int(monster.get("hitDice", 0)),
		"classicMagicResistance": int(monster.get("magicResistance", 0)),
		"classicCanSummon": int(monster.get("canSummon", 0)),
		"classicForceFriend": force_friend,
	}


func materialize_classic_battle(
	battle_record: Dictionary,
	monsters_by_id: Dictionary,
	creature_book: Dictionary
) -> Dictionary:
	var battle_id := int(battle_record.get("id", -1))
	if battle_id < 0:
		return _error("Compiled Classic battle has no valid ID")
	var grid: Variant = battle_record.get("grid", [])
	if not (grid is Array) or grid.size() != CLASSIC_BATTLE_GRID_CELLS:
		return _error(
			"Classic battle %d must contain a %dx%d monster grid" % [
				battle_id,
				CLASSIC_BATTLE_GRID_SIZE,
				CLASSIC_BATTLE_GRID_SIZE,
			]
		)
	var creatures: Array = []
	for cell_index: int in range(grid.size()):
		var raw_monster_id := int(grid[cell_index])
		if raw_monster_id == 0:
			continue
		if creatures.size() >= CLASSIC_MAX_MONSTERS:
			return _error("Classic battle %d exceeds the 100-monster limit" % battle_id)
		var monster_id: int = abs(raw_monster_id)
		var monster: Variant = monsters_by_id.get(monster_id, {})
		if not (monster is Dictionary) or monster.is_empty():
			return _error(
				"Classic battle %d references missing monster %d" % [battle_id, monster_id]
			)
		var bestiary_name := resolve_classic_monster_bestiary_name(
			monster_id,
			monster,
			creature_book
		)
		if bestiary_name.is_empty():
			return _error(
				"Classic battle %d monster %d (%s) has no matching Remake bestiary entry" % [
					battle_id,
					monster_id,
					monster.get("displayName", "unnamed"),
				]
			)
		# Data BD stores cells in x-major order. Classic offsets the 13x13
		# formation by five tiles before applying its randomized distance.
		var x := floori(float(cell_index) / float(CLASSIC_BATTLE_GRID_SIZE))
		var y := cell_index % CLASSIC_BATTLE_GRID_SIZE
		creatures.append([
			bestiary_name,
			[x - CLASSIC_BATTLE_ORIGIN_OFFSET, y - CLASSIC_BATTLE_ORIGIN_OFFSET],
			_classic_battle_monster_metadata(monster_id, monster, raw_monster_id < 0),
		])
	return {
		"battle": {
			"Map": "temporary_zoomed_map",
			"Position": [0, 0],
			"is_relative_coords": 1,
			"bonus_distance": int(battle_record.get("dist", 0)),
			"Creatures": creatures,
			"Scripts": {},
			"battleMacro": int(battle_record.get("battleMacro", 0)),
			"classicBattleId": battle_id,
			"classicMessageBefore": int(battle_record.get("messageBefore", 0)),
			"classicMessageAfter": int(battle_record.get("messageAfter", 0)),
		},
		"creatureCount": creatures.size(),
	}


func _classic_monster_can_be_turned(monster: Dictionary) -> bool:
	var type_flags: Variant = monster.get("typeFlags", [])
	if not (type_flags is Array) or type_flags.size() < 3:
		return false
	# Data MD type slots 1 and 2 are undead and nether spawn respectively.
	return bool(type_flags[1]) or bool(type_flags[2])


func _combat_context() -> Dictionary:
	var state_machine: Object = _autoload("StateMachine")
	if state_machine == null or not state_machine.has_method("is_combat_state"):
		return {"error": "Realmz combat state is unavailable"}
	if not bool(state_machine.is_combat_state()):
		return {"error": "Classic combat command ran outside a battle"}
	var combat_state: Variant = state_machine.get("combat_state")
	var combatants: Variant = combat_state.get("all_battle_creatures_btns") \
		if combat_state is Object else null
	if not (combatants is Array):
		return {"error": "Realmz combat roster is unavailable"}
	return {
		"stateMachine": state_machine,
		"state": combat_state,
		"combatants": combatants,
	}


func select_classic_combatants(payload: Dictionary, combatants: Array) -> Array:
	var selected: Array = []
	var monster_id := int(payload.get("monsterId", -1))
	var monster_name_id := int(payload.get("monsterNameId", -1))
	var max_matches := int(payload.get("maxMatches", 0))
	var include_all_factions := bool(payload.get("includeAllFactions", false))
	if max_matches <= 0:
		return selected
	for combatant_value: Variant in combatants:
		var creature: Variant = _combatant_creature(combatant_value)
		if creature == null or not _is_living_combat_creature(creature):
			continue
		var identity_matches := _classic_monster_name_id(creature) == monster_name_id \
			if monster_name_id >= 0 else _classic_monster_id(creature) == monster_id
		if not identity_matches:
			continue
		if not include_all_factions and _combat_creature_faction(creature) == 0:
			continue
		selected.append(combatant_value)
		if selected.size() >= max_matches:
			break
	return selected


func select_classic_combatants_by_ids(monster_ids: Array, combatants: Array) -> Array:
	var selected: Array = []
	for combatant_value: Variant in combatants:
		var creature: Variant = _combatant_creature(combatant_value)
		if creature == null or not _is_living_combat_creature(creature):
			continue
		if monster_ids.has(_classic_monster_id(creature)):
			selected.append(combatant_value)
	return selected


func select_classic_combatants_by_ids_and_faction(
	monster_ids: Array,
	faction: int,
	combatants: Array
) -> Array:
	var selected: Array = []
	for combatant_value: Variant in combatants:
		var creature: Variant = _combatant_creature(combatant_value)
		if creature == null or not _is_living_combat_creature(creature):
			continue
		if _combat_creature_faction(creature) != faction:
			continue
		if monster_ids.has(_classic_monster_id(creature)):
			selected.append(combatant_value)
	return selected


func apply_classic_rout(combatants: Array, fleeing_trait: Script) -> int:
	for combatant_value: Variant in combatants:
		var creature: Variant = _combatant_creature(combatant_value)
		if not (creature is Object) or not creature.has_method("add_trait"):
			return -1
	for combatant_value: Variant in combatants:
		var creature: Object = _combatant_creature(combatant_value)
		creature.add_trait(fleeing_trait, [])
		CombatRoutRulesScript.mark_routed(creature)
	return combatants.size()


func remove_classic_combatants(combat_state: Variant, combatants: Array) -> int:
	if not (combat_state is Object) or not combat_state.has_method("remove_cb_from_battle"):
		return -1
	var defeated: Variant = combat_state.get("battle_dead_enemies")
	var removed := 0
	for combatant_value: Variant in combatants:
		var creature: Variant = _combatant_creature(combatant_value)
		if creature == null:
			continue
		if combat_state.has_method("queue_classic_death_macro"):
			combat_state.queue_classic_death_macro(creature)
		if combat_state.has_method("remove_registered_combatant"):
			combat_state.remove_registered_combatant(combatant_value)
			removed += 1
			continue
		if defeated is Array and _combat_creature_faction(creature) != 0:
			if not defeated.has(creature):
				defeated.append(creature)
		combat_state.remove_cb_from_battle(combatant_value)
		removed += 1
	return removed


func _combatant_creature(combatant: Variant) -> Variant:
	if combatant is Object or combatant is Dictionary:
		return combatant.get("creature")
	return null


func _is_living_combat_creature(creature: Variant) -> bool:
	if creature is Object and creature.has_method("get_stat"):
		return int(creature.get_stat("curHP")) > 0
	if creature is Dictionary:
		return int(creature.get("curHP", creature.get("currentHP", 0))) > 0
	return false


func _combat_creature_faction(creature: Variant) -> int:
	if creature is Object:
		return int(creature.get("curFaction"))
	if creature is Dictionary:
		return int(creature.get("curFaction", creature.get("faction", 0)))
	return 0


func _active_combat_faction(state_machine: Object) -> Variant:
	var decide_state: Variant = state_machine.get("cb_decide_state")
	var active_combatant: Variant = decide_state.get("current_active_creabutton") \
		if decide_state is Object else null
	var active_creature: Variant = _combatant_creature(active_combatant)
	if active_creature == null:
		return null
	return _combat_creature_faction(active_creature)


func _classic_spawn_origin(payload: Dictionary, state_machine: Object) -> Variant:
	var supplied: Variant = payload.get("actorPosition")
	if supplied is Vector2:
		return supplied
	if supplied is Vector2i:
		return Vector2(supplied)
	if supplied is Array and supplied.size() >= 2:
		return Vector2(float(supplied[0]), float(supplied[1]))
	var decide_state: Variant = state_machine.get("cb_decide_state")
	var active_combatant: Variant = decide_state.get("current_active_creabutton") \
		if decide_state is Object else null
	var active_creature: Variant = _combatant_creature(active_combatant)
	return active_creature.get("position") if active_creature is Object else null


func _classic_monster_id(creature: Variant) -> int:
	if creature is Object:
		if _object_has_property(creature, "classic_monster_id"):
			var property_id := int(creature.get("classic_monster_id"))
			if property_id >= 0:
				return property_id
		if creature.has_meta("classic_monster_id"):
			return int(creature.get_meta("classic_monster_id"))
		return _classic_monster_id_from_name(str(creature.get("name")))
	if creature is Dictionary:
		if creature.has("classicMonsterId"):
			return int(creature["classicMonsterId"])
		if creature.has("classic_monster_id"):
			return int(creature["classic_monster_id"])
		return _classic_monster_id_from_name(str(creature.get("name", "")))
	return -1


func _classic_monster_name_id(creature: Variant) -> int:
	if creature is Object:
		if _object_has_property(creature, "classic_monster_name_id"):
			var property_id := int(creature.get("classic_monster_name_id"))
			if property_id >= 0:
				return property_id
		if creature.has_meta("classic_monster_name_id"):
			return int(creature.get_meta("classic_monster_name_id"))
		return -1
	if creature is Dictionary:
		if creature.has("classicMonsterNameId"):
			return int(creature["classicMonsterNameId"])
		if creature.has("classic_monster_name_id"):
			return int(creature["classic_monster_name_id"])
		return -1
	return -1


func _set_classic_monster_identity(
	creature: Object,
	monster_id: int,
	monster: Dictionary
) -> void:
	var name_id := int(monster.get("nameId", -1))
	creature.set_meta("classic_monster_id", monster_id)
	creature.set_meta("classic_monster_name_id", name_id)
	creature.set_meta("classic_death_macro", int(monster.get("deathMacro", 0)))
	if _object_has_property(creature, "classic_monster_id"):
		creature.set("classic_monster_id", monster_id)
	if _object_has_property(creature, "classic_monster_name_id"):
		creature.set("classic_monster_name_id", name_id)


func _object_has_property(value: Object, property_name: String) -> bool:
	for property_value: Dictionary in value.get_property_list():
		if str(property_value.get("name", "")) == property_name:
			return true
	return false


func _classic_monster_id_from_name(creature_name: String) -> int:
	# The existing City of Bywater bestiary keeps the Classic ID as the final
	# word of each converted creature name, such as "Royal Guard 95".
	var words := creature_name.strip_edges().split(" ", false)
	if words.is_empty() or not words[-1].is_valid_int():
		return -1
	return int(words[-1])


func _add_classic_ally(payload: Dictionary) -> Dictionary:
	var game_global: Object = _autoload("GameGlobal")
	var player_allies: Variant = game_global.get("player_allies") if game_global != null else null
	if not (player_allies is Array):
		return _error("Realmz ally state is unavailable")
	if player_allies.size() >= 20:
		return {"status": "skipped", "message": "Classic ally limit of 20 has been reached"}
	var node_access: Object = _autoload("NodeAccess")
	var resources: Object = node_access.__Resources() if node_access != null else null
	var creature_book: Variant = resources.get("crea_book") if resources != null else null
	if not (creature_book is Dictionary):
		return _error("Realmz bestiary resources are unavailable")
	var monster: Variant = payload.get("monster", {})
	if not (monster is Dictionary):
		return _error("Classic ally command is missing its monster record")
	var monster_id := int(payload.get("monsterId", -1))
	var bestiary_name := resolve_classic_monster_bestiary_name(monster_id, monster, creature_book)
	if bestiary_name.is_empty():
		return _error("Classic ally %d (%s) has no matching Remake bestiary entry" % [
			monster_id,
			monster.get("displayName", "unnamed"),
		])
	var creature_script: Variant = game_global.get("combatCreatureGD")
	if not (creature_script is Script):
		return _error("Realmz creature script is unavailable")
	var ally: Object = creature_script.new()
	if not ally.has_method("initialize_from_bestiary_dict"):
		return _error("Realmz creature cannot load a bestiary entry")
	ally.initialize_from_bestiary_dict(bestiary_name)
	_set_classic_monster_identity(ally, monster_id, monster)
	game_global.add_npc_ally(ally)
	return {"name": str(ally.get("name")), "monsterId": monster_id}


func resolve_classic_monster_bestiary_name(
	monster_id: int,
	monster: Dictionary,
	creature_book: Dictionary
) -> String:
	var display_name := str(monster.get("displayName", ""))
	var name_matches: Array[String] = []
	for bestiary_key: Variant in creature_book:
		var entry: Variant = creature_book[bestiary_key]
		if not (entry is Dictionary):
			continue
		var data: Variant = entry.get("data", {})
		if not (data is Dictionary):
			continue
		var explicit_ids := _classic_resource_ids(entry, "classicMonsterId", "classicMonsterIds")
		explicit_ids.append_array(
			_classic_resource_ids(data, "classicMonsterId", "classicMonsterIds")
		)
		if not explicit_ids.is_empty():
			if explicit_ids.has(monster_id):
				return str(bestiary_key)
			continue
		var native_id: Variant = data.get("id")
		if native_id is int or native_id is float:
			if abs(int(native_id)) == monster_id:
				return str(bestiary_key)
		var native_name := str(data.get("name", bestiary_key))
		if not display_name.is_empty() and native_name.to_lower() == display_name.to_lower():
			name_matches.append(str(bestiary_key))
	return name_matches[0] if name_matches.size() == 1 else ""


func _present_random_branch(payload: Dictionary) -> Dictionary:
	_play_sound(payload)
	if int(payload.get("messageId", 0)) == 0:
		return {}
	return await _show_text(payload)


func _present_priest_turning(payload: Dictionary) -> Dictionary:
	_play_sound(payload)
	return await _show_text(payload)


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
			_append_complex_scroll_choice(
				encounter,
				payload.get("scenarioItems", []),
				choices,
				choice_tokens
			)
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
			if selected == "scroll":
				var scroll_result := await _select_complex_item(
					encounter,
					payload.get("itemTexts", []),
					payload.get("scenarioItems", []),
					"scroll"
				)
				if str(scroll_result.get("status", "")) == "cancelled":
					continue
				return scroll_result
			if selected == "item":
				var item_result := await _select_complex_item(
					encounter,
					payload.get("itemTexts", []),
					payload.get("scenarioItems", [])
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
		_append_complex_scroll_choice(
			encounter,
			payload.get("scenarioItems", []),
			choices,
			choice_tokens
		)
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
		if selected == "scroll":
			var scroll_result := await _select_complex_item(
				encounter,
				payload.get("itemTexts", []),
				payload.get("scenarioItems", []),
				"scroll"
			)
			if str(scroll_result.get("status", "")) == "cancelled":
				continue
			scroll_result["thiefEncounter"] = resolver.rogue_encounter.duplicate(true)
			return scroll_result
		if selected == "item":
			var item_result := await _select_complex_item(
				encounter,
				payload.get("itemTexts", []),
				payload.get("scenarioItems", [])
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
	spell_id_mapping: Dictionary,
	supported_spell_ids: Array = []
) -> int:
	var spell_ids: Variant = encounter.get("spellIds", [])
	var spell_results: Variant = encounter.get("spellResults", [])
	if not (spell_ids is Array) or not (spell_results is Array):
		return 4
	for index: int in range(min(spell_ids.size(), spell_results.size())):
		var spell_id := int(spell_ids[index])
		if spell_id > 0 and spell_id in supported_spell_ids:
			return int(spell_results[index])
		if spell_id > 0 and spell_id < 7 and spell_class == spell_id:
			return int(spell_results[index])
		if spell_id >= 1101:
			var mapped_name := _mapped_spell_name(spell_id, spell_id_mapping)
			if _normalized_spell_name(mapped_name) == _normalized_spell_name(spell_name) \
					and (supported_spell_ids.is_empty() or spell_id in supported_spell_ids):
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


func classic_spell_resource_supports_id(spell: Variant, spell_id: int) -> bool:
	if not (spell is Object) or not spell.has_method("supports_classic_spell_id"):
		return true
	return bool(spell.supports_classic_spell_id(spell_id))


func spell_effect_targets(target_mode: String, party: Array, selected: Array) -> Array:
	if target_mode == "party":
		return party.duplicate()
	if target_mode == "selected":
		return selected.duplicate()
	return []


func classic_field_spell_target_resolution(
	payload: Dictionary,
	character: Object,
	spell: Object,
	roll: int
) -> Dictionary:
	var save_index := int(spell.get("classic_spell_save_index"))
	var save_mode := str(spell.get("classic_spell_save_mode"))
	if not CLASSIC_FIELD_SPELL_SAVE_MODES.has(save_mode):
		return _error("Native spell has invalid Classic save metadata")
	if save_mode != "none" and not CLASSIC_SPELL_SAVE_STATS.has(save_index):
		return _error("Native spell has no Classic save type")
	if save_mode != "none" and not character.has_method("get_stat"):
		return _error("Classic field-spell target has no readable stats")

	var forced := bool(payload.get("forceAffect", false))
	var save_chance := 0.0
	if save_mode != "none":
		save_chance = clampf(
			_classic_spell_save_chance(character, save_index)
				+ int(payload.get("power", 0)) * int(payload.get("saveAdjustment", 0)),
			0.0,
			100.0
		)
	var saved := not forced and save_mode != "none" and roll <= save_chance
	var effect_scale := 1.0
	if saved:
		effect_scale = 0.5 if save_mode == "half_damage" else 0.0
	return {
		"character": character,
		"name": str(character.get("name")),
		"roll": roll,
		"saveChance": save_chance,
		"saved": saved,
		"forced": forced,
		"effectScale": effect_scale,
	}


func classic_custom_spell_target_resolution(
	payload: Dictionary,
	character: Object,
	spell: Object,
	resistance_roll: int,
	save_roll: int
) -> Dictionary:
	if not spell.is_generically_executable():
		return _error(
			"Classic custom spell %d uses unsupported special %d" % [
				int(spell.classic_spell_ids[0]),
				int(spell.classic_special),
			]
		)
	var save_index := int(spell.classic_spell_save_index)
	var save_mode := str(spell.classic_spell_save_mode)
	var check_resistance := bool(payload.get("checkResistance", false))
	var can_resist := int(spell.classic_cannot) != 1 and int(spell.classic_cannot) <= 2
	if (check_resistance and can_resist) or save_mode != "none":
		if not character.has_method("get_stat"):
			return _error("Classic custom-spell target has no readable stats")

	var power := int(payload.get("power", 0))
	var forced := bool(payload.get("forceAffect", false))
	var resistance_chance := 0.0
	if check_resistance and can_resist:
		resistance_chance = clampf(
			_classic_spell_save_chance(character, 6)
				+ power * int(spell.classic_resist_adjust),
			0.0,
			100.0
		)
	var resisted := not forced and check_resistance and can_resist \
		and resistance_roll <= resistance_chance

	var save_chance := 0.0
	if save_mode != "none":
		if not CLASSIC_SPELL_SAVE_STATS.has(save_index):
			return _error("Classic custom spell has no executable save type")
		save_chance = clampf(
			_classic_spell_save_chance(character, save_index)
				+ int(spell.classic_save_bonus)
				+ power * (
					int(spell.classic_save_adjust)
					+ int(payload.get("saveAdjustment", 0))
				),
			0.0,
			100.0
		)
	var saved := not forced and not resisted and save_mode != "none" \
		and save_roll <= save_chance
	var effect_scale := 0.0 if resisted else 1.0
	if saved:
		effect_scale = 0.5 if save_mode == "half_damage" else 0.0
	return {
		"character": character,
		"name": str(character.get("name")),
		"resistanceRoll": resistance_roll,
		"resistanceChance": resistance_chance,
		"resisted": resisted,
		"roll": save_roll,
		"saveChance": save_chance,
		"saved": saved,
		"forced": forced,
		"effectScale": effect_scale,
	}


func resolve_complex_item_result(
	encounter: Dictionary,
	item_name: String,
	item_id_mapping: Dictionary,
	item_texts: Array,
	classic_item_identity: Variant = 0
) -> int:
	var item_ids: Variant = encounter.get("itemIds", [])
	var item_results: Variant = encounter.get("itemResults", [])
	if not (item_ids is Array) or not (item_results is Array):
		return 4
	var normalized_item_name := _normalized_item_name(item_name)
	var classic_item_ids: Array[int] = []
	if classic_item_identity is Array:
		for classic_id_value: Variant in classic_item_identity:
			var classic_id: int = abs(int(classic_id_value))
			if classic_id != 0 and not classic_item_ids.has(classic_id):
				classic_item_ids.append(classic_id)
	else:
		var classic_id: int = abs(int(classic_item_identity))
		if classic_id != 0:
			classic_item_ids.append(classic_id)
	for index: int in range(min(item_ids.size(), item_results.size())):
		var item_id: int = abs(int(item_ids[index]))
		if item_id == 0:
			continue
		if classic_item_ids.has(item_id):
			return int(item_results[index])
		for candidate_name: String in _classic_item_names(
			item_id,
			item_id_mapping,
			item_texts
		):
			if _normalized_item_name(candidate_name) == normalized_item_name:
				return int(item_results[index])
	return 4


func resolve_complex_item_selection(
	encounter: Dictionary,
	item: Dictionary,
	item_id_mapping: Dictionary,
	item_texts: Array,
	scenario_items: Array
) -> Dictionary:
	var selection := classify_complex_item(item, scenario_items)
	if str(selection.get("status", "")) == "error":
		return selection
	selection["itemName"] = str(item.get("name", ""))
	match str(selection.get("mode", "item")):
		"item":
			# Ordinary encounter-response items are inspected, not consumed.
			selection["outcome"] = resolve_complex_item_result(
				encounter,
				str(item.get("name", "")),
				item_id_mapping,
				item_texts,
				_classic_item_ids(item)
			)
		"spell-item":
			var spell_response := _complex_spell_item_response(encounter, selection)
			if str(spell_response.get("status", "")) == "error":
				return spell_response
			selection.merge(spell_response, true)
			selection["consumeItem"] = true
		"door-activation":
			selection["outcome"] = 0
			selection["consumeItem"] = true
		_:
			return _error("Classic encounter item has an invalid response mode")
	return selection


func classify_complex_item(item: Dictionary, scenario_items: Array) -> Dictionary:
	var scenario_item := _matching_scenario_item(item, scenario_items)
	if not scenario_item.is_empty():
		var item_type := int(scenario_item.get("type", 0))
		var special1 := int(scenario_item.get("special1", 0))
		if item_type == 20:
			var spell_id: int = abs(int(scenario_item.get("special2", 0)))
			if spell_id == 0:
				return _error("Classic spell item has no spell ID")
			return {
				"mode": "spell-item",
				"spellId": spell_id,
				"spellPower": _classic_item_spell_power(special1),
			}
		if abs(item_type) == 23 or special1 == -23:
			var action_point_id: int = abs(int(scenario_item.get("special5", 0)))
			if action_point_id == 0:
				return _error("Classic door item has no Data ED3 action point")
			return {
				"mode": "door-activation",
				"doorActivationActionPointId": action_point_id,
			}

	for spell_field: String in ["_on_field_use_spell", "_on_combat_use_spell"]:
		var spell_value: Variant = item.get(spell_field, [])
		if not (spell_value is Array) or spell_value.size() < 2:
			continue
		var spell_identity := _native_item_spell_identity(str(spell_value[0]))
		if str(spell_identity.get("spellName", "")).is_empty():
			return _error("Encounter spell item has no native spell name")
		var response := {
			"mode": "spell-item",
			"spellName": str(spell_identity.get("spellName", "")),
			"spellPower": int(spell_value[1]),
		}
		var native_spell_id := int(spell_identity.get("spellId", 0))
		if native_spell_id != 0:
			response["spellId"] = native_spell_id
		return response

	return {"mode": "item"}


func is_complex_scroll_item(item: Dictionary, scenario_items: Array) -> bool:
	return str(item.get("type", "")).to_lower() == "scroll" \
		and str(classify_complex_item(item, scenario_items).get("mode", "")) == "spell-item"


func consume_complex_item(holder: Object, item: Dictionary) -> Dictionary:
	if holder == null:
		return _error("Classic encounter item has no owning character")
	var inventory: Variant = holder.get("inventory")
	if not (inventory is Array) or not inventory.has(item):
		return _error("Classic encounter item is no longer in its owner's inventory")
	var maximum_charges := int(item.get("charges_max", 0))
	if maximum_charges <= 0:
		return {"consumed": false, "remainingCharges": int(item.get("charges", 0))}
	var remaining_charges := int(item.get("charges", 0))
	if remaining_charges <= 0:
		return _error("Classic encounter item has no charges remaining")
	remaining_charges -= 1
	item["charges"] = remaining_charges
	var removed := remaining_charges == 0 and bool(item.get("delete_on_empty", false))
	if removed:
		inventory.erase(item)
	return {
		"consumed": true,
		"remainingCharges": remaining_charges,
		"removed": removed,
	}


func _matching_scenario_item(item: Dictionary, scenario_items: Array) -> Dictionary:
	var carried_ids := _classic_item_ids(item)
	if carried_ids.is_empty():
		return {}
	for scenario_item_value: Variant in scenario_items:
		if not (scenario_item_value is Dictionary):
			continue
		var item_id: int = abs(int(scenario_item_value.get("itemId", -1)))
		if item_id in carried_ids:
			return scenario_item_value
	return {}


func _classic_item_spell_power(raw_power: int) -> int:
	# Classic uses 8 as the sentinel for a random power from 1 through 7.
	return randi_range(1, 7) if abs(raw_power) == 8 else abs(raw_power)


func _native_item_spell_identity(label: String) -> Dictionary:
	var spell_name := label.strip_edges()
	var spell_id := 0
	var marker := spell_name.rfind(" (")
	if marker >= 0 and spell_name.ends_with(")"):
		var id_text := spell_name.substr(marker + 2, spell_name.length() - marker - 3)
		if id_text.is_valid_int():
			spell_id = abs(int(id_text))
			spell_name = spell_name.left(marker).strip_edges()
	return {"spellName": spell_name, "spellId": spell_id}


func _complex_spell_item_response(encounter: Dictionary, selection: Dictionary) -> Dictionary:
	var spell_id := int(selection.get("spellId", 0))
	var spell_name := str(selection.get("spellName", ""))
	var custom_spell: Variant = classic_spell_override(spell_id)
	if custom_spell != null:
		return {
			"outcome": resolve_complex_spell_result(
				encounter,
				str(custom_spell.get("name")),
				int(custom_spell.get("classic_spell_class")),
				{},
				custom_spell.get("classic_spell_ids")
			),
			"spellName": str(custom_spell.get("name")),
			"spellId": spell_id,
		}
	var spell_mapping: Dictionary = {}
	var spell_ids: Object = _autoload("SpellsIdDivinity")
	if spell_ids != null and spell_ids.mappings is Dictionary:
		spell_mapping = spell_ids.mappings
	if spell_name.is_empty() and spell_id != 0:
		spell_name = _mapped_spell_name(spell_id, spell_mapping)
	if spell_name.is_empty():
		return _error("Classic spell item has no Remake spell mapping")
	var spell: Variant = _loaded_spell(spell_name)
	if spell == null:
		return _error("Mapped spell '%s' is not loaded" % spell_name)
	var spell_class := int(spell.get("classic_spell_class")) \
		if spell.get("classic_spell_class") != null else 0
	var supported_spell_ids: Array = spell.get("classic_spell_ids") \
		if spell.get("classic_spell_ids") is Array else []
	return {
		"outcome": resolve_complex_spell_result(
			encounter,
			spell_name,
			spell_class,
			spell_mapping,
			supported_spell_ids
		),
		"spellName": spell_name,
		"spellId": spell_id,
	}


func _classic_item_ids(item: Dictionary) -> Array[int]:
	var ids := _classic_resource_ids(item, "classicItemId", "classicItemIds")
	if ids.is_empty() and item.has("classic_item_id"):
		ids.append(abs(int(item["classic_item_id"])))
	return ids


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


func _append_complex_scroll_choice(
	encounter: Dictionary,
	scenario_items: Variant,
	choices: Array,
	tokens: Array
) -> void:
	if not _has_complex_spell_responses(encounter):
		return
	var available_scenario_items: Array = scenario_items if scenario_items is Array else []
	if not _party_has_complex_scroll(available_scenario_items):
		return
	choices.append("Use a scroll")
	tokens.append("scroll")


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


func _party_has_complex_scroll(scenario_items: Array) -> bool:
	for character_value: Variant in _party_characters():
		if not _can_select_item(character_value):
			continue
		var inventory: Variant = character_value.get("inventory")
		for item_value: Variant in inventory:
			if not (item_value is Dictionary):
				continue
			if is_complex_scroll_item(item_value, scenario_items):
				return true
	return false


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
	var supported_spell_ids: Array = spell.get("classic_spell_ids") \
		if spell.get("classic_spell_ids") is Array else []
	return {
		"outcome": resolve_complex_spell_result(
			encounter,
			str(spell.get("name")),
			spell_class,
			spell_mapping,
			supported_spell_ids
		),
		"spellName": str(spell.get("name")),
		"spellPower": power,
	}


func _select_complex_item(
	encounter: Dictionary,
	item_texts: Variant,
	scenario_items: Variant,
	required_mode := ""
) -> Dictionary:
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
	var picked_holder: Variant = item_menu.picked_character
	if not (picked_holder is Object):
		picked_holder = holder
	var item_ids: Object = _autoload("ItemIdDivinity")
	var item_mapping: Dictionary = item_ids.mapping if item_ids != null else {}
	var response_item_texts: Array = item_texts if item_texts is Array else []
	var available_scenario_items: Array = scenario_items if scenario_items is Array else []
	var response := resolve_complex_item_selection(
		encounter,
		item,
		item_mapping,
		response_item_texts,
		available_scenario_items
	)
	if str(response.get("status", "")) == "error":
		return response
	if required_mode == "scroll" and not is_complex_scroll_item(item, available_scenario_items):
		return {"status": "cancelled"}
	if bool(response.get("consumeItem", false)):
		var consumption := consume_complex_item(picked_holder, item)
		if str(consumption.get("status", "")) == "error":
			return consumption
		response["itemConsumption"] = consumption
	return response


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


func _loaded_spell(spell_name: String) -> Variant:
	var node_access: Object = _autoload("NodeAccess")
	var resources: Object = node_access.__Resources() if node_access != null else null
	if resources == null or not resources.spells_book.has(spell_name):
		return null
	var spell_entry: Variant = resources.spells_book[spell_name]
	if spell_entry is Dictionary:
		return spell_entry.get("script")
	return spell_entry


func _normalized_spell_name(spell_name: String) -> String:
	var normalized := spell_name.strip_edges().to_lower()
	if normalized == "discover magic i":
		return "discover magic"
	return normalized


func _classic_resource_ids(
	resource: Dictionary,
	singular_field: String,
	plural_field: String
) -> Array[int]:
	var ids: Array[int] = []
	if resource.has(singular_field):
		ids.append(abs(int(resource[singular_field])))
	var plural_value: Variant = resource.get(plural_field, [])
	if plural_value is Array:
		for id_value: Variant in plural_value:
			var resource_id: int = abs(int(id_value))
			if not ids.has(resource_id):
				ids.append(resource_id)
	return ids


func _classic_item_names(
	item_id: int,
	item_id_mapping: Dictionary,
	item_texts: Array,
	item_book: Dictionary = {}
) -> Array[String]:
	var names: Array[String] = []
	for item_key: Variant in item_book:
		var item_value: Variant = item_book[item_key]
		if not (item_value is Dictionary):
			continue
		if _classic_resource_ids(item_value, "classicItemId", "classicItemIds").has(item_id):
			names.append(str(item_key))
	var mapped_name := str(item_id_mapping.get(
		item_id,
		item_id_mapping.get(str(item_id), "")
	))
	if not mapped_name.is_empty() and not names.has(mapped_name):
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
	var party := _party_characters()
	var damage_result := apply_rogue_trap_damage(
		trap,
		character,
		party
	)
	if str(damage_result.get("status", "")) == "error":
		return damage_result
	var spell_result: Dictionary = {}
	var spell_request := rogue_trap_spell_request(trap, character, party)
	if not spell_request.is_empty():
		spell_result = await _apply_classic_spell_to_targets(
			spell_request.get("payload", {}),
			spell_request.get("targets", [])
		)
		if str(spell_result.get("status", "")) == "error":
			return spell_result
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
	return {"spellResult": spell_result}


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


func rogue_trap_spell_request(
	trap: Dictionary,
	selected_character: Object,
	party: Array
) -> Dictionary:
	var spell_id := int(trap.get("spellId", 0))
	if spell_id == 0:
		return {}
	return {
		"payload": {
			"spellId": spell_id,
			"power": int(trap.get("spellPower", 0)),
			"saveAdjustment": 0,
			"forceAffect": false,
		},
		"targets": [selected_character] if bool(trap.get("rogueOnly", false)) \
			else party.duplicate(),
	}


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

	var item_texts: Variant = payload.get("itemTexts", [])
	var response_item_texts: Array = item_texts if item_texts is Array else []

	var item_names: Array[String] = []
	for item_id_value: Variant in item_ids:
		var item_id: int = abs(int(item_id_value))
		if item_id == 0:
			continue
		var item_name := ""
		for candidate: String in _classic_item_names(
			item_id, item_id_mapping, response_item_texts, available_items
		):
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
		for candidate: String in _classic_item_names(
			item_id, item_id_mapping, item_texts, available_items
		):
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
	for item_value: Variant in available_items.values():
		if not (item_value is Dictionary):
			continue
		for item_id: int in _classic_resource_ids(
			item_value, "classicItemId", "classicItemIds"
		):
			candidate_ids[item_id] = true
	for item_text_value: Variant in item_texts:
		if item_text_value is Dictionary:
			candidate_ids[abs(int(item_text_value.get("itemId", 0)))] = true

	var accepted_names: Dictionary = {}
	for item_id_value: Variant in candidate_ids.keys():
		var item_id := int(item_id_value)
		if item_id == 0 or not classic_shop_accepts_item_id(item_id, accept_ranges):
			continue
		for item_name: String in _classic_item_names(
			item_id, item_id_mapping, item_texts, available_items
		):
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


func _take_party_wealth(payload: Dictionary) -> Dictionary:
	var game_global: Object = _autoload("GameGlobal")
	if game_global == null:
		return _error("Realmz game state is unavailable")
	var pooled_money: Variant = game_global.money_pool
	if not (pooled_money is Array):
		return _error("Realmz pooled wealth is unavailable")
	var party := _party_characters()
	var result: Dictionary = InventoryRulesScript.take_party_currency(
		party,
		pooled_money,
		int(payload.get("currency", -1)),
		int(payload.get("amount", -1))
	)
	if str(result.get("status", "")) == "error":
		return result
	if bool(result.get("paid", false)):
		_refresh_party_panels(party)
	else:
		result["warningId"] = int(payload.get("warningId", 0))
	return result


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
	var node_access: Object = _autoload("NodeAccess")
	var resources: Object = node_access.__Resources() if node_access != null else null
	var item_book: Dictionary = resources.items_book \
		if resources != null and resources.items_book is Dictionary else {}
	var item_texts: Variant = payload.get("itemTexts", [])
	return _classic_item_names(
		abs(int(payload.get("itemId", 0))),
		item_mapping,
		item_texts if item_texts is Array else [],
		item_book
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


func _apply_coward_penalty(payload: Dictionary) -> Dictionary:
	var text_rect: Object = _text_rect()
	if text_rect == null:
		return _error("Realmz HUD TextRect is unavailable for the Classic coward penalty")

	await text_rect.set_text(CLASSIC_COWARD_RETREAT_MESSAGE, true)
	var sound_result := _play_sound(payload)
	await text_rect.set_text(CLASSIC_COWARD_EXPERIENCE_MESSAGE, true)

	var party := _party_characters()
	var result := apply_classic_coward_experience_penalty(
		party,
		int(payload.get("experiencePerLevel", 0))
	)
	_refresh_party_panels(party)
	result["warningIds"] = payload.get("warningIds", []).duplicate()
	result["soundResult"] = sound_result
	if bool(payload.get("backUpParty", false)):
		var retreat_result := retreat_classic_party(
			_autoload("GameGlobal"),
			payload.get("entryMovement")
		)
		for retreat_key: Variant in retreat_result:
			result[retreat_key] = retreat_result[retreat_key]
	else:
		result["partyBackedUp"] = false
		result["backUpReason"] = "Classic does not retreat the party in dungeons"
	return result


func apply_classic_coward_experience_penalty(
	party: Array,
	experience_per_level: int
) -> Dictionary:
	var per_level := maxi(0, experience_per_level)
	var characters_affected := 0
	var experience_removed := 0
	for character_value: Variant in party:
		if not (character_value is Object):
			continue
		if not _object_has_property(character_value, "level") \
			or not _object_has_property(character_value, "exp_tnl"):
			continue
		var penalty := per_level * maxi(0, int(character_value.get("level")))
		if penalty == 0:
			continue
		character_value.set("exp_tnl", int(character_value.get("exp_tnl")) + penalty)
		characters_affected += 1
		experience_removed += penalty
	return {
		"charactersAffected": characters_affected,
		"experiencePerLevel": per_level,
		"experienceRemoved": experience_removed,
	}


func retreat_classic_party(game_global: Object, movement_value: Variant) -> Dictionary:
	if game_global == null:
		return {
			"partyBackedUp": false,
			"backUpReason": "Realmz game state is unavailable",
		}
	var movement := _classic_overworld_movement(movement_value)
	if movement == Vector2i.ZERO:
		return {
			"partyBackedUp": false,
			"backUpReason": "Classic battle entry movement is unavailable",
		}
	var map: Variant = game_global.get("map")
	if not (map is Object):
		return {
			"partyBackedUp": false,
			"backUpReason": "Realmz overworld map is unavailable",
		}
	var overworld_character: Variant = map.get("owcharacter")
	if not (overworld_character is Object) \
		or not _object_has_property(overworld_character, "tile_position_x") \
		or not _object_has_property(overworld_character, "tile_position_y"):
		return {
			"partyBackedUp": false,
			"backUpReason": "Realmz overworld party position is unavailable",
		}
	var previous_position := Vector2i(
		int(overworld_character.get("tile_position_x")),
		int(overworld_character.get("tile_position_y"))
	)
	var target_position := previous_position - movement
	var moved_characters: Array = []
	for property_name: String in ["focuscharacter", "owcharacter"]:
		var character: Variant = map.get(property_name)
		if character is Object and character.has_method("set_tile_position") \
			and not moved_characters.has(character):
			character.set_tile_position(Vector2(target_position))
			moved_characters.append(character)
	if moved_characters.is_empty():
		return {
			"partyBackedUp": false,
			"backUpReason": "Realmz overworld party cannot be repositioned",
		}
	if map.has_method("explore_tiles_from_tilepos"):
		map.explore_tiles_from_tilepos(target_position)
	return {
		"partyBackedUp": true,
		"entryMovement": movement,
		"fromPosition": previous_position,
		"position": target_position,
	}


func _classic_overworld_movement(value: Variant) -> Vector2i:
	var movement := Vector2i.ZERO
	if value is Vector2i:
		movement = value
	elif value is Vector2:
		movement = Vector2i(value)
	elif value is Array and value.size() >= 2:
		movement = Vector2i(int(value[0]), int(value[1]))
	if absi(movement.x) > 1 or absi(movement.y) > 1:
		return Vector2i.ZERO
	return movement


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
		var node_access: Object = _autoload("NodeAccess")
		var resources: Object = node_access.__Resources() if node_access != null else null
		var item_book: Dictionary = resources.items_book \
			if resources != null and resources.items_book is Dictionary else {}
		var item_texts: Variant = payload.get("itemTexts", [])
		var names := _classic_item_names(
			abs(int(payload.get("value", 0))),
			item_mapping,
			item_texts if item_texts is Array else [],
			item_book
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


func _give_character_condition(payload: Dictionary) -> Dictionary:
	var result: Dictionary = CharacterConditionRulesScript.apply_condition(
		_party_characters(),
		_current_selected_characters(),
		str(payload.get("targetMode", "")),
		int(payload.get("conditionIndex", -1)),
		int(payload.get("duration", 0))
	)
	if str(result.get("status", "")) == "error":
		return result
	var affected_characters: Array = result.get("affectedCharacters", [])
	for character_value: Variant in affected_characters:
		_play_sound({"soundId": int(payload.get("soundId", 0))})
		_refresh_character_panel(character_value)
	result.erase("affectedCharacters")
	return result


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
	return await _apply_classic_spell_to_targets(payload, targets)


func _apply_classic_spell_to_targets(payload: Dictionary, targets: Array) -> Dictionary:
	if targets.is_empty():
		return _error("Classic spell command has no targets")

	var spell_ids: Object = _autoload("SpellsIdDivinity")
	var spell_id_mapping: Dictionary = spell_ids.mappings \
		if spell_ids != null and spell_ids.mappings is Dictionary else {}
	var spell_id := int(payload.get("spellId", 0))
	var custom_spell: Variant = classic_spell_override(spell_id)
	if custom_spell != null and custom_spell.is_generically_executable():
		return await _apply_custom_spell_to_targets(payload, targets, custom_spell)
	var spell_name := _mapped_spell_name(spell_id, spell_id_mapping)
	if spell_name.is_empty():
		if custom_spell != null:
			return _error(
				"Classic custom spell %d uses unsupported special %d" % [
					spell_id,
					int(custom_spell.classic_special),
				]
			)
		return _error("Classic spell %d has no Remake mapping" % spell_id)
	var spell: Variant = _loaded_spell(spell_name)
	if spell == null:
		return _error("Mapped spell '%s' has no executable resource" % spell_name)
	if not classic_spell_resource_supports_id(spell, spell_id):
		return _error(
			"Mapped spell '%s' does not support Classic spell %d" % [spell_name, spell_id]
		)

	var script_helper: Object = _autoload("ScriptHelperFuncs")
	if script_helper == null:
		return _error("Realmz spell helper is unavailable")
	var resolutions: Array = []
	var affected_count := 0
	for target: Variant in targets:
		if not (target is Object):
			return _error("Classic field-spell target is not a character")
		var resolution := classic_field_spell_target_resolution(
			payload,
			target,
			spell,
			randi_range(1, 100)
		)
		if str(resolution.get("status", "")) == "error":
			return resolution
		resolutions.append(resolution)
		var effect_scale := float(resolution.get("effectScale", 0.0))
		if effect_scale <= 0.0:
			continue
		affected_count += 1
		await script_helper.CastSpellOnPickedCharacters(
			[target],
			spell_name,
			int(payload.get("power", 0)),
			effect_scale
		)
	for target: Variant in targets:
		_refresh_character_panel(target)
	return {
		"spellName": spell_name,
		"targetCount": targets.size(),
		"affectedCount": affected_count,
		"resolutions": resolutions,
	}


func _apply_custom_spell_to_targets(
	payload: Dictionary,
	targets: Array,
	spell: Object
) -> Dictionary:
	if not spell.is_generically_executable():
		return _error(
			"Classic custom spell %d uses unsupported special %d" % [
				int(spell.classic_spell_ids[0]),
				int(spell.classic_special),
			]
		)
	var script_helper: Object = _autoload("ScriptHelperFuncs")
	if script_helper == null:
		return _error("Realmz spell helper is unavailable")
	var resolutions: Array = []
	var affected_count := 0
	for target: Variant in targets:
		if not (target is Object):
			return _error("Classic custom-spell target is not a character")
		var resolution := classic_custom_spell_target_resolution(
			payload,
			target,
			spell,
			randi_range(1, 100),
			randi_range(1, 100)
		)
		if str(resolution.get("status", "")) == "error":
			return resolution
		resolutions.append(resolution)
		var effect_scale := float(resolution.get("effectScale", 0.0))
		if effect_scale <= 0.0:
			continue
		affected_count += 1
		await script_helper.ApplySpellOnPickedCharacters(
			[target],
			spell,
			int(payload.get("power", 0)),
			effect_scale
		)
	for target: Variant in targets:
		_refresh_character_panel(target)
	return {
		"spellName": str(spell.name),
		"spellId": int(spell.classic_spell_ids[0]),
		"custom": true,
		"targetCount": targets.size(),
		"affectedCount": affected_count,
		"resolutions": resolutions,
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


func _picture_rect() -> Object:
	var ui: Object = _autoload("UI")
	if ui == null or ui.ow_hud == null:
		return null
	return ui.ow_hud.pictureRect


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
