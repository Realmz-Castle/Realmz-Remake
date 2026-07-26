extends "res://scripts/classic_runtime/classic_core_poison_spell.gd"


func _init() -> void:
	name = "Classic Poison 4309"
	classic_spell_class = 4
	classic_target_type = 5
	classic_spell_ids = [4309]
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	configure_stock_poison_spell({
		"packedSpellId": 4309,
		"displayName": "Classic Poison 4309",
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
		"duration1": -1,
		"duration2": -1,
		"powerDuration1": 0,
		"powerDuration2": 0,
		"spellLook1": 5,
		"spellLook2": 12,
		"sound1": 31,
		"sound2": 84,
		"targetType": 5,
		"size": 0,
		"special": 10,
		"damageType": 4,
		"spellClass": 4,
		"inCombat": 1,
		"inCamp": 1,
		"sourceRecord": {
			"sourceFile": "Data S",
			"recordIndex": 353,
			"byteOffset": 10590,
			"byteLength": 30,
		},
	})
