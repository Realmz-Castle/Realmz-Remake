var name : String = 'Poison Cloud'

var attributes : Array = ['Magical','Chemical']
var tags : Array = ['Magical']

var schools : Array = ['Enchanter']

# Fuction of target type, effect (phase), and line of sight
var targettile : int = 0  #0=anywhere 1=creature 2=empty 3=nowall

var school_levels : Dictionary = {"Sorcerer": 0, "Priest": 0, "Enchanter": 6}
var selection_costs : Dictionary = {"Sorcerer": 0, "Priest": 0, "Enchanter": 21}
var max_plevel : int = 7 # Is this ever not 7?
var in_field : bool = false
var in_combat : bool = true
var description : String = 'Poison Cloud\n\n Damage: Death or 1-2 x Power\n    Range: 6\n    Target: Fixed Size\n      Sight: NO'

var resist : int = 0 #ignores resistances and dodge 
var los : bool = false # line of sight
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Miasma'
var proj_hit : String = 'Slime'
var sounds : Array = ['slurpy.wav', 'big splat.wav']
var max_focus_loss : int = 0 # Where does this come from?

# Is this number of targets?
static func get_targets(_power : int, __casterchar)->int :
	return 1

static func get_min_duration(_power : int, __casterchar) -> int :
	return 0

static func get_duration_roll(_power : int, __casterchar) -> int:
	return 0
static func get_max_duration(_power : int, __casterchar) -> int :
	return 0

static func get_range(_power : int, __casterchar) -> int :
	return 6

static func get_min_damage(_power:int, _casterchar) :
	return 1 * _power

static func get_max_damage(_power:int, _casterchar) :
	return 2 * _power

static func get_damage_roll(_power : int, _casterchar) :
	var scaled_damage = 0
	for i in range(_power) :
		scaled_damage += randi_range(1, 2)
	return scaled_damage

static func get_accuracy(_casterchar, _power : int) :
	return 100 #= infinite wiith resist==0 anyway

static func get_sp_cost(_power : int, _casterchar) :
	return _power*100

# How is this different from get_targets
static func get_target_number(_power : int, _casterchar) :
	return 1

# Area of effect (the shape of the spell target)
static func get_aoe(_power : int, _casterchar) :
	return 'b1'



static func special_effect(_castercrea, _spell, _power, _main_targeted_tile, _effected_tiles, _effected_creas, _add_terrain) :
	#print('Death Special effect _effected_creas size : ', _effected_creas.size())
	#var deathspell = StateMachine.cb_anim_state.cur_action['spell']
	for creab in _effected_creas :
		#print('death : ', creab.creature.name)
		#var accuracyArray : Array = GameGlobal.calculate_spell_accuracy(_castercrea, creab.creature, deathspell, _power)
		#print('Death accuracyArray : ', accuracyArray)
		#var accuracy : float = accuracyArray[0]
		var accuracy = creab.creature.get_stat('EvasionMagic') + (1.0-creab.creature.get_stat('MultiplierMagic')) - 0.1*_power
		if randf()>accuracy :
			UI.ow_hud.creatureRect.logrect.log_other_text(creab.creature, ' survived.', null,'')
		else :
			creab.creature.change_cur_hp(- creab.creature.get_stat('curHP') - 10)
			UI.ow_hud.creatureRect.logrect.log_other_text(creab.creature, ' died.', null,'')
	return true
