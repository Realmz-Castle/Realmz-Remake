extends State
class_name ExplorationState

const ClassicCampaignGlobalScript = preload(
	"res://scripts/classic_runtime/classic_campaign_global.gd"
)


var map : Map
var state_machine : GameStateMachine
#var last_dir_input : Vector2 = Vector2.ZERO
#var time_since_last_dir_input : float = 0

#var warned_empty_pool : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	state_machine = get_parent()
	pass # Replace with function body.

func exit() :
	pass

func enter(_msg : Dictionary = {}) -> void:
	if _msg.has("campaign_start") or  _msg.has("campaign_continue") :
		var is_start : bool = _msg["campaign_start"] if _msg.has("campaign_start") else false
		var campaign : String = GameGlobal.currentcampaign
		var classic_campaign := GameGlobal.is_classic_campaign(campaign)
		var onstartGD: Variant = GameGlobal.get_native_campaign_start_script(campaign)
		if is_start and onstartGD != null:
			onstartGD.before_loading_ressources()
		if classic_campaign:
			GameGlobal.campaign_global_script = ClassicCampaignGlobalScript.new()
		else:
			GameGlobal.campaign_global_script = load(
				Paths.campaignsfolderpath + campaign + "/campaign_global_script.gd"
			).new()
		GameGlobal.cmp_resources.load_campaign_ressources( campaign )

		if not classic_campaign:
			GameGlobal.load_shops_script(campaign)
			GameGlobal.campaign_start_load_shops_data(GameGlobal.cmp_resources.items_book)
		map = GameGlobal.map
		if is_start and onstartGD != null:
			onstartGD.after_loading_ressources()
		if classic_campaign:
			var saved_payload_value: Variant = _msg.get("classic_save_payload", {})
			var saved_payload: Dictionary = saved_payload_value \
				if saved_payload_value is Dictionary else {}
			var legacy_location_value: Variant = _msg.get("classic_legacy_location", {})
			var legacy_location: Dictionary = legacy_location_value \
				if legacy_location_value is Dictionary else {}
			var classic_start: Dictionary = GameGlobal.start_current_classic_campaign(
				saved_payload,
				legacy_location
			)
			if str(classic_start.get("status", "")) == "error":
				push_error("Classic campaign start failed: %s" % classic_start.get(
					"message",
					"unknown error"
				))
				StateMachine.transition_to("Inactive", {})
				return
		else:
			map.load_map( campaign, GameGlobal.currentmap_name )
		map.explore_tiles_from_tilepos(Vector2(map.owcharacter.tile_position_x,map.owcharacter.tile_position_y))
		map.visible = true
		UI.show_only(UI.ow_hud)
		UI.ow_hud.initialize()
		print("ExplorationState campaign_start or campaign_continue done")
		for pc in GameGlobal.player_characters :
			pc.cur_campaign = campaign


func _state_process(_delta: float) -> void:
#	print("_state_process : "+name)
	#Set the mouse cursor...
	state_machine.call_deferred("set_arrow_mouse_cursor", _delta)


func _on_dir_input_received(input : Vector2i, _is_keyboard : bool) -> void :
	StateMachine.transition_to("Exploration/ExAnim", {"walk_inputs" : [input]})


func on_trying_to_move_to_tile_stack(_crea : Creature, stack : Array, position : Vector2) : #exporation mode
	var canwalk : bool = true
	var soundplayed : bool = false
	var stacksize = stack.size()
	var timetowalk : int = 0
	for i  in range(stack.size()) :
		var idef = stack[stacksize-i-1]
		timetowalk += idef["time"]
		if ((not GameGlobal.is_sailing_boat) and idef['water'] != 0) :
			if not GameGlobal.map.mapboats.has(Vector2i(position)) :
				canwalk = false
				timetowalk -= idef["time"]
				timetowalk += 5
		if GameGlobal.is_sailing_boat :
			if idef['water'] == 0 and idef['dock'] == 0 :
				canwalk = false
		canwalk = not ( idef['wall'] != 0 or idef['swall'] != 0 )
		if not soundplayed and idef['sound'] != [] :
			soundplayed = true
			var soundslist : Array = idef['sound']
			soundslist.shuffle()
			SfxPlayer.stream = GameGlobal.cmp_resources.sounds_book[soundslist[0]]
			SfxPlayer.play()
			
	# check for scripts checked the map :
	var canwalk_path : bool = GameGlobal.map.mapsecretpaths.has(Vector2i(position))
	var canwalk_secret : bool = false
	if GameGlobal.map.mapsecrets.has(Vector2i(position)) :
		if GameGlobal.map.mapsecrets[Vector2i(position)][0]== 1 :
			canwalk_secret  = true
	
	canwalk = (canwalk or canwalk_path or canwalk_secret) 
	if canwalk :
		if canwalk_path :
			GameGlobal.map.set_secretpath_seen( Vector2i(position) )
		if canwalk_secret :
			GameGlobal.map.set_secret_seen( Vector2i(position) )
	return [canwalk, timetowalk ]
