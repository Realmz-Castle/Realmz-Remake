extends Panel
class_name TurnOrderPanel

@onready var box : Container = $ScrollContainer/HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func update_display() :
	for c in box.get_children() :
		box.remove_child(c)
		c.queue_free()
	var battle_creatures_yet_to_act_btns : Array = StateMachine.combat_state.battle_creatures_yet_to_act_btns
	# this is an array of CombatCreaButtons
	for cb : CombatCreaButton in battle_creatures_yet_to_act_btns :
		var nbutton : Button = Button.new()
		nbutton.icon = cb.sprite.texture
		nbutton.mouse_entered.connect( UI.ow_hud._on_mouse_enter_combat_crea_button.bind(cb) )
		nbutton.mouse_exited.connect( UI.ow_hud._on_mouse_exit_combat_crea_button )
		#button.pressed.connect(_on_pressed.bind(button))
		box.add_child(nbutton)
		nbutton.cust




func _on_mouse_entered():
	UI.ow_hud._on_mouse_enter_combat_crea_button(self)
	GameGlobal.map.mouseinside = true


func _on_mouse_exited():
	UI.ow_hud._on_mouse_exit_combat_crea_button()
