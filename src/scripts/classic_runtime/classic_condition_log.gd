class_name ClassicConditionLog
extends RefCounted


static func write(character: Variant, message: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var ui: Node = tree.root.get_node_or_null("UI") if tree != null else null
	if ui != null and ui.get("ow_hud") != null:
		ui.get("ow_hud").creatureRect.logrect.log_other_text(
			character,
			message,
			null,
			""
		)
