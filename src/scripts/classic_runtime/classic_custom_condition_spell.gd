class_name ClassicCustomConditionSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const CharacterConditionRulesScript = preload(
	"res://scripts/classic_runtime/classic_character_condition_rules.gd"
)
const AreaPatternsScript = preload(
	"res://scripts/classic_runtime/classic_spell_area_patterns.gd"
)
const PoisonScript = preload(
	"res://scripts/classic_runtime/classic_poison.gd"
)

const TERRAIN_TEXTURE_BY_QUEUE_ICON := {
	4: "Web",
	5: "Trg",
	6: "Yfr",
	7: "Gcl",
	8: "Bcl",
	9: "ClassicQueue9",
	10: "ClassicQueue10",
	11: "Spn",
	12: "Slm",
	13: "Spr",
	14: "Bal",
	15: "Orb",
	16: "Thn",
}

var classic_condition_index := -1
var _shared_duration := 0
var _has_shared_duration := false


func configure_custom_condition_spell(record: Dictionary) -> bool:
	var special := absi(int(record.get("special", 0)))
	var condition_index := 1 if special in [53, 54] else special - 1
	if (special not in range(1, 41) and special not in [53, 54]) \
			or not CharacterConditionRulesScript.supports_condition(condition_index) \
			or not bool(record.get("inCombat", false)):
		return false
	var has_duration := _has_nonzero_field(
		record,
		["duration1", "duration2", "powerDuration1", "powerDuration2"]
	)
	var has_damage := _has_nonzero_field(
		record,
		["damage1", "damage2", "powerDamage1", "powerDamage2"]
	)
	if not has_duration and not has_damage:
		return false
	if int(record.get("queueIcon", 0)) > 0 \
			and not TERRAIN_TEXTURE_BY_QUEUE_ICON.has(int(record["queueIcon"])):
		return false

	classic_condition_index = condition_index
	_configure_custom_record(record)
	var condition_name := CharacterConditionRulesScript.condition_name(condition_index)
	if not tags.has(condition_name):
		tags.append(condition_name)
	if classic_queue_icon > 0:
		terrain_tex = str(TERRAIN_TEXTURE_BY_QUEUE_ICON[classic_queue_icon])
		terrain_walk_type = 0
		if not tags.has("Terrain"):
			tags.append("Terrain")
	description = "%s: Applies Classic's %s condition%s." % [
		name,
		condition_name,
		" and its authored damage" if has_damage else "",
	]
	return true


func is_generically_executable() -> bool:
	return classic_condition_index >= 0


func begin_classic_target_resolution(caster, power: int) -> void:
	_shared_duration = get_duration_roll(power, caster)
	_has_shared_duration = true


func end_classic_target_resolution() -> void:
	_shared_duration = 0
	_has_shared_duration = false


func add_traits_to_creature(caster, target, power: int) -> void:
	var duration := _shared_duration if _has_shared_duration \
		else get_duration_roll(power, caster)
	var applied := _apply_condition_duration(target, duration)
	match classic_special:
		2, 53, 54:
			if applied:
				_consume_remaining_actions(target)
			_consume_remaining_movement(target)
		3, 7:
			_halve_remaining_movement(target)
		10:
			if not PoisonScript._can_retain_spell_condition(target):
				CharacterConditionRulesScript.set_condition_value(
					target,
					classic_condition_index,
					0
				)


func get_aoe(power: int, _caster) -> Array[Vector2i]:
	if classic_target_type in [3, 4]:
		return AreaPatternsScript.pattern(
			power if classic_target_type == 4 else classic_size
		)
	return super.get_aoe(power, _caster)


func is_classic_queued_spell() -> bool:
	return classic_queue_icon > 0


func _apply_condition_duration(target: Variant, duration: int) -> bool:
	if duration == 0 or not (target is Object):
		return false
	var current := CharacterConditionRulesScript.condition_value(
		target,
		classic_condition_index
	)
	if current < 0:
		return false
	var combined := current + duration
	var player_controlled := target is PlayerCharacter \
		or bool(target.get("is_player_controlled"))
	if (player_controlled and combined >= 100) \
			or (not player_controlled and absi(combined) >= 125):
		return false
	var result: Dictionary = CharacterConditionRulesScript.set_condition_value(
		target,
		classic_condition_index,
		combined
	)
	return str(result.get("status", "")) != "error"


func _consume_remaining_movement(target: Variant) -> void:
	if not (target is Object) or not target.has_method("get_movement_left") \
			or not _has_property(target, "used_movepoints"):
		return
	target.set(
		"used_movepoints",
		int(target.get("used_movepoints"))
			+ maxi(0, int(target.call("get_movement_left")))
	)


func _consume_remaining_actions(target: Variant) -> void:
	if not (target is Object) or not target.has_method("get_apr_left") \
			or not _has_property(target, "used_apr"):
		return
	target.set(
		"used_apr",
		int(target.get("used_apr")) + maxi(0, int(target.call("get_apr_left")))
	)


func _halve_remaining_movement(target: Variant) -> void:
	if not (target is Object) or not target.has_method("get_movement_left") \
			or not _has_property(target, "used_movepoints"):
		return
	var remaining := maxi(0, int(target.call("get_movement_left")))
	target.set(
		"used_movepoints",
		int(target.get("used_movepoints")) + ceili(float(remaining) / 2.0)
	)


func _has_nonzero_field(record: Dictionary, field_names: Array[String]) -> bool:
	for field_name: String in field_names:
		if int(record.get(field_name, 0)) != 0:
			return true
	return false


func _has_property(target: Object, property_name: String) -> bool:
	for property: Dictionary in target.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true
	return false
