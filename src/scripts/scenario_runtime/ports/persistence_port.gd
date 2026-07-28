class_name PersistencePort
extends ScenarioCommandPort

const COMMANDS := [
	"snapshot_runtime",
	"restore_runtime",
]

var _router: ScenarioCommandRouter


func port_id() -> String:
	return "core.persistence"


func owned_command_ids() -> PackedStringArray:
	return PackedStringArray(COMMANDS)


func save_policy() -> Dictionary:
	return {"state": "aggregate"}


func configure(services: Dictionary) -> void:
	_router = services.get("commandRouter")


func execute(command_id: String, request: Dictionary) -> Dictionary:
	if _router == null:
		return {"status": "error", "message": "Persistence port is not configured"}
	if command_id == "snapshot_runtime":
		return {"status": "ok", "ports": _router.snapshot_state()}
	if command_id == "restore_runtime":
		var state: Variant = request.get("ports", {})
		if not (state is Dictionary):
			return {"status": "error", "message": "Saved port state must be a dictionary"}
		return _router.restore_state(state)
	return {"status": "error", "message": "Unsupported persistence command '%s'" % command_id}
