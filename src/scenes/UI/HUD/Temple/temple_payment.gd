extends RefCounted


static func can_afford_service(character_gold: int, pooled_gold: int, cost: int) -> bool:
	return cost >= 0 and character_gold + pooled_gold >= cost


static func balances_after_service(character_gold: int, pooled_gold: int, cost: int) -> Array[int]:
	var pooled_payment: int = min(pooled_gold, cost)
	return [character_gold - (cost - pooled_payment), pooled_gold - pooled_payment]


static func balances_after_transfer(source: Array, destination: Array) -> Array:
	var emptied_source: Array = source.duplicate()
	var combined_destination: Array = destination.duplicate()
	for currency_index in source.size():
		combined_destination[currency_index] += source[currency_index]
		emptied_source[currency_index] = 0
	return [emptied_source, combined_destination]
