extends SceneTree

const BundleScript = preload("res://scripts/classic_runtime/classic_campaign_bundle.gd")
const AuditScript = preload(
	"res://scripts/classic_runtime/classic_materialization_fixture_audit.gd"
)


func _init() -> void:
	var arguments := OS.get_cmdline_user_args()
	var json_output := arguments.has("--json")
	arguments.erase("--json")
	if arguments.size() != 1:
		printerr(
			"Usage: godot --headless --path <remake-src> --script " + \
			"res://scripts/classic_runtime/tests/audit_classic_materialization_fixture.gd " + \
			"-- <bundle-directory> [--json]"
		)
		quit(2)
		return

	var bundle = BundleScript.new()
	if not bundle.load_from_directory(str(arguments[0])):
		printerr("Classic materialization fixture is invalid: %s" % bundle.last_error)
		quit(1)
		return

	var report: Dictionary = AuditScript.inspect(bundle.documents)
	if json_output:
		print(JSON.stringify(report))
	else:
		_print_report(report)
	quit(0 if bool(report.get("accepted", false)) else 1)


func _print_report(report: Dictionary) -> void:
	print("Classic item/monster materialization fixture coverage:")
	for capability_name: String in AuditScript.REQUIRED_CAPABILITIES:
		var capability: Dictionary = report.get("capabilities", {}).get(
			capability_name,
			{}
		)
		print("- %s: %s" % [
			capability_name,
			"covered" if bool(capability.get("covered", false)) else "missing",
		])
	if bool(report.get("accepted", false)):
		print("Materialization fixture coverage accepted.")
	else:
		printerr(
			"Materialization fixture coverage incomplete: %s" % ", ".join(
				report.get("missingCapabilities", [])
			)
		)
