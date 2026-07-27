extends Node

var failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	_expect(UI.get("_ow_hud") == null, "gameplay HUD is absent during startup")
	_expect(
		not StateMachine.has_node("Exploration") and not StateMachine.has_node("Combat"),
		"gameplay states are absent during startup"
	)
	await get_tree().process_frame
	_expect(
		UI.get("_ow_hud") == null,
		"the first visible frame does not instantiate the gameplay HUD"
	)
	_expect(
		not StateMachine.has_node("Exploration") and not StateMachine.has_node("Combat"),
		"the first visible frame does not instantiate gameplay states"
	)

	var hud: Control = UI.ow_hud
	_expect(is_instance_valid(hud), "requesting the gameplay HUD instantiates it")
	_expect(hud.get_parent() == UI, "the lazy gameplay HUD joins the UI autoload")
	_expect(StateMachine.has_node("Exploration/ExMenus"), "exploration states load on demand")
	_expect(StateMachine.has_node("Combat/CbDecideAction"), "combat states load on demand")
	_expect(
		StateMachine.combat_state.get("cbanimstate") == StateMachine.cb_anim_state,
		"the lazy combat animation state is wired to combat"
	)
	_expect(
		StateMachine.cb_decide_state.get("combat_state") == StateMachine.combat_state,
		"the lazy decision state is wired to combat"
	)

	if failures.is_empty():
		print("Startup lazy-loading smoke passed.")
		get_tree().quit(0)
		return
	for failure: String in failures:
		printerr("FAIL: %s" % failure)
	get_tree().quit(1)


func _expect(condition: bool, message: String) -> void:
	if condition:
		print("PASS: %s" % message)
	else:
		failures.append(message)
