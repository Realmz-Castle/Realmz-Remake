extends "res://scripts/classic_runtime/classic_spell_override.gd"

const CoreSpellCatalogScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_catalog.gd"
)


func _init() -> void:
	name = "Stun"
	classic_spell_ids = [2712]
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(2712)
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	record["packedSpellId"] = 2712
	record["displayName"] = "Stun"
	record["description"] = (
		"Stun: Causes the target to become helpless for one round."
	)
	record["schools"] = ["Priest"]
	record["schoolLevels"] = {"Sorcerer": 0, "Priest": 7, "Enchanter": 0}
	record["selectionCosts"] = {"Sorcerer": 0, "Priest": 28, "Enchanter": 0}
	record["elements"] = [GameGlobal.ELEMENTS.MAGICAL]
	record["tags"] = ["Magical"]
	record["lineOfSight"] = true
	record["projectileTexture"] = GFX.TARGET
	record["projectileHit"] = GFX.WEB
	record["sounds"] = ["force field.wav", "teleport.wav"]
	record["sourceRecord"] = inventory.get("sourceRecord", {}).duplicate(true)
	configure(record)
	attributes = ["Magical", "Special"]


func get_min_duration(_power: int, _caster) -> int:
	return 1


func get_duration_roll(_power: int, _caster) -> int:
	return 1


func get_max_duration(_power: int, _caster) -> int:
	return 1


# The shipped row omits the helpless special code even though its description
# advertises that effect. Classic's spell-info screen displays the row's -1
# duration as one round, so the compatibility path corrects both bad fields.
func apply_classic_scaled_effect(
	caster,
	target,
	power: int,
	effect_scale: float
) -> void:
	if effect_scale <= 0.0:
		return
	var trait_script = load(
		"res://shared_assets/traits/t_classic_helpless.gd"
	)
	target.add_trait(trait_script, [get_duration_roll(power, caster)])
