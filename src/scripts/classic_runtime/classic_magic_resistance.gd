class_name ClassicMagicResistance
extends RefCounted

const SpellScreenScript = preload("res://scripts/classic_runtime/classic_spell_screen.gd")
const META_KEY := "classic_magic_resistance"
const ITEM_FIELD := "classicMagicResistance"
const RESIST_IGNORE_DODGE := 2
const RESIST_IGNORE_NOTHING := 3


static func normalize_item_data(
	item_data: Dictionary,
	canonical_item: Dictionary = {}
) -> Dictionary:
	var normalized := item_data.duplicate(true)
	var stats: Dictionary = normalized.get("stats", {}).duplicate(true)
	if normalized.has(ITEM_FIELD):
		normalized[ITEM_FIELD] = int(normalized[ITEM_FIELD])
		stats.erase("ClassicMagicResistance")
	elif stats.has("ClassicMagicResistance"):
		normalized[ITEM_FIELD] = int(stats["ClassicMagicResistance"])
		stats.erase("ClassicMagicResistance")
	elif stats.has("EvasionMagic") and canonical_item.has(ITEM_FIELD):
		# Saves created before the compatibility field existed used native magic
		# evasion for these catalog items. The current catalog proves which items
		# own Classic's all-or-nothing percentage.
		normalized[ITEM_FIELD] = int(stats["EvasionMagic"])
		stats.erase("EvasionMagic")
	if normalized.has("stats"):
		normalized["stats"] = stats
	return normalized


static func base_value(character: Object) -> int:
	if character == null or not character.has_meta(META_KEY):
		return 0
	return int(character.get_meta(META_KEY))


static func equipped_modifier(character: Object) -> int:
	if character == null:
		return 0
	var inventory: Variant = character.get("inventory")
	if not (inventory is Array):
		return 0
	var modifier := 0
	for item_value: Variant in inventory:
		if not (item_value is Dictionary):
			continue
		if int(item_value.get("equipped", 0)) != 1:
			continue
		modifier += int(item_value.get(ITEM_FIELD, 0))
	return modifier


static func chance(character: Object, power: int = 0, resist_adjust: int = 0) -> int:
	return clampi(
		base_value(character) + equipped_modifier(character) + power * resist_adjust,
		0,
		100
	)


static func spell_uses_resistance(spell: Object, classic_context := false) -> bool:
	if spell == null:
		return false
	if not classic_context:
		var classic_spell_ids: Variant = spell.get("classic_spell_ids")
		if not (classic_spell_ids is Array) or classic_spell_ids.is_empty():
			return false
	var resist_mode := int(spell.get("resist"))
	return resist_mode == RESIST_IGNORE_DODGE or resist_mode == RESIST_IGNORE_NOTHING


static func custom_spell_uses_resistance(spell: Object) -> bool:
	if spell == null:
		return false
	var spell_class := int(spell.get("classic_spell_class"))
	var cannot := int(spell.get("classic_cannot"))
	return abs(spell_class) != 9 and cannot != 1 and cannot <= 2


static func spell_resolution(
	character: Object,
	spell: Object,
	power: int,
	roll: int,
	classic_context := false,
	caster: Object = null
) -> Dictionary:
	var screen: Dictionary = SpellScreenScript.spell_resolution(character, spell, caster)
	if bool(screen.get("resisted", false)):
		return {
			"checksResistance": false,
			"checksScreen": true,
			"screenLevel": int(screen.get("screenLevel", 0)),
			"spellLevel": int(screen.get("spellLevel", 0)),
			"chance": 0,
			"roll": roll,
			"resisted": true,
			"reason": "spell-screen",
		}
	var checks_resistance := spell_uses_resistance(spell, classic_context)
	var resistance_chance := 0
	if checks_resistance:
		resistance_chance = chance(
			character,
			power,
			int(spell.get("classic_resist_adjust"))
		)
	return {
		"checksResistance": checks_resistance,
		"checksScreen": bool(screen.get("checksScreen", false)),
		"screenLevel": int(screen.get("screenLevel", 0)),
		"spellLevel": int(screen.get("spellLevel", 0)),
		"chance": resistance_chance,
		"roll": roll,
		"resisted": checks_resistance and roll <= resistance_chance,
		"reason": "magic-resistance" \
			if checks_resistance and roll <= resistance_chance else "",
	}


static func custom_spell_resolution(
	character: Object,
	spell: Object,
	power: int,
	roll: int,
	caster: Object = null
) -> Dictionary:
	var screen: Dictionary = SpellScreenScript.spell_resolution(character, spell, caster)
	if bool(screen.get("resisted", false)):
		return {
			"checksResistance": false,
			"checksScreen": true,
			"screenLevel": int(screen.get("screenLevel", 0)),
			"spellLevel": int(screen.get("spellLevel", 0)),
			"chance": 0,
			"roll": roll,
			"resisted": true,
			"reason": "spell-screen",
		}
	var checks_resistance := custom_spell_uses_resistance(spell)
	var resistance_chance := 0
	if checks_resistance:
		resistance_chance = chance(
			character,
			power,
			int(spell.get("classic_resist_adjust"))
		)
	return {
		"checksResistance": checks_resistance,
		"checksScreen": bool(screen.get("checksScreen", false)),
		"screenLevel": int(screen.get("screenLevel", 0)),
		"spellLevel": int(screen.get("spellLevel", 0)),
		"chance": resistance_chance,
		"roll": roll,
		"resisted": checks_resistance and roll <= resistance_chance,
		"reason": "magic-resistance" \
			if checks_resistance and roll <= resistance_chance else "",
	}
