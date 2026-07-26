extends "res://scripts/classic_runtime/classic_core_missile_spell.gd"


func _init() -> void:
	name = "Boulder"
	classic_spell_class = 9
	classic_target_type = 1
	classic_spell_ids = [4114]
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	configure_stock_missile_spell({
		"packedSpellId": 4114,
		"displayName": "Boulder",
		"range1": 12,
		"range2": 0,
		"queueIcon": 0,
		"toHitBonus": 0,
		"saveBonus": 0,
		"fixedTargetNum": 1,
		"canRotate": 0,
		"saveAdjust": 0,
		"cannot": 3,
		"resistAdjust": 0,
		"cost": 0,
		"damage1": 2,
		"damage2": 12,
		"powerDamage1": 0,
		"powerDamage2": 0,
		"duration1": 0,
		"duration2": 0,
		"powerDuration1": 0,
		"powerDuration2": 0,
		"spellLook1": 5,
		"spellLook2": 5,
		"sound1": 50,
		"sound2": 32,
		"targetType": 1,
		"size": 0,
		"special": 0,
		"damageType": 9,
		"spellClass": 9,
		"inCombat": 1,
		"inCamp": 0,
		"sourceRecord": {
			"sourceFile": "Data S",
			"recordIndex": 328,
			"byteOffset": 9840,
			"byteLength": 30,
		},
	})
