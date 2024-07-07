extends NinePatchRect
class_name  LogRect

var log_details : bool = true

@onready var logbox : VBoxContainer = $ColorRect/ScrollContainer/LogHBox

var attrColorDict : Dictionary = {"Fire" : Color.ORANGE, "Ice" : Color.CYAN, "Electric" : Color.MEDIUM_SLATE_BLUE,
	"Poison" : Color.FOREST_GREEN, "Chemical" : Color.GREEN_YELLOW, "Disease" : Color.YELLOW, "Healing" : Color.WHITE, "Mental" : Color.DEEP_PINK, 
	"Physical" : Color.LIGHT_CYAN, "Magical" : Color.CORNFLOWER_BLUE, "Bonus_dmg" : Color.HOT_PINK}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func clear() :
	for e in logbox.get_children() :
		e.queue_free()

func log_bandage(bandager : Creature, bandaged : Creature) :
	var newlabel : RichTextLabel = RichTextLabel.new()
	newlabel.custom_minimum_size = Vector2(0,24)
	newlabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	newlabel.size_flags_vertical = Control.SIZE_SHRINK_END
	newlabel.bbcode_enabled = true
	var labeltext = "[color=green]"+bandager.name+"[/color] bandages [color=green]"+bandaged.name+"[/color]"
	newlabel.parse_bbcode(labeltext)
	logbox.add_child(newlabel)

func log_bleed(bleeder : Creature) :
	var newlabel : RichTextLabel = RichTextLabel.new()
	newlabel.custom_minimum_size = Vector2(0,24)
	newlabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	newlabel.size_flags_vertical = Control.SIZE_SHRINK_END
	newlabel.bbcode_enabled = true
	var labeltext = "[color=green]"+bleeder.name+"[/color][color=red] is bleeding to death ![/color]"
	newlabel.parse_bbcode(labeltext)
	logbox.add_child(newlabel)

func log_melee_attack(attacker : CombatCreaButton, defender : CombatCreaButton, damage_detail : Dictionary, accuracy : float, is_crit : bool, crit_mult : float, crit_rate : float) ->void :
	#print("log_melee_attack")
	var newlabel : RichTextLabel = RichTextLabel.new()
	newlabel.custom_minimum_size = Vector2(0,24)
	newlabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	newlabel.size_flags_vertical = Control.SIZE_SHRINK_END
	newlabel.bbcode_enabled = true
	var attacker_color = "green" if attacker.creature.curFaction==0 else ("red" if attacker.creature.curFaction==1 else "blue")
	var defender_color = "green" if defender.creature.curFaction==0 else ("red" if defender.creature.curFaction==1 else "blue")
	
	var hit_txt : String = " critically hits ("+str(crit_rate)+'%, '+str(crit_mult)+'x)' if is_crit else " hits "
	
	var labeltext = "[color="+attacker_color+"]"+attacker.creature.name+"[/color][color=gray]"+hit_txt+"[/color][color="+defender_color+"]"+defender.creature.name+"[/color][color=gray] for [/color][color=white]"+str(damage_detail["total"])+"[/color] damage. "+"[color=white]("+str(100*accuracy)+"[/color]%)"
	
	newlabel.parse_bbcode(labeltext)
	logbox.add_child(newlabel)
	if not log_details :
		return
	var detailtext : String = ''
	var needcomma : bool = false
	var detaillabel : RichTextLabel = RichTextLabel.new()
	
	detaillabel.custom_minimum_size = Vector2(0,24)
	detaillabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detaillabel.size_flags_vertical = Control.SIZE_SHRINK_END
	detaillabel.bbcode_enabled = true
	detailtext += "    ("
	for t in damage_detail :
		if t!="total" :
			var tcolor : Color = attrColorDict[t]
			var tcol_string : String = '#'+tcolor.to_html()
			if needcomma :
				detailtext += ", "
			detailtext +=  "[color="+tcol_string+"]"+str(damage_detail[t])+' '+t+"[/color]"
			needcomma = true
	detailtext+=')'
	detaillabel.parse_bbcode(detailtext)
	logbox.add_child(detaillabel)

func log_melee_attack_miss(attacker,defender, accuracy : float) :
	#print("log_melee_attack_miss")
	var newlabel : RichTextLabel = RichTextLabel.new()
	newlabel.custom_minimum_size = Vector2(0,24)
	newlabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	newlabel.size_flags_vertical = Control.SIZE_SHRINK_END
	newlabel.bbcode_enabled = true
	var attacker_color = "green" if attacker.creature.curFaction==0 else ("red" if attacker.creature.curFaction==1 else "blue")
	var defender_color = "green" if defender.creature.curFaction==0 else ("red" if defender.creature.curFaction==1 else "blue")
	var labeltext = "[color="+attacker_color+"]"+attacker.creature.name+"[/color][color=gray] misses [/color][color="+defender_color+"]"+defender.creature.name+"[/color][color=white]("+str(100*accuracy)+"[/color]%)"
	newlabel.parse_bbcode(labeltext)
	logbox.add_child(newlabel)

func log_spell_cast(castercrea : Creature, spell , power : int, extratext : String) :
	#print("log_spell_cast")
	var newlabel : RichTextLabel = RichTextLabel.new()
	newlabel.custom_minimum_size = Vector2(0,24)
	newlabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	newlabel.size_flags_vertical = Control.SIZE_SHRINK_END
	newlabel.bbcode_enabled = true
	var caster_color := "green" if castercrea.curFaction==0 else ("red" if castercrea.curFaction==1 else "blue")
	var spell_color : String ="white"
	spell_color = get_spell_color_code(spell.attributes)
	var labeltext : String = "[color="+caster_color+"]"+castercrea.name+"[/color][color=gray] uses [/color][color="+spell_color+"]"+spell.name+"[/color][color=gray] lv.[/color][color=white]"+str(power)+"[/color]"+"!"
	newlabel.parse_bbcode(labeltext+ extratext)
	logbox.add_child(newlabel)

func log_spell_damage(castercrea : Creature, defender : CombatCreaButton, spell , power : int, damage_detail : Dictionary, accuracy : float) :
	#print("log_spell_damage")
	if damage_detail["total"]==0 and spell.get_max_damage(power,castercrea)==0 :
		return
	var newlabel : RichTextLabel = RichTextLabel.new()
	newlabel.custom_minimum_size = Vector2(0,24)
	newlabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	newlabel.size_flags_vertical = Control.SIZE_SHRINK_END
	newlabel.bbcode_enabled = true
	var spell_color : String ="white"
	#for a in spell.attributes :
		#if attrColorDict.has(a) :
			#spell_color = '#'+attrColorDict[a].to_html()
	spell_color = get_spell_color_code(spell.attributes)
	var caster_color := "green" if castercrea.curFaction==0 else ("red" if castercrea.curFaction==1 else "blue")
	var defender_color = "green" if defender.creature.curFaction==0 else ("red" if defender.creature.curFaction==1 else "blue")
	var labeltext = "    [color="+defender_color+"]"+defender.creature.name+"[/color][color=gray] takes "+"[color=white]"+str(damage_detail["total"])+"[/color][color=gray] damage from [/color][color="+spell_color+"]"+spell.name+"[/color] [color=white]("+str(100*accuracy)+"%)[/color]"
	newlabel.parse_bbcode(labeltext)
	logbox.add_child(newlabel)	

func log_spell_no_effect(castercrea : Creature, defender : CombatCreaButton, spell) :
	var newlabel : RichTextLabel = RichTextLabel.new()
	newlabel.custom_minimum_size = Vector2(0,24)
	newlabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	newlabel.size_flags_vertical = Control.SIZE_SHRINK_END
	newlabel.bbcode_enabled = true
	var spell_color : String ="white"
	spell_color = get_spell_color_code(spell.attributes)
	var caster_color := "green" if castercrea.curFaction==0 else ("red" if castercrea.curFaction==1 else "blue")
	var defender_color = "green" if defender.creature.curFaction==0 else ("red" if defender.creature.curFaction==1 else "blue")
	var labeltext = "    [color="+caster_color+"]"+castercrea.creature.name+"[/color][color=gray] 's [/color][color="+spell_color+"]"+spell.name+"[/color][color=gray] has no effect on [/color][color="+defender_color+"]"+defender.creature.name+"[/color]"
	newlabel.parse_bbcode(labeltext)
	logbox.add_child(newlabel)	

func get_spell_color_code(s_attributes : Array) -> String:
	var attr_nophysmag = s_attributes.duplicate()
	attr_nophysmag.erase("Physical")
	attr_nophysmag.erase("Magical")
	#var colcode = ''
	for a in attr_nophysmag :
		if attrColorDict.has(a) :
			return '#'+attrColorDict[a].to_html()
			#return colcode
	for a in attr_nophysmag :
		if ["Physical", "Magical"].has(a) :
			return '#'+attrColorDict[a].to_html()
	return "white"

func log_spell_miss(castercrea : Creature, defender : CombatCreaButton, spell , power : int, accuracy : float) :
	#print("log_spell_miss")
	var newlabel : RichTextLabel = RichTextLabel.new()
	newlabel.custom_minimum_size = Vector2(0,24)
	newlabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	newlabel.size_flags_vertical = Control.SIZE_SHRINK_END
	newlabel.bbcode_enabled = true
	var spell_color : String ="white"
	spell_color = get_spell_color_code(spell.attributes)
	var caster_color := "green" if castercrea.curFaction==0 else ("red" if castercrea.curFaction==1 else "blue")
	var defender_color = "green" if defender.creature.curFaction==0 else ("red" if defender.creature.curFaction==1 else "blue")
	var labeltext = "    [color="+defender_color+"]"+defender.creature.name+"[/color][color=gray] is not affected by [/color][color="+spell_color+"]"+spell.name+"[/color] [color=white]("+str(100*accuracy)+"%)[/color]"
	newlabel.parse_bbcode(labeltext)
	logbox.add_child(newlabel)	

func log_added_trait(crea : Creature, script,array) :
	var newlabel : RichTextLabel = RichTextLabel.new()
	newlabel.custom_minimum_size = Vector2(0,24)
	newlabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	newlabel.size_flags_vertical = Control.SIZE_SHRINK_END
	newlabel.bbcode_enabled = true
	var crea_color := "green" if crea.curFaction==0 else ("red" if crea.curFaction==1 else "blue")
	var labeltext = "[color="+crea_color+"]"+crea.name+"[/color][color=gray] gained effect : [/color][color=white]"+script.menuname+"[/color][color=gray], "+str(array)+".[/color]"
	newlabel.parse_bbcode(labeltext)
	logbox.add_child(newlabel)	

func log_stacked_trait(crea : Creature, script,array) :
	var newlabel : RichTextLabel = RichTextLabel.new()
	newlabel.custom_minimum_size = Vector2(0,24)
	newlabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	newlabel.size_flags_vertical = Control.SIZE_SHRINK_END
	newlabel.bbcode_enabled = true
	var crea_color := "green" if crea.curFaction==0 else ("red" if crea.curFaction==1 else "blue")
	var labeltext = "[color="+crea_color+"]"+crea.name+"[/color][color=gray] stacked effect : [/color][color=white]"+script.menuname+"[/color][color=gray], "+str(array)+".[/color]"
	newlabel.parse_bbcode(labeltext)
	logbox.add_child(newlabel)

func log_unstacked_trait(crea : Creature, script,array) :
	var newlabel : RichTextLabel = RichTextLabel.new()
	newlabel.custom_minimum_size = Vector2(0,24)
	newlabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	newlabel.size_flags_vertical = Control.SIZE_SHRINK_END
	newlabel.bbcode_enabled = true
	var crea_color := "green" if crea.curFaction==0 else ("red" if crea.curFaction==1 else "blue")
	var labeltext = "[color="+crea_color+"]"+crea.name+"[/color][color=gray] unstacked effect : [/color][color=white]"+script.menuname+"[/color][color=gray], "+str(array)+".[/color]"
	newlabel.parse_bbcode(labeltext)
	logbox.add_child(newlabel)

func log_removed_trait(crea : Creature, script) :
	var newlabel : RichTextLabel = RichTextLabel.new()
	newlabel.custom_minimum_size = Vector2(0,24)
	newlabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	newlabel.size_flags_vertical = Control.SIZE_SHRINK_END
	newlabel.bbcode_enabled = true
	var crea_color := "green" if crea.curFaction==0 else ("red" if crea.curFaction==1 else "blue")
	var labeltext = "[color="+crea_color+"]"+crea.name+"[/color][color=gray] lost effect : [/color][color=white]"+script.menuname+"[/color][color=gray].[/color]"
	newlabel.parse_bbcode(labeltext)
	logbox.add_child(newlabel)

func log_new_round(rnd : int) :
	var newlabel : RichTextLabel = RichTextLabel.new()
	newlabel.custom_minimum_size = Vector2(0,24)
	newlabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	newlabel.size_flags_vertical = Control.SIZE_SHRINK_END
	newlabel.bbcode_enabled = true
	var labeltext = "[b][color=yellow]BEGIN ROUND "+str(rnd)+"[/color][/b]"
	newlabel.parse_bbcode(labeltext)
	logbox.add_child(newlabel)

func log_other_text(creaone : Creature, textone : String, creatwo : Creature ,texttwo : String) -> void :
	var newlabel : RichTextLabel = RichTextLabel.new()
	newlabel.custom_minimum_size = Vector2(0,24)
	newlabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	newlabel.size_flags_vertical = Control.SIZE_SHRINK_END
	newlabel.bbcode_enabled = true
	var one_color : String = 'gray'
	var two_color : String = "gray"
	var one_name : String = ''
	var two_name : String = ''
	if creaone :
		one_color = "green" if creaone.curFaction==0 else ("red" if creaone.curFaction==1 else "blue")
		one_name = creaone.name
	if creatwo :
		two_color = "green" if creatwo.curFaction==0 else ("red" if creatwo.curFaction==1 else "blue")
		two_name = creatwo.name
	var labeltext = "[color="+one_color+"]"+one_name+"[/color][color=white]"+textone+"[/color][color="+two_color+"]"+two_name+"[/color][color=white]"+texttwo+"[/color]"
	newlabel.parse_bbcode(labeltext)
	logbox.add_child(newlabel)
