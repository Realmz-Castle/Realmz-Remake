extends Node
""" Example extending the architecture with a Combat system module. """
# the combat states must be reshaped according to the game. See GameGlobal.gd #

var _state # current combat state #
var _combatFileConfigs # json file with combat setup #
func _ready():
	pass # Replace with function body.

# combat system main loop #
func update(delta : float):
	if _state == GameGlobal.eCombatStates.unchecked:
		pass
	elif _state == GameGlobal.eCombatStates.startCombat:
		startCombat()	
		setState(GameGlobal.eCombatStates.inCombat)
	elif _state == GameGlobal.eCombatStates.inCombat:
		inCombat()	
	elif _state == GameGlobal.eCombatStates.endCombatFail or GameGlobal.eCombatStates.endCombatSuccess :
		endCombat()	
		setState(GameGlobal.eCombatStates.unchecked)
	pass
	
# load game #
func load(path : String):
	# load your json files with combat system config them add initiate those 
	# values.
	_combatFileConfigs = Utils.FileHandler.read_json_dic_from_file(path)
	setState(_combatFileConfigs["state"])
	print("Combat System current state: [" + str(_state) + "]")
	pass

func save(path : String):
	print("Saving combat system!")
	pass
	
# setup start variables to initialize the combat #
func startCombat():	
	# here you can update the screen to adapt to combat system view. #
	# can instantiate creatures, npcs, etc ... #
	# build a suitable user interface for combat #
	pass

# stay here until combat ends #
func inCombat():
	# combat logic can be here #
	#if playerDie:
		#setState(GameGlobal.eCombatStates.endCombatFail)
	#elif monstersCounter == 0 or playRun:
		#setState(GameGlobal.eCombatStates.endCombatSuccess)		
	pass

# setup start variables to end the combat #
func endCombat():
	# here you can return game default screen #
	# you can make checks if player is live or not #
	# possible to end the game, if yes, you can change the game state #
	# get_node("Main/CombatS").get_child(1).name
	get_node("../GameState").setState(GameGlobal.eGameStates.endGame)
	pass
	
# update the variable state #
func setState(state : int):
	_state = state
