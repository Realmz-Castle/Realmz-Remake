class_name ClassicCoreProtectionSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const ProtectionTraits := {
	12: preload("res://shared_assets/traits/t_prot_fire.gd"),
	13: preload("res://shared_assets/traits/t_prot_ice.gd"),
	14: preload("res://shared_assets/traits/t_prot_elect.gd"),
	15: preload("res://shared_assets/traits/t_prot_chem.gd"),
	16: preload("res://shared_assets/traits/t_prot_mental.gd"),
}
const PermanentTraitNames := {
	12: "p_prot_fire.gd",
	13: "p_prot_ice.gd",
	14: "p_prot_elect.gd",
	15: "p_prot_chem.gd",
	16: "p_prot_mental.gd",
}
const ProtectionLabels := {
	12: "fire",
	13: "cold",
	14: "electrical",
	15: "chemical",
	16: "mental",
}
const ProtectionElements := {
	12: GameGlobal.ELEMENTS.FIRE,
	13: GameGlobal.ELEMENTS.ICE,
	14: GameGlobal.ELEMENTS.ELECTRIC,
	15: GameGlobal.ELEMENTS.CHEMICAL,
	16: GameGlobal.ELEMENTS.MENTAL,
}


func configure_core_protection_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic protection spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_protection_record(record):
		push_error("Classic spell %d is not a damage protection record" % spell_id)
		return false
	_configure_core_record(inventory, record)
	var protection_code := absi(int(record.get("special", 0)))
	elements = [ProtectionElements[protection_code]]
	attributes = ["Magical"]
	tags = ["Magical", "Protection", ProtectionLabels[protection_code].capitalize()]
	description = _protection_description(protection_code)
	return true


func apply_classic_scaled_effect(
	_caster,
	target,
	power: int,
	effect_scale: float
) -> int:
	if effect_scale <= 0.0:
		return 0
	var duration := get_duration_roll(power, _caster)
	return duration if _apply_duration(target, duration) else 0


# resolvespell.c rolls once before iterating every target in the cast.
func apply_classic_group_effect(
	_caster,
	targets: Array,
	power: int,
	effect_scale := 1.0
) -> int:
	if effect_scale <= 0.0 or targets.is_empty():
		return 0
	var duration := get_duration_roll(power, _caster)
	var affected := 0
	for target: Variant in targets:
		if _apply_duration(target, duration):
			affected += 1
	return affected


func _apply_duration(target: Variant, duration: int) -> bool:
	if duration <= 0 or not (target is Object) or not target.has_method("add_trait"):
		return false
	var traits: Variant = target.get("traits")
	if not (traits is Array):
		return false
	var temporary_trait: GDScript = ProtectionTraits.get(classic_special)
	if temporary_trait == null:
		return false
	var temporary_name := temporary_trait.resource_path.get_file()
	var permanent_name := str(PermanentTraitNames.get(classic_special, ""))
	var current_duration := 0
	for trait_value: Variant in traits:
		if not (trait_value is Object):
			continue
		var trait_name := str(trait_value.get("name"))
		if trait_name == permanent_name:
			return false
		if trait_name == temporary_name:
			var duration_seconds: Variant = trait_value.get("duration")
			if duration_seconds == null:
				return false
			current_duration = ceili(float(duration_seconds) / 5.0)
	var condition_cap := 99 if _is_player_character(target) else 124
	if current_duration + duration > condition_cap:
		return false
	target.add_trait(temporary_trait, [duration])
	return true


func _is_player_character(target: Object) -> bool:
	return target is PlayerCharacter or bool(target.get("is_player_controlled"))


func _is_protection_record(record: Dictionary) -> bool:
	var protection_code := absi(int(record.get("special", 0)))
	if not ProtectionTraits.has(protection_code) \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or absi(int(record.get("damageType", 0))) != 8 \
			or absi(int(record.get("spellClass", 0))) != 8 \
			or int(record.get("cannot", 0)) not in [3, 4] \
			or not bool(record.get("inCombat", 0)) \
			or not bool(record.get("inCamp", 0)) \
			or int(record.get("targetType", -1)) not in [0, 9]:
		return false
	for field_name: String in ["damage1", "damage2", "powerDamage1", "powerDamage2"]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return int(record.get("duration1", 0)) > 0 \
		or int(record.get("powerDuration1", 0)) > 0


func _protection_description(protection_code: int) -> String:
	var duration_text := "%d-%d rounds" % [_duration_low, _duration_high]
	if _power_duration_low > 0:
		duration_text = "%d-%d rounds per power" % [
			_power_duration_low,
			_power_duration_high,
		]
	return "%s: Halves %s damage for %s." % [
		name,
		ProtectionLabels[protection_code],
		duration_text,
	]
