extends SceneTree

const CoreSpellCoverageScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_coverage.gd"
)
const SpellResourceCatalogScript = preload(
	"res://scripts/classic_runtime/classic_spell_resource_catalog.gd"
)
const SpellUsageAuditScript = preload(
	"res://scripts/classic_runtime/classic_spell_usage_audit.gd"
)


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	for child: Node in root.get_children():
		child.process_mode = Node.PROCESS_MODE_DISABLED
	var arguments := OS.get_cmdline_user_args()
	var json_output := arguments.has("--json")
	arguments.erase("--json")
	var matrix_path := SpellUsageAuditScript.SUPPORT_MATRIX_PATH
	var matrix_option := arguments.find("--matrix")
	if matrix_option >= 0:
		if matrix_option + 1 >= arguments.size():
			_print_usage()
			quit(2)
			return
		matrix_path = str(arguments[matrix_option + 1])
		arguments.remove_at(matrix_option + 1)
		arguments.remove_at(matrix_option)
	if not arguments.is_empty():
		_print_usage()
		quit(2)
		return

	var audit = SpellUsageAuditScript.new()
	var matrix := audit.load_support_matrix(matrix_path)
	if matrix.is_empty():
		push_error(audit.last_error)
		quit(2)
		return
	var native_spells := {}
	SpellResourceCatalogScript.merge_directory("res://shared_assets/spells", native_spells)
	var report: Dictionary = CoreSpellCoverageScript.new().inspect(matrix, native_spells)
	if json_output:
		print(JSON.stringify(report))
	else:
		_print_report(report)
	quit(0)


func _print_usage() -> void:
	print("Usage: report_classic_core_spell_coverage.gd [--matrix <matrix.json>] [--json]")


func _print_report(report: Dictionary) -> void:
	var totals: Dictionary = report.get("totals", {})
	var coverage: Dictionary = totals.get("coverageStatus", {})
	print("Classic player spell coverage: %d identities, %d curated as supported." % [
		int(totals.get("spellIds", 0)),
		int(totals.get("matrixSupported", 0)),
	])
	print("Review queue: %d exact resources, %d named resources, %d native variants." % [
		int(coverage.get("exact-resource-review", 0)),
		int(coverage.get("named-resource-review", 0)),
		int(coverage.get("native-variant-review", 0)),
	])
	print("Implementation queue: %d generic candidates, %d special behaviors." % [
		int(coverage.get("generic-implementation-candidate", 0)),
		int(coverage.get("special-implementation-required", 0)),
	])
	var mismatches := int(coverage.get("support-resource-mismatch", 0))
	var documented_gaps := int(coverage.get("documented-gap", 0))
	if mismatches > 0 or documented_gaps > 0:
		print("Exceptions: %d support/resource mismatches, %d documented gaps." % [
			mismatches,
			documented_gaps,
		])
