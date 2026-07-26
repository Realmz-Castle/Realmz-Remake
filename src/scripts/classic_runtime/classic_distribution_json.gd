class_name ClassicDistributionJson
extends RefCounted

static func stringify(value: Variant, sort_keys := false) -> String:
	return JSON.stringify(value, "", sort_keys) + "\n"
