extends State

# Enemy Pursue Script

# Responsible for:
# Chasing, attacking targets
# NavAgent guiding to target
# NavTimer for updating Taget position

# Dependencies:
# Enemy script
# Enemy Navigation script

@export var enemy : GreenSlimeEnemy
@export var navigation : EnemyNavigation

# Navigation Elements
@export var PursueDistance : int = 25 # Distance from target to stop at
@export var StaticTargetDistance : int = 1 # Distance from static target to move to

var Lost_target : bool = true
var Search_timeout : float = 5
var Search_timer : float = Search_timeout

var Attack_timeout = Vector2(3,5) # Attack timeouts, used for randomized attacking
var Attack_timer: float
var isAttacking : bool = false

func _enter_state():
	enemy.DebugPrintout("Entering Enemy Pursue State")
	Search_timer = Search_timeout

func _exit_state():
	enemy.DebugPrintout("Exiting Enemy Pursue State")

func Physics_Update(_delta):
	#print("navigation.Target_Reached = " + str(navigation.Target_Reached))
	if enemy.PlayerTarget and Lost_target:
		Lost_target = false
		enemy.Set_nav_desired_distance(PursueDistance)
	elif !enemy.PlayerTarget and !Lost_target:
		Lost_target = true
		enemy.Set_nav_desired_distance(StaticTargetDistance)
	elif enemy.PlayerTarget and navigation.Target_Reached:
		#print("Player in range, attack")
		enemy.Play_Anim("Attack1_slow")
	elif Lost_target and navigation.Target_Reached:
		enemy.Play_Anim("Idle")
		Search_timer -= _delta
		if Search_timer <= 0:
			enemy.DebugPrintout("enemy_pursue Search timed out")
			Transitioned.emit(self, "EnemyWanderState") # Transition to wander state
