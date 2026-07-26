extends "res://scripts/classic_runtime/classic_stock_attribute_spell.gd"


func _init() -> void:
	name = "Improved Luck"
	classic_spell_class = 8
	classic_target_type = 5
	classic_spell_ids = [4506]
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	configure_stock_attribute_spell({
		"packedSpellId": 4506,
		"displayName": "Improved Luck",
		"range1": 0,
		"range2": 0,
		"queueIcon": 0,
		"toHitBonus": 0,
		"saveBonus": 0,
		"fixedTargetNum": 0,
		"canRotate": 0,
		"saveAdjust": 0,
		"cannot": 3,
		"resistAdjust": 0,
		"cost": 0,
		"damage1": 0,
		"damage2": 0,
		"powerDamage1": 0,
		"powerDamage2": 0,
		"duration1": 0,
		"duration2": 0,
		"powerDuration1": 0,
		"powerDuration2": 0,
		"spellLook1": 14,
		"spellLook2": 14,
		"sound1": 93,
		"sound2": 83,
		"targetType": 5,
		"size": 6,
		"special": 66,
		"damageType": 8,
		"spellClass": 8,
		"inCombat": 0,
		"inCamp": 1,
		"sourceRecord": {
			"sourceFile": "Data S",
			"recordIndex": 380,
			"byteOffset": 11400,
			"byteLength": 30,
		},
	})
