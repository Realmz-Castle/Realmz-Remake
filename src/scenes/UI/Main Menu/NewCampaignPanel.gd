extends NinePatchRect

const ClassicCampaignPackageInstallerScript = preload(
	"res://scripts/classic_runtime/classic_campaign_package_installer.gd"
)
const ClassicStockCharacterRosterScript = preload(
	"res://scripts/classic_runtime/classic_stock_character_roster.gd"
)
const GameplayRuleRegistryScript = preload(
	"res://scripts/scenario_runtime/gameplay_rule_registry.gd"
)
const GameplayRuleSetScript = preload(
	"res://scripts/scenario_runtime/gameplay_rule_set.gd"
)

@onready var campaignsItemList : ItemList = $VBoxContainer/HBoxContainertT/ScenarioListVBox/CampaignsItemList
@onready var selectedCampaignNameLabel : Label = $VBoxContainer/HBoxContainertT/ScenDescrVBox/SelectedCampaignNameLabel
@onready var selectedCampaignDescrLabel: Label = $VBoxContainer/HBoxContainertT/ScenDescrVBox/SelectedCampaignDescrLabel
@onready var classicImportStatusLabel: Label = $VBoxContainer/ClassicImportStatusLabel
@onready var gameplayRulesPanel: VBoxContainer = $VBoxContainer/GameplayRulesPanel
@onready var gameplayPresetOption: OptionButton = (
	$VBoxContainer/GameplayRulesPanel/PresetRow/GameplayPresetOption
)
@onready var gameplayAdvancedCheck: CheckButton = (
	$VBoxContainer/GameplayRulesPanel/GameplayAdvancedCheck
)
@onready var gameplayAdvancedVBox: VBoxContainer = (
	$VBoxContainer/GameplayRulesPanel/GameplayAdvancedVBox
)

var selectedcampaign_onselect

@onready var startButton : Button = $VBoxContainer/HBoxContainerB/StartControl/StartButton
@onready var createCharacterButton : Button = (
	$VBoxContainer/HBoxContainerB/CreateCharacterControl/CreateCharacterButton
)
@onready var importClassicButton: Button = (
	$VBoxContainer/HBoxContainerB/ImportClassicControl/ImportClassicButton
)
@onready var classicImportDialog: FileDialog = $ClassicImportDialog
@onready var classicReplaceDialog: ConfirmationDialog = $ClassicReplaceDialog
@onready var classicImportResultDialog: AcceptDialog = $ClassicImportResultDialog

@onready var charPickRect : Control = $VBoxContainer/HBoxContainertT/PartyControl/CharPickRect


var campaignslist : Array = [] # array of Strings
var characterfoldernameslist : Array = [] # array of String
var characterslist : Array = [] # array of Character.gd objects
var charactersdict : Dictionary = {}  #  name : characterGD


var selectedCampaign : String = ''
var selected_campaign_index := -1

var pickedparty : Array = []
var pending_classic_import_directory := ""
var classic_import_in_progress := false
var gameplay_rule_registry: GameplayRuleRegistry
var gameplay_rule_selection: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	charPickRect.my_menu = self
	var _err_connnectcampaign = campaignsItemList.connect("item_selected",Callable(self,"_on_campaign_selected"))
#	campaignsItemList.connect("nothing_selected",Callable(self,"_on_campaign_unselected"))
	var _err_connectstartbutton = startButton.connect("pressed",Callable(self,"_on_StartButton_pressed"))
	gameplayPresetOption.item_selected.connect(_on_gameplay_preset_selected)
	gameplayAdvancedCheck.toggled.connect(_on_gameplay_advanced_toggled)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_CancelButton_pressed() -> void :
	self.hide()
#	self.get_parent().get_parent().newCharacterButton.show()

func _on_ImportClassicButton_pressed() -> void:
	var initial_directory := OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	if initial_directory.is_empty():
		initial_directory = Paths.realmzfolderpath
	classicImportDialog.current_dir = initial_directory
	classicImportDialog.popup_centered_ratio(0.8)


func _on_ClassicImportDialog_dir_selected(directory: String) -> void:
	request_classic_campaign_import(directory)


func request_classic_campaign_import(directory: String) -> void:
	if classic_import_in_progress:
		return
	var source_directory := _normalized_directory(directory)
	if source_directory.is_empty():
		_show_classic_import_error("Choose a complete Classic campaign export directory.")
		return
	pending_classic_import_directory = source_directory
	var campaign_name := source_directory.get_file()
	var destination := _normalized_directory(
		Paths.campaignsfolderpath
	).path_join(campaign_name)
	if DirAccess.dir_exists_absolute(destination):
		classicReplaceDialog.dialog_text = (
			"“%s” is already installed.\n\n"
			+ "Replace it with the selected export? The new package is validated "
			+ "before the installed copy is changed."
		) % campaign_name
		classicReplaceDialog.popup_centered()
		return
	call_deferred("_install_pending_classic_campaign", false)


func _on_ClassicReplaceDialog_confirmed() -> void:
	call_deferred("_install_pending_classic_campaign", true)


func _on_ClassicReplaceDialog_canceled() -> void:
	pending_classic_import_directory = ""
	_set_classic_import_status("Classic campaign installation canceled.", false)


func _install_pending_classic_campaign(replace_existing: bool) -> void:
	if classic_import_in_progress or pending_classic_import_directory.is_empty():
		return
	var source_directory := pending_classic_import_directory
	pending_classic_import_directory = ""
	classic_import_in_progress = true
	importClassicButton.disabled = true
	_set_classic_import_status(
		"Installing %s…" % source_directory.get_file(),
		false
	)
	await get_tree().process_frame

	var installer = ClassicCampaignPackageInstallerScript.new()
	var result: Dictionary = installer.install_export(
		source_directory,
		Paths.campaignsfolderpath,
		replace_existing
	)
	classic_import_in_progress = false
	importClassicButton.disabled = false
	if str(result.get("status", "")) != "ok":
		_show_classic_import_error(
			str(result.get("message", "Classic campaign installation failed."))
		)
		return

	var campaign_name := str(result.get("campaignName", source_directory.get_file()))
	GameGlobal.clear_classic_campaign_install_cache(campaign_name)
	fill()
	_select_campaign_by_name(campaign_name)
	var action := (
		"Updated" if bool(result.get("replacedExisting", false)) else "Installed"
	)
	var status := "%s %s — %s." % [
		action,
		campaign_name,
		result.get("readinessState", "Ready"),
	]
	var readiness_summary := str(result.get("readinessSummary", "")).strip_edges()
	if not readiness_summary.is_empty():
		status += " %s" % readiness_summary
	var warnings: Array = result.get("warnings", [])
	if not warnings.is_empty():
		status += " Warning: %s" % " ".join(warnings)
	_set_classic_import_status(status, false)
	classicImportResultDialog.title = "Classic Campaign Installed"
	classicImportResultDialog.dialog_text = status
	classicImportResultDialog.popup_centered()


func _show_classic_import_error(message: String) -> void:
	var status := "Install failed: %s" % message
	_set_classic_import_status(status, true)
	classicImportResultDialog.title = "Classic Campaign Install Failed"
	classicImportResultDialog.dialog_text = message
	classicImportResultDialog.popup_centered()


func _set_classic_import_status(message: String, is_error: bool) -> void:
	classicImportStatusLabel.text = message
	classicImportStatusLabel.modulate = (
		Color(1.0, 0.55, 0.45) if is_error else Color.WHITE
	)
	classicImportStatusLabel.visible = not message.is_empty()


func _select_campaign_by_name(campaign_name: String) -> void:
	for item_index: int in range(campaignsItemList.item_count):
		var metadata: Variant = campaignsItemList.get_item_metadata(item_index)
		if metadata is Dictionary \
				and str(metadata.get("campaignName", "")) == campaign_name:
			campaignsItemList.select(item_index)
			campaignsItemList.ensure_current_is_visible()
			_on_campaign_selected(item_index)
			return


func _normalized_directory(path: String) -> String:
	var stripped := path.strip_edges()
	if stripped.is_empty():
		return ""
	return (
		ProjectSettings.globalize_path(stripped)
		.replace("\\", "/")
		.simplify_path()
		.trim_suffix("/")
	)


func _on_campaign_selected(idx : int) -> void :
	set_ready(false, [])
	selected_campaign_index = idx
	createCharacterButton.disabled = true
	var metadata: Variant = campaignsItemList.get_item_metadata(idx)
	if not (metadata is Dictionary):
		return
	selectedCampaign = str(metadata.get("campaignName", ""))
	selectedcampaign_onselect = metadata.get("selectionRules")
	if bool(metadata.get("busy", false)):
		selectedCampaignDescrLabel.text = (
			selectedCampaign
			+ "\nThis campaign is already in use by another party.\nDelete that game first."
		)
		return
	if (
		selectedcampaign_onselect is Dictionary
		and bool(selectedcampaign_onselect.get("preview", false))
	):
		selectedcampaign_onselect = GameGlobal.get_campaign_selection_rules(
			selectedCampaign
		)
		metadata = metadata.duplicate(true)
		metadata["selectionRules"] = selectedcampaign_onselect
		campaignsItemList.set_item_metadata(idx, metadata)
		campaignsItemList.set_item_text(
			idx,
			_campaign_display_name(selectedCampaign, selectedcampaign_onselect)
		)
	createCharacterButton.disabled = not (
		selectedcampaign_onselect is Dictionary
		and bool(selectedcampaign_onselect.get("classic", false))
		and bool(selectedcampaign_onselect.get("valid", false))
	)
	if not createCharacterButton.disabled:
		var roster_result: Dictionary = (
			ClassicStockCharacterRosterScript.ensure_for_current_profile()
		)
		if str(roster_result.get("status", "")) == "ok":
			if not roster_result.get("created", []).is_empty():
				GameGlobal.load_profile_characters()
		else:
			push_warning(str(roster_result.get(
				"message",
				"Classic stock characters could not be installed."
			)))

	if selectedcampaign_onselect is Dictionary:
		selectedCampaignNameLabel.text = str(
			selectedcampaign_onselect.get("title", selectedCampaign)
		)
		selectedCampaignDescrLabel.text = _classic_campaign_description(
			selectedcampaign_onselect
		)
		_configure_gameplay_rules()
	else:
		gameplayRulesPanel.visible = false
		gameplay_rule_selection = {}
		selectedCampaignNameLabel.text = selectedCampaign
		selectedCampaignDescrLabel.text = GameGlobal.get_campaign_description(selectedCampaign)
	#reset the character picking panel
	charPickRect.fill()

func _on_StartButton_pressed() -> void :
	if selectedcampaign_onselect is Dictionary and not bool(
		selectedcampaign_onselect.get("valid", false)
	):
		return
	GameGlobal.set_current_campaign(
		selectedCampaign,
		selectedcampaign_onselect,
		gameplay_rule_selection
	)
	var data_dict : Dictionary = {
		"fatigue" = 0.0,
		"position" = Vector2.ZERO,
		"time" = 0,
		"money_pool" = [0,0,0],
		"money_banked" = [0,0,0],
		"light_time" = 0,
		"light_power" = 0,
		"classic_light_condition" = 0,
		"classic_party_conditions" = {},
		"camping" = 0,
		"classic_camping_disabled" = 0,
		"allow_char_swap" = 0,
		"curr_temple" = [],
		"curr_shop" = '',
		"stuff_done" = {},
		"native_encounters" = {},
		"map_boats_dict" = {},
		"is_sailing_boat" = 0,
		"boat_image" = 'no boat_image',
		"save_name" = "",
		"save_descr" = '',
		"campaign" = selectedCampaign,
		"gameplay_rule_selection" = gameplay_rule_selection.duplicate(true),
		"currentmap_name" = "Default Map",
		"shops_dict" = {},
		"minimaps" = [],
		"GlobalEffects" = {
			"WaterBreath" : {"Duration" : 0},
			"FeatherFall" : {"Duration" : 0},
			"Awareness" : {"Duration" : 0},
			"Scrying" : {"Duration" : 0},
			"Shielded" : {"Duration" : 0},
			"Sentry" : {"Duration" : 0},
			"CharmProt" : {"Duration" : 0}
		}
	}
	for pc in pickedparty :
		pc.cur_campaign = GameGlobal.currentcampaign
	GameGlobal.player_characters = pickedparty
	GameGlobal.init_globals_before_game_start(data_dict)
	
	StateMachine.transition_to("Exploration", {"campaign_start" : true})
	#GameState._state = GameGlobal.eGameStates.startGame
	#transition here ?
#	GameGlobal.startCampaign(selectedCampaign)
	#get_tree().get_root().remove_child(get_parent().get_parent().get_parent())
#
#	print("STARTCAMPAIGN playerchat0 item0 ", pickedparty[0].inventory[0])
	return
		




func fill() -> void :
	selectedCampaign = ""
	selected_campaign_index = -1
	selectedcampaign_onselect = null
	selectedCampaignNameLabel.text = ""
	selectedCampaignDescrLabel.text = ""
	set_ready(false, [])
	createCharacterButton.disabled = true
	gameplayRulesPanel.visible = false
	gameplay_rule_selection = {}

	campaignslist = Utils.FileHandler.list_dirs_in_directory(Paths.campaignsfolderpath)
	campaignsItemList.clear()
	for campaign_value: Variant in campaignslist:
		var campaign_name := str(campaign_value)
		if not GameGlobal.is_classic_campaign(campaign_name):
			continue
		var selection_rules: Variant = GameGlobal.get_campaign_selection_preview(
			campaign_name
		)
		var display_name := _campaign_display_name(campaign_name, selection_rules)
		var busy := false
		if GameGlobal.honest_mode :
			var savepath : String = (
				Paths.profilesfolderpath
				+ GameGlobal.currentprofile
				+ "/Saves/"
				+ campaign_name
				+ "/"
			)
			if DirAccess.dir_exists_absolute(savepath) :
				if Utils.FileHandler.list_dirs_in_directory(savepath).size()>0 :
					busy = true
					display_name += " (busy)"
		var item_index := campaignsItemList.item_count
		campaignsItemList.add_item(display_name)
		campaignsItemList.set_item_metadata(item_index, {
			"campaignName": campaign_name,
			"selectionRules": selection_rules,
			"busy": busy,
		})

	return


func _configure_gameplay_rules() -> void:
	gameplayRulesPanel.visible = (
		selectedcampaign_onselect is Dictionary
		and bool(selectedcampaign_onselect.get("classic", false))
		and bool(selectedcampaign_onselect.get("valid", false))
	)
	gameplay_rule_selection = {}
	if not gameplayRulesPanel.visible:
		return
	gameplay_rule_registry = GameplayRuleRegistryScript.new()
	if not gameplay_rule_registry.load_builtin_catalog():
		gameplayRulesPanel.visible = false
		selectedCampaignDescrLabel.text += "\nRules unavailable: %s" % gameplay_rule_registry.last_error
		return
	var recommended_preset := "core.classic"
	var install: Variant = GameGlobal.get_classic_campaign_install(selectedCampaign)
	if install != null and install.get("bundle") != null:
		recommended_preset = str(
			install.bundle.documents.get("runtime", {}).get(
				"recommendedGameplayProfile",
				recommended_preset
			)
		)
	gameplayPresetOption.clear()
	var preset_ids: Array = gameplay_rule_registry.presets.keys()
	preset_ids.sort()
	var selected_index := 0
	for preset_id: String in preset_ids:
		var item_index := gameplayPresetOption.item_count
		gameplayPresetOption.add_item(_gameplay_preset_label(preset_id))
		gameplayPresetOption.set_item_metadata(item_index, preset_id)
		if preset_id == recommended_preset:
			selected_index = item_index
	gameplayPresetOption.select(selected_index)
	gameplayAdvancedCheck.button_pressed = false
	gameplayAdvancedVBox.visible = false
	_on_gameplay_preset_selected(selected_index)


func _on_gameplay_preset_selected(index: int) -> void:
	if gameplay_rule_registry == null or index < 0:
		return
	var preset_id := str(gameplayPresetOption.get_item_metadata(index))
	gameplay_rule_selection = {"presetId": preset_id, "domains": {}}
	_rebuild_gameplay_advanced_controls()


func _on_gameplay_advanced_toggled(enabled: bool) -> void:
	gameplayAdvancedVBox.visible = enabled
	if enabled:
		_rebuild_gameplay_advanced_controls()


func _rebuild_gameplay_advanced_controls() -> void:
	for child: Node in gameplayAdvancedVBox.get_children():
		child.free()
	if gameplay_rule_registry == null:
		return
	var resolved := gameplay_rule_registry.resolve(
		str(gameplay_rule_selection.get("presetId", "core.classic")),
		gameplay_rule_selection.get("domains", {})
	)
	if str(resolved.get("status", "")) != "ok":
		var error_label := Label.new()
		error_label.text = str(resolved.get("message", "Gameplay rules are invalid"))
		gameplayAdvancedVBox.add_child(error_label)
		return
	var ruleset: GameplayRuleSet = resolved["ruleset"]
	for domain: String in GameplayRuleSetScript.DOMAINS:
		var domain_box := VBoxContainer.new()
		var provider_row := HBoxContainer.new()
		var label := Label.new()
		label.text = _gameplay_domain_label(domain)
		label.custom_minimum_size.x = 150.0
		provider_row.add_child(label)
		var provider_option := OptionButton.new()
		provider_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var provider_ids: Array = []
		for provider_id: String in gameplay_rule_registry.providers:
			var provider: GameplayRuleProvider = gameplay_rule_registry.providers[provider_id]
			if provider.domain == domain:
				provider_ids.append(provider_id)
		provider_ids.sort()
		var selected_provider_index := 0
		for provider_id: String in provider_ids:
			var item_index := provider_option.item_count
			provider_option.add_item(provider_id)
			provider_option.set_item_metadata(item_index, provider_id)
			if provider_id == ruleset.provider_id(domain):
				selected_provider_index = item_index
		provider_option.select(selected_provider_index)
		provider_option.item_selected.connect(
			_on_gameplay_provider_selected.bind(domain, provider_option)
		)
		provider_row.add_child(provider_option)
		domain_box.add_child(provider_row)
		var provider: GameplayRuleProvider = gameplay_rule_registry.providers[
			ruleset.provider_id(domain)
		]
		var option_values := ruleset.options(domain)
		for option_id: String in provider.option_schema:
			domain_box.add_child(
				_create_gameplay_option_row(
					domain,
					option_id,
					provider.option_schema[option_id],
					option_values[option_id]
				)
			)
		gameplayAdvancedVBox.add_child(domain_box)


func _on_gameplay_provider_selected(
	index: int,
	domain: String,
	provider_option: OptionButton
) -> void:
	var domains: Dictionary = gameplay_rule_selection.get("domains", {}).duplicate(true)
	domains[domain] = {
		"providerId": str(provider_option.get_item_metadata(index)),
		"options": {},
	}
	gameplay_rule_selection["domains"] = domains
	_rebuild_gameplay_advanced_controls()


func _create_gameplay_option_row(
	domain: String,
	option_id: String,
	schema: Dictionary,
	value: Variant
) -> Control:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = option_id
	label.custom_minimum_size.x = 175.0
	row.add_child(label)
	match str(schema.get("type", "")):
		"boolean":
			var checkbox := CheckButton.new()
			checkbox.button_pressed = bool(value)
			checkbox.toggled.connect(
				func(enabled: bool) -> void:
					_set_gameplay_option(domain, option_id, enabled)
			)
			row.add_child(checkbox)
		"enum":
			var option := OptionButton.new()
			option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var values: Array = schema.get("values", [])
			for enum_value: Variant in values:
				option.add_item(str(enum_value))
			option.select(maxi(0, values.find(value)))
			option.item_selected.connect(
				func(index: int) -> void:
					_set_gameplay_option(domain, option_id, values[index])
			)
			row.add_child(option)
		"integer", "float":
			var spin := SpinBox.new()
			spin.allow_greater = false
			spin.allow_lesser = false
			spin.min_value = float(schema.get("minimum", -1000000))
			spin.max_value = float(schema.get("maximum", 1000000))
			spin.step = 1.0 if schema["type"] == "integer" else 0.1
			spin.value = float(value)
			spin.value_changed.connect(
				func(next_value: float) -> void:
					_set_gameplay_option(
						domain,
						option_id,
						int(next_value) if schema["type"] == "integer" else next_value
					)
			)
			row.add_child(spin)
	return row


func _set_gameplay_option(domain: String, option_id: String, value: Variant) -> void:
	var domains: Dictionary = gameplay_rule_selection.get("domains", {}).duplicate(true)
	var selection: Dictionary = domains.get(domain, {
		"providerId": "",
		"options": {},
	}).duplicate(true)
	if str(selection.get("providerId", "")).is_empty():
		var resolved := gameplay_rule_registry.resolve(
			str(gameplay_rule_selection.get("presetId", "core.classic")),
			domains
		)
		if str(resolved.get("status", "")) != "ok":
			return
		selection["providerId"] = resolved["ruleset"].provider_id(domain)
	var options: Dictionary = selection.get("options", {}).duplicate(true)
	options[option_id] = value
	selection["options"] = options
	domains[domain] = selection
	gameplay_rule_selection["domains"] = domains


func _gameplay_preset_label(preset_id: String) -> String:
	if preset_id == "core.classic":
		return "Classic fidelity (recommended)"
	if preset_id == "core.samuel":
		return "Samuel native behavior"
	return preset_id


func _gameplay_domain_label(domain: String) -> String:
	return {
		"mapTime": "Map / Time",
		"combat": "Combat",
		"inventory": "Inventory",
		"character": "Character",
		"presentation": "Presentation",
		"persistence": "Persistence",
	}.get(domain, domain)


func _campaign_display_name(campaign_name: String, selection_rules: Variant) -> String:
	if selection_rules is Dictionary:
		if bool(selection_rules.get("preview", false)):
			return "%s — Classic" % selection_rules.get("title", campaign_name)
		return "%s — Classic: %s" % [
			selection_rules.get("title", campaign_name),
			selection_rules.get("readinessState", "Invalid"),
		]
	return "%s — Unsupported legacy format" % campaign_name


func _on_CreateCharacterButton_pressed() -> void:
	if createCharacterButton.disabled or selectedCampaign.is_empty():
		return
	var character_panel: Variant = get_parent().get_node_or_null(
		"NewCharacterPanel"
	)
	if character_panel == null \
			or not character_panel.has_method("configure_classic_campaign"):
		selectedCampaignDescrLabel.text += (
			"\nCannot create: the character editor is unavailable."
		)
		return
	var result: Variant = character_panel.call(
		"configure_classic_campaign",
		selectedCampaign,
		self
	)
	if not (result is Dictionary) \
			or str(result.get("status", "")) != "ok":
		selectedCampaignDescrLabel.text += "\nCannot create: %s" % str(
			result.get("message", "Classic character setup failed.")
			if result is Dictionary
			else "Classic character setup failed."
		)
		return
	hide()
	character_panel.show()


func resume_after_character_creation(campaign_name: String) -> void:
	fill()
	show()
	for item_index: int in range(campaignsItemList.item_count):
		var metadata: Variant = campaignsItemList.get_item_metadata(item_index)
		if metadata is Dictionary \
				and str(metadata.get("campaignName", "")) == campaign_name:
			campaignsItemList.select(item_index)
			_on_campaign_selected(item_index)
			return


func _classic_campaign_description(selection_rules: Dictionary) -> String:
	var lines: Array[String] = [
		str(selection_rules.get("description", "")),
		str(selection_rules.get("versionLabel", "")),
		"Status: %s" % selection_rules.get("readinessState", "Invalid"),
		str(selection_rules.get("readinessSummary", "")),
	]
	if bool(selection_rules.get("valid", false)):
		lines.append(
			"Party: %s" % selection_rules.get("restrictionsDescription", "")
		)
	var diagnostic := str(selection_rules.get("diagnostic", "")).strip_edges()
	if not diagnostic.is_empty():
		lines.append("Cannot start: %s" % diagnostic)
	var visible_lines: Array[String] = []
	for line: String in lines:
		if not line.is_empty():
			visible_lines.append(line)
	return "\n".join(visible_lines)

func set_ready(rdy : bool, party : Array) :
	startButton.disabled = not rdy
	if rdy :
		pickedparty = party#GameGlobal.player_characters = party
	else :
		pickedparty = []
#	print("characters : ",characterlist)
