extends Camera2D

# Variable Exports
@export var Speed: float = 200
@export var Accel: float = 15
@export var ZoomSpeed: float = 10
var MovementEnabled = false # Movement enabled/disabled

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#Player movement disabled
	if !MovementEnabled:
		return
	
	# Get the direction as a Vector2
	var direction: Vector2 = Input.get_vector("PlayerMoveLeft", "PlayerMoveRight", "PlayerMoveUp", "PlayerMoveDown")
	position.x += (delta * Speed * direction.x)
	position.y += (delta * Speed * direction.y)
	
	if Input.is_action_just_pressed("DebugCameraZoomIn"):
		#print("Camera Zoom in")
		zoom.x += delta * ZoomSpeed
		zoom.y += delta * ZoomSpeed
	elif Input.is_action_just_pressed("DebugCameraZoomOut"):
		#print("Camera Zoom out")
		zoom.x -= delta * ZoomSpeed
		zoom.y -= delta * ZoomSpeed
	

func ObjectMovement(value):
	MovementEnabled = value
