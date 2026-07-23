extends RefCounted

const Petrification = preload(
	"res://scripts/classic_runtime/classic_petrification.gd"
)
const trait_types := ["crea_bg_blue"]

var chara
var trait_source := ""


func _init(args: Array) -> void:
	chara = args[0]
	Petrification.force_state(chara)


func _on_get_player_controlled() -> bool:
	return false


func _on_get_stat(stat_name: String, stat):
	if stat_name in ["EvasionMelee", "EvasionRanged", "MultiplierHealing"]:
		return 0
	return stat


func _on_change_cur_hp(hp_change: int) -> int:
	return 0 if hp_change > 0 else hp_change


func blocks_spellcasting() -> bool:
	return true
