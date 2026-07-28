extends State
class_name ExplorationState

const ClassicCampaignGlobalScript = preload(
	"res://scripts/classic_runtime/classic_campaign_global.gd"
)
const ClassicMapBridgeScript = preload("res://scripts/classic_runtime/classic_map_bridge.gd")


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
		var campaign : String = GameGlobal.currentcampaign
		var classic_campaign := GameGlobal.is_classic_campaign(campaign)
		if not classic_campaign:
			push_error(
				"Campaign '%s' cannot start without a realmz-remake-scenario v2 manifest" % campaign
			)
			StateMachine.transition_to("Inactive", {})
			return
		GameGlobal.campaign_global_script = ClassicCampaignGlobalScript.new()
		GameGlobal.cmp_resources.load_campaign_ressources( campaign )
		for pc: PlayerCharacter in GameGlobal.player_characters:
			pc.resolve_classic_learned_spell_identities(
				GameGlobal.cmp_resources.spells_book,
				SpellsIdDivinity.mappings
			)
		map = GameGlobal.map
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
			push_error("Scenario campaign start failed: %s" % classic_start.get(
				"message",
				"unknown error"
			))
			StateMachine.transition_to("Inactive", {})
			return
		map.explore_tiles_from_tilepos(Vector2(map.owcharacter.tile_position_x,map.owcharacter.tile_position_y))
		map.visible = true
		UI.show_only(UI.ow_hud)
		UI.ow_hud.initialize()
		# A restored command is replayed only after its Godot map and HUD exist.
		GameGlobal.call_deferred("resume_current_classic_continuation")
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
		canwalk = canwalk and not ( idef['wall'] != 0 or idef['swall'] != 0 )
	_play_tile_stack_sound(stack)
			
	# check for scripts checked the map :
	var canwalk_path : bool = GameGlobal.map.mapsecretpaths.has(Vector2i(position))
	var canwalk_secret : bool = false
	if GameGlobal.map.mapsecrets.has(Vector2i(position)) :
		if GameGlobal.map.mapsecrets[Vector2i(position)][0]== 1 :
			canwalk_secret  = true
	
	var mapfocuschar: Variant = GameGlobal.map.focuscharacter
	var current_position := Vector2i(
		int(mapfocuschar.tile_position_x),
		int(mapfocuschar.tile_position_y)
	)
	var classic_movement: Dictionary = GameGlobal.resolve_classic_map_movement(
		current_position,
		Vector2i(position)
	)
	if bool(classic_movement.get("handled", false)):
		canwalk = bool(classic_movement.get("allowed", false))
		if canwalk and classic_movement.has("movementTime"):
			timetowalk = int(classic_movement["movementTime"])
		if str(classic_movement.get("status", "")) == "error":
			push_error(str(classic_movement.get(
				"message",
				"Classic dungeon movement failed"
			)))
	else:
		canwalk = (canwalk or canwalk_path or canwalk_secret)
	if canwalk :
		if is_instance_valid(GameGlobal.classic_campaign_session):
			timetowalk = GameGlobal.classic_movement_pass_time_units(
				timetowalk,
				stack
			)
		if canwalk_path :
			GameGlobal.map.set_secretpath_seen( Vector2i(position) )
		if canwalk_secret :
			GameGlobal.map.set_secret_seen( Vector2i(position) )
	return [canwalk, timetowalk ]


func _play_tile_stack_sound(stack: Array) -> void:
	var selection := ClassicMapBridgeScript.select_tile_stack_sound(stack)
	var native_sounds: Variant = selection.get("nativeSounds", [])
	if native_sounds is Array and not native_sounds.is_empty():
		var sounds: Array = native_sounds.duplicate()
		sounds.shuffle()
		SfxPlayer.stream = GameGlobal.cmp_resources.sounds_book[sounds[0]]
		SfxPlayer.play()
		return
	var classic_sound_id := int(selection.get("classicSoundId", 0))
	if classic_sound_id == 0:
		return
	var result: Dictionary = GameGlobal.play_classic_map_sound(classic_sound_id)
	if str(result.get("status", "")) == "error":
		push_error(str(result.get("message", "Classic map sound playback failed")))
