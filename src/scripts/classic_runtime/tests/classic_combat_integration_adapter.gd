extends "res://scripts/scenario_runtime/godot/scenario_godot_services.gd"

var test_autoloads: Dictionary = {}
var test_combatant_scene: Variant
var shown_messages: Array = []
var played_sounds: Array = []


func configure_test_dependencies(autoloads: Dictionary, combatant_scene: Variant) -> void:
	test_autoloads = autoloads
	test_combatant_scene = combatant_scene


func _autoload(autoload_name: String) -> Node:
	return test_autoloads.get(autoload_name)


func _combatant_scene_resource() -> Variant:
	return test_combatant_scene


func _show_text(payload: Dictionary) -> Dictionary:
	shown_messages.append(int(payload.get("messageId", 0)))
	return {}


func _play_sound(payload: Dictionary) -> Dictionary:
	var sound_id := int(payload.get("soundId", 0))
	if sound_id != 0:
		played_sounds.append(sound_id)
	return {}
