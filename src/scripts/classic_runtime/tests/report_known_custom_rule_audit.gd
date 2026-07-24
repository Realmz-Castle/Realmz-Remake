extends SceneTree

const AuditScript = preload(
	"res://scripts/classic_runtime/classic_known_custom_rule_audit.gd"
)


func _init() -> void:
	var report: Dictionary = AuditScript.new().inspect_path()
	print(JSON.stringify(report, "  ", false))
	if bool(report.get("accepted", false)):
		quit(0)
	else:
		quit(1)
