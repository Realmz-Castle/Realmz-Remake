extends NinePatchRect
class_name TempleMenu

const SPELLBUTTON_TSCN : PackedScene = preload("res://scenes/UI/HUD/Temple/temple_spell_button.tscn")
const PRICELABEL_TSCN : PackedScene = preload("res://scenes/UI/HUD/Temple/spell_price_label.tscn")
const TemplePayment = preload("res://scenes/UI/HUD/Temple/temple_payment.gd")

@export var spells_box : Container
@export var prices_box : Container
@export var char_portrait: TextureRect
@export var char_name_label : Label
@export var char_hp_label : Label
@export var char_status_label : Label
@export var char_gold_label : Label
@export var pool_gold_label : Label
@export var char_status_timer : Timer

var displayed_chara : Creature
var chara_conditions : Array = []
var statusesindex : int = 0

var temple_caster : Creature #used for casting the spells, dummy creature
var banking_session_active: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	temple_caster = Creature.new()
	temple_caster.stats["maxSP"] = 9999999999
	temple_caster.stats["curSP"] = 9999999999
	pass # Replace with function body.

func show_temple_window() :
	banking_session_active = UI.ow_hud.moneyControl.banking_available
	if banking_session_active:
		var balances := TemplePayment.balances_after_transfer(
			GameGlobal.money_banked,
			GameGlobal.money_pool
		)
		GameGlobal.money_banked = balances[0]
		GameGlobal.money_pool = balances[1]
	show()
	display_character(GameGlobal.player_characters[0])


func close_temple_window() -> void:
	if banking_session_active:
		var balances := TemplePayment.balances_after_transfer(
			GameGlobal.money_pool,
			GameGlobal.money_banked
		)
		GameGlobal.money_pool = balances[0]
		GameGlobal.money_banked = balances[1]
		banking_session_active = false
	hide()
	char_status_timer.stop()


func _display_services() :
	print("Temple _display_services : GameGlobal.currentTemple : ", GameGlobal.currentTemple)
	for c in spells_box.get_children() :
		spells_box.remove_child(c)
	for c in prices_box.get_children() :
		prices_box.remove_child(c)
	for e in GameGlobal.currentTemple :
		print("Temple proot")
		var newbutton : Button = SPELLBUTTON_TSCN.instantiate()
		newbutton.text = e[0]
		if TemplePayment.can_afford_service(displayed_chara.money[0], GameGlobal.money_pool[0], e[2]) :
			newbutton.pressed.connect(_on_spell_button_pressed.bind(e))
		else :
			newbutton.disabled = true
		spells_box.add_child(newbutton)
		var newprice : Label = PRICELABEL_TSCN.instantiate()
		newprice.text = str(e[2]) + ' G'
		newprice.custom_minimum_size = Vector2(0,25)
		newprice.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		prices_box.add_child(newprice)

func display_character(chara : Creature) :
	displayed_chara = chara
	char_gold_label.text = str(chara.money[0])
	pool_gold_label.text = str(GameGlobal.money_pool[0])
	char_name_label.text = chara.name
	char_hp_label.text = str(chara.get_stat("curHP"))+' / '+ str(chara.get_stat("maxHP"))
	if chara.get("portrait") :
		char_portrait.texture = chara.portrait
	else :
		char_portrait.texture = chara.textureL
	chara_conditions.clear()
	statusesindex = 0
	for t in chara.traits :
		chara_conditions.append(t.get_info_as_text())
	_on_char_status_time_out()
	char_status_timer.start()
	_display_services()

func _on_spell_button_pressed(namepowercost : Array) :
	var cost : int = round(namepowercost[2])
	if not TemplePayment.can_afford_service(displayed_chara.money[0], GameGlobal.money_pool[0], cost) :
		display_character(displayed_chara)
		return
	var balances := TemplePayment.balances_after_service(
		displayed_chara.money[0],
		GameGlobal.money_pool[0],
		cost
	)
	displayed_chara.money[0] = balances[0]
	GameGlobal.money_pool[0] = balances[1]
	temple_caster.stats["curSP"] = 9999999999
	var spell = NodeAccess.__Resources().spells_book[namepowercost[0]]["script"]
	print(spell)
	SfxPlayer.stream = GameGlobal.cmp_resources.sounds_book[spell.sounds[1]]
	SfxPlayer.play()
	if spell.get("proj_hit") :
		await UI.ow_hud.show_spell_effect_on_char_menu( displayed_chara, spell.proj_hit)
	await GameGlobal.do_spell_field_effect(temple_caster, displayed_chara, spell, namepowercost[1])
	if spell.get("special_effect") : 
		print("TEMPLE FIELD SPECIAL EFFECT")
		var is_over : bool = await spell.special_effect(temple_caster, spell, namepowercost[1], Vector2.ZERO, [], [displayed_chara], false)
	display_character(displayed_chara)
	UI.ow_hud.updateCharPanelDisplay()

func _on_char_status_time_out() :
	if chara_conditions.is_empty() :
		char_status_label.text = ''
		statusesindex = 0
	else :
		statusesindex += 1
		statusesindex = statusesindex % chara_conditions.size()
		char_status_label.text = chara_conditions[statusesindex]


func _on_left_button_pressed() -> void:
	var pcid : int = GameGlobal.player_characters.find(displayed_chara)-1
	var teamsize : int = GameGlobal.player_characters.size()
	#find the magic user before picked_character
	var prevchar : Creature = GameGlobal.player_characters[(pcid)%teamsize]
	if prevchar == displayed_chara :
		return
	else :
		display_character(prevchar)


func _on_right_button_pressed() -> void:
	var pcid : int = GameGlobal.player_characters.find(displayed_chara)+1
	var teamsize : int = GameGlobal.player_characters.size()
	#find the magic user before picked_character
	var nextchar = GameGlobal.player_characters[(pcid)%teamsize]
	if nextchar == displayed_chara :
		return
	else :
		display_character(nextchar)


func _on_timer_timeout() -> void:
	pass # Replace with function body.


func _on_pool_button_pressed() -> void:
	UI.ow_hud.moneyControl._on_PoolButton_pressed()
	display_character(displayed_chara)


func _on_share_button_pressed() -> void:
	UI.ow_hud.moneyControl._on_ShareButton_pressed()
	display_character(displayed_chara)


func _on_exit_button_pressed() -> void:
	close_temple_window()
	StateMachine.exit_ex_menu_state()
