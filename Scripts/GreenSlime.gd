extends CharacterBody2D
class_name  GreenSlimeEnemy
# Enemy Script

# Responsible for:
# Raycast, Line of Sight detection
# Vision area for player tracking

#TODO: Add a timeout for heading to last known target location, in case of being stuck

@export var VariedSpeed : float = 0 # Varied Speed controlled by animator player
@export var acceleration = 7
@export var DebugLabelVisible : bool = false # Label to tell which state enemy is in
@export var DEBUG_TARGET : Marker2D #Used to monitor target positions
@onready var debug_state = $Navigation/DebugState
@onready var ray_cast_2d = $Navigation/RayCast2D
@onready var navigation = $Navigation
@onready var animation_controller = $AnimationController
@onready var hurtbox = $Hurtbox
@onready var healthbar = $Healthbar

var Player_in_range : Node2D # Player body entered Detection
var PlayerTarget : Node2D # Player in Range & LOS
var ScriptSpeedInfluence: float = 1 # Used to go faster or slower, 1 = 100% speed

# Debug testing
var TargetObject: Node2D # Used to track a player or object

# Temporary placeholder for Stats
var Health : float = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	if DebugLabelVisible : #Enable debug label if toggled
		debug_state.visible = true
	debug_state.text = "Idle"
	
	hurtbox.TakeDamage.connect(RecieveDmg)
	healthbar.init_health(Health)
	
func _physics_process(_delta):
	SetActiveTarget() # Examine player in range and check LOS, set PlayerTarget
	
func CheckLOS(Target : Node2D) -> bool:
	if Target: # If target is valid, set raycast position to Target
		var TargetCentermass : Vector2 = Target.global_position
		TargetCentermass.y -= 15 # Center raycast to the middle of Target
		ray_cast_2d.target_position = TargetCentermass - global_position
		
		# If raycast is colliding with Target, LOS is true
		if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider() == Target:
			#print("LOS true, Target =" + str(Target.name))
			return true
	return false

func SetActiveTarget():
	# Check for player in detection & line of sight, set active target
	if !PlayerTarget and Player_in_range and CheckLOS(Player_in_range):
		PlayerTarget = Player_in_range
		#print("Player target set " + str(PlayerTarget))
	#Line of sight lost, but player in range
	elif PlayerTarget and Player_in_range and !CheckLOS(Player_in_range):
		#print("Player LOS lost " + str(PlayerTarget))
		PlayerTarget = null
	# Player went out of vision range
	elif PlayerTarget and !Player_in_range:
		#print("Player target out of range " + str(PlayerTarget))
		PlayerTarget = null

func Set_nav_desired_distance(New_distance : int):
	# Set navigation range to desired distance
	if navigation: navigation.navigation_agent_2d.target_desired_distance = New_distance

# Assign player entering vision area
func _on_player_detection_body_entered(body):
	#print("Player found! Player = " + str(body))
	Player_in_range = body

# Unassign player leaving vision area
func _on_player_detection_body_exited(_body):
	#print("Player lost Player = " + str(_body))
	Player_in_range = null

func Play_Anim(anim_name : String):
	if animation_controller:
		animation_controller.Play_anim(anim_name)

func Flip_anim_sprite(Direction : bool):
	if animation_controller:
		animation_controller.Flip_anim_sprite(Direction)

func DebugPrintout(text : String):
	if DebugLabelVisible:
		print(text)

func Variable_speed() -> float:
	return VariedSpeed
	
func RecieveDmg(damage : int):
	Health -= damage
	healthbar.health = Health
	if Health <= 0:
		queue_free()
