var name : String = 'Discover Magic'
var attributes : Array = []
var tags : Array = ['Magical', 'Melee']
var schools : Array = ['Sorcerer']

var targettile : int = 1  #0=anywhere 1=creature 2=empty 3=nowall 

var level : int = 1
var selection_cost : int = 1
var max_plevel : int = 7
var in_field : bool = true
var in_combat : bool = true
var description : String = 'Identifies all magic items on target.\\nCan be used in or out of combat or during treasure collection.\\nSP cost : Power * 1'
var resist : int = 0 #ignores resistances and dodge
#var aoe : String = 'b1'
var los : bool = true
var ray : bool = false
var rot : bool = false
#var proj_tex : String = 'Cloud'
var proj_hit : String = 'Whirl'
var sounds : Array = ['','spell launch 5.wav']
var max_focus_loss : int = 0

static func get_targets(_power : int, __casterchar)->int :
	return 1

#static func get_hits(_power : int, __casterchar)->int :
#	return 1

static func get_min_duration(_power : int, __casterchar) -> int :
	return 0

static func get_max_duration(_power : int, __casterchar) -> int :
	return 0

#static func get_duration_roll(_power : int, __casterchar) -> int :
#	return 0

static func get_range(_power : int, __casterchar) -> int :
	return 1
	
static func get_min_damage(_power:int, _casterchar) :
	return 0
	
static func get_max_damage(_power:int, _casterchar) :
	return 0
	
static func get_damage_roll(_power : int, _casterchar) :
	return 0

static func get_accuracy(_casterchar, _power : int) :
	return 100 #= infinite wiith resist==0 anyway

static func get_sp_cost(_power : int, _casterchar) :
	return _power

static func get_target_number(_power : int, _casterchar) :
	return 1

static func get_aoe(_power : int, _casterchar) :
	return 'b1'

static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) -> bool :
	var text : String = ''
	for c : Creature in _effected_creas :
		var c_magic_items : Array = []
		for i : Dictionary in c.inventory :
			if i['is_magical'] : c_magic_items.append(i['name'])
		if c_magic_items.is_empty() :
			text += c.name + ' carries no magic item.\\n'
		else :
			text += c.name + ' carries magic items :\\n'
			for i : int in range(c_magic_items.size()) :
				if i < c_magic_items.size() :
					text += c_magic_items[i] +', '
				else :
					text += c_magic_items[i] +'\\n'
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
