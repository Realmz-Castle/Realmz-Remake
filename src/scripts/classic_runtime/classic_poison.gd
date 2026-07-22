class_name ClassicPoison
extends RefCounted

const AnimationScript = preload(
	"res://scripts/classic_runtime/classic_animation.gd"
)
const SECONDS_PER_HOUR := 3600
const SPELL_IMMUNITIES_META_KEY := "classic_spell_immunities"
const TEMPORARY_TRAIT_NAME := "t_poison.gd"
const PERMANENT_TRAIT_NAME := "p_poison.gd"


static func player_reduction(power: int) -> Dictionary:
	return {
		"power": max(0, power - 1),
		"damage": absi(power),
	}


static func monster_reduction(power: int) -> Dictionary:
	var remaining: int = max(0, power - 1)
	return {
		"power": remaining,
		"damage": remaining,
	}


static func elapsed_hour_boundaries(previous_time: int, current_time: int) -> int:
	if current_time <= previous_time:
		return 0
	var previous_hour := int(floor(float(previous_time) / SECONDS_PER_HOUR))
	var current_hour := int(floor(float(current_time) / SECONDS_PER_HOUR))
	return max(0, current_hour - previous_hour)


static func elapsed_time_pass_hour_boundaries(seconds: int) -> int:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return 0
	var state_machine: Node = tree.root.get_node_or_null("StateMachine")
	if state_machine != null and bool(state_machine.call("is_combat_state")):
		return 0
	var game_global: Node = tree.root.get_node_or_null("GameGlobal")
	if game_global == null:
		return 0
	var current_time := int(game_global.get("time"))
	var scaled_seconds := roundi(seconds * float(game_global.get("time_scale")))
	return elapsed_hour_boundaries(current_time - scaled_seconds, current_time)


static func is_player_character(character: Object) -> bool:
	return character is PlayerCharacter or bool(character.get("is_player_controlled"))


static func can_take_damage(character: Object) -> bool:
	if character == null or not character.has_method("get_stat") \
			or int(character.get_stat("curHP")) <= 0:
		return false
	if is_player_character(character):
		return not AnimationScript.is_permanently_animated(character)
	return not AnimationScript.is_animated(character)


static func apply_spell_condition(
	character: Object,
	power: int,
	permanent_trait: GDScript
) -> bool:
	if character == null or power <= 0 or permanent_trait == null \
			or not character.has_method("add_trait") \
			or not character.has_method("remove_trait"):
		return false
	var traits: Variant = character.get("traits")
	if not (traits is Array):
		return false

	# The source resolver writes Poison into one signed condition slot. A new
	# permanent value replaces temporary poison but never replaces an existing
	# permanent value.
	var has_permanent := false
	for trait_value: Variant in traits.duplicate():
		if not (trait_value is Object):
			continue
		var trait_name := str(trait_value.get("name"))
		if trait_name == PERMANENT_TRAIT_NAME:
			has_permanent = true
		elif trait_name == TEMPORARY_TRAIT_NAME:
			character.remove_trait(trait_value)

	# Poison's special handler clears the condition from animated targets and
	# from monsters with mental-class immunity after direct damage is resolved.
	if not _can_retain_spell_condition(character):
		_clear_permanent_poison(character)
		return false
	if has_permanent:
		return false
	character.add_trait(permanent_trait, [power])
	return true


static func _can_retain_spell_condition(character: Object) -> bool:
	if is_player_character(character):
		return not AnimationScript.is_permanently_animated(character)
	if AnimationScript.is_animated(character):
		return false
	if not character.has_meta(SPELL_IMMUNITIES_META_KEY):
		return true
	var immunities: Variant = character.get_meta(SPELL_IMMUNITIES_META_KEY)
	return not (immunities is Array and immunities.size() > 5 \
		and int(immunities[5]) != 0)


static func _clear_permanent_poison(character: Object) -> void:
	var traits: Array = character.get("traits")
	for trait_value: Variant in traits.duplicate():
		if trait_value is Object \
				and str(trait_value.get("name")) == PERMANENT_TRAIT_NAME:
			character.remove_trait(trait_value)
