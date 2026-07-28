class_name DefaultScenarioPorts
extends RefCounted

const RouterScript = preload(
	"res://scripts/scenario_runtime/scenario_command_router.gd"
)
const MapPortScript = preload(
	"res://scripts/scenario_runtime/ports/map_port.gd"
)
const CombatPortScript = preload(
	"res://scripts/scenario_runtime/ports/combat_port.gd"
)
const InventoryPortScript = preload(
	"res://scripts/scenario_runtime/ports/inventory_port.gd"
)
const CharacterPortScript = preload(
	"res://scripts/scenario_runtime/ports/character_port.gd"
)
const PresentationPortScript = preload(
	"res://scripts/scenario_runtime/ports/presentation_port.gd"
)
const PersistencePortScript = preload(
	"res://scripts/scenario_runtime/ports/persistence_port.gd"
)


static func create(
	port_runtime: Object,
	gameplay_rule_set: GameplayRuleSet = null
) -> Dictionary:
	var router := RouterScript.new()
	for port: ScenarioCommandPort in [
		MapPortScript.new(),
		CombatPortScript.new(),
		InventoryPortScript.new(),
		CharacterPortScript.new(),
		PresentationPortScript.new(),
		PersistencePortScript.new(),
	]:
		if not router.register_port(port):
			return {"status": "error", "message": router.last_error}
	router.configure({
		"scenarioPortRuntime": port_runtime,
		"commandRouter": router,
		"gameplayRules": gameplay_rule_set,
	})
	return {"status": "ok", "router": router}
