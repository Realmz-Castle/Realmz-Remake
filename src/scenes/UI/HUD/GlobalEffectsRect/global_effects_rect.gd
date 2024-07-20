extends TextureRect
class_name GlobalEffectsRect

## displays if the party effects in GameGlobal are active.

@onready var water_sprite : AnimatedSprite2D = $WaterSprite2D
@onready var feather_sprite : AnimatedSprite2D = $FeatherSprite2D
@onready var eye_sprite : AnimatedSprite2D = $EyeSprite2D
@onready var orb_sprite : AnimatedSprite2D = $OrbSprite2D
@onready var shield_sprite : AnimatedSprite2D = $ShieldSprite2D
@onready var sentry_sprite : AnimatedSprite2D = $SentrySprite2D

## Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func update_display() :
	water_sprite.visible =  GameGlobal.global_effects["WaterBreath"]["Duration"] >0
	feather_sprite.visible =  GameGlobal.global_effects["FeatherFall"]["Duration"] >0
	eye_sprite.visible =  GameGlobal.global_effects["Awareness"]["Duration"] >0
	orb_sprite.visible =  GameGlobal.global_effects["Scrying"]["Duration"] >0
	shield_sprite.visible =  GameGlobal.global_effects["Shielded"]["Duration"] >0
	sentry_sprite.visible =  GameGlobal.global_effects["Sentry"]["Duration"] >0
