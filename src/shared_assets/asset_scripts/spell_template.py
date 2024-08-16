# Template for the GDScript content
gdscript_template = """var name : String = '{name}'
# Can we auto-generate this?
var attributes : Array = []
# Can we auto-generate this?
var tags : Array = {tags}

# Not merged with duplicates
var schools : Array = {schools}

# Fuction of target type, effect (phase), and line of sight
var targettile : int = {target_type}  #0=anywhere 1=creature 2=empty 3=nowall 

var level : int = {level}
var selection_cost : int = {selection_cost}
var max_plevel : int = 7 # Is this ever not 7?
var in_field : bool = {usable_in_camp}
var in_combat : bool = {usable_in_combat}
var description : String = '{description}'

# How does this work?
var resist : int = 0 #ignores resistances and dodge 
var los : bool = {is_los} # line of sight
var ray : bool = {is_ray}
var rot : bool = {can_rotate}
{proj_tex}
{proj_hit}
var sounds : Array = {sounds}
var max_focus_loss : int = 0 # Where does this come from?

# Is this number of targets?
static func get_targets(_power : int, __casterchar)->int :
\treturn 1

# How does this relate to duration roll?
static func get_min_duration(_power : int, __casterchar) -> int :
\treturn 0

# How does this relate to duration roll?
static func get_max_duration(_power : int, __casterchar) -> int :
\treturn 0

# Should the be a range roll?
static func get_range(_power : int, __casterchar) -> int :
\treturn 1

static func get_min_damage(_power:int, _casterchar) :
\treturn {min_damage}

static func get_max_damage(_power:int, _casterchar) :
\treturn {max_damage}

static func get_damage_roll(_power : int, _casterchar) :
{damage_roll}

# How does this work?
static func get_accuracy(_casterchar, _power : int) :
\treturn 100 #= infinite wiith resist==0 anyway

static func get_sp_cost(_power : int, _casterchar) :
\treturn _power*{base_cost}

# How is this different from get_targets
static func get_target_number(_power : int, _casterchar) :
\treturn 1

# What is this?
static func get_aoe(_power : int, _casterchar) :
\treturn 'b1'

{add_traits_to_target}

{special_effect_function}

"""