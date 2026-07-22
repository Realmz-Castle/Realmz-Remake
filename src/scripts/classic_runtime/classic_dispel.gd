class_name ClassicDispel
extends RefCounted

const TEMPORARY_TRAIT_PREFIX := "t_"
const CHARM_TRAITS := ["t_charmed.gd", "t_classic_charmed.gd"]


static func apply(target: Object) -> Dictionary:
	if target == null or not target.has_method("remove_trait"):
		return {"status": "invalid-target", "removed": []}
	var traits: Variant = _property_value(target, "traits")
	if not (traits is Array):
		return {"status": "invalid-target", "removed": []}

	var party_character := bool(_property_value(target, "is_player_controlled", false))
	var removed: Array[String] = []
	for trait_value: Variant in traits.duplicate():
		if not (trait_value is Object):
			continue
		# Trait identity is conventionally a script constant, so it does not
		# appear in get_property_list() even though Object.get() resolves it.
		var trait_name := str(trait_value.get("name"))
		if not trait_name.begins_with(TEMPORARY_TRAIT_PREFIX):
			continue
		# Classic stores allegiance outside the condition array. Destroy Magic
		# resets it for party characters, but not for monsters.
		if not party_character and trait_name in CHARM_TRAITS:
			continue
		target.remove_trait(trait_value)
		removed.append(trait_name)

	if party_character:
		var base_faction: Variant = _property_value(target, "baseFaction")
		if base_faction != null and _has_property(target, "curFaction"):
			target.set("curFaction", int(base_faction))
	return {"status": "applied", "removed": removed}


static func _property_value(value: Object, property_name: String, fallback = null):
	if not _has_property(value, property_name):
		return fallback
	return value.get(property_name)


static func _has_property(value: Object, property_name: String) -> bool:
	for property: Dictionary in value.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true
	return false
