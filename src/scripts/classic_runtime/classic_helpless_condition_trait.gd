extends RefCounted

const IdleScript = preload(
	"res://shared_assets/CreatureScripts/classic_idle.gd"
)

var chara
var trait_source := ""


func _init(args: Array) -> void:
	chara = args[0]


func _on_get_player_controlled() -> bool:
	return false


func _on_get_creature_script():
	return IdleScript


func blocks_spellcasting() -> bool:
	return true
