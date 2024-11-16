extends Camera2D

# Variable Exports
@export var Speed: float = 200
@export var ZoomXDefault: float = 2.75
@export var ZoomYDefault: float = 2.75
@export var ZoomSpeed: float = 10
@export var max_zoom_in : float = 4.25
@export var max_zoom_out : float = 1.75
var MovementEnabled = false # Movement enabled/disabled

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("CameraZoomIn"):
		var MovementDelta = delta * ZoomSpeed
		#print("Camera Zoom in")
		if zoom.x < max_zoom_in:
			zoom += Vector2(MovementDelta,MovementDelta)
		#print("PlayerCamera(): Zoom level = " + str(zoom))
	elif Input.is_action_just_pressed("CameraZoomOut"):
		var MovementDelta = delta * ZoomSpeed
		#print("Camera Zoom out")
		if zoom.x > max_zoom_out:
			zoom -= Vector2(MovementDelta,MovementDelta)
		#print("PlayerCamera(): Zoom level = " + str(zoom))
	elif Input.is_action_just_pressed("CameraZoomReset"):
		zoom = Vector2(ZoomXDefault,ZoomYDefault)
	
	#Movement disabled
	if !MovementEnabled:
		return
	
	# Get the direction as a Vector2
	var direction: Vector2 = Input.get_vector("PlayerMoveLeft", "PlayerMoveRight", "PlayerMoveUp", "PlayerMoveDown")
	position.x += (delta * Speed * direction.x)
	position.y += (delta * Speed * direction.y)

func ObjectMovement(value):
	#print("Camera Movement = " + str(value))
	MovementEnabled = value
	if !MovementEnabled: #Reset Camera Position
		zoom = Vector2(ZoomXDefault,ZoomYDefault)
		position = Vector2.ZERO
