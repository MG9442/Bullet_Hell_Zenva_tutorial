extends CharacterBody2D

# Variable Exports
@export var Speed: float = 200
@export var Accel: float = 15
@export var WeaponSwinging: bool = false
var PlayerControllerEnabled = false # Player movement enabled/disabled
var DirectionToggle = false # Right = false, Left = true
var l_hand_origin : Vector2 # Origin point of LHand
var r_hand_origin : Vector2 # Origin point of RHand

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
	if Input.is_action_just_pressed("PlayerAttack"):
		var DirectionString #Concat with Animation name
		var Thrown_weapon : Node2D # Node returned from bullet container
		if DirectionToggle: DirectionString = "L"
		else: DirectionString = "R"
		animation_player.play("ThrowHold_" + str(DirectionString))
		
		Thrown_weapon = BulletContainer.get_bullet()
		Thrown_weapon.visible = true
		Thrown_weapon.global_position = Held_weapon.global_position
		Thrown_weapon.rotation = r_weapon_pivot.rotation
		
	elif Input.is_action_just_pressed("PlayerBlock"):
		l_hand.position = Vector2(0,l_hand.position.y)
	elif Input.is_action_just_released("PlayerBlock"):
		l_hand.position = l_hand_origin
		if DirectionToggle: l_hand.position *= Vector2(-1,1) # Swap position if facing left
	
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
	var weapon_pivot_rotation = snapped(r_weapon_pivot.rotation_degrees,1)
	var weapon_pivot_abs = abs(weapon_pivot_rotation)
	# Reset rotation by adding/subtracting 360 degrees
	if weapon_pivot_rotation <= -360:
		r_weapon_pivot.rotation_degrees += 360
		#print("Added 360 degrees")
	elif weapon_pivot_rotation >= 360:
		r_weapon_pivot.rotation_degrees -= 360
		#print("Subtracted 360 degrees")
	
	#  Flip the sprite based on pivot rotation
	if !DirectionToggle and !WeaponSwinging and (weapon_pivot_abs > 90 and weapon_pivot_abs < 270): #Flip R->L
		DirectionToggle = true
		Flip_sprite_Direction(DirectionToggle)
		#print("DirectionToggle Left")
	elif DirectionToggle and !WeaponSwinging and (weapon_pivot_abs > 270 or weapon_pivot_abs < 90): #Flip L->R
		DirectionToggle = false
		Flip_sprite_Direction(DirectionToggle)
		#print("DirectionToggled Right")
		
	if DirectionToggle and !WeaponSwinging and snapped(r_hand.rotation_degrees,1) != 180: #Left side
		r_hand.rotation_degrees = 180 # Rotate
		#print("Rotating Hand position 180")
	elif !DirectionToggle and !WeaponSwinging and snapped(r_hand.rotation_degrees,1) != 0: #Right side
		r_hand.rotation_degrees = 0 # Set to default
		#print("Rotating Hand position to 0")
		
	# Ensure that pivot doesn't rotate behind back
	if (!DirectionToggle and (weapon_pivot_abs <= 90 or weapon_pivot_abs >= 270)):
		r_weapon_pivot.look_at(get_global_mouse_position())
	elif (DirectionToggle and weapon_pivot_abs >= 90 and weapon_pivot_abs <= 270):
		r_weapon_pivot.look_at(get_global_mouse_position())

func PlayerMovement(value):
	#print("Player Movement = " + str(value))
	PlayerControllerEnabled = value

func character_stats() -> int:
	return Strength
