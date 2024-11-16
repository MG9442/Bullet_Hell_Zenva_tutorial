extends State

# Enemy Idle/Wander Script

# Responsible for:
# Idle timeout
# Randomized wandering

# Dependencies:
# Enemy script
# Enemy navigation script

@export var enemy: GreenSlimeEnemy
@export var navigation : EnemyNavigation
@export var WanderTimeMax : int = 60 # Maximum randomized time to initiate wandering
@export var WanderDistance : int = 100 # Distance from current location to wander
@export var Wanderdesireddistance : int = 25 # Distance to consider target reached, avoids walls
@export var wander_timer: Timer

func _enter_state():
	enemy.DebugPrintout("Entering Enemy Idle State")
	DebugLabelUpdate()
	randomize_timer()
	
func _exit_state():
	enemy.DebugPrintout("Exiting Enemy Idle State")
	wander_timer.stop()

func Physics_Update(_delta : float):
	if enemy.PlayerTarget:
		Transitioned.emit(self, "EnemyPursueState") # Transition to Pursue state
	elif navigation.Target_Reached:
		enemy.Play_Anim("Idle")
		DebugLabelUpdate()

# Randomize wander timer & position
func randomize_wander():
	# Randomize a local point, then convert to global
	var random_target = Vector2(randi_range(-WanderDistance, WanderDistance), 
							 randi_range(-WanderDistance, WanderDistance))
	#print("random target before conversion = " + str(random_target))
	random_target = enemy.position + random_target
	#print("random target = " + str(random_target))
	navigation.Set_Wander_Target(random_target)
	enemy.Set_nav_desired_distance(Wanderdesireddistance) # Avoids running into walls

func randomize_timer():
	var randomtime = randf_range(3, WanderTimeMax)
	wander_timer.wait_time = randomtime
	#print("randomize_wander(): randomtime assigned = " + str(randomtime))
	wander_timer.start()

func DebugLabelUpdate():
	if enemy.debug_state:
		enemy.debug_state.text = "Idle"

func _on_wander_timer_timeout():
	#print("Wander Timer expired!")
	DebugLabelUpdate()
	enemy.Play_Anim("Idle")
	randomize_timer()
	randomize_wander()
