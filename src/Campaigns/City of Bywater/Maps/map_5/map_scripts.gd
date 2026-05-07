static func _on_map_load(_map) :  #Necessary even if unused, replace body with "pass" if so.
	pass

static func Take_Stairs_U() :
	# Return to the trap door access point on map_0 (AP25 at 16,17).
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(0, 16, 17, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You climb back up through the trap door and emerge once more into the abandoned crypt at the edge of the graveyard.', 'message nod.wav')
	return
