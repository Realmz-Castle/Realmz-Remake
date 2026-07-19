extends RefCounted


static func can_afford_service(character_gold: int, pooled_gold: int, cost: int) -> bool:
	return cost >= 0 and character_gold + pooled_gold >= cost


static func balances_after_service(character_gold: int, pooled_gold: int, cost: int) -> Array[int]:
	var pooled_payment: int = min(pooled_gold, cost)
	return [character_gold - (cost - pooled_payment), pooled_gold - pooled_payment]
