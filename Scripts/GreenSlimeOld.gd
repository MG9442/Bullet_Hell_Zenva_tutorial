extends CharacterBody2D

@export var VariedSpeed : float = 0 # Varied Speed controlled by animator player
@export var acceleration = 7
@export var DebugLabelVisible : bool = false # Label to tell which state enemy is in

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

# Navigation Elements
@onready var navigation_agent_2d = $Navigation/NavigationAgent2D
@onready var Nav_timer = $Navigation/NavTimer
@onready var debug_state = $Navigation/DebugState
@export var PursueDistance : int = 20 # Distance from target to stop at
@export var TargetObject: Node2D # Used to track a player or object
var TargetPosition: Vector2 # Used to navigate to a static location

# StateMachine Elements
@onready var idle_timer = $StateMachine/IdleTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	if DebugLabelVisible : #Enable debug label if toggled
		debug_state.visible = true
	animation_player.play("Idle")
	debug_state.text = "Idle"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !TargetObject and !TargetPosition: # No target set
		return
	
	var direction = navigation_agent_2d.get_next_path_position() - self.global_position
	direction = direction.normalized()
	
	# Flip Sprite based on direction normal (negative = left, positive = right)
	if direction.x < 0:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false
		
	# Examine distance that enemy is away from Target
	if Target_Reached(TargetPosition) and TargetObject:
		debug_state.text = "TargetObject reached"
		animation_player.play("Idle")
		navigation_agent_2d.debug_enabled = false
		return
	elif !TargetObject and Target_Reached(TargetPosition) and idle_timer.is_stopped():
		debug_state.text = "Static target reached"
		animation_player.play("Idle")
		TargetPosition = Vector2.ZERO
		navigation_agent_2d.debug_enabled = false
		idle_timer.start(3)
		return
	if DebugLabelVisible:
		navigation_agent_2d.debug_enabled = true
	debug_state.text = "Pursuing Target"
	#print("Slimedirection = " + str(direction.x))
	#print("SlimeVariedSpeed = " + str(VariedSpeed))
	velocity = velocity.lerp(direction * VariedSpeed, acceleration * delta)
	animation_player.play("SlideMove")
	move_and_slide()

# Used to transition back to Idle
func _on_idle_timer_timeout():
	print("Idle Timer expired!")

# Used to periodically update position of a moving taget
func _on_nav_timer_timeout():
	if TargetObject:
		navigation_agent_2d.target_position = TargetObject.global_position
		# Update last known position in case target is lost
		TargetPosition = TargetObject.global_position
	else:
		Nav_timer.stop()

# Used for setting a moving object like a player
func SwapTargets(NewTarget : Node2D):
	if !NewTarget: # guard against value not being ready or set yet
		print("SwapTargets(): Error, invalid setting of Targets!")
		return
	TargetObject = NewTarget
	var MovePosition = closest_nav_position(NewTarget.global_position)
	navigation_agent_2d.target_position = MovePosition
	Nav_timer.start() # Used since target could be actively moving

# Determine if Target position has been reached
func Target_Reached(TargetExamine : Vector2) -> bool:
	# Examine distance that enemy is away from Target
	var distance =  TargetExamine - global_position
	#print("SlimeDistance.length() = " + str(distance.length()))
	if distance.length() <= PursueDistance: 
		#print("GreenSlime(): Target reached!")
		return true
	else:
		return false

# Return position that falls within navmesh
func closest_nav_position(target_position : Vector2) -> Vector2:
	var map := get_world_2d().navigation_map
	var closest_point := NavigationServer2D.map_get_closest_point(map, target_position)
	print("SwapTargets(): closestPoint on Navmap = " + str(closest_point))
	return closest_point

# Used for setting a static position
func WanderPosition(WanderPos : Vector2):
	if !TargetObject or !navigation_agent_2d: # guard against value not being ready or set yet
		return
	TargetObject.global_position = WanderPos
	var MovePosition = closest_nav_position(WanderPos)
	TargetObject.global_position = MovePosition
	navigation_agent_2d.target_position = MovePosition
