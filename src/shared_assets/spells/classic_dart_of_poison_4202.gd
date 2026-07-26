extends "res://scripts/classic_runtime/classic_core_missile_spell.gd"


func _init() -> void:
	name = "Dart of Poison"
	classic_spell_class = 9
	classic_target_type = 1
	classic_spell_ids = [4202]
	classic_spell_save_index = 4
	classic_spell_save_mode = "half_damage"
	configure_stock_missile_spell({
		"packedSpellId": 4202,
		"displayName": "Dart of Poison",
		"range1": 4,
		"range2": 0,
		"queueIcon": 0,
		"toHitBonus": 0,
		"saveBonus": 0,
		"fixedTargetNum": 0,
		"canRotate": 0,
		"saveAdjust": 0,
		"cannot": 0,
		"resistAdjust": 0,
		"cost": 0,
		"damage1": 1,
		"damage2": 2,
		"powerDamage1": 0,
		"powerDamage2": 0,
		"duration1": 0,
		"duration2": 0,
		"powerDuration1": 0,
		"powerDuration2": 0,
		"spellLook1": 2,
		"spellLook2": 12,
		"sound1": 43,
		"sound2": 40,
		"targetType": 1,
		"size": 0,
		"special": 10,
		"damageType": 4,
		"spellClass": 9,
		"inCombat": 1,
		"inCamp": 0,
		"sourceRecord": {
			"sourceFile": "Data S",
			"recordIndex": 331,
			"byteOffset": 9930,
			"byteLength": 30,
		},
	})
