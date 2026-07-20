extends RefCounted


const KIND := "complexEncounter"


static func create(encounter_id: int) -> Dictionary:
	return {
		"kind": KIND,
		"encounter": "CE%d" % encounter_id,
	}


static func is_branch(value: Variant) -> bool:
	return (
		value is Dictionary
		and str(value.get("kind", "")) == KIND
		and not str(value.get("encounter", "")).is_empty()
	)
