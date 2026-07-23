extends RefCounted

const RoutRules = preload(
	"res://scripts/classic_runtime/classic_combat_rout_rules.gd"
)
const RunningAwayScript = preload(
	"res://shared_assets/CreatureScripts/runningaway.gd"
)
const CLASSIC_TRAIT_NAMES := [
	"t_classic_fleeing.gd",
	"p_classic_fleeing.gd",
]

var chara
var trait_source := ""


func _init(args: Array) -> void:
	chara = args[0]
	RoutRules.mark_routed(chara)


func _on_remove_trait(character, trait_script) -> void:
	if trait_script != self:
		return
	for trait_value: Variant in character.traits:
		if trait_value != self \
				and str(trait_value.get("name")) in CLASSIC_TRAIT_NAMES:
			return
	RoutRules.clear_routed(character)


func _on_get_player_controlled() -> bool:
	return false


func _on_get_creature_script():
	return RunningAwayScript
