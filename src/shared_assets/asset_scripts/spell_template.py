# Template for the GDScript content
gdscript_template = """var name : String = '{name}'
var attributes : Array = []
var tags : Array = {tags}
var schools : Array = {schools}

var targettile : int = {target_type}  #0=anywhere 1=creature 2=empty 3=nowall 

var level : int = {level}
var selection_cost : int = {selection_cost}
var max_plevel : int = 7
var in_field : bool = {usable_in_camp}
var in_combat : bool = {usable_in_combat}
var description : String = '{description}'
var resist : int = {resist_adjust} #ignores resistances and dodge
var los : bool = true # line of sight where does this come from?
var ray : bool = false # Where does this come from?
var rot : bool = {can_rotate}
{proj_tex}
{proj_hit}
var sounds : Array = {sounds}
var max_focus_loss : int = 0

static func get_targets(_power : int, __casterchar)->int :
\treturn 1

static func get_min_duration(_power : int, __casterchar) -> int :
\treturn 0

static func get_max_duration(_power : int, __casterchar) -> int :
\treturn 0

static func get_range(_power : int, __casterchar) -> int :
\treturn {range}

static func get_min_damage(_power:int, _casterchar) :
\treturn {min_damage}

static func get_max_damage(_power:int, _casterchar) :
\treturn {max_damage}

static func get_damage_roll(_power : int, _casterchar) :
\treturn 0

static func get_accuracy(_casterchar, _power : int) :
\treturn 100 #= infinite wiith resist==0 anyway

static func get_sp_cost(_power : int, _casterchar) :
\treturn _power*{base_cost}

static func get_target_number(_power : int, _casterchar) :
\treturn 1

static func get_aoe(_power : int, _casterchar) :
\treturn 'b1'

{special_effect_function}

"""