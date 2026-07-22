extends RefCounted

const name := "p_classic_animated.gd"
const menuname := "Animated (Classic)"
const stacks := false
const permanent := 1
const trait_types := ["no_exp"]

var chara
var trait_source := "Puppet Master"


func _init(args: Array) -> void:
	chara = args[0]


func _on_chara_dead(character) -> void:
	character.remove_trait(self)


func get_saved_variables() -> Array:
	return []


func _on_get_stat(stat_name: String, stat):
	if stat_name == "SP_regen_mult":
		return 0
	return stat


func _on_get_player_controlled() -> bool:
	return false


func _on_get_creature_script():
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var game_global: Node = tree.root.get_node_or_null("GameGlobal")
	if game_global == null:
		return null
	var resources = game_global.get("cmp_resources")
	if resources == null:
		return null
	var creature_scripts: Dictionary = resources.get("creascripts_book")
	return creature_scripts.get("dumb_melee.gd")


func get_info_as_text() -> String:
	return "Permanently Animated (source: %s)" % trait_source


func equals_args(_traits_array: Array) -> bool:
	return true
