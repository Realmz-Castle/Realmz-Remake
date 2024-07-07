extends NinePatchRect

@export var done_button : Button

@export var changelabel : Label
@export var vbox : VBoxContainer
@export var qtybox : GridContainer
@onready var bgroup: ButtonGroup = ButtonGroup.new()

@export var coinsLabel : Label
@export var gemsLabel : Label
@export var jewelsLabel : Label

@export var gldButDown : Button
@export var gemButUp : Button
@export var gemButDown : Button
@export var jewButUp : Button

@export var banking_box : Control

@export var bankcoinsLabel : Label
@export var bankgemsLabel : Label
@export var bankjewelsLabel : Label

var charmoneypanelTSCN : PackedScene = preload( "res://scenes/UI/HUD/MoneyRect/CharacterMoneyPanel.tscn" )


var selected_character = null
var selected_character_control = null
var quantity : int = 1

#var pool : Array = [0,0,0]

var money_changing_available : bool = false
var banking_available : bool = false

var goldstogem : float = 0.01
var gemtogolds : int = 90
var gemstojews : float = 0.01
var jewstogems : int = 90

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize(characters : Array) :
	set_money_change_enabled(money_changing_available)
	coinsLabel.text = str(GameGlobal.money_pool[0])
	gemsLabel.text = str(GameGlobal.money_pool[1])
	jewelsLabel.text = str(GameGlobal.money_pool[2])
	bankcoinsLabel.text = str(GameGlobal.money_banked[0])
	bankgemsLabel.text = str(GameGlobal.money_banked[1])
	bankjewelsLabel.text = str(GameGlobal.money_banked[2])
	for child in vbox.get_children() :
		vbox.remove_child(child)
		child.queue_free()
	var first : bool = true
	for c in GameGlobal.player_characters :
		var charmoneypanel = charmoneypanelTSCN.instantiate()
		charmoneypanel.setup(self, c)
		vbox.add_child(charmoneypanel)
		if first :
			first = false
			charmoneypanel._on_Button_pressed()
	for b in qtybox.get_children() :
		b.set_button_group(bgroup)

func close() :
#	GameState.set_paused(false)
	get_parent().on_moneyControl_close()
	hide()

func character_button_pressed(cb, chara) :
	selected_character = chara
	selected_character_control = cb
	print("selected_character : ",selected_character,", control : ",selected_character_control)
	for child in vbox.get_children() :
		child.set_selected(child==cb)


func on_viewport_size_changed(screensize) :
	_set_size(Vector2(screensize.x-320, screensize.y))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_money_change_enabled(yes : bool) :
	money_changing_available = yes
	if yes :
		changelabel.set_text("Money Changing is available.")
		changelabel.add_theme_color_override("font_color", Color(0,1,0, 1) )
		gemButUp.show()
		jewButUp.show()
		gldButDown.show()
		gemButDown.show()
	else :
		changelabel.set_text("Money Changing is not available.")
		changelabel.add_theme_color_override("font_color", Color(1,0,0, 1) )
		gemButUp.hide()
		jewButUp.hide()
		gldButDown.hide()
		gemButDown.hide()


func set_banking_availlable(yes : bool) :
	banking_available = yes
	banking_box.visible = yes
	done_button.text = "Exit and Quicksave" if (GameGlobal.honest_mode and yes) else "Done"

func _on_DoneButton_pressed():
	close()

func _on_QtyButton_toggled(button_pressed, qty : int):
	quantity = qty


func _on_changeArrow_pressed(from, to) :
	var q = min(quantity, GameGlobal.money_pool[from])
	print("_on_changeArrow_pressed ",from,' ',to, ", q=",q)
#	q = int(floor(q/10)*10) #always a multiple of 10
	if from == 0 : #coins :
		# round q to the neartest multiple of 100
		q = 100*floor(q/100)
		GameGlobal.money_pool[0] -= int(q)
		GameGlobal.money_pool[1] += int(q*goldstogem)
		print("converted ",q," coins into ", int(q*goldstogem), " gems")
	elif from == 1 : #gems :
		if to == 0 : #gems to gold
			GameGlobal.money_pool[1] -= int(q)
			GameGlobal.money_pool[0] += int(q*gemtogolds)
			print("converted ",q," gems into ", int(q*gemtogolds), " coins")
		elif to==2 : #gems to jew lol
			q = 100*floor(q/100)
			GameGlobal.money_pool[1] -= int(q)
			GameGlobal.money_pool[2] += int(q*gemstojews)
			print("converted ",q," gems into ", int(q*gemstojews), " jews")
	elif from == 2 :
		GameGlobal.money_pool[2] -= int(q)
		GameGlobal.money_pool[1] += int(q*jewstogems)
		print("converted ",q," jews into ", int(q*jewstogems), " gems")
	coinsLabel.text = str(GameGlobal.money_pool[0])
	gemsLabel.text = str(GameGlobal.money_pool[1])
	jewelsLabel.text = str(GameGlobal.money_pool[2])
	
	
func _on_poolArrow_pressed(mult : int, currency : int) :
	print("_on_poolArrow_pressed")
	if selected_character == null :
		return
	var q : int = quantity
	if mult == -1 :
		q = min (quantity, selected_character.money[currency])
		
	else :
		q = min (quantity, GameGlobal.money_pool[currency])
		q = min(q, selected_character.get_stat("Weight_Limit") - selected_character.get_inventory_weight() )
	selected_character.money[currency] += mult*q
	GameGlobal.money_pool[currency] -= mult * q
	selected_character_control.setup(self,selected_character)
	coinsLabel.text = str(GameGlobal.money_pool[0])
	gemsLabel.text = str(GameGlobal.money_pool[1])
	jewelsLabel.text = str(GameGlobal.money_pool[2])
	for charpanel in get_parent().charsVContainer.get_children() :
		if charpanel.character == selected_character :
			charpanel.update_display()

func _on_PoolButton_pressed():
	for currency in range(3) :
		for character in GameGlobal.player_characters :
			GameGlobal.money_pool[currency] += character.money[currency]
			character.money[currency] = 0
	coinsLabel.text = str(GameGlobal.money_pool[0])
	gemsLabel.text = str(GameGlobal.money_pool[1])
	jewelsLabel.text = str(GameGlobal.money_pool[2])
	for charpanel in get_parent().charsVContainer.get_children() :
		charpanel.update_display()
	
	for child in vbox.get_children() :
		child.setup(self, child.character)

func _on_ShareButton_pressed():
	print("MoneyRect _on_ShareButton_pressed TODO FIX THIS !")
#	var can_carry_more : bool = true

	for c in range(3) :
		var currency : int = 2-c
		while GameGlobal.money_pool[currency]>0 :
			#get the characters with inv  carry weight  left :
			var pcs_can_carry : Array = []
			var min_nonzero_weight : int = 999999999
			for pc in GameGlobal.player_characters :
				var weightleft : int = pc.get_stat("Weight_Limit") - pc.get_inventory_weight()
				if weightleft > 0 :
					pcs_can_carry.append(pc)
					min_nonzero_weight = min(weightleft, min_nonzero_weight)
			var pcs_number : int = pcs_can_carry.size()
			# if all characters are full, stop trying.
			if pcs_number == 0 :
				break
			# if money > pcs_number then we dont need to share  one by one
			if GameGlobal.money_pool[currency]>pcs_number :
				var give_to_each : int = min( min_nonzero_weight, floor(float(GameGlobal.money_pool[currency])/float(pcs_number)) )
				for pc in pcs_can_carry :
					pc.money[currency] += give_to_each
				GameGlobal.money_pool[currency] -= give_to_each * pcs_number
			#if  there s  less money than availlable pcs,  share one by one.
			else :
				for pc in pcs_can_carry :
					if GameGlobal.money_pool[currency] >0 :
						pc.money[currency] += 1
						GameGlobal.money_pool[currency] -= 1
					else :
						break
	coinsLabel.text = str(GameGlobal.money_pool[0])
	gemsLabel.text = str(GameGlobal.money_pool[1])
	jewelsLabel.text = str(GameGlobal.money_pool[2])
	for charpanel in get_parent().charsVContainer.get_children() :
		charpanel.update_display()
	
	for child in vbox.get_children() :
		child.setup(self, child.character)
				
#func get_min_weight_left_in_() -> int :
#			var min_weight_left : int = 9223372036854775807
#			for character in GameGlobal.player_characters :
#				var weightleft = character.get_stat("Weight_Limit") - character.get_inventory_weight()
#				min_weight_left = min(min_weight_left, weightleft)
#			return min_weight_left


func _on_bank_but_pressed(mult : int, currency : int) :
	#mult = -1 =  store to bank  from pool
	var q : int = quantity
	if mult == -1 :
		q = min (quantity, GameGlobal.money_pool[currency])
	else :
		q = min (quantity, GameGlobal.money_banked[currency])
	GameGlobal.money_banked[currency] -= mult * q
	GameGlobal.money_pool[currency] += mult * q
	coinsLabel.text = str(GameGlobal.money_pool[0])
	gemsLabel.text = str(GameGlobal.money_pool[1])
	jewelsLabel.text = str(GameGlobal.money_pool[2])
	bankcoinsLabel.text = str(GameGlobal.money_banked[0])
	bankgemsLabel.text = str(GameGlobal.money_banked[1])
	bankjewelsLabel.text = str(GameGlobal.money_banked[2])
