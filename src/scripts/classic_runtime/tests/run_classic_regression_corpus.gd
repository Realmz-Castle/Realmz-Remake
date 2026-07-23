extends SceneTree

const CorpusScript = preload(
	"res://scripts/classic_runtime/classic_regression_corpus.gd"
)


func _init() -> void:
	var manifest_path := CorpusScript.DEFAULT_MANIFEST
	var json_output := false
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--json":
			json_output = true
		elif not argument.begins_with("--"):
			manifest_path = argument
	var corpus = CorpusScript.new()
	var report: Dictionary = corpus.run(manifest_path)
	if json_output:
		print(JSON.stringify(report))
	else:
		print(
			"Classic regression corpus: %d scenario(s), %d domain(s)"
			% [
				report.get("scenarios", []).size(),
				report.get("domains", []).size(),
			]
		)
		for scenario_value: Variant in report.get("scenarios", []):
			if not (scenario_value is Dictionary):
				continue
			print(
				"  %s: %s (%d case(s))"
				% [
					scenario_value.get("scenarioId", ""),
					"PASS" if bool(scenario_value.get("ok", false)) else "FAIL",
					scenario_value.get("cases", []).size(),
				]
			)
		print(
			"  classifications: %s"
			% report.get("classificationCounts", {})
		)
		for failure_value: Variant in report.get("failures", []):
			if failure_value is Dictionary:
				printerr(corpus.format_failure(failure_value))
	if bool(report.get("ok", false)):
		if not json_output:
			print("Classic regression corpus passed.")
		quit(0)
		return
	if not json_output:
		printerr("Classic regression corpus failed.")
	quit(1)
