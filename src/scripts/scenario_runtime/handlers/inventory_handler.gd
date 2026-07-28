class_name ScenarioInventoryHandler
extends ClassicOpcodeHandler


func _init() -> void:
	configure(
		"core.inventory",
		PackedInt32Array([6, 10, 21, 22, 32, 33, 36, 49, 51, 60, 65, 73, 91])
	)


func execute_on_runtime(instruction: Dictionary, runtime: Object) -> Dictionary:
	var code := int(instruction.get("code", 0))
	var record_id := int(instruction.get("id", 0))
	match code:
		6:
			return _invoke(runtime, "_execute_load_shop", [record_id])
		10:
			return _invoke(runtime, "_execute_treasure", [record_id])
		21:
			return _invoke(
				runtime,
				"_execute_item_possession_branch",
				[record_id, bool(runtime.gosub_active)]
			)
		22:
			return _invoke(runtime, "_execute_item_mutation", [record_id])
		32:
			return _invoke(runtime, "_yield_result", [
				"offer_temple",
				{
					"costPercent": record_id,
					"soundId": 10105,
				},
			])
		33:
			return _invoke(runtime, "_execute_take_gold", [record_id])
		36:
			return _invoke(runtime, "_yield_result", [
				"store_party_equipment",
				{
					"capture": record_id != 0,
					"storageId": record_id,
				},
			])
		49:
			return _invoke(runtime, "_yield_result", [
				"enable_banking",
				{
					"soundId": 128,
					"warningId": 106,
				},
			])
		51:
			return _invoke(runtime, "_execute_shop_mutation", [record_id])
		60:
			return _invoke(runtime, "_execute_currency_clear", [record_id])
		65:
			return _invoke(runtime, "_execute_random_items", [record_id])
		73:
			return _invoke(runtime, "_execute_restricted_shop", [record_id])
		91:
			return _invoke(runtime, "_yield_result", [
				"drop_party_items",
				{"soundId": 655},
			])
	return _unsupported(instruction)
