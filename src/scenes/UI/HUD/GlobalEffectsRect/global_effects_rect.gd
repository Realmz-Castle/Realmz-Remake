extends TextureRect
class_name GlobalEffectsRect

## displays if the party effects in GameGlobal are active.

@onready var water_sprite : AnimatedSprite2D = $WaterSprite2D
@onready var feather_sprite : AnimatedSprite2D = $FeatherSprite2D
@onready var eye_sprite : AnimatedSprite2D = $EyeSprite2D
@onready var orb_sprite : AnimatedSprite2D = $OrbSprite2D
@onready var shield_sprite : AnimatedSprite2D = $ShieldSprite2D
@onready var sentry_sprite : AnimatedSprite2D = $SentrySprite2D
@onready var search_button: Button = $SearchButton

## Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func update_display() :
	water_sprite.visible =  GameGlobal.global_effects["WaterBreath"]["Duration"] >0
	feather_sprite.visible =  GameGlobal.global_effects["FeatherFall"]["Duration"] >0
	var classic_search_available := is_instance_valid(
		GameGlobal.classic_campaign_session
	)
	var search_active := GameGlobal.is_classic_party_condition_active(5)
	var awareness_active: bool = (
		GameGlobal.global_effects["Awareness"]["Duration"] > 0
	)
	search_button.visible = classic_search_available
	search_button.disabled = not classic_search_available
	search_button.set_pressed_no_signal(
		classic_search_available and search_active
	)
	eye_sprite.visible = classic_search_available or awareness_active
	if classic_search_available:
		if search_active:
			if eye_sprite.animation != &"Searching" \
					or not eye_sprite.is_playing():
				eye_sprite.play(&"Searching")
		else:
			eye_sprite.animation = &"Searching"
			eye_sprite.stop()
			eye_sprite.frame = 0
			eye_sprite.frame_progress = 0.0
	elif awareness_active:
		if eye_sprite.animation != &"Looking" or not eye_sprite.is_playing():
			eye_sprite.play(&"Looking")
	orb_sprite.visible =  GameGlobal.global_effects["Scrying"]["Duration"] >0
	shield_sprite.visible =  GameGlobal.global_effects["Shielded"]["Duration"] >0
	sentry_sprite.visible =  GameGlobal.global_effects["Sentry"]["Duration"] >0
