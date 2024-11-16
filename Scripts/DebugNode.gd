extends Area2D

@onready var DebugModeUI # Used to display debug properties
@onready var marker = $Marker

func _ready():
	# Add GameManager from group
	DebugModeUI = get_tree().get_first_node_in_group("DebugModeUI")

func _on_input_event(viewport, event, shape_idx):
	if DebugModeUI.visible and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#print("Object selected in DebugMode = " + str(owner))
		DebugModeUI.selected_object_switch(owner)

func show_active(enable : bool):
	marker.visible = enable
	#print("DebugNode(): show_active = " + str(enable))

func examine_properties() -> Array:
	var properties : Array
	properties.append("Name")
	properties.append(owner.name)
	properties.append("Transform")
	properties.append(owner.global_position)
	properties.append("Scale")
	properties.append(owner.scale)
	if owner.has_method("RecieveDmg"):
		properties.append("Health")
		properties.append(owner.Health)
	properties.append("ZIndex")
	properties.append(owner.z_index)
	
	#for i in properties.size():
		#if i%2 != 0: continue # Skip every other value, do for loop in pairs
		#print("DebugNode-> examine_properties: " + str(properties[i]) + " = " + str(properties[i+1]))
	
	return properties

func examine_health() -> float:
	if owner.has_method("RecieveDmg"):
		return owner.Health
	return 0

func examine_transform() -> Vector2:
	return owner.global_position

func scale_owner(new_scale : Vector2):
	owner.scale = new_scale
	#print("owner.scale = " + str(owner.scale))

func z_index_owner(new_zindex : int):
	owner.z_index = new_zindex

func move_owner(new_position : Vector2):
	owner.global_position += new_position
	#print("new_position = " + str(new_position))
	#print("owner.global_position = " + str(owner.global_position))

func damage_owner(new_health : int):
	if owner.has_method("RecieveDmg"):
		owner.RecieveDmg(new_health)

func delete_owner():
	owner.queue_free()
