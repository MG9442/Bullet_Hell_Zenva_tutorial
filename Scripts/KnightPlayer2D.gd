extends CharacterBody2D

# Variable Exports
@export var Speed: float = 200
@export var Accel: float = 15
@export var Throwing_speed : float = 50
@export var WeaponSwinging: bool = false
var PlayerControllerEnabled = false # Player movement enabled/disabled
var DirectionToggle = false # Right = false, Left = true
var l_hand_origin : Vector2 # Origin point of LHand
var r_hand_origin : Vector2 # Origin point of RHand
var last_known_pivot = 0 # last known good weapon pivot
var Power_timer = 0 #Timer used to check power throw

# Temporary placeholder for Stats
@export var Strength: int = 10

# Variable References
@onready var anim_body = $Anim_Body
@onready var r_hand = $RWeaponPivot/RHand
@onready var l_hand = $LHand
@onready var animation_player = $AnimationPlayer
@onready var r_weapon_pivot = $RWeaponPivot
@onready var Held_weapon = $RWeaponPivot/RHand/Wood_Hammer
@onready var BulletContainer = $BulletContainer
@onready var Axe_Throw_raycast = $AxeThrowRaycast
@onready var Throw_cooldown = $Throw_cooldown

var thrown_weapon_scene = preload("res://Scenes/Hammer_Thrown.tscn")

#TODO: Add Collision shape child to enable/disable in Animation player when switching weapons

func _ready():
	# Save original hand transform for reference later
	l_hand_origin = l_hand.position
	r_hand_origin = r_hand.position

func _physics_process(_delta): #Change to _process if character blurry
	
	#Player movement disabled
	if !PlayerControllerEnabled:
		return
	
	# Get the direction as a Vector2
	var direction: Vector2 = Input.get_vector("PlayerMoveLeft", "PlayerMoveRight", "PlayerMoveUp", "PlayerMoveDown")
	
	# Play Movement Animations
	if direction.x == 0 and direction.y == 0:
		anim_body.play("Idle")
	else:
		anim_body.play("Run")
	
	velocity.x = move_toward(velocity.x, Speed * direction.x, Accel)
	velocity.y = move_toward(velocity.y, Speed * direction.y, Accel)
	
	#Player attack animation
	if !WeaponSwinging and Held_weapon.visible:
		if Input.is_action_pressed("PlayerAttack"):
			var DirectionString #Concat with Animation name
			if DirectionToggle: DirectionString = "L"
			else: DirectionString = "R"
			animation_player.play("ThrowHold_" + str(DirectionString))
			WeaponSwinging = true
			Power_timer = 0 #Reset
			
		elif Input.is_action_just_pressed("PlayerBlock"):
			l_hand.position = Vector2(0,l_hand.position.y)
		elif Input.is_action_just_released("PlayerBlock"):
			l_hand.position = l_hand_origin
			if DirectionToggle: l_hand.position *= Vector2(-1,1) # Swap position if facing left
	elif WeaponSwinging and Input.is_action_just_released("PlayerAttack"):
		#print("Swining action released")
		WeaponSwinging = false
		animation_player.play("RESET")
	else: #examine power swing
		Power_timer += _delta
		if Held_weapon.modulate != Color("bababa") and Power_timer > 0.1 and Power_timer < 0.2:
			Held_weapon.modulate = Color("bababa")
			Throwing_speed += 50
		elif Held_weapon.modulate != Color("d6d6d6") and Power_timer > 0.25 and Power_timer < 0.35:
			Held_weapon.modulate = Color("d6d6d6")
			Throwing_speed += 50
		elif Held_weapon.modulate != Color("e3e3e3") and Power_timer > 0.4 and Power_timer < 0.6:
			Held_weapon.modulate = Color("e3e3e3")
			Throwing_speed += 50
		elif Held_weapon.modulate != Color("ffffff") and Power_timer > 1:
			Held_weapon.modulate = Color("ffffff")
			Throwing_speed += 50
		elif Held_weapon.scale.x == 1 and Power_timer > 2:
			Held_weapon.scale *= Vector2(1.25,1.25)
	
	move_and_slide()
	Handle_Weapon_Rotation()

func Flip_sprite_Direction(Direction):
	# Mirror hand transforms across x axis
	# Direction -> Right = false, Left = true
	#print("l_hand position = " + str(l_hand.position) + " r_hand position = " + str(r_hand.position))
	l_hand.position *= Vector2(-1,1) #Move x postion to other side of body transform
	l_hand.flip_h = Direction
	r_hand.flip_h = Direction
	anim_body.flip_h = Direction

func Handle_Weapon_Rotation():
	
	# Analysis the pivot based on mouse position
	r_weapon_pivot.look_at(get_global_mouse_position())
	var attempted_pivot = snapped(r_weapon_pivot.rotation_degrees,1)
	var attempted_pivot_abs = abs(attempted_pivot)
	#print("attempted_pivot =" + str(attempted_pivot))
	# Ensure that pivot doesn't rotate behind back while swinging
	if WeaponSwinging:
		Axe_Throw_raycast.target_position = -(global_position - get_global_mouse_position())
		if (DirectionToggle and (attempted_pivot_abs <= 90 or attempted_pivot_abs >= 270)):
			r_weapon_pivot.rotation_degrees = last_known_pivot
			return
		elif (!DirectionToggle and (attempted_pivot_abs >= 90 and attempted_pivot_abs <= 270)):
			r_weapon_pivot.rotation_degrees = last_known_pivot
			return
		else:
			r_weapon_pivot.rotation_degrees = attempted_pivot
			last_known_pivot = attempted_pivot
	
	# Reset rotation by adding/subtracting 360 degrees
	if attempted_pivot <= -360:
		r_weapon_pivot.rotation_degrees += 360
		attempted_pivot += 360
		#print("Added 360 degrees")
	elif attempted_pivot >= 360:
		r_weapon_pivot.rotation_degrees -= 360
		attempted_pivot -= 360
		#print("Subtracted 360 degrees")
	
	#  Flip the sprite based on pivot rotation
	if !DirectionToggle and (attempted_pivot_abs > 90 and attempted_pivot_abs < 270): #Flip R->L
		DirectionToggle = true
		Flip_sprite_Direction(DirectionToggle)
		#print("DirectionToggle Left")
	elif DirectionToggle and (attempted_pivot_abs > 270 or attempted_pivot_abs < 90): #Flip L->R
		DirectionToggle = false
		Flip_sprite_Direction(DirectionToggle)
		#print("DirectionToggled Right")
		
	if DirectionToggle and !WeaponSwinging and snapped(r_hand.rotation_degrees,1) != 180: #Left side
		r_hand.rotation_degrees = 180 # Rotate
		#print("Rotating Hand position 180")
	elif !DirectionToggle and !WeaponSwinging and snapped(r_hand.rotation_degrees,1) != 0: #Right side
		r_hand.rotation_degrees = 0 # Set to default
		#print("Rotating Hand position to 0")

func PlayerMovement(value):
	#print("Player Movement = " + str(value))
	PlayerControllerEnabled = value

func character_stats() -> int:
	return Strength

func Throw_weapon():
	var Thrown_weapon : Node2D # Node returned from bullet container
	var vector_to_mouse : Vector2 = -(global_position - get_global_mouse_position()).normalized()
	Thrown_weapon = BulletContainer.get_bullet()
	Thrown_weapon.visible = true
	Thrown_weapon.global_position = Held_weapon.global_position
	Thrown_weapon.rotation = r_weapon_pivot.rotation
	Thrown_weapon.velocity.x = move_toward(velocity.x, Throwing_speed * vector_to_mouse.x, Throwing_speed * Accel)
	Thrown_weapon.velocity.y = move_toward(velocity.y, Throwing_speed * vector_to_mouse.y, Throwing_speed * Accel)
	Thrown_weapon.modulate = Held_weapon.modulate
	Thrown_weapon.scale = Held_weapon.scale
	Held_weapon.visible = false
	Throw_cooldown.start()
	#print("Power_timer elapsed timer = " + str(snapped(Power_timer,0.1)))

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if Input.is_action_pressed("PlayerAttack"):
		#print("Swinging Action being held")
		animation_player.pause()
	else:
		WeaponSwinging = false
		Throw_weapon()

func _on_throw_cooldown_timeout() -> void:
	Held_weapon.visible = true
	Held_weapon.modulate = Color("9a9a9a")
	Held_weapon.scale = Vector2(1,1)
	Throwing_speed = 50
