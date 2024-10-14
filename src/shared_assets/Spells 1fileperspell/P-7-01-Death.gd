var name : String = 'Death'
var attributes : Array = ['Magical']
var tags : Array = ['Magical', 'Instant_Death']
var schools : Array = ['Priest']
var targettile : int = 1  #0=anywhere 1=creature 2=empty 3=nowall 

var level : int = 7
var selection_cost : int = 1
var max_plevel : int = 7
var in_field : bool = false
var in_combat : bool = true
var description : String = 'Death : \n -10% resist per Power\n Range : 5\nTarget : Single Target\nLine of Sight : Yes.'
var resist : int = 3 #can be resisted or evaded
#var aoe : String = 'b1'
var los : bool = true
var ray : bool = false
var rot : bool = false
var proj_tex : String = 'Spark'
var proj_hit : String = 'Target'
var sounds : Array = ['spell launch 1.wav','clash.wav']
var max_focus_loss : int = 0

static func get_targets(_power : int, __casterchar)->int :
	return 1

static func get_min_duration(_power : int, __casterchar) -> int :
	return 0

static func get_max_duration(_power : int, __casterchar) -> int :
	return 0

static func get_range(_power : int, __casterchar) -> int :
	return 6
	
static func get_min_damage(_power:int, _casterchar) :
	return 0
	
static func get_max_damage(_power:int, _casterchar) :
	return 0
	
static func get_damage_roll(_power : int, _casterchar) :
	return 0

static func get_accuracy(_casterchar, _power : int) :
	return 1.0 + 0.10 * _power

static func get_sp_cost(_power : int, _casterchar) :
	return 75*_power

static func get_target_number(_power : int, _casterchar) :
	return 1

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
