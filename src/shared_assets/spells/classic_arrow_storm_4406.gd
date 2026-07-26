extends "res://scripts/classic_runtime/classic_core_missile_spell.gd"


func _init() -> void:
	name = "Arrow Storm"
	classic_spell_class = 9
	classic_target_type = 1
	classic_spell_ids = [4406]
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	configure_stock_missile_spell({
		"packedSpellId": 4406,
		"displayName": "Arrow Storm",
		"range1": 20,
		"range2": 0,
		"queueIcon": 0,
		"toHitBonus": 0,
		"saveBonus": 0,
		"fixedTargetNum": 6,
		"canRotate": 0,
		"saveAdjust": 0,
		"cannot": 3,
		"resistAdjust": 0,
		"cost": 0,
		"damage1": 0,
		"damage2": 0,
		"powerDamage1": 1,
		"powerDamage2": 6,
		"duration1": 0,
		"duration2": 0,
		"powerDuration1": 0,
		"powerDuration2": 0,
		"spellLook1": 1,
		"spellLook2": 5,
		"sound1": 25,
		"sound2": 19,
		"targetType": 1,
		"size": 0,
		"special": 0,
		"damageType": 9,
		"spellClass": 9,
		"inCombat": 1,
		"inCamp": 0,
		"sourceRecord": {
			"sourceFile": "Data S",
			"recordIndex": 365,
			"byteOffset": 10950,
			"byteLength": 30,
		},
	})
