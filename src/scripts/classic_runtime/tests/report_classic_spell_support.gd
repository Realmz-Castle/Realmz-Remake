extends SceneTree

const BundleScript = preload("res://scripts/classic_runtime/classic_campaign_bundle.gd")
const SpellUsageAuditScript = preload(
	"res://scripts/classic_runtime/classic_spell_usage_audit.gd"
)
const SpellResourceCatalogScript = preload(
	"res://scripts/classic_runtime/classic_spell_resource_catalog.gd"
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
	var native_campaign_directory := ""
	var native_campaign_option := arguments.find("--native-campaign")
	if native_campaign_option >= 0:
		if native_campaign_option + 1 >= arguments.size():
			_print_usage()
			quit(2)
			return
		native_campaign_directory = str(arguments[native_campaign_option + 1])
		arguments.remove_at(native_campaign_option + 1)
		arguments.remove_at(native_campaign_option)
	if arguments.is_empty():
		_print_usage()
		quit(2)
		return

	var bundles: Array = []
	for directory_value: Variant in arguments:
		var bundle = BundleScript.new()
		if not bundle.load_from_directory(str(directory_value)):
			push_error("%s: %s" % [directory_value, bundle.last_error])
			quit(2)
			return
		bundles.append(bundle)

	var audit = SpellUsageAuditScript.new()
	var matrix := audit.load_support_matrix(matrix_path)
	if matrix.is_empty():
		push_error(audit.last_error)
		quit(2)
		return
	var native_spells := {}
	SpellResourceCatalogScript.merge_directory("res://shared_assets/spells", native_spells)
	if not native_campaign_directory.is_empty():
		SpellResourceCatalogScript.merge_directory(
			native_campaign_directory.path_join("Spells"), native_spells
		)
	var report: Dictionary = audit.inspect_bundles(bundles, matrix, native_spells)
	if json_output:
		print(JSON.stringify(report))
	else:
		_print_report(report)
	quit(0)


func _print_usage() -> void:
	print(
		"Usage: report_classic_spell_support.gd <bundle-directory> " +
		"[bundle-directory ...] [--matrix <matrix.json>] " +
		"[--native-campaign <campaign-directory>] [--json]"
	)


func _print_report(report: Dictionary) -> void:
	var totals: Dictionary = report.get("totals", {})
	print("Classic spell usage: %d campaign%s, %d spell ID%s, %d usage%s." % [
		int(totals.get("campaigns", 0)),
		"" if int(totals.get("campaigns", 0)) == 1 else "s",
		int(totals.get("spellIds", 0)),
		"" if int(totals.get("spellIds", 0)) == 1 else "s",
		int(totals.get("usages", 0)),
		"" if int(totals.get("usages", 0)) == 1 else "s",
	])
	print("Matrix coverage: %d documented, %d supported, %d unclassified." % [
		int(totals.get("documentedSpellIds", 0)),
		int(totals.get("supportedSpellIds", 0)),
		int(totals.get("unclassifiedSpellIds", 0)),
	])
	var native_resolution: Dictionary = totals.get("nativeResolution", {})
	print("Native resolution: %d exact ID, %d name-only, %d missing, %d variant, %d unmapped." % [
		int(native_resolution.get("exact-id-resource", 0)),
		int(native_resolution.get("name-only-resource", 0)),
		int(native_resolution.get("missing-native-resource", 0)),
		int(native_resolution.get("unsupported-native-variant", 0)),
		int(native_resolution.get("unmapped-identity", 0)),
	])
	var unclassified: Array[String] = []
	for row_value: Variant in report.get("spells", []):
		if row_value is Dictionary \
				and str(row_value.get("supportStatus", "")) == "unclassified":
			unclassified.append("%d %s" % [
				int(row_value.get("classicSpellId", 0)),
				str(row_value.get("displayName", "")),
			])
	if not unclassified.is_empty():
		print("Unclassified spell IDs: %s" % ", ".join(unclassified))
	var unavailable: Variant = report.get("sourceCoverage", {}).get(
		"notRepresentedByBundleV1", []
	)
	if unavailable is Array and not unavailable.is_empty():
		print("Not represented by bundle v1: %s" % ", ".join(unavailable))
