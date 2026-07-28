class_name MapPort
extends DelegatingScenarioPort

const COMMANDS := [
	"redraw_map",
	"set_map_tile",
	"set_trigger_percent",
	"teleport",
	"shift_party_position",
	"alter_game_time",
	"set_camping_permission",
	"update_exploration_status",
	"set_view_direction",
	"set_view_mode",
	"set_map_darkness",
	"set_random_encounter_rect",
	"set_land_look",
	"give_map",
	"back_up_party",
]
const OPERATIONS := {
	"redraw_map": "_redraw_map",
	"set_map_tile": "_set_map_tile",
	"set_trigger_percent": "_set_trigger_percent",
	"teleport": "_teleport_classic_party",
	"shift_party_position": "_shift_party_position",
	"alter_game_time": "_alter_game_time",
	"set_camping_permission": "_set_camping_permission",
	"update_exploration_status": "_update_exploration_status",
	"set_view_direction": "_set_view_direction",
	"set_view_mode": "_set_view_mode",
	"set_map_darkness": "_set_map_darkness",
	"set_random_encounter_rect": "_set_random_encounter_rect",
	"set_land_look": "_set_land_look",
	"give_map": "_give_player_map",
	"back_up_party": "_back_up_party",
}


func port_id() -> String:
	return "core.map"


func service_operation(command_id: String) -> String:
	return str(OPERATIONS.get(command_id, ""))


func owned_command_ids() -> PackedStringArray:
	return PackedStringArray(COMMANDS)
