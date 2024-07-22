extends Object
class_name  Creature
#Creature
#Only custom classes that inherit from Object or another class can be extended (have child classes)

# Declare member variables here. Examples:
var name : String = 'Base Creature'
var used_resource : String = "SP"
var focus_counter : int = 0

var scripts_dict : Dictionary = {}
var creature_script : GDScript = null
var creature_script_memory : Dictionary = {}

var combat_button : CombatCreaButton # the object represienting this creat during a batle

var position : Vector2 = Vector2.ZERO # in tiles, coordinates should be positive integers. 0,0 = top left of map.
var size : Vector2 = Vector2.ONE
var dirfaced : int = 1  #  <0  is left, >0 is right
var selected : bool = false
var textureL : Texture2D = null #the image for the creature, facing left
var textureR : Texture2D = null # the image for the creature facing right
#if after initialization  TextureR is null, it will be just a horizontally flipped version of textureL

var baseFaction : int = 1 #0= allies of player. 1=Enemy, 2=Neutral. More faction ally/enemy relations can be defined in scenario data.
var curFaction : int = baseFaction # if a creature is attacked by its friends  or Charmed by another faction, they may temporarily switch sides and help another faction.
var fled_battle : bool = false

var is_player_controlled : bool = false  #doesnt account for  status effects liek fear etc
var is_npc_ally : bool = false
var is_summoned : bool = false
var summoner : Creature = null
var summoner_name : String = ''
var joins_combat : bool = true
var money : Array = [0,0,0]  #gold gems jewels
var experience : int = 0  #exp given when crea is killed

var life_status : int = 0  #0=fine  1=ko'd bleeding 2=ko'd bandaged 3=dead
var doing_on_death_action : bool = false #trye while casting on death spells, queued for cb removal to.
var please_remove_from_combat : bool = false
var reaction_ready : bool = true  # for atatcks of opportunity, set to true on new round

var spells : Array = []
var ai_variables : Dictionary = {}  #variables to be accessed by ai, normally  static unlike memory

var used_movepoints : int = 0 #used movement points THIS TURN
var used_apr : int = 0 #used mactions per round THIS TURN

#var attacked_this_turn : bool = false
var terrain_already_crossed_this_turn : Dictionary = {}

var hands : int = 2
var free_hands : int = 2
var free_ring_slots : int = 2
var can_dual_wield : bool = false

var equipment_slots : Dictionary = {
	"Melee Weapon" : 0,
	"Ranged Weapon" : 0,
	"Ammunition" : 0,
	"Head" : 0,
	"Body" : 0,
	"Hands" : 0,
	"Shield" : 0,
	"Feet" : 0,
	"Neck" : 0,
	"Belt" : 0,
	"Accessory" : 0,
	"Ring" : 0
}


var stats : Dictionary = {
	"MaxMovement" : 0,		#base max Movement points
	"MaxActions" : 0,			#Actions per round
	"Strength" : 0,
	"Intellect" : 0,
	"Wisdom" : 0,
	"Dexterity" : 0,
	"Vitality" : 0,
	"Weight_Limit" : 1000000000,
	"curHP" : 0,
	"curSP" : 0,
	"curTP" : 0,
	"curFP" : 0,
	"curRP" : 0,
	"maxHP" : 0,
	"maxSP" : 0,
	"maxTP" : 0,
	"maxFP" : 0,
	"maxRP" : 0,
	"HP_regen_base" : 1.0,
	"SP_regen_base" : 1.0,
	"HP_regen_mult" : 0.0, #added to the character's multiplier
	"SP_regen_mult" : 0.0, #added to the character's multiplier
	"AccuracyMelee" : 0,
	"AccuracyRanged" :0,
	"AccuracyMagic" : 0,
	"EvasionMelee" : 0,
	"EvasionRanged" : 0,
	"EvasionMagic" : 0,
	"ResistancePhysical" : 0.0,
	"ResistanceFire" : 0.0,
	"ResistanceIce" : 0.0,
	"ResistanceElect" : 0.0,
	"ResistancePoison" : 0.0,
	"ResistanceChemical" : 0.0,
	"ResistanceDisease" : 0.0,
	"ResistanceMagic" : 0.0,
	"ResistanceHealing" : 0.0,
	"ResistanceMental" : 0.0,
	"MultiplierPhysical" : 1.0,
	"MultiplierFire" : 1.0,
	"MultiplierIce" : 1.0,
	"MultiplierElect" : 1.0,
	"MultiplierPoison" : 1.0,
	"MultiplierChemical" : 1.0,
	"MultiplierDisease" : 1.0,
	"MultiplierMagic" : 1.0,
	"MultiplierHealing" : 1.0,
	"MultiplierMental" : 1.0,
	"Melee_Crit_Rate" : 0.0,
	"Melee_Crit_Mult" : 1.0,
	"Ranged_Crit_Rate" : 0.0,
	"Ranged_Crit_Mult" : 1.0,
	"Bonus_Physical_dmg" : 0,
	"Bonus_Magical_dmg" : 0,
	"Detect_Secret" : 0.0,
	"Acrobatics" : 0.0,
	"Detect_Trap" : 0.0,
	"Disable_Trap" : 0.0,
	"Force_Lock" : 0.0,
	"Pick_Lock" : 0.0,
	"Turn_Undead" : 0.0
	
	# Resistances is damage  taken substracted, Multipliers is damage taken multiplied.
	# Damage taken = (base_damage - damage_resistance)*damage_multiplier
	
} 
const NOTREALSTATS : Array = ['Range']

var base_stats = stats.duplicate(true)

var level : int = 0 # Except for Players, this is only indicative of a Creature's power

var abilities : Array = [] #Melee attack, magic, items etc
var inventory : Array = [] # items worn/carried and usable/dropped by this creature

var ITEM_NO_MELEE_WEAPON : Dictionary = {"name":"NO_MELEE_WEAPON", "weapon_dmg" : {"Physical" : [1,3]}, "stats" : {}, "charges" : 0, "charges_max" : 0, "sound" : "punch_male.wav"} #changed to var so sound can be changed
var current_melee_weapons : Array = [ITEM_NO_MELEE_WEAPON] #array of dictionaries
var ITEM_NO_RANGE_WEAPON : Dictionary = {"name":"NO_RANGE_WEAPON", "stats" : {}, "charges" : 0, "charges_max" : 0, "ammo_type" : "cantuse", "sound" : "punch_female.wav"} #changed to var so sound can be changed
var current_range_weapon : Dictionary = ITEM_NO_RANGE_WEAPON
var ITEM_NO_AMMO_WEAPON : Dictionary = {"name":"NO_AMMO_WEAPON", "stats" : {}, "charges" : 0, "charges_max" : 0, "ammo_type" : "none", "sound" : "punch_female.wav"}
var current_ammo_weapon : Dictionary = ITEM_NO_AMMO_WEAPON

var rotating_unarmed_melee_weapons : Array = []  # for stuff like ClawClawBite  or status efefcts from attacks

#var innateEffects : Array = []   # Array of objets of class "StatusEffect"
#var equipmentEffects : Array = []
#var temporaryEffects : Array = []


var traits : Array = [] 
var tags : Array = [] # Reptilian, Humanoid, Undead, Intelligent etc



func set_textures(lefttext : Texture2D, righttext : Texture2D = null)->void :
	textureL = lefttext
	if righttext == null :
		var  img = lefttext.get_data().flip_x()
		textureR = ImageTexture.new()
		textureR.create_from_image(img) #,0
	else :
		textureR = righttext

#NOT same as  being a playercharacter object !
func is_crea_player_controlled() -> bool :
#	var no_trait_control_loss : bool = true
	return curFaction==0 and is_player_controlled #and no_trait_control_loss

func move(dir : Vector2)->Array :  #Array returned is the list of  new  actions for the state action queue (counterattacks...)
	#print("creature.gd move : "+name)
	var extra_actions_queue : Array = []
	extra_actions_queue += _on_before_move(dir)
	#print("extra_actions_queue size : "+str(extra_actions_queue.size()))
	extra_actions_queue += combat_button.move(dir)
	#print("extra_actions_queue size : "+str(extra_actions_queue.size()))
	extra_actions_queue += _on_after_move(dir)
	#print("extra_actions_queue size : "+str(extra_actions_queue.size()))
	#print("creature.gd move : "+name+" END")
	return extra_actions_queue

func _on_before_move(dir : Vector2)-> Array :
	#attacks of oportunity ?
	var checkatattacksopportunity : bool = true
	for t in traits :
		var type = t.get("trait_types")
		if type :
			if type.has("AoO_imm") :  #attacks of Opportunity immunity
					checkatattacksopportunity = false
	if not checkatattacksopportunity :
		return []
	#now check creatures near you  that wouldnt be near you after moving
	var cbs_nearby_before : Array = []
	var cbs_nearby_after : Array = []
	var willAoO : Array = []
	#for cb : CombatCreaButton in GameGlobal.all_battle_creatures_btns :
		#
	#range(n: int): Starts from 0, increases by steps of 1, and stops before n. The argument n is exclusive.
	#range(b: int, n: int): Starts from b, increases by steps of 1, and stops before n. The arguments b and n are inclusive and exclusive, respectively.
	for x in range(-1,size.x+1) :
		for y in range(-1,size.y+1) :
			if ( ( x>=0 and x<size.x) and ( y>=0 and y<size.y) ) :
					continue
			var cbnearby : CombatCreaButton = GameGlobal.who_is_at_tile(Vector2(position.x+x,position.y+y))
			if not cbnearby :
				continue
			if cbnearby.creature.curFaction != curFaction and cbnearby.creature.reaction_ready :
				if not cbs_nearby_before.has(cbnearby) :
					cbs_nearby_before.append(cbnearby)
	for x in range(-1,size.x+1) :
		for y in range(-1,size.y+1) :
			if ( ( x>=0 and x<size.x) and ( y>=0 and y<size.y) ) :
					continue
			var cbnearby = GameGlobal.who_is_at_tile(Vector2(dir.x+position.x+x,dir.y+position.y+y))
			if not cbnearby :
				continue
			if cbnearby.creature.curFaction != curFaction and cbnearby.creature.reaction_ready :
				cbs_nearby_after.append(cbnearby)
				
	for cb in cbs_nearby_before :
		if not cbs_nearby_after.has(cb) :
			willAoO.append(cb)
	var counter_action_queue : Array = []
	for cb in willAoO :
		counter_action_queue.append({"type" : "MeleeAttack", "attacker" : cb, "defender" : combat_button, "weapon": cb.creature.current_melee_weapons[0] })
		cb.creature.reaction_ready = false
		print("    creature.move._on_before_move : counter_action_queue by "+cb.creature.name,cb.creature.position)
	return counter_action_queue
	#for cb : CombatCreaButton in willAoO :
		#cb.creature.used_apr -= 1
		#await GameGlobal.combat_melee_attack(cb, combat_button)
		

func _on_after_move(_dir : Vector2)-> Array :
	#Terrain effects :
	var terrain_effects_here : Array = GameGlobal.map.get_terrain_effects_at_pos(position)
	print("Creature _on_after_move "+name+" MOVE", terrain_effects_here)
	var queue_returned : Array = []
	for t in terrain_effects_here :
		print("Crea Move _on_after_move terrain : ", t["spell"].name)
		var t_type = t["spell"].terrain_walk_type #0=on entry and re entry this turn 1=every step
		if (t_type == 0 and not terrain_already_crossed_this_turn.keys().has(t)) or t_type==1:
			terrain_already_crossed_this_turn[t] = 1
			#var c_act_msg = {"type" : "Spell", "caster" : current_active_creabutton, "spell" : c[0], "s_plvl" : c[1], "used_item" : used_item , "add_terrain" : must_add_terrain, "override_aoe" : override_aoe }
			var act_msg = {"type" : "Spell", "caster" : combat_button, "castercrea" : t["caster"], "spell" : t["spell"], "s_plvl" : t["power"], "used_item" : {} , "add_terrain" : false, "override_aoe" : [position] , "from_terrain" : true, "Targeted Tiles" : [position], "Main Targeted Tile" : position }
			queue_returned.append(act_msg)
##		for o in creature.terrain_already_crossed_this_turn.keys() :
##			if not terrain_effects_here.has(o) :
##				creature.terrain_already_crossed_this_turn.erase(o)
	return queue_returned

func move_to(newpos : Vector2)->void :
	position = newpos



#used after ai 's decideaction in Gamestate. returns true if can melee attack or move to this position
func is_position_ok_for_me(pos : Vector2) -> bool :
	#print("CREATURE (at gamestate decide action) is_position_ok_for_me ,"+name+", "+str(pos))
	for x in range(size.x) :
		for y in range(size.y) :
			var checkedpos : Vector2 = pos+Vector2(x,y)
			var who : CombatCreaButton = GameGlobal.who_is_at_tile(checkedpos)
			#if who :
				#print("   is_position_ok_for_me : crea found : ",who.creature.name +" at "+str(checkedpos)+ " (who!= null and who!=combat_button)? ", (who!= null and who!=combat_button))
			var iswalkable : bool = GameGlobal.is_map_tile_walkable_by_char(self, checkedpos)
			if ( (who!= null and (who!=combat_button and who.creature.curFaction==curFaction)) or (not iswalkable)  ):
				return false
	return true


#func get_effects()->Array :
#	var alleffects : Array = []
#	for e in innateEffects :
#		alleffects.append({e : innateEffects[e]} )
#	for e in equipmentEffects :
#		alleffects.append({e : innateEffects[e]})
#	for e in temporaryEffects :
#		alleffects.append({e : innateEffects[e]})
#	return alleffects

func get_mp_cost_for_tile_stack(stack : Array)->int : #<0 means not walkable
	#print("creature get_mp_cost_for_tile : " + name, " ")
	var walkeffects : Array = []
	for e in traits  :
		if e.has_method("_on_walking_on_tile_element") :
			walkeffects.append(e)
	var total_cost : float = 0
	for tile in stack :
		#print("tile name : ",tile["name"],", tile time : ",tile["time"])
		if tile["wall"]>0 :
			return -1
		var tile_time : float = ceil(tile["time"]/5)
		var cost_f : float = float(tile_time)
		var effects : Array = [1]
		for e in walkeffects :
			var e_effect : Array = e._on_walking_on_tile(tile)
			var e_has_effect_here : bool = e_effect[0] != tile_time
			if e_has_effect_here :
				if e_effect[1] :  #should return now
					return int(max(0, e_effect[0]))
				else :
					effects.append(e_effect[0])
		for f in effects :
			cost_f *= f
		total_cost += cost_f
	return max(ceil(total_cost),0)

		
func recalculate_stats() :
#	print("BUG IN RECALCULATE STATS")
	print("called creaturegd.recalculate_stats "+name)
#	NodeAccess.__MainScene().get_tree().quit()
#	print(name," max hp is ",stats["maxHP"], " cur hp is ",stats["curHP"])
	var prevminusHP : int = stats["maxHP"]-stats["curHP"]
	var prevminusSP : int = stats["maxSP"]-stats["curSP"]
	stats["curHP"] = base_stats["maxHP"] - prevminusHP
	stats["curSP"] = base_stats["maxSP"] - prevminusSP
	for s in stats :
		if s != 'curHP' and s != 'curSP' :
			stats[s] = base_stats[s]
	for e in  inventory :
		if e["equipped"] == 1 :
			for s in e["stats"] :
				if not NOTREALSTATS.has(s) :
					stats[s] += e["stats"][s]
				if s.begins_with("Multiplier") :
					if stats[s]>=0 and e["stats"][s]>=0 :
						stats[s] *= e["stats"][s]
					else :
						stats[s] = -absf(e["stats"][s] * stats[s])
				else :
					stats[s] += e["stats"][s]
	for t in traits :
		for s in stats :
#			if t.has_method("_on_calculate_"+s) :
#				stats[s] += t.call("_on_calculate_"+s)
#			var tproperties = t.get_property_list()
			if "_on_calculate_"+s in t :
				stats[s] += t.get("_on_calculate_"+s)
#	print("stats recalculated for ", name)
#	print(name," max hp is ",stats["maxHP"], " cur hp is ",stats["curHP"])

func get_stat(statname : String) :
	if statname == "Weight_Limit" :
		return 1200
	var this_stat = stats[statname]
	if not ["AccuracyMelee","AccuracyRanged","AccuracyMagic","Melee_Crit_Rate","Melee_Crit_Mult","Ranged_Crit_Rate","Ranged_Crit_Mult"].has(statname) :
		this_stat = roundi(this_stat)
	for t in traits :
		if t.has_method("_on_get_stat") :
			this_stat = t._on_get_stat(statname, this_stat)
	return this_stat

# checks for weight or other limitations and scripts
func can_add_inventory_item(item : Dictionary) ->bool :
#	print("creature can add inventory item :")
#	print(get_inventory_weight()+item_get_weight(item),' <> ',stats["Weight_Limit"])
	return get_inventory_weight()+item_get_weight(item)<=get_stat("Weight_Limit")

func item_get_weight(item : Dictionary)->int :
	return item["weight"]+item["charges_weight"]*item["charges"]

func get_inventory_weight() -> int :
	var carriedweight : int = 0
	for i in inventory :
		carriedweight += item_get_weight(i)
	carriedweight += ( money[0] +money[1] +money[2] )
	return carriedweight

func get_movement() ->int :
#	print("name ", name, ", base_stats[maxmove] :  ",base_stats["MaxMovement"], ', invweight : ' , get_inventory_weight(), ', max : ', get_stat("Weight_Limit") )
	return int(ceil(base_stats["MaxMovement"] * ( 1.0 - float(get_inventory_weight() / float(get_stat("Weight_Limit")) ) ) ) )

func get_movement_left() ->int :
	return get_movement() - used_movepoints

func get_apr_left() :
	var max_actions_stat : float = get_stat("MaxActions")
	var max_actions_stat_floor : int = floor(max_actions_stat)
	var evenroundbonus : float = 0
	
	if max_actions_stat_floor<max_actions_stat : #give +1 anction on even turns
		if StateMachine.combat_state.cur_battle_round %2 == 0 :
			evenroundbonus = 1
	return floor(get_stat("MaxActions"))-used_apr + evenroundbonus

func add_inventory_item(item : Dictionary,  index = -1) ->bool :
#	print("Creature add_inventory_item :  i changed true  to can_add_inventory_item")
	if can_add_inventory_item(item) :
		if index==-1 :
			inventory.append(item.duplicate(true))
		else :
			inventory.insert(index,item.duplicate(true))
		return true
	else :
		return false

#  can be used to check if character has item too  if dict  returned is empty
func get_item(item : Dictionary) -> Dictionary :
	for  i in inventory :
		if i["name"]==item["name"] and i["weight"]==item["weight"] and i["stats_mini"]==item["stats_mini"] and i["price"]==item["price"] :
			return i
	return {}


func drop_inventory_item(item : Dictionary) -> bool :
	print(name+" drop_inventory_item "+item["name"])
	if item["equipped"]!=0 :
		SfxPlayer.stream = NodeAccess.__Resources().sounds_book['generation error.ogg']
		SfxPlayer.play()
		return false
	var dropped = true
	if item.has("_on_drop_source") :
		var returned = item["_on_drop"]._on_drop(self,item)
		if returned != null :
			dropped = returned
	if dropped :
		inventory.erase(item)
	return dropped



func add_trait(traitscript, trait_array : Array) -> RefCounted:  #trait_array is the arguments passed to the trait script to initialize it
	print("Creature add_trait before" , name)
#	var mytraitstr : String = ''
#	for t in traits :
#		mytraitstr += t.name+' '
#	print(mytraitstr)
	for t in traits :
		if t.name==traitscript.name :
			if t.stacks :
				if StateMachine.is_combat_state() :
					UI.ow_hud.creatureRect.logrect.log_stacked_trait(self,traitscript, trait_array)
				t.stack(trait_array)
				return t
	if StateMachine.is_combat_state() :
		UI.ow_hud.creatureRect.logrect.log_added_trait(self,traitscript, trait_array)
	var trait_array_w_chara : Array = [self]
	trait_array_w_chara.append_array(trait_array)
	var traitinstance = traitscript.new( trait_array_w_chara )
	traitinstance.chara = self
	traits.append(traitinstance)
	print("    Creature add_trait after : added" , traitinstance.menuname)
	return traitinstance
#	print("Creature add_trait",name)
#	mytraitstr = ''
#	for t in traits :
#		mytraitstr += t.name+' '
#	print(mytraitstr)

func remove_trait(traitscript) :
	print(" Creature Remmove Trait")
	if StateMachine.is_combat_state() :
		UI.ow_hud.creatureRect.logrect.log_removed_trait(self,traitscript)
	if traitscript.has_method("_on_remove_trait") :
		traitscript._on_remove_trait(self, traitscript)
	traits.erase(traitscript)
#	print("Creature has traits :",name, traits)

func remove_trait_stack(traitscript : GDScript, trait_array : Array) :
	var rtrait = traitscript.new(trait_array)
#	print(traitscript.source_code)
#	print(rtrait.has_method("_on_time_pass"))
#	print(rtrait.get("name"))
	for t in traits :
		if t.name == rtrait.name :
			if t.stacks :
				t.unstack(trait_array)
				if StateMachine.is_combat_state() :
					UI.ow_hud.creatureRect.logrect.log_unstacked_trait(self,traitscript, trait_array)
				return
			else :
				print("PROBLEM ??? : Creature.remove_trait_stack , "+name+" : trait "+rtrait.name+" doesnt stack, cant be weakened.")
				#if t.equals_args(trait_array) :
					#remove_trait(t)
					#return
	#remove_trait(traitscript)

func add_spell_from_source(spellname : String, spellsource : String, slevel : int) :
	var spellscript  = GDScript.new()
	spellscript.set_source_code(spellsource)
	var _err_newscript_reload = spellscript.reload()
	#var slevel = spellscript.level
	spells[slevel-1].append({"name":spellname, "source":spellsource, "script":spellscript})

func add_spell_from_spells_book(spellname : String, slevel : int) :
	var resources = NodeAccess.__Resources()
	var spelldict = resources.spells_book[spellname]
	add_spell_drom_dict(spelldict, slevel)

func add_spell_drom_dict(spell_dict : Dictionary, slevel : int) :
	#var slevel = spell_dict["script"].level
	while spells.size() < level :
		spells.append([])
	spells[slevel-1].append(spell_dict)

func get_all_spells() -> Array :
	var returned : Array = []
	for sl in spells :
		for s in sl :
			returned.append(s)
	return returned

func _on_time_pass(seconds : int) :
#	print("time pass ",name, traits)
	for t in traits :
#		print ("trait "+t.name )
		if t.has_method("_on_time_pass") :
#			print(name+" "+t.name+" _on_time_pass  execution")
			t._on_time_pass(self, seconds)
#		else :
#			print ("trait "+t.name+" has no _on_time_pass method")
	#now regen HP/SP :
	var hp_regen_amount : float = max(0,seconds*max(0,get_stat("HP_regen_base"))*get_stat("HP_regen_mult") / 86400)
	change_cur_hp(hp_regen_amount * level)
	var sp_regen_amount : float = max(0,seconds*max(0,get_stat("SP_regen_base"))*get_stat("SP_regen_mult") / 86400)
	change_cur_sp(sp_regen_amount * level)

# returns stats of the spell when cast by this character
func get_spell_data(spell, power : int)->Dictionary :
	var spelldata : Dictionary = {}
	
	for vn in ["attributes", "resist", "aoe", "los", "graphics","sounds"  ] :
		var datum = spell.get(vn)
		var methodname : String = "_on_get_spell_"+vn
		for t in traits :
			if t.has_method(methodname) :
				# Object. Variant call(method: String, ...) vararg
				datum = t.call(methodname, datum, spell, power, self)
		spelldata[vn] = datum

	var hits = spell.get_hits(power, self) if spell.has_method("get_hits") else 1
	
	for t in traits :
		if t.has_method("_on_get_spell_hits") :
			hits = t._on_get_spell_hits(hits,spell, power, self)
	spelldata["hits"] = hits
	
	var srange = spell.get_range(power, self)
	for t in traits :
		if t.has_method("_on_get_spell_range") :
			srange = t._on_get_spell_range(srange,spell, power, self)
	spelldata["range"] = srange

	var sp_cost = spell.get_sp_cost(power, self)
	for t in traits :
		if t.has_method("_on_get_spell_sp_cost") :
			sp_cost = t._on_get_spell_sp_cost(sp_cost,spell, power, self)
	spelldata["sp_cost"] = floor(sp_cost)

	var tg_number = spell.get_target_number(power, self)
	for t in traits :
		if t.has_method("_on_get_spell_target_number") :
			tg_number = t._on_get_spell_target_number(tg_number,spell, power, self)
	spelldata["tg_number"] = floor(tg_number)

	return spelldata


func does_crea_know_spell_named(spellname : String) :
	for slvl : int in range(spells.size()) :
		for s_dict : Dictionary in  spells[slvl] :
			#print(s_dict)
			if s_dict['name']==spellname : return true
	return false


#func get_spell_cost(spell,power : int) :
#	if spell.has_method("get_sp_cost") :
#		var sp_cost = spell.get_sp_cost(power, self)
#		for t in traits :
#			if t.has_method("_on_get_spell_sp_cost") :
#				sp_cost = t._on_get_spell_sp_cost(sp_cost,spell, power, self)
#		return floor(sp_cost)
#	else :
#		return 0


#func _on_spell_cast(spell, powerlevel) -> Array:
#	var spcost = spell.get_sp_cost(powerlevel)
##	var attacks = {Attributes, Damage, }
#	for t in traits :
#		if t.has_method("_spell_cost_mod") :
#			spcost = t._spell_cost_mod(spell, powerlevel, spcost)
#	stats["curSP"] -= int(spcost)
#
#	var attacks : Array = []
#	for h in range(spell.hits) :
#		var new_attack : Dictionary = {}
#		new_attack["Attributes"] = spell.attributes
#		new_attack["Damage"] = spell.get_damage_roll(powerlevel)
#
#
#
#		attacks.append(new_attack)
#	for t in traits :
#		if t.has_method("_spell_mod") :
#			attacks = t._spell_mod(attacks, spell, powerlevel)
#	return attacks


# Called when the node enters the scene tree for the first time.
func _ready():
	print("creature wow i actually  can use a  ready function")
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func initialize_from_bestiary_dict(creaname : String) :
	var resources = NodeAccess.__Resources()
	var cdata : Dictionary = resources.crea_book[creaname]
	textureL = cdata["data"]["image"]
	textureR = cdata["data"]["image"] #usually just the  same and flipped with sprite
	name = cdata["data"]["name"]
	level =  cdata["data"]["level"]
	size = Vector2(cdata["data"]["size"][0], cdata["data"]["size"][1])
	baseFaction = cdata["data"]["faction"]
	curFaction = baseFaction
	experience = cdata["data"]["exp"]
	spells.clear()
	tags = cdata["data"]["tags"]
	if cdata["data"].has("is_player_controlled") :
		is_player_controlled = bool(cdata["data"]["is_player_controlled"])
#	var resources = NodeAccess.__Resources()
	spells = [ [],[],[],[],[],[],[] ]
	for se in cdata["tools"]["spells"] :
		var spell = resources.spells_book[se[0]]['script']

		add_spell_from_spells_book(se[0], spell.level)
#		spells.append([ resources.spells_book[se[0]] , se[1] ])
	for s in cdata["stats"] :
		base_stats[s] = cdata["stats"][s]
		stats[s] = cdata["stats"][s]
	stats["curHP"] = stats["maxHP"]
	stats["curSP"] = stats["maxSP"]
	stats["curRP"] = stats["maxRP"]
	stats["curFP"] = stats["maxFP"]
	stats["curTP"] = stats["maxTP"]
	#inv/money
	money = cdata["tools"]["money"]
	for i_name_eq_arr in cdata["tools"]["inventory"] :  #[itemname, shouldequip01]
		var item_added : Dictionary = resources.items_book[i_name_eq_arr[0]]
		add_inventory_item(item_added.duplicate())
		if i_name_eq_arr[1]>0 :
			print("Creature generation : "+name+" equips "+item_added["name"])
			equip_item(item_added)
		else :
			print("Creature generation : "+name+" does not equip "+item_added["name"])
	#rotating_unarmed_melee_weapons
	rotating_unarmed_melee_weapons.clear()
	var loaded_unarmed : Array = cdata["tools"]["unarmed_melee_attacks"]  #an array of  dicts with meapon_name or  weapon item  dict data
	#var ITEM_NO_MELEE_WEAPON : Dictionary = {"name":"NO_MELEE_WEAPON", "stats" : {}, "charges" : 0, "charges_max" : 0, "sound" : "punch_male.wav"}
	print("loaded_unarmed ",loaded_unarmed)
	for wdata : Dictionary in loaded_unarmed :
		if wdata.has("weapon_name") :
			rotating_unarmed_melee_weapons.append(resources.items_book[ wdata["weapon_name"] ].duplicate())
		else :
			#{"weapon_dmg" : {"Physical" : [1,4], "Ice" : [1,2]}, "sound" : "slurpy.wav", "icon" : "Slime", "melee_inflicted_traits" : [  ["regeneration_over_time.gd" , [1.0,-1] ,1.0]  ] },
			wdata["imgdata"] = ''
			wdata["imgdatasize"] = 0
			wdata["type"] = 'Unarmed'
			wdata["name"] = 'NO_MELEE_WEAPON'
			var item = resources.generate_item_from_json_dict(wdata)
			rotating_unarmed_melee_weapons.append(item)
	if rotating_unarmed_melee_weapons.size()>0 :
		current_melee_weapons[0] = rotating_unarmed_melee_weapons[0]
	
	if cdata.has("traits") :
		var cdata_traits_arrays_array : Array = cdata["traits"]
		print("cdata_traits_arrays_array ", cdata_traits_arrays_array)
		for traitarray in cdata_traits_arrays_array :
			print("Creature initialize_from_bestiary_dict traitarray ",traitarray)
			var traitname = traitarray[0]
			var traitinit = traitarray[1]
			var newscript : GDScript = GDScript.new()
			var scriptcreated : bool = false
			if traitname.ends_with('.gd') :
				if traitname.begins_with(GameGlobal.currentcampaign) :
					pass
				else :
					newscript = load("res://shared_assets/traits/"+traitname)
				scriptcreated = true
	##				var args : Array = traitinit
				#new_item[traitname] = [newscript,traitinit]#.new(args)
			else :
				newscript.set_source_code(traitname)
				var _err_newscript_reload = newscript.reload()
				if _err_newscript_reload == OK :
					scriptcreated = true
				else :
					print("ERROR LOADING CREATURE TRAIT SCRIPT from bestiary entry "+name+ " "+traitname+ " , error code : "+_err_newscript_reload)
				
			if scriptcreated :
				print("Creature.initialize_from_bestiary_dict added a trait : "+traitname+" to "+name)
				var newtrait = add_trait(newscript, traitinit)
				if newscript.permanent :
					newtrait.trait_source = "Innate"
	
	
	#TODO  ai stuff
	
	ai_variables = cdata["ai"].duplicate()
	
	scripts_dict = cdata["scripts"].duplicate()
	var default_script_name : String = scripts_dict["default"]
	creature_script = NodeAccess.__Resources().creascripts_book[default_script_name]
	
	spells.clear()
	#for s in  cdata["tools"]["spells"] :
		#add_spell_from_spells_book(s[0])
		
	recalculate_stats()


# called by CbDecideAction State
func _on_new_round() :
	print("Creature "+name+" _on_new_round()")
	if is_instance_valid(combat_button) :
		combat_button.set_creature_represented(self)
	reaction_ready = true
	used_movepoints = 0
	used_apr = 0
	focus_counter = 0
	please_remove_from_combat = false
	doing_on_death_action = false
	#attacked_this_turn = false
	terrain_already_crossed_this_turn.clear()
	if life_status == 1 :
		change_cur_hp(-1)
		if stats['curSP'] <= -10  :
			UI.ow_hud.creatureRect.logrect.log_bleed(self)
		else :
			UI.ow_hud.creatureRect.logrect.log_other_text(self, " was not rescued in time.", null,'')
	for t in traits :
		if t.has_method("_on_new_round") :
			await t._on_new_round(self)

func on_battle_end() :
	fled_battle = false
	please_remove_from_combat = false
	doing_on_death_action = false
	if life_status==1 :
		life_status = 2
	for t in traits :
		if t.has_method("_on_battle_end") :
			await t._on_battle_end(self)

#happens right after an accuracy check is done in a melee attack or spell in GameGlobal.combat_melee_attack and GameGlobal.
func on_evasion_check(evasion_stats_used : Array, attacker : Creature, spellscriptornullformelee, power : int) -> Array :
	var returned_action_queue : Array = []
	var continue_action : bool = true
	for t in traits :
		if t.has_method("_on_evasion_check") :
			var t_returned_array : Array = t._on_evasion_check(self, evasion_stats_used, attacker, spellscriptornullformelee, power)
			returned_action_queue += t_returned_array[1]
			continue_action = continue_action and t_returned_array[0]
	return [continue_action, returned_action_queue]

func on_after_melee_attack() :
	if current_melee_weapons[0]["name"]=="NO_MELEE_WEAPON" :
		if rotating_unarmed_melee_weapons.size()>0 :
			var index : int = used_apr % rotating_unarmed_melee_weapons.size()
			current_melee_weapons[0] = rotating_unarmed_melee_weapons[index]


func _on_before_melee_attack(_attacker : CombatCreaButton, damage_detail : Dictionary) -> Array :
	#returns array [do_melee_attack : bool, new_attacker: CombatCreaButton, new_defender : CombatCreaButton, new_attack_data]
	var returnedArray : Array = [true, _attacker , combat_button, damage_detail, []] #last is for extra  queued actions
	for t in traits :
		if t.has_method("_on_before_melee_attack") :
			if returnedArray[0] :
				returnedArray = t._on_before_melee_attack(self, returnedArray)
			else :
				break
	return returnedArray

#func calculate_damage_taked_from_spell_attack(spell, spell_damage) :
	#var spell_attributes : Array= spell.attributes
	#for a in spell_attributes :
		#if not GameGlobal.dmg_type_def_stats_dict.has(a) :
			#continue
		#var res_name : String = GameGlobal.dmg_type_def_stats_dict[a][0]
		#var res_stat : float = stats[res_name]
		#var mul_name : String = GameGlobal.dmg_type_def_stats_dict[a][1]
		#var mul_stat : float = stats[mul_name]
		#spell_damage = max(0,spell_damage - res_stat)*mul_stat


##returns  [has_effect : bool , applied_damage : int , added_to_action_queue : Array ]
func on_hit_by_spell(caster : Creature, spell, powerlevel, spell_damage : int) :
	var applied_damage = spell_damage
	var has_effect : bool = true
	var added_to_action_queue : Array = []
	for t in traits :
		if t.has_method("_on_spell_hit_chara") :
			#[has_effect, applied_damage, [{added_to_action_queue}] ]
			var returned_array = t._on_spell_hit_chara(caster, spell, powerlevel, applied_damage)
			has_effect = has_effect and returned_array[0]
			applied_damage = returned_array[1]
			added_to_action_queue.append(returned_array[2])
	return [has_effect, applied_damage, added_to_action_queue ]
		

func change_cur_hp(hpchange : int) -> void :
	if life_status ==3 :
		return
	var prev_hp = stats['curHP']
	stats['curHP'] += hpchange
	if prev_hp>0 and stats['curHP'] <=0 :
		for t in traits :
			if t.has_method("_on_chara_dead") :
				t._on_chara_dead(self)
		# #0=fine  1=ko'd bleeding 2=ko'd bandaged 3=dead
		if stats['curHP'] <=min(-10, -level) :
			life_status = 3
		if StateMachine.is_combat_state() :
			life_status = max(life_status , 2)
		else :
			life_status = 2
		#die()
	if prev_hp<=0 and stats['curHP'] > 0 :
		life_status = 0
	return

func change_cur_sp(spchange : int) :
	#print("Creature change_cur_sp "+name+' ',spchange,' cursp : ',stats['curSP'])
	stats['curSP'] += spchange
	#print("after changecurdsp : ", stats['curSP'])
	stats['curSP'] = min (stats['curSP'],stats['maxSP'])
#	stats['curSP'] = max (stats['curSP'],0)

func die() :
	if stats['curHP'] <= 0  :
		if stats['curHP'] > -10 :
			life_status = 1
		else :
			life_status = 3
	else :
		stats['curHP'] = randi_range(-9,-1)
		life_status = 1
	


#func resurrect(new_pos : Vector2) :
	#life_status = 0
	#if GameGlobal.player_characters.has(self) or GameGlobal.player_allies.has(self) :
		#GameGlobal.battle_dead_party_members.erase(self)
	#else :
		#GameGlobal.battle_dead_enemies.erase(self)
	#GameGlobal.add_pc_or_npcally_to_battle_map(self, new_pos)

func get_spell_resource_cost(spell, plvl : int) :
	if spell.has_method("get_sp_cost") :
		var cost = spell.get_sp_cost(plvl,self)
		#print("Creature get_spell_resource_cost "+spell.name+' '+str(plvl)+' : '+str(cost))
		for t in traits :
			if t.has_method("_on_get_spell_sp_cost") :
				cost = t._on_get_spell_sp_cost(cost,spell, plvl, self)
		return floor(cost)
	else :
		return 0

func on_ability_use(spell, plvl : int) :
	#print("Creature on_ability_use "+name)
	change_cur_sp(-get_spell_resource_cost(spell, plvl))

#returns the string saved in the character  folder as data.json
#func get_save_string()-> String :
#	var save_string : String = ''
#
#
#
##	save_string += ('\n"exp_tnl" : '+ str(exp_tnl)+',')
##	save_string += ('\n"selection_pts" : '+ str(selection_pts)+',')
#
#	save_string += ('{"name":"'+name+'", "level" : '+ str(level)+',"free":1, "money" : '+ str(money)+',')
#	save_string += ('\n"is_npc_ally" : '+ str(int(is_npc_ally))+',')
#	save_string += ('\n"is_summoned" : '+ str(int(is_summoned))+',')
#	save_string += ('\n"summoner_name" : "'+ str(summoner_name)+'",')
#	save_string += ('\n"joins_combat" : '+ str(int(joins_combat))+',')
#	save_string += ('\n"curHP" : '+ str(get_stat("curHP"))+',')
#	save_string += ('\n"cur'+used_resource+'" : '+ str(get_stat("cur"+used_resource))+',')
#
#	save_string += ('\n"base_stats" : '+ str(base_stats)+',')
##		match chara.used_resource
#	#save inventory 
#	#to avoid saving traits from equiopment, temporarily unequip all
#	var temp_unequipped_items : Array = []
#	for item in inventory :
#		if item["equipped"] == 1 :
#			if unequip_item(item) :
#				item["equipped"] = 2  #unequipped but tagged for re equipping
#				temp_unequipped_items.append(item)
#
#	save_char_file.store_line('"inventory" : [')
#	var addcomma : String = ''
#	for item in chara.inventory :
#		var inventoryJSONstring : String = JSON.stringify(item)
#		save_char_file.store_line(addcomma+inventoryJSONstring)
#		addcomma = ','
#	save_char_file.store_line('],')
#
#	print("temp_unequipped_items")
#	for item in temp_unequipped_items :
#		print("Utils temp_unequipped_items : re equip "+item["name"])
#		chara.equip_item(item)
#
#	#save spells
#	var spellsJSONstring : String = JSON.stringify(chara.spells)
#	save_char_file.store_line('"spells" : ')
#	save_char_file.store_line(spellsJSONstring)
#	save_char_file.store_line(',')
#
#	#save traits :
#	save_char_file.store_line('"traits" : [')
#	addcomma = ''
#	for chartrait in chara.traits :
#		if chartrait.name.ends_with('.gd') :
#			var savedvars = JSON.stringify(chartrait.get_saved_variables())
#			var line : String = '{"type" : "standard", "name" : "'+ chartrait.name +'", "saved_variables" : '+savedvars+'}'
#			save_char_file.store_line(addcomma+line)
#		else :
#			var tsourcecode : String = chartrait.get_script().get_source_code()
##			tsourcecode = "SAUCE"
#			var savedvars = '[]'
#			if chartrait.get("saved_variables") :
#				savedvars = JSON.stringify(chartrait.get_saved_variables())
#			save_char_file.store_line(addcomma+'{"type" : "custom", "source" : "'+tsourcecode +'", "saved_variables" : '+savedvars+'}')
#		addcomma = ','
#	save_char_file.store_line(']')
#	save_char_file.store_line('}')






func equip_item(item) -> bool :  #returns true iff could equip
	print("CREATURE "+name+" equip_item "+item["name"])
	# check if item is in my inventory first !
	if not inventory.has(item) :
		print("ERROR : This character doesn't own this item lol")
		return false
	# Actually Equip the item
	if can_equip_item(item) :
		if item["slots"].has("Melee Weapon") :
#			current_melee_weapon = item
			current_melee_weapons.erase(ITEM_NO_MELEE_WEAPON)
			current_melee_weapons.append(item)
			var dbugtext : String = ' '
			for i in current_melee_weapons :
				dbugtext+= i["name"]+', '
				
			print("PlayerChar "+name+" current_melee_weapons : ", dbugtext)
		if item["slots"].has("Ranged Weapon") :
			current_range_weapon = item
			print("PlayerChar "+name+" current_tange_weapon : ", item["name"])
		if item["slots"].has("Ammunition") :
			current_ammo_weapon = item
			print("PlayerChar "+name+" current_ammo_weapon : ", item["name"])
		
		
		for s in item["slots"] :
			equipment_slots[s]=1
		
		if item.has("hands") :
			free_hands -= item["hands"]
		
		if item["slots"].has("Ring") :
			free_ring_slots -= 1
		
		item["equipped"] = 1
		if item.has("_on_equipping") :
#			print("item "+item["name"]+" checked equipping")
			item["_on_equipping"]._on_equipping(self, item)
		else :
			pass
#			print("item has no \"_on_equipping\" script")
		
		if item.has("traits") :
			print("item.has(traits)", item["traits"])
			for t in item["traits"] :
				var traitname : String = t[0]
				print(item[traitname])
#				new_item[traitname] = [newscript,traitinit]#new_trait_script
				add_trait(item[traitname][0],item[traitname][1])
				if item[traitname][0].permanent :
					item[traitname][0].trait_source = "Equipment : "+item['name']
		
#		print(item.name, " equipped : ", item["equipped"])
		recalculate_stats()
		return true
	else :
		return false


#returns true if successfully unequipped
func unequip_item(item, check_script = true) -> bool :
	var can_unequip : bool = true
	if check_script and item.has("_on_unequipping") :
#			print("item "+item["name"]+" checked unequipping")
		can_unequip = item["_on_unequipping"]._on_equipping(self, item)
	if not can_unequip :
		SfxPlayer.stream = NodeAccess.__Resources().sounds_book['generation error.ogg']
		SfxPlayer.play()
		return false
	# check if item is in my inventory first !
	if not inventory.has(item) :
		print("ERROR : This character doesn't own this item lol")
		return false
	# Actually Unequip the Item :
	
	if item["slots"].has("Melee Weapon") :
#		current_melee_weapon = ITEM_NO_MELEE_WEAPON
#		print("current_melee_weapons.has(item) ? ",current_melee_weapons.has(item))
		if current_melee_weapons.has(item) :
			current_melee_weapons.erase(item)
		else :
			var found : bool = false
			for i in current_melee_weapons :
				if i["name"] == item["name"] and item["equipped"]==1 :
					current_melee_weapons.erase(i)
					found = true
					break
			if not found :
				print("PLAYERCHAR unequip_item ERROR : weapon ws not in current_melee_weapons")
		if current_melee_weapons.is_empty() :
			current_melee_weapons = [ITEM_NO_MELEE_WEAPON]
#		print("PlayerChar "+name+" current_melee_weapons : ", current_melee_weapons)
		var dbugtext : String = ' '
		for i in current_melee_weapons :
			dbugtext+= i["name"]+', '
			
		print("CREATURE PlayerChar "+name+" current_melee_weapons : ", dbugtext)
			
	if item["slots"].has("Ranged Weapon") :
		current_range_weapon = ITEM_NO_RANGE_WEAPON
		print("CREATURE PlayerChar "+name+" current_tange_weapon : ", item["name"])
	if item["slots"].has("Ammunition") :
		current_ammo_weapon = ITEM_NO_AMMO_WEAPON
		print("PlayerChar "+name+" current_ammo_weapon : ", item)
	
	
	for s in item["slots"] :
		equipment_slots[s]=0
	
	if item["slots"].has("Ring") :
		free_ring_slots += 1
	
	if item.has("hands") :
		free_hands += item["hands"]
	
	if item.has("traits") :
#			print("item.has(traits)", item["traits"])
		for t in item["traits"] :
			var traitname : String = t[0]
#				new_item[traitname] = [newscript,traitinit]#new_trait_script
#zfzfzfzf
			#remove_trait_stack(item[traitname][0],item[traitname][1])
			remove_trait(item[traitname][0])
	
	item["equipped"] = 0
	recalculate_stats()
	return true
#	print(item.name, " equipped : ", item["equipped"])

func can_equip_item(item) -> bool :
	print("CREATURE "+name+ " can_equip_item ", item["name"])
#	print(equipment_slots)
	var hasfreeslots : bool = true
	for s in item["slots"] :
		hasfreeslots = hasfreeslots and (equipment_slots[s]==0)
	
	if item["slots"].has("Ring") :
		hasfreeslots = hasfreeslots and free_ring_slots>=1
	
	if item.has("hands") :
	
	# you can equip two 1 handed melee weapons if you can dual wield
	# however you may still equip  only  one shield
		if item["slots"].has("Shield") :
			hasfreeslots = hasfreeslots and (free_hands >= item["hands"])
		else :
			hasfreeslots =  (free_hands >= item["hands"])
			if item["slots"].has("Melee Weapon") and equipment_slots["Melee Weapon"]!=0 :
				hasfreeslots = can_dual_wield and hasfreeslots
	return hasfreeslots


func get_creature_script() :
	for t in traits :
		if t.has_method("_on_get_creature_script") :
			return t._on_get_creature_script()
	return creature_script


#missing last_bracket }  so you can add more in other class. i  know this is shit.
func get_save_string() -> String :
	var savestring : String = ''

	savestring += ('{"name":"'+name+'", "level" : '+ str(level)+', "money" : '+ str(money)+',')
	savestring += ('\n"is_npc_ally" : '+ str(int(is_npc_ally))+',')
	savestring += ('\n"is_summoned" : '+ str(int(is_summoned))+',')
	savestring += ('\n"summoner_name" : "'+ str(summoner_name)+'",')
	savestring += ('\n"joins_combat" : '+ str(int(joins_combat))+',')
	savestring += ('\n"curHP" : '+ str(get_stat("curHP"))+',')
	savestring += ('\n"curSP'+'" : '+ str(get_stat("curSP"))+',')
	savestring += ('\n"base_stats" : '+ str(base_stats)+',')
	#save inventory 
	#to avoid saving traits from equiopment, temporarily unequip all
	var temp_unequipped_items : Array = []
	for item in inventory :
		if item["equipped"] == 1 :
			if unequip_item(item) :
				item["equipped"] = 2  #unequipped but tagged for re equipping
				temp_unequipped_items.append(item)
		
	savestring += ('\n"inventory" : [')
	var addcomma : String = ''
	for item in inventory :
		print("CREATURE ITEM HAS imgdatasize ??? ", item["name"], item.has("imgdatasize"))
		var inventoryJSONstring : String = JSON.stringify(item)
		savestring += ('\n'+addcomma+inventoryJSONstring)
		addcomma = ','
	savestring += ('\n],')
	
	print("temp_unequipped_items")
	for item in temp_unequipped_items :
#		print("Utils temp_unequipped_items : re equip "+item["name"])
		equip_item(item)
		
	#save spells
	var spellsJSONstring : String = JSON.stringify(spells)
#	print("Creature spellsJSONstring : ", spellsJSONstring)
	savestring += ('\n"spells" : ')
	savestring += ('\n'+spellsJSONstring)
	savestring += ('\n'+',')
	
	#save traits :
	savestring += ('\n"traits" : [')
	addcomma = ''
	for chartrait in traits :
		if chartrait.name.ends_with('.gd') :
			var savedvars = JSON.stringify(chartrait.get_saved_variables())
			var line : String = '{"type" : "standard", "name" : "'+ chartrait.name +'", "saved_variables" : '+savedvars+'}'
			savestring += ('\n'+addcomma+line)
		else :
			var tsourcecode : String = chartrait.get_script().get_source_code()
#			tsourcecode = "SAUCE"
			var savedvars = '[]'
			if chartrait.get("saved_variables") :
				savedvars = JSON.stringify(chartrait.get_saved_variables())
			savestring += ('\n'+addcomma+'{"type" : "custom", "source" : "'+tsourcecode +'", "saved_variables" : '+savedvars+'}')
		addcomma = ','
	savestring += ('\n]')
#	savestring += ('\n}')
	return savestring
