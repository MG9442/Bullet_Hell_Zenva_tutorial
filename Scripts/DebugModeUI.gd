extends CanvasLayer

var selected_object : Node # Mouse click on selected object during DebugMode

@onready var DebugObjectProperties = $PropertiesContainer
@onready var name_property = $PropertiesContainer/NameProperty
@onready var transform_property = $PropertiesContainer/TransformProperty
@onready var scale_property = $PropertiesContainer/ScaleProperty
@onready var zindex_property = $PropertiesContainer/ZIndex
@onready var health_property = $PropertiesContainer/Health

@onready var TransformX = $PropertiesContainer/TransformProperty/SpinBox1
@onready var TransformY = $PropertiesContainer/TransformProperty/SpinBox2
@onready var ScaleLink = $PropertiesContainer/ScaleProperty/CheckButton
@onready var ScaleX = $PropertiesContainer/ScaleProperty/SpinBox1
@onready var ScaleY = $PropertiesContainer/ScaleProperty/SpinBox2
@onready var ZIndex = $PropertiesContainer/ZIndex/SpinBox1
@onready var HealthValue = $PropertiesContainer/Health/SpinBox1

var scalex_previous : float = 0
var scaley_previous : float = 0
var scale_lock : bool = false # lock out the changing of the scaling (on init & linked changed)

func _process(_delta):
	if selected_object:
		var debug_node = selected_object.find_child("DebugNode")
		var direction: Vector2 = Input.get_vector("ArrowLeft", "ArrowRight", "ArrowUp", "ArrowDown")
		var speed = direction * _delta * 200
		if direction != Vector2.ZERO: debug_node.move_owner(speed)
		#populate_list(debug_node.examine_properties()) # Populate list of selected object's properties
	if selected_object and Input.is_action_just_pressed("DeleteKey") and !selected_object.is_in_group("player"):
		selected_object.find_child("DebugNode").delete_owner()
		enable_properties(false)
		selected_object = null
	if selected_object and Input.is_action_just_pressed("EscapeKey"):
		unselect_object()

func unselect_object():
	if selected_object:
		enable_properties(false) # Hide properties menu
		selected_object.find_child("DebugNode").show_active(false) # Hide previous selection
		selected_object = null

func enable_properties(enable : bool):
	DebugObjectProperties.visible = enable

func hide_selection_list():
	name_property.visible = false
	transform_property.visible = false
	scale_property.visible = false
	zindex_property.visible = false
	health_property.visible = false

func selected_object_switch(new_object : Node):
	if selected_object:
		selected_object.find_child("DebugNode").show_active(false) # Hide previous selection
	var DebugNode = new_object.find_child("DebugNode")
	DebugNode.show_active(true)
	enable_properties(true)
	var properties : Array = DebugNode.examine_properties()
	populate_list(properties) # Populate list of selected object's properties
	selected_object = new_object
	#print("GameManager(): Selected Object = " + str(selected_object))

func populate_list(properties : Array):
	hide_selection_list() # Hide all elements starting out
	for i in properties.size():
		if i%2 != 0: continue # Skip every other value, do for loop in pairs
		#print("DebugModeUI-> populate_list: " + str(properties[i]) + " = " + str(properties[i+1]))
		match properties[i]:
			"Name":
				name_property.find_child("Label1").text = properties[i+1]
				name_property.visible = true
			"Transform":
				var transform : Vector2 = properties[i + 1]
				transform_property.find_child("SpinBox1").value = transform.x
				transform_property.find_child("SpinBox2").value = transform.y
				transform_property.visible = true
			"Scale":
				var scale : Vector2 = properties[i + 1]
				scale_lock = true
				scale_property.find_child("SpinBox1").value = scale.x
				scale_property.find_child("SpinBox2").value = scale.y
				scale_lock = false
				#Assign values for comparison
				scalex_previous = scale.x
				scaley_previous = scale.y
				scale_property.visible = true
			"ZIndex":
				zindex_property.find_child("SpinBox1").value = properties[i+1]
				zindex_property.visible = true
			"Health":
				health_property.find_child("SpinBox1").value = properties[i+1]
				health_property.visible = true
			_:
				print("populate_list(): Error, property not found! " + str(properties[i]))


func _on_scale_x_value_changed(value):
	if scale_lock: #Keep from infinite loop scale change
		return
	scale_lock = true
	var new_scale : Vector2
	if ScaleLink.button_pressed and scalex_previous < ScaleX.value: # Increase scale proportionally
		ScaleY.value += (ScaleX.value - scalex_previous) # Increase by new scaling diff
	elif ScaleLink.button_pressed: # Decrease scale proportionally
		ScaleY.value -= (scalex_previous - ScaleX.value)
	#print("ScaleX.value = " + str(ScaleX.value) + " scalex_previous = " + str(scalex_previous))
	#print("Scale value = (" + str(ScaleX.value) + "," + str(ScaleY.value) + ")")
	#print("Scale step = " + str(ScaleX.step))
	new_scale.x = ScaleX.value
	new_scale.y = ScaleY.value
	selected_object.find_child("DebugNode").scale_owner(new_scale)
	scalex_previous = ScaleX.value
	scaley_previous = ScaleY.value
	ScaleX.get_line_edit().release_focus()
	scale_lock = false

func _on_scale_y_value_changed(value):
	if scale_lock: # Keep from infinite loop scale change
		return
	scale_lock = true
	var new_scale : Vector2
	if ScaleLink.button_pressed and scaley_previous < ScaleY.value: # Increase scale proportionally
		ScaleX.value += (ScaleY.value - scaley_previous) # Increase by new scaling diff
	elif ScaleLink.button_pressed: # Decrease scale proportionally
		ScaleX.value -= (scaley_previous - ScaleY.value) # Decrease by new scaling diff
	#print("ScaleY.value = " + str(ScaleY.value) + " scaley_previous = " + str(scaley_previous))
	#print("Scale value = (" + str(ScaleX.value) + "," + str(ScaleY.value) + ")")
	#print("Scale step = " + str(ScaleY.step))
	new_scale.x = ScaleX.value
	new_scale.y = ScaleY.value
	selected_object.find_child("DebugNode").scale_owner(new_scale)
	scalex_previous = ScaleX.value
	scaley_previous = ScaleY.value
	ScaleY.get_line_edit().release_focus()
	scale_lock = false

func _on_z_value_value_changed(value):
	if !selected_object:
		return
	selected_object.find_child("DebugNode").z_index_owner(value)
	#print("Changing Z index to " + str(value))

func _on_health_value_value_changed(value):
	if !selected_object:
		return
	var object_health : float = selected_object.find_child("DebugNode").examine_health()
	var health_diff : float = object_health - value #Use the difference to find damage value
	selected_object.find_child("DebugNode").damage_owner(health_diff)
	if value <= 0: # Object was deleted, remove object selection
		enable_properties(false)
		selected_object = null
	print("Object Health = " + str(object_health) + " value = " + str(value))
	print("damage value = " + str(health_diff))
