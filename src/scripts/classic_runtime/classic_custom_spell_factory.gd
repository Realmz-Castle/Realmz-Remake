class_name ClassicCustomSpellFactory
extends RefCounted

const SpellOverrideScript = preload(
	"res://scripts/classic_runtime/classic_spell_override.gd"
)
const LethalSpellScript = preload(
	"res://scripts/classic_runtime/classic_core_lethal_spell.gd"
)
const CharmSpellScript = preload(
	"res://scripts/classic_runtime/classic_core_charm_spell.gd"
)
const ConditionSpellScript = preload(
	"res://scripts/classic_runtime/classic_custom_condition_spell.gd"
)
const HealingSpellScript = preload(
	"res://scripts/classic_runtime/classic_core_healing_spell.gd"
)
const SpellPointSurgeScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_point_surge_spell.gd"
)
const SupportScript = preload(
	"res://scripts/classic_runtime/classic_custom_spell_support.gd"
)


static func create(record: Dictionary, spell_id := 0) -> Variant:
	var source := SupportScript.normalize_record(record)
	if spell_id != 0:
		source["packedSpellId"] = abs(spell_id)
	match SupportScript.kind(source):
		SupportScript.CONDITION:
			var condition = ConditionSpellScript.new()
			if condition.configure_custom_condition_spell(source):
				return condition
		SupportScript.LETHAL:
			var lethal = LethalSpellScript.new()
			if lethal.configure_custom_lethal_spell(source):
				return lethal
		SupportScript.CHARM:
			var charm = CharmSpellScript.new()
			if charm.configure_custom_charm_spell(source):
				return charm
		SupportScript.HEALING:
			var healing = HealingSpellScript.new()
			if healing.configure_custom_healing_spell(source):
				return healing
		SupportScript.SPELL_POINT_SURGE:
			var surge = SpellPointSurgeScript.new()
			if surge.configure_custom_spell_point_surge(source):
				return surge
	var generic = SpellOverrideScript.new()
	generic.configure(source)
	return generic


static func is_executable(record: Dictionary, spell_id := 0) -> bool:
	var source := record.duplicate(true)
	if spell_id != 0:
		source["packedSpellId"] = abs(spell_id)
	return SupportScript.is_executable(source)
