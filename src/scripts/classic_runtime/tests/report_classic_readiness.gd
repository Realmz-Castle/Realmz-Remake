extends SceneTree

const ReadinessScript = preload("res://scripts/classic_runtime/classic_campaign_readiness.gd")
const MAX_DISPLAYED_DIAGNOSTICS := 25


func _init() -> void:
	var arguments := OS.get_cmdline_user_args()
	var json_output := arguments.has("--json")
	arguments.erase("--json")
	if arguments.is_empty() or arguments.size() > 2:
		print("Usage: report_classic_readiness.gd <bundle-directory> [native-campaign-directory] [--json]")
		quit(2)
		return

	var native_context := {}
	if arguments.size() == 2:
		native_context = _load_native_context(str(arguments[1]))
	var report: Dictionary = ReadinessScript.new().inspect_directory(
		str(arguments[0]), native_context
	)
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


func _load_native_context(campaign_directory: String) -> Dictionary:
	var context := {
		"bestiary": {},
		"items": {},
		"spells": {},
		"sounds": {},
	}
	_merge_json_book("res://shared_assets/Bestiary/stuff_book.json", context["bestiary"])
	_merge_json_book("res://shared_assets/items/stuff_book.json", context["items"])
	_merge_json_book(campaign_directory.path_join("Bestiary/stuff_book.json"), context["bestiary"])
	_merge_json_book(campaign_directory.path_join("Items/stuff_book.json"), context["items"])
	_collect_spell_names("res://shared_assets/spells", context["spells"])
	_collect_spell_names(campaign_directory.path_join("Spells"), context["spells"])
	_collect_file_names("res://shared_assets/sounds", context["sounds"])
	_collect_file_names(campaign_directory.path_join("Sounds"), context["sounds"])
	return context


func _merge_json_book(path: String, destination: Dictionary) -> void:
	if not FileAccess.file_exists(path):
		return
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if value is Dictionary:
		destination.merge(value, true)


func _collect_spell_names(directory: String, destination: Dictionary) -> void:
	var access := DirAccess.open(directory)
	if access == null:
		return
	var expression := RegEx.new()
	expression.compile("(?m)^\\s*name\\s*=\\s*[\"']([^\"']+)[\"']")
	var class_expression := RegEx.new()
	class_expression.compile("(?m)^\\s*classic_spell_class\\s*=\\s*(-?\\d+)")
	var ids_expression := RegEx.new()
	ids_expression.compile("(?m)^\\s*classic_spell_ids\\s*=\\s*\\[([^\\]]*)\\]")
	access.list_dir_begin()
	var file_name := access.get_next()
	while not file_name.is_empty():
		if not access.current_is_dir() and file_name.ends_with(".gd"):
			var source := FileAccess.get_file_as_string(directory.path_join(file_name))
			var match_result := expression.search(source)
			if match_result != null:
				var metadata := {}
				var class_match := class_expression.search(source)
				if class_match != null:
					metadata["classicSpellClass"] = int(class_match.get_string(1))
				var ids_match := ids_expression.search(source)
				if ids_match != null:
					var classic_spell_ids: Array[int] = []
					for id_text: String in ids_match.get_string(1).split(","):
						var trimmed_id := id_text.strip_edges()
						if trimmed_id.is_valid_int():
							classic_spell_ids.append(int(trimmed_id))
					metadata["classicSpellIds"] = classic_spell_ids
				destination[match_result.get_string(1)] = metadata
		file_name = access.get_next()
	access.list_dir_end()


func _collect_file_names(directory: String, destination: Dictionary) -> void:
	var access := DirAccess.open(directory)
	if access == null:
		return
	access.list_dir_begin()
	var file_name := access.get_next()
	while not file_name.is_empty():
		if not access.current_is_dir():
			var resource_name := file_name.trim_suffix(".import")
			if not resource_name.ends_with(".uid"):
				destination[resource_name] = true
		file_name = access.get_next()
	access.list_dir_end()
