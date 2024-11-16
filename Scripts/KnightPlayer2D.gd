extends CharacterBody2D

# Variable Exports
@export var Speed: float = 200
@export var Accel: float = 15
@export var WeaponSwinging: bool = false
var PlayerControllerEnabled = false # Player movement enabled/disabled
var DirectionToggle = false # Right = false, Left = true
var l_hand_origin : Vector2 # Origin point of LHand
var r_hand_origin : Vector2 # Origin point of RHand
var last_known_pivot = 0 # last known good weapon pivot

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
	if !WeaponSwinging:
		if Input.is_action_just_pressed("PlayerAttack"):
			var DirectionString #Concat with Animation name
			if DirectionToggle: DirectionString = "L"
			else: DirectionString = "R"
			animation_player.play("ThrowHold_" + str(DirectionString))
			WeaponSwinging = true
			
		elif Input.is_action_just_pressed("PlayerBlock"):
			l_hand.position = Vector2(0,l_hand.position.y)
		elif Input.is_action_just_released("PlayerBlock"):
			l_hand.position = l_hand_origin
			if DirectionToggle: l_hand.position *= Vector2(-1,1) # Swap position if facing left
	elif WeaponSwinging and Input.is_action_just_released("PlayerAttack"):
		#print("Swining action released")
		WeaponSwinging = false
		animation_player.play("RESET")
	
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
	
	Thrown_weapon.velocity.x = move_toward(velocity.x, 250 * vector_to_mouse.x, Accel*300)
	Thrown_weapon.velocity.y = move_toward(velocity.y, 250 * vector_to_mouse.y, Accel*300)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if Input.is_action_pressed("PlayerAttack"):
		#print("Swinging Action being held")
		animation_player.pause()
	else:
		WeaponSwinging = false
		Throw_weapon()
