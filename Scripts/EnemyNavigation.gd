extends Node2D
class_name  EnemyNavigation

# Enemy Navigation Script

# Responsible for:
# NavAgent guiding to target
# NavTimer for updating Taget position

# Dependencies:
# Enemy script

@export var enemy : GreenSlimeEnemy

# Navigation Elements
@export var navigation_agent_2d : NavigationAgent2D
@export var Nav_timer : Timer
var Target_Reached : bool = true # Navigation finished because target was reached

var Nav_Target_position : Vector2 # Nav target

signal Target_reached

func _physics_process(_delta):
	Set_Nav_Timer() # Control Nav timer based on PlayerTarget
	var direction = Direction_to_Target() # Determine direction & flip sprite
	Check_nav_target()
	if !Target_Reached:
		enemy.velocity = enemy.velocity.lerp(direction * enemy.VariedSpeed, enemy.acceleration * _delta)
		enemy.Play_Anim("SlideMove")
		enemy.move_and_slide()
		DebugLabelUpdate() # Update label to show navigation status

# Used to start/stop Nav timer
func Set_Nav_Timer():
	if enemy.PlayerTarget and Nav_timer.is_stopped():
		Nav_timer.start() # Used since target could be actively moving
	elif !enemy.PlayerTarget and Nav_timer.time_left > 0:
		Set_Static_Target(navigation_agent_2d.get_final_position())
		Nav_timer.stop()

func Set_Static_Target(static_target : Vector2):
	#print("Navigation static target set")
	navigation_agent_2d.target_position = static_target
	if enemy.DEBUG_TARGET:
		enemy.DEBUG_TARGET.global_position = static_target

func Set_Wander_Target(wander_target : Vector2):
	#print("Navigation wander target set")
	navigation_agent_2d.target_position = wander_target
	Target_Reached = false
	Nav_timer.start()
	if enemy.DEBUG_TARGET:
		enemy.DEBUG_TARGET.global_position = wander_target

func Direction_to_Target() -> Vector2:
	# Normalize distance to get direction
	var direction = (navigation_agent_2d.get_next_path_position() - global_position).normalized()
	
	# Flip Sprite based on direction normal (negative = left, positive = right)
	if direction.x < 0: enemy.Flip_anim_sprite(true)
	else: enemy.Flip_anim_sprite(false)
	
	return direction

# Used to periodically update position of a moving taget
func _on_nav_timer_timeout():
	#print("Nav_Timer timeout")
	navigation_agent_2d.target_position = enemy.PlayerTarget.global_position
	if enemy.DEBUG_TARGET:
		enemy.DEBUG_TARGET.global_position = enemy.PlayerTarget.global_position
	
	# Determine if Target has moved
	if Nav_Target_position != navigation_agent_2d.target_position:
		#print("nav target changed = " + str(Nav_Target_position))
		Nav_Target_position = navigation_agent_2d.target_position
		Target_Reached = false

func DebugLabelUpdate():
	if enemy.DebugLabelVisible:
		navigation_agent_2d.debug_enabled = true
		if enemy.PlayerTarget: enemy.debug_state.text = "Pursuing Target LOS = true"
		else: enemy.debug_state.text = "Wandering to target LOS = false"

func Check_nav_target():
	var position_distance = navigation_agent_2d.target_position - global_position
	#print("Check_nav_target position_distance = " + str(position_distance.length()))
	if position_distance.length() <= navigation_agent_2d.target_desired_distance:
		#print("Target navigation reached")
		#print("Target_desired_distance = " + str(navigation_agent_2d.target_desired_distance))
		Target_Reached = true
