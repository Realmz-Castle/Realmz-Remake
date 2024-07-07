extends State
class_name CbTargetingState


@onready var combat_state : CombatState = get_parent()



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func enter(_msg : Dictionary = {}) -> void:
	print("CBTargeting state entered, _msg : ", _msg)

#OK from map.targetingLayer
func _on_player_spell_signal_received(msg : Dictionary) :
	print("CbTargeting  _on_player_spell : ", msg)
