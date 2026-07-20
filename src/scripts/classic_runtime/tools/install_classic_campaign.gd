extends SceneTree

const PackageInstallerScript = preload(
	"res://scripts/classic_runtime/classic_campaign_package_installer.gd"
)


func _init() -> void:
	var arguments := OS.get_cmdline_user_args()
	var replace_existing := arguments.has("--replace")
	var json_output := arguments.has("--json")
	arguments.erase("--replace")
	arguments.erase("--json")
	if arguments.is_empty() or arguments.size() > 2:
		_print_usage()
		quit(2)
		return

	var campaigns_directory := "res://Campaigns"
	if arguments.size() == 2:
		campaigns_directory = str(arguments[1])
	var installer = PackageInstallerScript.new()
	var result: Dictionary = installer.install_export(
		str(arguments[0]),
		campaigns_directory,
		replace_existing
	)
	if json_output:
		print(JSON.stringify(result))
	elif str(result.get("status", "error")) == "ok":
		print("Installed Classic campaign: %s" % result.get("campaignName", ""))
		print("Destination: %s" % result.get("installedDirectory", ""))
		print("Readiness: %s" % result.get("readinessState", "Ready"))
		for warning: String in result.get("warnings", []):
			printerr("Warning: %s" % warning)
	else:
		printerr("Classic campaign installation failed: %s" % result.get("message", ""))
	quit(0 if str(result.get("status", "error")) == "ok" else 1)


func _print_usage() -> void:
	printerr(
		"Usage: install_classic_campaign.gd <export-directory> " + \
		"[campaigns-directory] [--replace] [--json]"
	)
