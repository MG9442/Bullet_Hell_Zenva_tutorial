extends Node

@onready var DebugMenu = $"../DebugModeUI"
@onready var knight_player_2d = $"../KnightPlayer2D"
@onready var player_camera = $"../KnightPlayer2D/PlayerCamera"

var DebugMode : bool = false
var freeze_time : bool = false
@export var CameraSpeed: float = 200
@export var CameraAccel: float = 15

# Called when the node enters the scene tree for the first time.
func _ready():
	knight_player_2d.PlayerMovement(!DebugMode)
	EnterDebugMode(DebugMode)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("DebugMode"):
		DebugMode = !DebugMode # Toggle on/off
		#print("Debug Camera Mode = " + str(DebugMode))
		knight_player_2d.PlayerMovement(!DebugMode)
		player_camera.ObjectMovement(DebugMode)
		EnterDebugMode(DebugMode)

func EnterDebugMode(enable : bool):
	if enable: 
		DebugMenu.visible = true
		DebugMenu.enable_properties(false)
		return
		
	# Disable Debug mode
	DebugMenu.visible = false
	DebugMenu.unselect_object()
	get_tree().paused = false

func _on_freeze_time_toggled(toggled_on):
	#print("Freeze_time = " + str(toggled_on))
	get_tree().paused = toggled_on
