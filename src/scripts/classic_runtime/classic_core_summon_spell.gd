class_name ClassicCoreSummonSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const SummoningScript = preload("res://scripts/classic_runtime/classic_summoning.gd")

var classic_summon_tier := 0
var _pending_choice: Dictionary = {}
var _pending_caster_id := 0
var _pending_targets := 0


func configure_core_summon_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic summon %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_summon_record(record):
		push_error("Classic spell %d is not a supported special-58 summon" % spell_id)
		return false

	_configure_core_record(inventory, record)
	classic_summon_tier = SummoningScript.resolved_tier(
		spell_id,
		int(record.get("size", 0))
	)
	targettile = TARGET_TILE.EMPTY
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	description = "%s: Summons a tier %d creature to fight for the caster." % [
		name,
		classic_summon_tier,
	]
	return true


func get_aoe(_power: int, _caster) -> Array[Vector2i]:
	return [Vector2i.ZERO]


func summon_choice(bestiary: Dictionary, selection_index := -1) -> Dictionary:
	return SummoningScript.choose_candidate(bestiary, classic_summon_tier, selection_index)


func place_summon(
	caster: Object,
	target_position: Vector2i,
	creature: Object,
	combat_state: Object,
	destination_open := true
) -> Dictionary:
	if int(combat_state.get("classic_monster_slots_used")) >= SummoningScript.MAX_MONSTER_SLOTS:
		return {"status": "monster-limit"}
	if not destination_open:
		return {"status": "blocked-destination"}
	if not combat_state.has_method("add_pc_or_npc_ally_to_battle_map"):
		return {"status": "missing-combat-placement"}

	SummoningScript.apply_summon_identity(creature, caster)
	creature.set("position", Vector2(target_position))
	if not bool(combat_state.add_pc_or_npc_ally_to_battle_map(
		creature,
		Vector2(target_position)
	)):
		return {"status": "placement-failed"}
	combat_state.set(
		"classic_monster_slots_used",
		int(combat_state.get("classic_monster_slots_used")) + 1
	)
	var initiative: Variant = combat_state.get("battle_creatures_yet_to_act_btns")
	var combat_button: Variant = creature.get("combat_button")
	if initiative is Array and combat_button != null and not initiative.has(combat_button):
		initiative.append(combat_button)
	return {"status": "summoned", "creature": creature}


func special_effect(
	caster,
	_spell,
	power: int,
	main_targeted_tile,
	_effected_tiles,
	_effected_creatures,
	_add_terrain
) -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	var resources: Node = tree.root.get_node_or_null("Main/Resources") \
		if tree != null else null
	var bestiary: Variant = resources.get("crea_book") if resources != null else null
	var state_machine: Node = tree.root.get_node_or_null("StateMachine") \
		if tree != null else null
	var combat_state: Variant = state_machine.get("combat_state") \
		if state_machine != null else null
	if not (bestiary is Dictionary) or not (combat_state is Object):
		push_warning("%s could not access the active combat bestiary" % name)
		return true

	var choice := _choice_for_cast(bestiary, caster, power)
	if str(choice.get("status", "")) != "selected":
		push_warning("%s found no summonable creature (%s)" % [name, choice.get("status", "unknown")])
		return true
	var creature_script: GDScript = load("res://Creature/Creature.gd")
	var creature = creature_script.new()
	creature.initialize_from_bestiary_dict(
		str(choice["bestiaryKey"]),
		GameGlobal.classic_monster_generation_context("summon")
	)
	var target := Vector2i(main_targeted_tile)
	var destination_open := _destination_is_open(combat_state, creature, target)
	var result := place_summon(caster, target, creature, combat_state, destination_open)
	if str(result.get("status", "")) != "summoned":
		push_warning("%s summon failed: %s" % [name, result.get("status", "unknown")])
	return true


func _choice_for_cast(bestiary: Dictionary, caster: Object, power: int) -> Dictionary:
	var caster_id := caster.get_instance_id()
	if _pending_targets <= 0 or _pending_caster_id != caster_id:
		_pending_choice = summon_choice(bestiary)
		_pending_caster_id = caster_id
		_pending_targets = maxi(1, power)
	_pending_targets -= 1
	return _pending_choice


func _destination_is_open(combat_state: Object, creature: Object, target: Vector2i) -> bool:
	if not combat_state.has_method("is_map_tile_walkable_by_char"):
		return false
	var tree := Engine.get_main_loop() as SceneTree
	var game_global: Node = tree.root.get_node_or_null("GameGlobal") \
		if tree != null else null
	if game_global == null or not game_global.has_method("who_is_at_tile"):
		return false
	var size := Vector2i(creature.get("size"))
	for x: int in range(maxi(1, size.x)):
		for y: int in range(maxi(1, size.y)):
			var occupied_tile := Vector2(target + Vector2i(x, y))
			if not combat_state.is_map_tile_walkable_by_char(creature, occupied_tile) \
					or game_global.who_is_at_tile(occupied_tile) != null:
				return false
	return true


func _is_summon_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 58 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("targetType", -1)) != 0 \
			or int(record.get("damageType", 0)) != 0 \
			or int(record.get("spellClass", 0)) != 0 \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)):
		return false
	for field_name: String in [
		"damage1", "damage2", "powerDamage1", "powerDamage2",
		"duration1", "duration2", "powerDuration1", "powerDuration2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return true
