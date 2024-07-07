extends NinePatchRect
class_name  AlliesRect

@export var creavboxTSCN : PackedScene
@export var summonsboxTSCN : PackedScene


@export var summonsvbox : VBoxContainer
@export var specialshbox : HBoxContainer

@export var okbutton : Button
@export var oklabel  : Label

var listed_creas : Array = []
var summonernames : Array = []
var summoners_dict : Dictionary = {}

signal done_allying

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func fill(allies : Array) :
	print("alliesrect allies : ",allies)
	listed_creas.clear()
	summonernames.clear()
	summoners_dict.clear()
	summoners_dict[""] = [0,99999999999999]
	for l in summonsvbox.get_children() :
		l.queue_free()
	for b in specialshbox.get_children() :
		b.queue_free()
	for crea in allies :
		print(crea.name, ': ally ? ', crea.is_npc_ally, ", summonned ? ", crea.is_summoned,", alive ? ",crea.get_stat("curHP") > 0)
		if crea.is_npc_ally and not crea.is_summoned :
			var newcreabutton = create_crea_button(crea,specialshbox, "")
			newcreabutton.force_togggle_pressed()
		if crea.is_summoned and crea.get_stat("curHP") > 0 :
			var summoner = null
			for pc in GameGlobal.player_characters :
				if pc.name == crea.summoner_name :
					summoner = pc
					break
			if summoner == null :
				break
			if not summonernames.has(crea.summoner_name) :
				summonernames.append(crea.summoner_name)
				summoners_dict[crea.summoner_name] = [0,summoner.get_max_perma_summons()]
				var newsummonerline = summonsboxTSCN.instantiate()
				summonsvbox.add_child(newsummonerline)
				newsummonerline.set_character( summoner )

			var summonerbox = summonsvbox.get_child( summonernames.find(crea.summoner_name) )
			var newcreabutton = create_crea_button(crea,summonerbox.hbox, summoner.name)
			#auto toggle !
			if summoners_dict[crea.summoner_name][0] < summoners_dict[crea.summoner_name][1] :
				newcreabutton.force_togggle_pressed()


func create_crea_button(c : Creature, box : HBoxContainer, summoner_name : String) :
	var b = creavboxTSCN.instantiate()
	box.add_child(b)
	b.set_creature(c, summoner_name)
	#connect ?
	b.creabutton_toggled.connect(_on_creabutton_toggled)
	return b

func _on_creabutton_toggled(summoner_name : String, is_pressed : bool) -> void :
	if summoner_name.is_empty() :
		return
	var index : int = summonernames.find(summoner_name)
	if index<0 :
		return  #not a summon  lol
	var summonerbox = summonsvbox.get_child( index )
	var incr : int = 1 if is_pressed else -1
	summoners_dict[summoner_name][0] += incr
#	print("summoners_dict : ", summoners_dict)
	if not summoner_name.is_empty() :
		summonerbox._set_cur( summoners_dict[summoner_name][0] )
	#disable/enable ok button ?  only check  this summoner box ? NO  lol
#	print("summonerbox : " , summonerbox.cur ,' ', summonerbox.max)
	var toomuch_name : String = ''
	var enabled : bool = true
	for sbox in summonsvbox.get_children() :
		if sbox.cur > sbox.max :
			toomuch_name = sbox.character.name
			enabled = false
			break
	okbutton.disabled = not enabled
	if enabled :
		oklabel.hide()
	else :
		oklabel.text = toomuch_name + " cannot keep so many summoned creatures !"
		oklabel.show()
	

func _on_ok_button_pressed():
	get_parent().hide()
	GameGlobal.player_allies.clear()
	for sc in specialshbox.get_children() :
		if sc.button.button_pressed :
			GameGlobal.player_allies.append(sc.creature)
	for sn in summonernames :
		var summonerbox = summonsvbox.get_child( summonernames.find(sn) )
		for creab in summonerbox.hbox.get_children() :
			if creab.button.button_pressed :
				GameGlobal.player_allies.append(creab.creature)
	for c in GameGlobal.player_allies :
		print("ally : "+c.name)
	UI.ow_hud.fillCharactersRect()
	emit_signal("done_allying")
