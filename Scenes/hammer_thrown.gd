extends CharacterBody2D

@onready var Collision : CollisionShape2D = $Wood_Hammer/Hammer_Hitbox/CollisionShape2D
@onready var ResetTimer : Timer = $ResetTimer

var activeFlag : bool = false
var Killzone : int = 500 # Killzone to reset bullet
var speed : int = 0 # speed used to determine dmg vector

func _physics_process(_delta: float) -> void:
	if activeFlag:
		rotation += 0.35
		move_and_slide()
		#print("thrown_weapon global_position = " + str(global_position))
		var max_piont = abs(global_position.x)
		if (abs(global_position.y) > max_piont): max_piont = abs(global_position.y)
		if (max_piont >= Killzone):
			reset_bullet()

func deal_damage() -> float: #return damage for hurtbox
	var weapon_dmg : float = 10
	var dmg_multiplier : float = 1
	dmg_multiplier = speed/50
	weapon_dmg = weapon_dmg * dmg_multiplier
	if scale.x > 1: weapon_dmg = weapon_dmg * 2
	#print("speed = " + str(speed))
	#print("dmg_multipliered = " + str(dmg_multiplier))
	#print("weapon_dmg = " + str(weapon_dmg))
	#print("weapon.scale = " + str(scale))
	reset_bullet()
	return weapon_dmg

func reset_bullet():
	visible = false
	speed = 0
	velocity = Vector2(0,0)
	global_position = Vector2(0,0)
	scale = Vector2(1,1)
	Collision.set_deferred("disabled", true)
	activeFlag = false
 
func activate_bullet():
	visible = true
	Collision.disabled = false
	activeFlag = true
	ResetTimer.start()

func set_speed(new_speed : int):
	speed = new_speed

func _on_reset_timer_timeout() -> void:
	reset_bullet()
