var name : String = 'Discover Magic'

var attributes : Array = ['Magical','Misc']
var tags : Array = ['Magical']

var schools : Array = ['Sorcerer', 'Priest', 'Enchanter']

# Fuction of target type, effect (phase), and line of sight
var targettile : int = 1  #0=anywhere 1=creature 2=empty 3=nowall

var school_levels : Dictionary = {"Sorcerer": 1, "Priest": 1, "Enchanter": 1}
var selection_costs : Dictionary = {"Sorcerer": 1, "Priest": 1, "Enchanter": 1}
var max_plevel : int = 7 # Is this ever not 7?
var in_field : bool = true
var in_combat : bool = true
var description : String = 'Discover Magic:  This spell will reveal all items that have magical properties.  It can be cast during combat or while collecting treasure.  It will not give specific information about magical items.'

var resist : int = 0 #ignores resistances and dodge 
var los : bool = false # line of sight
var ray : bool = false
var rot : bool = false

var proj_hit : String = 'Whirl'
var sounds : Array = ['spell launch 6.wav', 'boing.wav']
var max_focus_loss : int = 0 # Where does this come from?

# Is this number of targets?
static func get_targets(_power : int, __casterchar)->int :
	return 1

static func get_min_duration(_power : int, __casterchar) -> int :
	return 3

static func get_duration_roll(_power : int, __casterchar) -> int:
	var base_duration = randi_range(3, 7)
	return base_duration

static func get_max_duration(_power : int, __casterchar) -> int :
	return 7

static func get_range(_power : int, __casterchar) -> int :
	return 15

static func get_min_damage(_power:int, _casterchar) :
	return 0

static func get_max_damage(_power:int, _casterchar) :
	return 0

static func get_damage_roll(_power : int, _casterchar) :
	return 0

static func get_accuracy(_casterchar, _power : int) :
	return 100 #= infinite wiith resist==0 anyway

static func get_sp_cost(_power : int, _casterchar) :
	return _power*1

# How is this different from get_targets
static func get_target_number(_power : int, _casterchar) :
	return 1

# Area of effect (the shape of the spell target)
static func get_aoe(_power : int, _casterchar) :
	return 'b1'



static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) -> bool :
	var text : String = ''
	for c : Creature in _effected_creas :
		var c_magic_items : Array = []
		for i : Dictionary in c.inventory :
			if i['is_magical'] : c_magic_items.append(i['name'])
		if c_magic_items.is_empty() :
			text += c.name + ' carries no magic item.\n'
		else :
			text += c.name + ' carries magic items :\n'
			for i : int in range(c_magic_items.size()) :
				if i < c_magic_items.size() :
					text += c_magic_items[i] +', '
				else :
					text += c_magic_items[i] +'\n'
	var textRect = UI.ow_hud.textRect
	if StateMachine.is_combat_state() :
		textRect.show()
		UI.ow_hud.creatureRect.hide()
	textRect.set_text(text, true)
	await textRect.interruption_over
	if StateMachine.is_combat_state() :
		textRect.hide()
		UI.ow_hud.creatureRect.show()
	return true
