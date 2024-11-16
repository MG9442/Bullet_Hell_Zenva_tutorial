extends Node2D
class_name EnemyAnimationController

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

var Anim_string_list : PackedStringArray # List of animation names
var Anim_series : PackedStringArray # Animation series to play
var isAnimPlaying : bool
var SpriteDirection : bool # Sprite direction, left = true; right = false

func _ready():
	Anim_string_list = animation_player.get_animation_list()

func Play_anim_series(Anim_array : PackedStringArray):
	print("Play_anim_series, Anim_array = " + str(Anim_array))
	Anim_series = Anim_array

func Play_anim(anim_name : String):
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
	else:
		print("EnemyAnimationController Error: " + str(anim_name) + " does not exist!")

func Flip_anim_sprite(sprite_direction : bool):
	if SpriteDirection != sprite_direction:
		SpriteDirection = sprite_direction
		animated_sprite_2d.flip_h = sprite_direction

func _on_animation_player_animation_finished(_anim_name):
	pass # Replace with function body.
