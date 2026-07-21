const name := "t_classic_charmed.gd"
const menuname := "Charmed"
const stacks := true
const trait_types: Array = []

var chara
var charmer


func _init(args: Array) -> void:
	chara = args[0]
	_apply_charmer(args[1] if args.size() > 1 else null)


func stack(args: Array) -> void:
	_apply_charmer(args[0] if not args.is_empty() else null)


func unstack(_args: Array) -> void:
	# Classic charm has no duration or strength stack to decrement.
	pass


func _apply_charmer(caster) -> void:
	charmer = caster
	if charmer != null:
		chara.curFaction = charmer.curFaction


func _on_remove_trait(character, trait_script) -> void:
	if trait_script == self:
		character.curFaction = character.baseFaction


func _on_battle_end(character) -> void:
	character.remove_trait(self)


func _on_get_player_controlled() -> bool:
	return false


func _on_get_creature_script():
	var tree := Engine.get_main_loop() as SceneTree
	var game_global: Node = tree.root.get_node_or_null("GameGlobal") if tree != null else null
	if game_global == null:
		return null
	var resources = game_global.get("cmp_resources")
	if resources == null:
		return null
	var creature_scripts: Dictionary = resources.get("creascripts_book")
	return creature_scripts.get("test_crea_script.gd")


func get_info_as_text() -> String:
	if charmer != null:
		return "Charmed by %s for this battle" % charmer.name
	return "Charmed for this battle"
