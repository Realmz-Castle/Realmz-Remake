class_name ClassicMagicResistance
extends RefCounted

const SpellScreenScript = preload("res://scripts/classic_runtime/classic_spell_screen.gd")
const SpellSavesScript = preload("res://scripts/classic_runtime/classic_spell_saves.gd")
const AnimationScript = preload("res://scripts/classic_runtime/classic_animation.gd")
const ProjectileProtectionScript = preload(
	"res://scripts/classic_runtime/classic_projectile_protection.gd"
)
const META_KEY := "classic_magic_resistance"
const SPELL_IMMUNITIES_META_KEY := "classic_spell_immunities"
const CLASSIC_HIT_DICE_META_KEY := "classic_hit_dice"
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
	var stable_inventory := character.has_method("inventory_instances")
	var inventory: Variant = character.inventory_instances() \
		if stable_inventory else _property_value(character, "inventory")
	if not (inventory is Array):
		return 0
	var modifier := 0
	for item_value: Variant in inventory:
		if item_value is ItemInstance:
			if not item_value.equipped:
				continue
			var definition := NodeAccess.__Resources().get_item_definition(
				item_value
			)
			if definition != null:
				modifier += definition.classic_magic_resistance()
			continue
		# Installed pre-M6 campaign characters and adapter test doubles may still
		# expose their old dictionary inventory. Convert only the Classic field
		# needed by this compatibility rule; live Creature inventories take the
		# stable branch above.
		if stable_inventory or not (item_value is Dictionary):
			continue
		var legacy_item: Dictionary = item_value
		if not bool(legacy_item.get("equipped", 0)):
			continue
		if legacy_item.has(ITEM_FIELD):
			modifier += int(legacy_item[ITEM_FIELD])
		elif legacy_item.get("stats", {}) is Dictionary:
			modifier += int(
				legacy_item.get("stats", {}).get("ClassicMagicResistance", 0)
			)
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
	caster: Object = null,
	pre_resistance_roll: int = -1,
	party_charm_bonus: int = 0
) -> Dictionary:
	var early_roll := pre_resistance_roll if pre_resistance_roll >= 0 else roll
	var early: Dictionary = pre_resistance_resolution(
		character, spell, power, early_roll, caster, classic_context, party_charm_bonus
	)
	if str(early.get("status", "")) == "error" or bool(early.get("resisted", false)):
		return _early_stop_result(early, roll)
	if spell_class_immunity(character, spell):
		return _with_early_result({
			"checksResistance": false,
			"checksScreen": false,
			"checksClassImmunity": true,
			"checksProjectileProtection": false,
			"chance": 0,
			"roll": roll,
			"resisted": true,
			"reason": "spell-class-immunity",
		}, early)
	var screen := {
		"checksScreen": false,
		"screenLevel": 0,
		"spellLevel": 0,
		"resisted": false,
	}
	# Classic class-9 missiles clear the accumulated spell-screen result before
	# their projectile-protection and dodge check.
	if abs(int(spell.get("classic_spell_class"))) != 9:
		screen = SpellScreenScript.spell_resolution(character, spell, caster)
	if bool(screen.get("resisted", false)):
		return _with_early_result({
			"checksResistance": false,
			"checksScreen": true,
			"checksClassImmunity": false,
			"checksProjectileProtection": false,
			"screenLevel": int(screen.get("screenLevel", 0)),
			"spellLevel": int(screen.get("spellLevel", 0)),
			"chance": 0,
			"roll": roll,
			"resisted": true,
			"reason": "spell-screen",
		}, early)
	if animated_spell_immunity(character, spell, classic_context):
		return _with_early_result({
			"checksResistance": false,
			"checksScreen": bool(screen.get("checksScreen", false)),
			"checksClassImmunity": false,
			"checksAnimatedImmunity": true,
			"checksProjectileProtection": false,
			"chance": 0,
			"roll": roll,
			"resisted": true,
			"reason": "animated-immunity",
		}, early)
	var projectile_protection: Dictionary = ProjectileProtectionScript.spell_resolution(
		character, spell
	)
	if bool(projectile_protection.get("resisted", false)):
		return _with_early_result({
			"checksResistance": false,
			"checksScreen": bool(screen.get("checksScreen", false)),
			"checksClassImmunity": false,
			"checksAnimatedImmunity": false,
			"checksProjectileProtection": true,
			"screenLevel": int(screen.get("screenLevel", 0)),
			"spellLevel": int(screen.get("spellLevel", 0)),
			"chance": 0,
			"roll": roll,
			"resisted": true,
			"reason": "projectile-protection",
		}, early)
	var checks_resistance := spell_uses_resistance(spell, classic_context)
	var resistance_chance := 0
	if checks_resistance:
		resistance_chance = chance(
			character,
			power,
			int(spell.get("classic_resist_adjust"))
		)
	var resisted := checks_resistance and roll <= resistance_chance
	return _with_early_result({
		"checksResistance": checks_resistance,
		"checksScreen": bool(screen.get("checksScreen", false)),
		"checksClassImmunity": false,
		"checksAnimatedImmunity": false,
		"checksProjectileProtection": bool(
			projectile_protection.get("checksProjectileProtection", false)
		),
		"screenLevel": int(screen.get("screenLevel", 0)),
		"spellLevel": int(screen.get("spellLevel", 0)),
		"chance": resistance_chance,
		"roll": roll,
		"resisted": resisted,
		"reason": "magic-resistance" if resisted else "",
	}, early)


static func pre_resistance_resolution(
	character: Object,
	spell: Object,
	power: int,
	roll: int,
	caster: Object,
	classic_context := false,
	party_charm_bonus: int = 0
) -> Dictionary:
	var early: Dictionary
	if spell_uses_charm_resistance(spell, classic_context):
		early = charm_resistance_resolution(
			character, spell, power, roll, classic_context, party_charm_bonus
		)
		early["mode"] = "charm-resistance"
	else:
		early = opposed_level_resolution(character, spell, power, roll, caster)
		early["mode"] = "opposed-level" \
			if bool(early.get("checksOpposedLevel", false)) else ""
	return early


static func _early_stop_result(early: Dictionary, resistance_roll: int) -> Dictionary:
	var unavailable := str(early.get("status", "")) == "error"
	var reason := str(early.get("mode", ""))
	var result := {
		"checksResistance": false,
		"checksScreen": false,
		"checksClassImmunity": false,
		"checksAnimatedImmunity": false,
		"checksProjectileProtection": false,
		"chance": 0,
		"roll": resistance_roll,
		"resisted": true,
		"reason": reason + "-unavailable" if unavailable else reason,
	}
	if unavailable:
		result["status"] = "error"
		result["message"] = str(
			early.get("message", "Classic pre-resistance check failed")
		)
	return _with_early_result(result, early)


static func _with_early_result(result: Dictionary, early: Dictionary) -> Dictionary:
	var mode := str(early.get("mode", ""))
	result["checksCharmResistance"] = mode == "charm-resistance"
	result["checksOpposedLevel"] = mode == "opposed-level"
	result["charmChance"] = int(early.get("chance", 0)) \
		if mode == "charm-resistance" else 0
	result["charmRoll"] = int(early.get("roll", 0)) \
		if mode == "charm-resistance" else 0
	result["opposedChance"] = int(early.get("chance", 0)) \
		if mode == "opposed-level" else 0
	result["opposedRoll"] = int(early.get("roll", 0)) \
		if mode == "opposed-level" else 0
	return result


static func charm_resistance_resolution(
	character: Object,
	spell: Object,
	power: int,
	roll: int,
	classic_context := false,
	party_charm_bonus: int = 0
) -> Dictionary:
	if not spell_uses_charm_resistance(spell, classic_context):
		return {
			"checksCharmResistance": false,
			"chance": 0,
			"roll": roll,
			"resisted": false,
		}
	if character == null:
		return {
			"status": "error",
			"message": "Classic charm resistance requires a target",
			"checksCharmResistance": true,
			"chance": 0,
			"roll": roll,
			"resisted": false,
		}

	var resistance_chance: Variant = _classic_monster_charm_chance(character)
	if resistance_chance == null:
		if not character.has_method("get_stat"):
			return {
				"status": "error",
				"message": "Classic charm resistance requires readable target saves",
				"checksCharmResistance": true,
				"chance": 0,
				"roll": roll,
				"resisted": false,
			}
		resistance_chance = int(SpellSavesScript.save_chance_for(character, 0))
	resistance_chance = int(resistance_chance) \
		+ power * int(spell.get("classic_save_adjust")) \
		+ party_charm_bonus
	return {
		"checksCharmResistance": true,
		"chance": int(resistance_chance),
		"roll": roll,
		"resisted": roll <= int(resistance_chance),
	}


static func spell_uses_charm_resistance(spell: Object, classic_context := false) -> bool:
	return _is_classic_spell(spell, classic_context) \
		and int(spell.get("classic_spell_class")) == 0


static func spell_uses_pre_resistance(spell: Object, classic_context := false) -> bool:
	if spell_uses_charm_resistance(spell, classic_context):
		return true
	return spell != null \
		and spell.has_method("uses_classic_opposed_level_check") \
		and bool(spell.uses_classic_opposed_level_check())


static func animated_spell_immunity(
	character: Object,
	spell: Object,
	classic_context := false
) -> bool:
	if character == null or not _is_classic_spell(spell, classic_context):
		return false
	if int(spell.get("classic_spell_class")) not in [0, 5]:
		return false
	return AnimationScript.is_animated(character)


static func spell_class_immunity(character: Object, spell: Object) -> bool:
	if character == null or spell == null \
			or not character.has_meta(SPELL_IMMUNITIES_META_KEY):
		return false
	var spell_class := int(spell.get("classic_spell_class"))
	if spell_class < 0 or spell_class >= 6:
		return false
	var immunities: Variant = character.get_meta(SPELL_IMMUNITIES_META_KEY)
	return immunities is Array and spell_class < immunities.size() \
		and int(immunities[spell_class]) != 0


static func opposed_level_resolution(
	character: Object,
	spell: Object,
	power: int,
	roll: int,
	caster: Object
) -> Dictionary:
	var checks_opposed := spell != null \
		and spell.has_method("uses_classic_opposed_level_check") \
		and bool(spell.uses_classic_opposed_level_check())
	if not checks_opposed:
		return {
			"checksOpposedLevel": false,
			"chance": 0,
			"roll": roll,
			"resisted": false,
		}
	if character == null or caster == null:
		return {
			"status": "error",
			"message": "Classic opposed-level spell resolution requires caster and target",
			"checksOpposedLevel": true,
			"chance": 0,
			"roll": roll,
			"resisted": false,
		}
	var target_level: Variant = _combat_level(character)
	var caster_level: Variant = _combat_level(caster)
	if target_level == null or caster_level == null:
		return {
			"status": "error",
			"message": "Classic opposed-level spell resolution requires readable levels",
			"checksOpposedLevel": true,
			"chance": 0,
			"roll": roll,
			"resisted": false,
		}

	# Negative Classic damage types check target level against caster level before
	# spell screens, general resistance, and the ordinary damage-type save.
	var chance := 35 + 5 * int(target_level) - 5 * int(caster_level)
	chance += power * int(spell.get("classic_save_adjust"))
	return {
		"checksOpposedLevel": true,
		"chance": chance,
		"roll": roll,
		"resisted": roll <= chance,
	}


static func custom_spell_resolution(
	character: Object,
	spell: Object,
	power: int,
	roll: int,
	caster: Object = null,
	pre_resistance_roll: int = -1,
	party_charm_bonus: int = 0
) -> Dictionary:
	var early_roll := pre_resistance_roll if pre_resistance_roll >= 0 else roll
	var early: Dictionary = charm_resistance_resolution(
		character, spell, power, early_roll, true, party_charm_bonus
	)
	early["mode"] = "charm-resistance" \
		if bool(early.get("checksCharmResistance", false)) else ""
	if str(early.get("status", "")) == "error" or bool(early.get("resisted", false)):
		return _early_stop_result(early, roll)
	if spell_class_immunity(character, spell):
		return _with_early_result({
			"checksResistance": false,
			"checksScreen": false,
			"checksClassImmunity": true,
			"checksProjectileProtection": false,
			"chance": 0,
			"roll": roll,
			"resisted": true,
			"reason": "spell-class-immunity",
		}, early)
	var screen := {
		"checksScreen": false,
		"screenLevel": 0,
		"spellLevel": 0,
		"resisted": false,
	}
	if abs(int(spell.get("classic_spell_class"))) != 9:
		screen = SpellScreenScript.spell_resolution(character, spell, caster)
	if bool(screen.get("resisted", false)):
		return _with_early_result({
			"checksResistance": false,
			"checksScreen": true,
			"checksClassImmunity": false,
			"checksProjectileProtection": false,
			"screenLevel": int(screen.get("screenLevel", 0)),
			"spellLevel": int(screen.get("spellLevel", 0)),
			"chance": 0,
			"roll": roll,
			"resisted": true,
			"reason": "spell-screen",
		}, early)
	if animated_spell_immunity(character, spell, true):
		return _with_early_result({
			"checksResistance": false,
			"checksScreen": bool(screen.get("checksScreen", false)),
			"checksClassImmunity": false,
			"checksAnimatedImmunity": true,
			"checksProjectileProtection": false,
			"chance": 0,
			"roll": roll,
			"resisted": true,
			"reason": "animated-immunity",
		}, early)
	var projectile_protection: Dictionary = ProjectileProtectionScript.spell_resolution(
		character, spell
	)
	if bool(projectile_protection.get("resisted", false)):
		return _with_early_result({
			"checksResistance": false,
			"checksScreen": bool(screen.get("checksScreen", false)),
			"checksClassImmunity": false,
			"checksAnimatedImmunity": false,
			"checksProjectileProtection": true,
			"screenLevel": int(screen.get("screenLevel", 0)),
			"spellLevel": int(screen.get("spellLevel", 0)),
			"chance": 0,
			"roll": roll,
			"resisted": true,
			"reason": "projectile-protection",
		}, early)
	var checks_resistance := custom_spell_uses_resistance(spell)
	var resistance_chance := 0
	if checks_resistance:
		resistance_chance = chance(
			character,
			power,
			int(spell.get("classic_resist_adjust"))
		)
	var resisted := checks_resistance and roll <= resistance_chance
	return _with_early_result({
		"checksResistance": checks_resistance,
		"checksScreen": bool(screen.get("checksScreen", false)),
		"checksClassImmunity": false,
		"checksAnimatedImmunity": false,
		"checksProjectileProtection": bool(
			projectile_protection.get("checksProjectileProtection", false)
		),
		"screenLevel": int(screen.get("screenLevel", 0)),
		"spellLevel": int(screen.get("spellLevel", 0)),
		"chance": resistance_chance,
		"roll": roll,
		"resisted": resisted,
		"reason": "magic-resistance" if resisted else "",
	}, early)


static func _combat_level(character: Object) -> Variant:
	if character.has_meta(CLASSIC_HIT_DICE_META_KEY):
		return int(character.get_meta(CLASSIC_HIT_DICE_META_KEY))
	for property: Dictionary in character.get_property_list():
		if str(property.get("name", "")) == "level":
			return int(character.get("level"))
	return null


static func _classic_monster_charm_chance(character: Object) -> Variant:
	if not character.has_meta(CLASSIC_HIT_DICE_META_KEY):
		return null
	# Classic ignores a monster's stored charm save here and derives the roll
	# from hit dice plus its magic-using and intelligent type flags.
	var resistance_chance := 35 + 4 * int(character.get_meta(CLASSIC_HIT_DICE_META_KEY))
	var tags: Variant = _property_value(character, "tags")
	if tags is Array:
		if "Magic Using" in tags:
			resistance_chance += 5
		if "Intelligent" in tags:
			resistance_chance += 5
	return resistance_chance


static func _is_classic_spell(spell: Object, classic_context: bool) -> bool:
	if spell == null:
		return false
	if classic_context:
		return true
	var classic_spell_ids: Variant = spell.get("classic_spell_ids")
	return classic_spell_ids is Array and not classic_spell_ids.is_empty()


static func _property_value(value: Object, property_name: String) -> Variant:
	for property: Dictionary in value.get_property_list():
		if str(property.get("name", "")) == property_name:
			return value.get(property_name)
	return null
