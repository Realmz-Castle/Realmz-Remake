#Map test Script generated from old AP format

static func _on_map_load(_map) :
	print("mapscript _on_map_load() !!! ")
	# Add any initialization code here


static func XAP27() : #27
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=2 start_coord=50,5 end_coord=89,34 [LRR0/2]
	await ScriptHelperFuncsClass.display_text_wait_noise('As you top a knoll, you come upon an Orc female giving birth.  She looks quite pale, and is so weak she doesn\'t even notice you.  The baby is breached and will die if you do not help.  Do you aid her?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('You are successful at delivering the baby.  The mother only has time to see the face of her healthy newborn boy, before she slips into a coma and dies.  It would seem you have become parents by default.  What do you do?', 'message nod.wav')
	branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 0, "You see the corpses of over 3 dozen Dogre.  Many are nothing but armor stretched over withered bones but several are considerably more fresh.  Even though, the flesh on some seems to be withered as if aged hundreds of years in just moments.", "You see a group of Dogre in the distance.  Do you want to attack them?")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('You wrap the babe in a blanket and secure him to your back.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(15)
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 38, 32, 0)
	return

static func XAP28() : #28
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=2 start_coord=50,5 end_coord=89,34 [LRR0/2]
	await ScriptHelperFuncsClass.display_text_wait_noise('You stumble upon an old Orc burial mound.   Several of the mounds seem to be untouched, but many have been dug up. Do you wish to excavate them in search for valuables?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('You break into several mounds and find nothing of value.  As you are excavating another mound, you feel a chill in the air.  A spirit rises from one of the mounds that is yet untouched and speaks in a voice that resembles leaves rustling.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('"This most sacred ground has been disturbed for the last time!  Foolish mortals, now you shall wish for the  everlasting peace that you so cruelly deny us!"  The spirit sweeps a wispy hand over the mounds.  The earth erupts as corpses rise.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('The air is filled with a musty smell as the dead stumble forth to attack.', 'message nod.wav')
	GameGlobal.start_battle("Battle_28","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	return

static func XAP29() : #29
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=2 start_coord=50,5 end_coord=89,34 [LRR0/2]
	await ScriptHelperFuncsClass.display_text_wait_noise('You hear the sound of battle in the distance.  You see a band of orcs being attacked by a large group of goblins.  The orcs appear doomed unless you help.  The battle spreads out to engulf you.  Do you stand with the orcs or attack both parties?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(false, 1, 30, "", "")
	if not branch.is_empty(): return branch
	GameGlobal.start_battle("Battle_53","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	return
