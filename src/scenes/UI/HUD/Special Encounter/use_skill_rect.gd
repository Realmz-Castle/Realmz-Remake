extends NinePatchRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

@onready var charportrait : TextureRect = $CharFaceRect
@onready var charnamelabel : Label = $CharNameLabel

@onready var acroskillbutt : Button = $skillchanceContainer/skillContainer/AcroSkillButt
@onready var deteskillbutt : Button = $skillchanceContainer/skillContainer/DeteSkillButt
@onready var disaskillbutt : Button = $skillchanceContainer/skillContainer/DisaSkillButt
@onready var pickskillbutt : Button = $skillchanceContainer/skillContainer/PickSkillButt

@onready var acrochancebutt : Button =$skillchanceContainer/chanceContainer/AcroChanceButt
@onready var detechancebutt : Button =$skillchanceContainer/chanceContainer/DeteChanceButt
@onready var disachancebutt : Button =$skillchanceContainer/chanceContainer/DisaChanceButt
@onready var pickchancebutt : Button =$skillchanceContainer/chanceContainer/PickChanceButt

var character = null
var encounter_script

var acro_chance : float = 0
var dete_chance : float = 0
var disa_chance : float = 0
var pick_chance : float = 0

signal skill_picked

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func display_character_skills(encounterscript) :
	if character == null :
		return
	if character.get("portrait") :
		charportrait.texture = character.portrait
	else :
		charportrait.texture = character.textureL
	charnamelabel.text = character.name
	
	
	encounter_script = encounterscript
	#initialize flags just in case, Object.get(property: StringName) const
	if encounterscript.get("detected_trap_flag_stuff_done") != null :
		if not GameGlobal.stuff_done.has(encounter_script.detected_trap_flag_stuff_done) :
			GameGlobal.stuff_done[encounter_script.detected_trap_flag_stuff_done] = 0
	if encounterscript.get("disabled_trap_flag_stuff_done") != null :
		if not GameGlobal.stuff_done.has(encounter_script.disabled_trap_flag_stuff_done) :
			GameGlobal.stuff_done[encounter_script.disabled_trap_flag_stuff_done] = 0
	if encounterscript.get("picked_trap_flag_stuff_done") != null :
		if not GameGlobal.stuff_done.has(encounter_script.picked_trap_flag_stuff_done) :
			GameGlobal.stuff_done[encounter_script.picked_trap_flag_stuff_done] = 0
	
	acroskillbutt.disabled = true
	acrochancebutt.text = "-"
	deteskillbutt.disabled = true
	detechancebutt.text = "-"
	disaskillbutt.disabled = true
	disachancebutt.text = "-"
	pickskillbutt.disabled = true
	pickchancebutt.text = "-"
	
	#ACROBATICS
	if encounterscript.get("acro_difficulty") != null :
		acroskillbutt.disabled = false
		acro_chance = clampf(0.01*(character.get_stat("Acrobatics")-encounterscript.acro_difficulty),0.0,1.0)
		acrochancebutt.text = str(acro_chance*100)+'%'
	else :
		acroskillbutt.disabled = true
		acrochancebutt.text = "X"
	
	#DETECT
	if encounterscript.get("detected_trap_flag_stuff_done") :
		if encounterscript.get("dete_difficulty") != null :
			deteskillbutt.disabled = false
			dete_chance = clampf(0.01*(character.get_stat("Detect_Trap")-encounterscript.dete_difficulty),0.0,1.0)
			detechancebutt.text = str(dete_chance*100)+'%'
		else :
			deteskillbutt.disabled = true
			detechancebutt.text = "X"
		if GameGlobal.stuff_done.has(encounter_script.detected_trap_flag_stuff_done) :
			if GameGlobal.stuff_done[encounter_script.detected_trap_flag_stuff_done]>0 :
				deteskillbutt.disabled = true
				detechancebutt.text = "DONE"
	else :
		deteskillbutt.disabled = true
		detechancebutt.text = "X"
			

	#DISABLE
	if encounterscript.get("disa_difficulty") != null :
		#if there is a detected_trap_flag_stuff_done, only show disable if done
		if encounterscript.get("detected_trap_flag_stuff_done") != null :
			if GameGlobal.stuff_done[encounter_script.detected_trap_flag_stuff_done]>0 :
				disaskillbutt.disabled = false
				disa_chance = clampf(0.01*(character.get_stat("Disable_Trap")-encounterscript.disa_difficulty),0.0,1.0)
				detechancebutt.text = str(dete_chance*100)+'%'
			if GameGlobal.stuff_done.has(encounter_script.disabled_trap_flag_stuff_done) :
				if GameGlobal.stuff_done[encounter_script.disabled_trap_flag_stuff_done]>0 :
					disaskillbutt.disabled = true
					disachancebutt.text = "DONE"
	else :
		disaskillbutt.disabled = true
		disachancebutt.text = "X"
	
	#PICK
	if encounterscript.get("pick_difficulty") != null :
		pickskillbutt.disabled = false
		pick_chance = clampf(0.01*(character.get_stat("Pick_Lock")-encounterscript.pick_difficulty),0.0,1.0)
		pickchancebutt.text = str(pick_chance*100)+'%'
		if GameGlobal.stuff_done.has(encounter_script.picked_trap_flag_stuff_done) :
			if GameGlobal.stuff_done[encounter_script.picked_trap_flag_stuff_done]>0 :
				pickskillbutt.disabled = true
				pickchancebutt.text = "DONE"
	else :
		pickskillbutt.disabled = true
		pickchancebutt.text = "X"

	
	#DISABLE : 
	if encounterscript.get("disa_difficulty") != null :
		if GameGlobal.stuff_done.has(encounter_script.detected_trap_success_flag_stuff_done) :
			if GameGlobal.stuff_done[encounter_script.detected_trap_success_flag_stuff_done] >0 :
				disaskillbutt.disabled = false
				disa_chance = clampf(0.01*(character.get_stat("Disable_Trap")-encounterscript.disa_difficulty),0.0,1.0)
				disachancebutt.text = str(disa_chance*100)+'%'
		else :
			disaskillbutt.disabled = true
			disachancebutt.text = "?"
		
		if GameGlobal.stuff_done.has(encounter_script.disabled_trap_flag_stuff_done) :
			if GameGlobal.stuff_done[encounter_script.disabled_trap_flag_stuff_done] >0 :
				disaskillbutt.disabled = true
				disachancebutt.text = "DONE"

	else :
		if not GameGlobal.stuff_done.has(encounter_script.disabled_trap_success_flag_stuff_done) :
			disaskillbutt.disabled = true
			disachancebutt.text = "?"
		else :
			disaskillbutt.disabled = true
			disachancebutt.text = "DONE"
	#var detected_trap_flag_stuff_done : String = ''
	#var disabled_trap_flag_stuff_done : String = ''
	#var acro_difficulty : float = 0
	#var dete_difficulty : float = 0
	#var disa_difficulty : float = 0
	#var pick_difficulty : float = 0
	
	#"Detect_Secret" : 0.0,
	#"Acrobatics" : 0.0,
	#"Detect_Trap" : 0.0,
	#"Disable_Trap" : 0.0,
	#"Force_Lock" : 0.0,
	#"Pick_Lock" : 0.0,
	#"Turn_Undead" : 0.0


func _on_LeftButton_pressed():
	var charindex = GameGlobal.player_characters.find(character)
	var indexminus = charindex-1
	if indexminus <0 :
		indexminus = GameGlobal.player_characters.size()-1
	character = GameGlobal.player_characters[indexminus]
	display_character_skills(encounter_script)

func _on_RightButton_pressed():
	var charindex = GameGlobal.player_characters.find(character)
	var indexplus = (charindex+1) % GameGlobal.player_characters.size()
	character = GameGlobal.player_characters[indexplus]
	display_character_skills(encounter_script)
	
	

func _on_skillbutton_pressed(skillname : String) :
	emit_signal("skill_picked", skillname, character)
	#hide()

func _on_CancelButton_pressed():
	emit_signal("skill_picked", "abort", null)
	hide()
