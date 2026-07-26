class_name ClassicMonsterTransformation
extends RefCounted

const PRESERVED_PROPERTIES: Array[String] = [
	"combat_button",
	"position",
	"dirfaced",
	"selected",
	"baseFaction",
	"curFaction",
	"reaction_ready",
	"used_movepoints",
	"used_apr",
	"used_spr",
	"has_turned_undead",
	"terrain_already_crossed_this_turn",
	"is_summoned",
	"summoner",
	"summoner_name",
	"joins_combat",
]
const PRESERVED_CLASSIC_CONDITION_METADATA: Array[String] = [
	"classic_regeneration_per_round",
	"classic_spell_screen_level",
]


static func transform(target: Object) -> bool:
	if not is_legal_target(target):
		return false
	var tree := Engine.get_main_loop() as SceneTree
	var resources: Node = tree.root.get_node_or_null("Main/Resources") \
		if tree != null else null
	if not (resources is Object):
		return false
	var bestiary: Variant = resources.get("crea_book")
	if not (bestiary is Dictionary):
		return false
	var form_key := choose_form(bestiary, Vector2i(target.get("size")))
	if form_key.is_empty():
		return false
	var creature_script: GDScript = load("res://Creature/Creature.gd")
	if creature_script == null:
		return false
	var replacement = creature_script.new()
	replacement.initialize_from_bestiary_dict(
		form_key,
		GameGlobal.classic_monster_generation_context("transformation")
	)
	return apply_form(target, replacement)


static func candidate_keys(bestiary: Dictionary, target_size: Vector2i) -> Array[String]:
	var native_candidates: Array[String] = []
	var classic_candidates: Array[String] = []
	var has_classic_set := false
	for key_value: Variant in bestiary:
		var entry: Variant = bestiary[key_value]
		if not (entry is Dictionary):
			continue
		var is_classic_entry := _has_classic_identity(entry)
		has_classic_set = has_classic_set or is_classic_entry
		var data: Variant = entry.get("data", {})
		if not (data is Dictionary):
			continue
		var size_value: Variant = data.get("size", [])
		if not (size_value is Array) or size_value.size() < 2:
			continue
		var candidate_size := Vector2i(int(size_value[0]), int(size_value[1]))
		if candidate_size != target_size \
				or int(data.get("summonable", 0)) != 1 \
				or int(data.get("level", 0)) <= 0:
			continue
		var key := str(key_value)
		native_candidates.append(key)
		if is_classic_entry:
			classic_candidates.append(key)
	native_candidates.sort()
	classic_candidates.sort()
	# Loaded campaign bestiaries are merged over the shared book. When Classic
	# records are present, they represent the active Data MD set used by Realmz.
	return classic_candidates if has_classic_set else native_candidates


static func choose_form(
	bestiary: Dictionary,
	target_size: Vector2i,
	selection_index := -1
) -> String:
	var candidates := candidate_keys(bestiary, target_size)
	if candidates.is_empty():
		return ""
	var index := randi_range(0, candidates.size() - 1) \
		if selection_index < 0 else selection_index % candidates.size()
	return candidates[index]


static func is_legal_target(target: Variant) -> bool:
	if not (target is Object) \
			or not target.has_method("initialize_from_bestiary_dict") \
			or not _has_property(target, "size") \
			or _has_property(target, "icon"):
		return false
	if _has_property(target, "life_status") and int(target.get("life_status")) != 0:
		return false
	return true


static func apply_form(target: Object, replacement: Object) -> bool:
	if not _has_property(target, "size") or not _has_property(replacement, "size"):
		return false
	if Vector2i(target.get("size")) != Vector2i(replacement.get("size")):
		return false

	var old_form := str(target.get("bestiary_key")) \
		if _has_property(target, "bestiary_key") else str(target.get("name"))
	var new_form := str(replacement.get("bestiary_key")) \
		if _has_property(replacement, "bestiary_key") else str(replacement.get("name"))
	var preserved := {}
	for property_name: String in PRESERVED_PROPERTIES:
		if _has_property(target, property_name) and _has_property(replacement, property_name):
			preserved[property_name] = _copy_value(target.get(property_name))
	var active_conditions := _active_condition_traits(target)
	var classic_condition_metadata := {}
	for meta_name: String in PRESERVED_CLASSIC_CONDITION_METADATA:
		if target.has_meta(meta_name):
			classic_condition_metadata[meta_name] = _copy_value(target.get_meta(meta_name))

	for property: Dictionary in replacement.get_property_list():
		var property_name := str(property.get("name", ""))
		if property_name.is_empty() or PRESERVED_PROPERTIES.has(property_name) \
				or (int(property.get("usage", 0)) & PROPERTY_USAGE_SCRIPT_VARIABLE) == 0 \
				or not _has_property(target, property_name):
			continue
		target.set(property_name, _copy_value(replacement.get(property_name)))
	for property_name: String in preserved:
		target.set(property_name, preserved[property_name])

	_merge_active_conditions(target, active_conditions)
	if _has_property(target, "money"):
		target.set("money", [0, 0, 0])
	_copy_classic_metadata(replacement, target)
	for meta_name: String in classic_condition_metadata:
		target.set_meta(meta_name, classic_condition_metadata[meta_name])
	target.set_meta("classic_transformed_from", old_form)
	target.set_meta("classic_transformed_form", new_form)

	var combat_button: Variant = target.get("combat_button") \
		if _has_property(target, "combat_button") else null
	if is_instance_valid(combat_button) and combat_button.has_method("set_creature_represented"):
		combat_button.set_creature_represented(target)
	return true


static func _active_condition_traits(target: Object) -> Array:
	var result: Array = []
	if not _has_property(target, "traits"):
		return result
	var traits_value: Variant = target.get("traits")
	if not (traits_value is Array):
		return result
	for trait_value: Variant in traits_value:
		if not (trait_value is Object):
			continue
		var source := str(trait_value.get("trait_source")) \
			if _has_property(trait_value, "trait_source") else ""
		if source == "Innate" or source.begins_with("Equipment :"):
			continue
		result.append(trait_value)
	return result


static func _merge_active_conditions(target: Object, active_conditions: Array) -> void:
	if not _has_property(target, "traits"):
		return
	var merged: Array = target.get("traits") if target.get("traits") is Array else []
	for condition: Variant in active_conditions:
		var condition_name := str(condition.get("name")) if condition is Object else ""
		for index: int in range(merged.size() - 1, -1, -1):
			var form_trait: Variant = merged[index]
			if form_trait is Object and str(form_trait.get("name")) == condition_name:
				merged.remove_at(index)
		merged.append(condition)
	for trait_value: Variant in merged:
		if trait_value is Object and _has_property(trait_value, "chara"):
			trait_value.set("chara", target)
	target.set("traits", merged)


static func _copy_classic_metadata(source: Object, target: Object) -> void:
	for meta_name: StringName in target.get_meta_list():
		if str(meta_name).begins_with("classic_"):
			target.remove_meta(meta_name)
	for meta_name: StringName in source.get_meta_list():
		if str(meta_name).begins_with("classic_"):
			target.set_meta(meta_name, _copy_value(source.get_meta(meta_name)))


static func _has_classic_identity(entry: Dictionary) -> bool:
	if entry.has("classicMonsterId"):
		var monster_id := int(entry["classicMonsterId"])
		if monster_id >= 0 and monster_id < 200:
			return true
	var ids: Variant = entry.get("classicMonsterIds", [])
	if ids is Array:
		for id_value: Variant in ids:
			var monster_id := int(id_value)
			if monster_id >= 0 and monster_id < 200:
				return true
	return false


static func _copy_value(value: Variant) -> Variant:
	if value is Dictionary or value is Array:
		return value.duplicate(true)
	return value


static func _has_property(value: Object, property_name: String) -> bool:
	for property: Dictionary in value.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true
	return false
