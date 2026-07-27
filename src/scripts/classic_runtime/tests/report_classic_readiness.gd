extends SceneTree

const ReadinessScript = preload("res://scripts/classic_runtime/classic_campaign_readiness.gd")
const NativeContextBuilderScript = preload(
	"res://scripts/classic_runtime/classic_native_context_builder.gd"
)
const MAX_DISPLAYED_DIAGNOSTICS := 25


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	for child: Node in root.get_children():
		child.process_mode = Node.PROCESS_MODE_DISABLED
	var arguments := OS.get_cmdline_user_args()
	var json_output := arguments.has("--json")
	arguments.erase("--json")
	if arguments.is_empty() or arguments.size() > 2:
		print("Usage: report_classic_readiness.gd <bundle-directory> [native-campaign-directory] [--json]")
		quit(2)
		return

	var native_context := {}
	var native_preparation := {}
	if arguments.size() == 2:
		var preparation_result: Dictionary = NativeContextBuilderScript.new().build(
			str(arguments[1])
		)
		native_context = preparation_result.get("context", {})
		native_preparation = NativeContextBuilderScript.public_report(
			preparation_result
		)
	var report: Dictionary = ReadinessScript.new().inspect_directory(
		str(arguments[0]), native_context
	)
	if not native_preparation.is_empty():
		report["nativePreparation"] = native_preparation
		if not bool(native_preparation.get("ok", false)):
			report["ready"] = false
			report["status"] = "preparation-failed"
			report["summary"] = "Native resource preparation failed: %s %s" % [
				NativeContextBuilderScript.first_error(native_preparation),
				str(report.get("summary", "")),
			]
	if json_output:
		print(JSON.stringify(report))
	else:
		_print_report(report)
	quit(0 if bool(report.get("ready", false)) else 1)


func _print_report(report: Dictionary) -> void:
	print("Classic campaign readiness: %s" % report.get("campaign", {}).get("name", "Unknown"))
	print(report.get("summary", "No readiness summary was produced."))
	var diagnostics: Array = report.get("diagnostics", [])
	for diagnostic_value: Variant in diagnostics.slice(0, MAX_DISPLAYED_DIAGNOSTICS):
		if not (diagnostic_value is Dictionary):
			continue
		var diagnostic: Dictionary = diagnostic_value
		var location := str(diagnostic.get("source", "unknown source"))
		if int(diagnostic.get("recordIndex", -1)) >= 0:
			location += " record %d" % int(diagnostic["recordIndex"])
		if int(diagnostic.get("slot", -1)) >= 0:
			location += " slot %d" % int(diagnostic["slot"])
		print("- [%s] %s: %s (%s)" % [
			str(diagnostic.get("classification", "diagnostic")),
			str(diagnostic.get("code", "unknown")),
			str(diagnostic.get("message", "")),
			location,
		])
	if diagnostics.size() > MAX_DISPLAYED_DIAGNOSTICS:
		print("- ... %d additional diagnostics; use --json for the complete report." % [
			diagnostics.size() - MAX_DISPLAYED_DIAGNOSTICS,
		])
