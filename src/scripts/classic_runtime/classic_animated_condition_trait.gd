extends RefCounted

const DumbMeleeScript = preload(
	"res://shared_assets/CreatureScripts/dumb_melee.gd"
)
const trait_types := ["no_exp"]

var chara
var trait_source := ""


func _init(args: Array) -> void:
	chara = args[0]


func _on_chara_dead(character) -> void:
	character.remove_trait(self)


func _on_get_stat(stat_name: String, stat):
	if stat_name == "SP_regen_mult":
		return 0
	return stat


func _on_get_player_controlled() -> bool:
	return false


func _on_get_creature_script():
	return DumbMeleeScript


func blocks_spellcasting() -> bool:
	return true
