extends SceneTree

const CorpusReportScript = preload(
	"res://scripts/classic_runtime/classic_campaign_corpus_report.gd"
)


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	for child: Node in root.get_children():
		child.process_mode = Node.PROCESS_MODE_DISABLED
	var arguments := OS.get_cmdline_user_args()
	var json_output := arguments.has("--json")
	var include_compressed_estimate := not arguments.has("--no-compression")
	arguments.erase("--json")
	arguments.erase("--no-compression")
	var output_path := ""
	var expected_campaigns := 13
	var positional: Array[String] = []
	for argument_value: Variant in arguments:
		var argument := str(argument_value)
		if argument.begins_with("--output="):
			output_path = argument.trim_prefix("--output=")
		elif argument.begins_with("--expected-count="):
			var count_text := argument.trim_prefix("--expected-count=")
			if not count_text.is_valid_int():
				_print_usage()
				quit(2)
				return
			expected_campaigns = int(count_text)
		else:
			positional.append(argument)
	if positional.size() > 1:
		_print_usage()
		quit(2)
		return
	var campaigns_directory := (
		positional[0] if not positional.is_empty() else "res://Campaigns"
	)
	var report: Dictionary = CorpusReportScript.new().inspect(
		campaigns_directory,
		{
			"expectedCampaigns": expected_campaigns,
			"includeCompressedEstimate": include_compressed_estimate,
		}
	)
	if not output_path.is_empty() and not _write_report(output_path, report):
		quit(2)
		return
	if json_output:
		print(JSON.stringify(report))
	else:
		_print_report(report)
	quit(0 if bool(report.get("allReady", false)) else 1)


func _print_report(report: Dictionary) -> void:
	var totals: Dictionary = report.get("totals", {})
	print("Classic built-in campaign readiness and footprint")
	print(
		"Campaigns: %d/%d; ready: %d; blocked: %d; install failures: %d"
		% [
			int(totals.get("campaigns", 0)),
			int(report.get("expectedCampaigns", 0)),
			int(totals.get("readyCampaigns", 0)),
			int(totals.get("blockedCampaigns", 0)),
			int(totals.get("installFailures", 0)),
		]
	)
	print(
		"Readiness: %d progression blockers; %d fidelity fallbacks"
		% [
			int(totals.get("progressionBlockers", 0)),
			int(totals.get("fidelityFallbacks", 0)),
		]
	)
	print(
		"Diagnostics: %d active; %d inactive; %d preparation errors"
		% [
			int(totals.get("activeDiagnostics", 0)),
			int(totals.get("inactiveDiagnostics", 0)),
			int(totals.get("preparationErrors", 0)),
		]
	)
	print(
		"Footprint: %.1f MiB installed; %.1f MiB compressed estimate; %.1f MiB JSON"
		% [
			_mib(totals.get("installedBytes", 0)),
			_mib(totals.get("compressedEstimateBytes", 0)),
			_mib(totals.get("jsonBytes", 0)),
		]
	)
	print(
		"Duplicate content: %.1f MiB total; %.1f MiB across campaign identities"
		% [
			_mib(totals.get("duplicateBytes", 0)),
			_mib(totals.get("crossCampaignDuplicateBytes", 0)),
		]
	)
	for campaign_value: Variant in report.get("campaigns", []):
		if not (campaign_value is Dictionary):
			continue
		var campaign: Dictionary = campaign_value
		var readiness: Dictionary = campaign.get("readiness", {})
		var campaign_totals: Dictionary = readiness.get("totals", {})
		print(
			"- %s: %s; %d blocker(s); %d fallback(s); %.1f MiB"
			% [
				str(campaign.get("directory", "")),
				str(campaign.get("install", {}).get("selectionState", "Invalid")),
				int(campaign_totals.get("progressionBlockers", 0)),
				int(campaign_totals.get("fidelityFallbacks", 0)),
				_mib(campaign.get("footprint", {}).get("installedBytes", 0)),
			]
		)


func _write_report(path: String, report: Dictionary) -> bool:
	var normalized := path.replace("\\", "/")
	if normalized.begins_with("res://") or normalized.begins_with("user://"):
		normalized = ProjectSettings.globalize_path(normalized)
	var parent := normalized.get_base_dir()
	if not parent.is_empty():
		var error := DirAccess.make_dir_recursive_absolute(parent)
		if error != OK:
			printerr("Could not create report directory: %s" % parent)
			return false
	var file := FileAccess.open(normalized, FileAccess.WRITE)
	if file == null:
		printerr("Could not write report: %s" % normalized)
		return false
	file.store_string(JSON.stringify(report, "\t", true) + "\n")
	file.close()
	return true


func _print_usage() -> void:
	print(
		"Usage: report_classic_campaign_corpus.gd [campaigns-directory] "
		+ "[--expected-count=13] [--output=<path>] [--json] [--no-compression]"
	)


static func _mib(value: Variant) -> float:
	return float(value) / 1048576.0
